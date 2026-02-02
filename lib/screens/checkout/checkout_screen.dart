import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/address_provider.dart';
import '../../services/payment_service.dart';
import '../auth/login_screen.dart';
import '../payment/order_confirmation_screen.dart';

/// Simplified Checkout Screen - Flipkart Style
/// EMI feature is on hold - shows "Coming Soon"
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _showAddressForm = false;

  // Address Form Controllers
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  String _paymentMethod = 'upi';
  late PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
    // Check if user has saved addresses
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressProvider = context.read<AddressProvider>();
      if (!addressProvider.hasAddresses) {
        setState(() => _showAddressForm = true);
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _paymentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    if (!auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Step Indicator (simplified: Address → Payment)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStepIndicator(0, 'Address'),
                Expanded(child: Container(height: 2, color: _currentStep > 0 ? AppTheme.primaryColor : Colors.grey.shade300)),
                _buildStepIndicator(1, 'Payment'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _currentStep == 0 ? _buildAddressStep() : _buildPaymentStep(cart),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    return Column(
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
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text('${step + 1}', style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: isActive ? AppTheme.primaryColor : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildAddressStep() {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, _) {
        return Column(
          children: [
            // Saved Addresses Section
            if (addressProvider.hasAddresses && !_showAddressForm) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Iconsax.location, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            const Text('Delivery Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() => _showAddressForm = true),
                          icon: const Icon(Iconsax.add, size: 18),
                          label: const Text('Add New'),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // List saved addresses
                    ...addressProvider.addresses.map((address) => _buildAddressCard(address, addressProvider)),
                  ],
                ),
              ),
            ],

            // Add New Address Form
            if (_showAddressForm) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Iconsax.location, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              addressProvider.hasAddresses ? 'Add New Address' : 'Delivery Address',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        if (addressProvider.hasAddresses)
                          TextButton(
                            onPressed: () => setState(() => _showAddressForm = false),
                            child: const Text('Cancel'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(_phoneController, 'Phone Number', Iconsax.call, TextInputType.phone),
                    _buildTextField(_streetController, 'Street Address', Iconsax.home, TextInputType.streetAddress),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_cityController, 'City', null, TextInputType.text)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField(_stateController, 'State', null, TextInputType.text)),
                      ],
                    ),
                    _buildTextField(_pincodeController, 'PIN Code', Iconsax.location, TextInputType.number, maxLength: 6),
                    
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _saveAddress(addressProvider),
                        icon: const Icon(Iconsax.tick_circle),
                        label: const Text('Save Address'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // EMI Coming Soon Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Iconsax.calendar, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('EMI Option', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Coming Soon! Pay in easy installments.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('SOON', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addressProvider.selectedAddress != null ? () => setState(() => _currentStep = 1) : _validateAndProceed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Continue to Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddressCard(Address address, AddressProvider provider) {
    final isSelected = provider.selectedAddress?.id == address.id;
    return GestureDetector(
      onTap: () => provider.selectAddress(address.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.phone,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('DEFAULT', style: TextStyle(color: Colors.green.shade700, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.fullAddress,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Iconsax.trash, color: Colors.red.shade300, size: 20),
              onPressed: () => provider.removeAddress(address.id),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAddress(AddressProvider provider) {
    if (_phoneController.text.length < 10) {
      _showError('Please enter a valid phone number');
      return;
    }
    if (_streetController.text.isEmpty) {
      _showError('Please enter your street address');
      return;
    }
    if (_cityController.text.isEmpty || _stateController.text.isEmpty) {
      _showError('Please enter city and state');
      return;
    }
    if (_pincodeController.text.length != 6) {
      _showError('Please enter a valid 6-digit PIN code');
      return;
    }

    final address = Address(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      phone: _phoneController.text,
      street: _streetController.text,
      city: _cityController.text,
      state: _stateController.text,
      pincode: _pincodeController.text,
    );

    provider.addAddress(address);
    provider.selectAddress(address.id);
    
    // Clear form
    _phoneController.clear();
    _streetController.clear();
    _cityController.clear();
    _stateController.clear();
    _pincodeController.clear();
    
    setState(() => _showAddressForm = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address saved successfully!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData? icon, TextInputType type, {int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLength: maxLength,
        decoration: InputDecoration(
          hintText: hint,
          counterText: '',
          prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  void _validateAndProceed() {
    if (_phoneController.text.length < 10) {
      _showError('Please enter a valid phone number');
      return;
    }
    if (_streetController.text.isEmpty) {
      _showError('Please enter your street address');
      return;
    }
    if (_cityController.text.isEmpty || _stateController.text.isEmpty) {
      _showError('Please enter city and state');
      return;
    }
    if (_pincodeController.text.length != 6) {
      _showError('Please enter a valid 6-digit PIN code');
      return;
    }
    setState(() => _currentStep = 1);
  }

  Widget _buildPaymentStep(CartProvider cart) {
    return Column(
      children: [
        // Order Summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Iconsax.bag_2, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 24),
              ...cart.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text('x${item.quantity}', style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(width: 12),
                    Text('₹${item.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('₹${cart.totalAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Payment Methods
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildPaymentOption('upi', Iconsax.mobile, 'UPI', 'GPay, PhonePe, Paytm'),
              _buildPaymentOption('card', Iconsax.card, 'Card', 'Credit/Debit Card'),
              _buildPaymentOption('netbanking', Iconsax.bank, 'Net Banking', 'All major banks'),
              _buildPaymentOption('cod', Iconsax.money, 'Cash on Delivery', 'Pay when delivered'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 0),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _processPayment(cart),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _paymentMethod == 'cod' ? Colors.orange : AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        _paymentMethod == 'cod' ? 'Place Order' : 'Pay ₹${cart.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String value, IconData icon, String title, String subtitle) {
    final isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.08) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey, width: 2),
              ),
              child: isSelected
                  ? Center(child: Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryColor)))
                  : null,
            ),
            const SizedBox(width: 14),
            Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.grey, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? AppTheme.primaryColor : null)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(CartProvider cart) async {
    setState(() => _isLoading = true);

    final shippingAddress = {
      'phone': _phoneController.text,
      'street': _streetController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'postalCode': _pincodeController.text,
    };

    final items = cart.items.map((item) => {
      'productID': item.product.id,
      'productName': item.product.name,
      'quantity': item.quantity,
      'price': item.product.offerPrice ?? item.product.price,
    }).toList();

    try {
      if (_paymentMethod == 'cod') {
        // COD Flow
        await _paymentService.placeCodOrder(
          items: items,
          shippingAddress: shippingAddress,
          onSuccess: (orderId) {
            cart.clearCart();
            _navigateToSuccess(orderId, cart.totalAmount);
          },
          onError: (error) {
            _showError(error);
            setState(() => _isLoading = false);
          },
        );
      } else {
        // Online Payment via Razorpay
        await _paymentService.initiatePayment(
          context: context,
          items: items,
          shippingAddress: shippingAddress,
          paymentMethod: _paymentMethod,
          onSuccess: (orderId) {
            cart.clearCart();
            _navigateToSuccess(orderId, cart.totalAmount);
          },
          onError: (error) {
            _showError(error);
            setState(() => _isLoading = false);
          },
        );
      }
    } catch (e) {
      _showError('Payment failed: $e');
      setState(() => _isLoading = false);
    }
  }

void _navigateToSuccess(String orderId, double total) { // Add total as parameter
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => OrderConfirmationScreen(
        orderId: orderId,
        orderData: {
          'paymentMethod': _paymentMethod,
          'totalAmount': total,
          'downPayment': _paymentMethod == 'cod' ? 0 : total, // For non-EMI, downpayment is the total
        },
        emiPlan: null,
      ),
    ),
  );
}

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
