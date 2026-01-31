import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/emi_plan.dart';
import '../../services/api_service.dart';
import 'order_confirmation_screen.dart';

class DownPaymentScreen extends StatefulWidget {
  final EmiPlan? selectedPlan;
  final Map<String, dynamic> shippingAddress;

  const DownPaymentScreen({
    super.key,
    this.selectedPlan,
    required this.shippingAddress,
  });

  @override
  State<DownPaymentScreen> createState() => _DownPaymentScreenState();
}

class _DownPaymentScreenState extends State<DownPaymentScreen> {
  bool _isLoading = false;
  String _selectedPaymentMethod = 'upi';
  final _upiController = TextEditingController();

  // Down payment percentage (10-25%)
  double get downPaymentPercentage => 0.10; // 10%

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final subtotal = cart.totalAmount;
    final processingFee = widget.selectedPlan?.processingFee ?? 0;
    final downPayment = subtotal * downPaymentPercentage;
    final loanAmount = subtotal - downPayment;
    final monthlyEmi = widget.selectedPlan != null
        ? (loanAmount + processingFee) / widget.selectedPlan!.tenure
        : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Complete Payment'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Order Summary
            _buildOrderSummary(cart, subtotal, downPayment, loanAmount, processingFee, monthlyEmi),
            const SizedBox(height: 16),

            // Payment Method Selection
            _buildPaymentMethods(),
            const SizedBox(height: 16),

            // Payment Details
            if (_selectedPaymentMethod == 'upi') _buildUpiSection(),
            if (_selectedPaymentMethod == 'card') _buildCardSection(),
            if (_selectedPaymentMethod == 'netbanking') _buildNetbankingSection(),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildPayButton(downPayment),
    );
  }

  Widget _buildOrderSummary(
    CartProvider cart,
    double subtotal,
    double downPayment,
    double loanAmount,
    double processingFee,
    double monthlyEmi,
  ) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.receipt_text, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),

          // Items
          ...cart.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                Text(currencyFormat.format(item.product.offerPrice ?? item.product.price)),
              ],
            ),
          )),

          const Divider(height: 24),

          // Breakdown
          _buildSummaryRow('Subtotal', currencyFormat.format(subtotal)),
          if (widget.selectedPlan != null) ...[
            _buildSummaryRow('Down Payment (${(downPaymentPercentage * 100).toInt()}%)', currencyFormat.format(downPayment), 
                highlight: true),
            _buildSummaryRow('Loan Amount', currencyFormat.format(loanAmount)),
            _buildSummaryRow('Processing Fee', currencyFormat.format(processingFee)),
            _buildSummaryRow('Interest', '₹0 (0%)', valueColor: Colors.green),
            const Divider(height: 16),
            _buildSummaryRow('Monthly EMI', '${currencyFormat.format(monthlyEmi)} x ${widget.selectedPlan!.tenure}',
                isBold: true, valueColor: AppTheme.primaryColor),
          ],

          const Divider(height: 24),

          // Total Due Now
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pay Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  currencyFormat.format(widget.selectedPlan != null ? downPayment : subtotal),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool highlight = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            color: highlight ? AppTheme.primaryColor : AppTheme.textSecondary,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
          )),
          Text(value, style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor,
          )),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          _buildPaymentOption('upi', Iconsax.mobile, 'UPI', 'Google Pay, PhonePe, Paytm'),
          _buildPaymentOption('card', Iconsax.card, 'Credit/Debit Card', 'Visa, Mastercard, Rupay'),
          _buildPaymentOption('netbanking', Iconsax.bank, 'Net Banking', 'All major banks'),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, IconData icon, String title, String subtitle) {
    final isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey, width: 2),
              ),
              child: isSelected
                  ? Center(child: Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryColor)))
                  : null,
            ),
            const SizedBox(width: 16),
            Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppTheme.primaryColor : null)),
                  Text(subtitle, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enter UPI ID', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _upiController,
            decoration: InputDecoration(
              hintText: 'yourname@upi',
              prefixIcon: const Icon(Iconsax.mobile),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Popular UPI Apps', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildUpiApp('GPay', Colors.blue),
              _buildUpiApp('PhonePe', Colors.purple),
              _buildUpiApp('Paytm', Colors.blue.shade900),
              _buildUpiApp('BHIM', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpiApp(String name, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(name[0], style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20))),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildCardSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Card Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Card Number',
              prefixIcon: const Icon(Iconsax.card),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'MM/YY',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'CVV',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetbankingSection() {
    final banks = ['HDFC', 'ICICI', 'SBI', 'Axis', 'Kotak', 'PNB'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Bank', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: banks.length,
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text(banks[index], style: const TextStyle(fontWeight: FontWeight.w500))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(double amount) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(
                'Pay ${currencyFormat.format(widget.selectedPlan != null ? amount : context.read<CartProvider>().totalAmount)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      final cart = context.read<CartProvider>();
      final auth = context.read<AuthProvider>();
      final subtotal = cart.totalAmount;
      final downPayment = subtotal * downPaymentPercentage;

      // Create order
      final orderData = {
        'userId': auth.userId,
        'items': cart.items.map((item) => {
          'productId': item.product.id,
          'quantity': item.quantity,
          'price': item.product.offerPrice ?? item.product.price,
        }).toList(),
        'totalAmount': subtotal,
        'shippingAddress': widget.shippingAddress,
        'paymentMethod': _selectedPaymentMethod,
        'paymentStatus': 'completed',
        'downPayment': widget.selectedPlan != null ? downPayment : subtotal,
        'emiPlanId': widget.selectedPlan?.id,
      };

      final response = await ApiService().createOrder(orderData);

      if (mounted) {
        if (response['success'] == true) {
          // Clear cart
          cart.clearCart();

          // Navigate to confirmation
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OrderConfirmationScreen(
                orderId: response['data']['_id'],
                orderData: orderData,
                emiPlan: widget.selectedPlan,
              ),
            ),
          );
        } else {
          _showError(response['message'] ?? 'Payment failed');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Payment failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
