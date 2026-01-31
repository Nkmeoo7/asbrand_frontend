import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/order.dart';
import '../../models/emi_plan.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../payment/down_payment_screen.dart';
import '../../widgets/emi_plan_picker.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // KYC Form Controllers
  final _panController = TextEditingController();
  final _pincodeController = TextEditingController();
  String _selectedGender = 'male';
  DateTime? _dateOfBirth;

  // Address Form Controllers
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  String _paymentMethod = 'emi'; // Default to EMI
  EmiPlan? _selectedEmiPlan;
  bool _useEmi = true;

  @override
  void dispose() {
    _panController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    // If not logged in, redirect to login
    if (!auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: 'As', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              TextSpan(text: 'Brand', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF83C5BE))),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Credit Limit Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Shop upto ₹20000 & Pay later in EMIs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFeaturePill(Iconsax.percentage_square, 'Interest Free\nEMIs'),
                    _buildFeaturePill(Iconsax.money, 'No hidden\ncharges'),
                    _buildFeaturePill(Iconsax.card_slash, 'Credit Card\nNOT required'),
                  ],
                ),
              ],
            ),
          ),

          // Step Indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStepIndicator(0, 'Details'),
                _buildStepLine(0),
                _buildStepIndicator(1, 'Address'),
                _buildStepLine(1),
                _buildStepIndicator(2, 'EMI'),
                _buildStepLine(2),
                _buildStepIndicator(3, 'Pay'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCurrentStep(auth, cart),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isActive && _currentStep > step
                  ? const Icon(Iconsax.tick_circle, color: Colors.white, size: 18)
                  : Text('${step + 1}', style: TextStyle(color: isActive ? Colors.white : Colors.grey)),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: isActive ? AppTheme.primaryColor : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStepLine(int afterStep) {
    final isActive = _currentStep > afterStep;
    return Container(
      width: 40,
      height: 2,
      color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
    );
  }

  Widget _buildCurrentStep(AuthProvider auth, CartProvider cart) {
    switch (_currentStep) {
      case 0:
        return _buildKycStep(auth);
      case 1:
        return _buildAddressStep();
      case 2:
        return _buildEmiStep(cart);
      case 3:
        return _buildPaymentStep(cart);
      default:
        return const SizedBox();
    }
  }

  Widget _buildKycStep(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('We Just need a few details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // PAN Number
          TextFormField(
            controller: _panController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Enter your PAN Number',
              hintStyle: TextStyle(color: AppTheme.textHint),
              prefixIcon: const Icon(Iconsax.card),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          // Email (pre-filled)
          TextFormField(
            initialValue: auth.user?.email ?? '',
            enabled: false,
            decoration: InputDecoration(
              hintText: 'Email',
              prefixIcon: const Icon(Iconsax.sms),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          // Pincode
          TextFormField(
            controller: _pincodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: 'Pin Code',
              hintStyle: TextStyle(color: AppTheme.textHint),
              prefixIcon: const Icon(Iconsax.location),
              counterText: '',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),

          // Gender
          Row(
            children: [
              const Text('Gender', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 24),
              ...['male', 'female', 'other'].map((gender) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    Radio<String>(
                      value: gender,
                      groupValue: _selectedGender,
                      onChanged: (v) => setState(() => _selectedGender = v!),
                      activeColor: AppTheme.primaryColor,
                    ),
                    Text(gender[0].toUpperCase() + gender.substring(1)),
                  ],
                ),
              )),
            ],
          ),
          const SizedBox(height: 16),

          // Date of Birth
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime(1995),
                firstDate: DateTime(1950),
                lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
              );
              if (date != null) setState(() => _dateOfBirth = date);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Text(
                    _dateOfBirth != null
                        ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                        : 'dd/mm/yyyy',
                    style: TextStyle(color: _dateOfBirth != null ? Colors.black : AppTheme.textHint),
                  ),
                  const SizedBox(width: 8),
                  Icon(Iconsax.calendar, color: AppTheme.primaryColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Next Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_panController.text.length != 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid PAN number'), backgroundColor: Colors.red),
                  );
                  return;
                }
                if (_pincodeController.text.length != 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid 6-digit pincode'), backgroundColor: Colors.red),
                  );
                  return;
                }
                if (_dateOfBirth == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select your date of birth'), backgroundColor: Colors.red),
                  );
                  return;
                }
                setState(() => _currentStep = 1);
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Shipping Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Phone Number',
              prefixIcon: const Icon(Iconsax.call),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _streetController,
            decoration: InputDecoration(
              hintText: 'Street Address',
              prefixIcon: const Icon(Iconsax.home),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: 'City',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _stateController,
                  decoration: InputDecoration(
                    hintText: 'State',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep = 0),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.primaryColor),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_phoneController.text.isEmpty || _streetController.text.isEmpty ||
                        _cityController.text.isEmpty || _stateController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all address fields'), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    setState(() => _currentStep = 2);
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmiStep(CartProvider cart) {
    return Column(
      children: [
        // EMI Toggle
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // EMI Option
              GestureDetector(
                onTap: () => setState(() => _useEmi = true),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _useEmi ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _useEmi ? AppTheme.primaryColor : Colors.grey.shade200, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _useEmi ? AppTheme.primaryColor : Colors.grey, width: 2),
                        ),
                        child: _useEmi ? Center(child: Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryColor))) : null,
                      ),
                      const SizedBox(width: 16),
                      Icon(Iconsax.calendar, color: _useEmi ? AppTheme.primaryColor : Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Pay with EMI', style: TextStyle(fontWeight: FontWeight.bold, color: _useEmi ? AppTheme.primaryColor : null)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                                  child: const Text('0% Interest', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            Text('Split into 3-12 monthly payments', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Full Payment Option
              GestureDetector(
                onTap: () => setState(() {
                  _useEmi = false;
                  _selectedEmiPlan = null;
                }),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: !_useEmi ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: !_useEmi ? AppTheme.primaryColor : Colors.grey.shade200, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: !_useEmi ? AppTheme.primaryColor : Colors.grey, width: 2),
                        ),
                        child: !_useEmi ? Center(child: Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryColor))) : null,
                      ),
                      const SizedBox(width: 16),
                      Icon(Iconsax.money, color: !_useEmi ? AppTheme.primaryColor : Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pay Full Amount', style: TextStyle(fontWeight: FontWeight.bold, color: !_useEmi ? AppTheme.primaryColor : null)),
                            Text('UPI, Card, or Net Banking', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // EMI Plan Picker (if EMI selected)
        if (_useEmi)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select EMI Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                EmiPlanPicker(
                  productPrice: cart.totalAmount,
                  onPlanSelected: (plan, emi) {
                    setState(() => _selectedEmiPlan = plan);
                  },
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        
        // Navigation
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppTheme.primaryColor),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  if (_useEmi && _selectedEmiPlan == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select an EMI plan'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  setState(() => _currentStep = 3);
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Proceed to Pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentStep(CartProvider cart) {
    return Column(
      children: [
        // Order Summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...cart.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(child: Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text('x${item.quantity}'),
                    const SizedBox(width: 12),
                    Text('₹${item.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('₹${cart.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Payment Method
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildPaymentOption('cod', 'Cash on Delivery', Iconsax.money),
              _buildPaymentOption('prepaid', 'Pay Online', Iconsax.card),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Place Order Button
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 2),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppTheme.primaryColor),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _proceedToPayment(cart),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_useEmi ? 'Pay Down Payment' : 'Pay Now', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    final isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.grey),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (isSelected) const Icon(Iconsax.tick_circle, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  void _proceedToPayment(CartProvider cart) {
    final shippingAddress = {
      'phone': _phoneController.text,
      'street': _streetController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'postalCode': _pincodeController.text,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DownPaymentScreen(
          selectedPlan: _useEmi ? _selectedEmiPlan : null,
          shippingAddress: shippingAddress,
        ),
      ),
    );
  }

  Future<void> _placeOrder(CartProvider cart) async {
    setState(() => _isLoading = true);

    try {
      final orderData = Order(
        id: '',
        orderDate: DateTime.now(),
        orderStatus: 'pending',
        items: cart.items.map((item) => OrderItem(
          productId: item.product.id,
          productName: item.product.name,
          quantity: item.quantity,
          price: item.product.offerPrice ?? item.product.price,
        )).toList(),
        totalPrice: cart.totalAmount,
        shippingAddress: ShippingAddress(
          phone: _phoneController.text,
          street: _streetController.text,
          city: _cityController.text,
          state: _stateController.text,
          postalCode: _pincodeController.text,
        ),
        paymentMethod: _paymentMethod,
        orderTotal: OrderTotal(
          subtotal: cart.totalAmount,
          discount: 0,
          total: cart.totalAmount,
        ),
      );

      final apiService = ApiService();
      final response = await apiService.createOrder(orderData.toJson());

      if (response['success'] == true) {
        cart.clearCart();
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.tick_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 16),
                  const Text('Order Placed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Order ID: ${response['data']?['_id'] ?? 'N/A'}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Continue Shopping'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
