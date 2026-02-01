import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/emi_plan.dart';
import '../../services/payment_service.dart';
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
  late PaymentService _paymentService;

  // Down payment percentage (10%)
  double get downPaymentPercentage => 0.10;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
  }

  @override
  void dispose() {
    _upiController.dispose();
    _paymentService.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
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
            _buildOrderSummary(cart, subtotal, downPayment, loanAmount, processingFee, monthlyEmi),
            const SizedBox(height: 16),
            _buildPaymentMethods(),
            const SizedBox(height: 16),
            if (_selectedPaymentMethod == 'upi') _buildUpiSection(),
            if (_selectedPaymentMethod == 'card') _buildCardSection(),
            if (_selectedPaymentMethod == 'netbanking') _buildNetbankingSection(),
            if (_selectedPaymentMethod == 'cod') _buildCodSection(),
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
          ...cart.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                Text(_formatCurrency(item.product.offerPrice ?? item.product.price)),
              ],
            ),
          )),
          const Divider(height: 24),
          _buildSummaryRow('Subtotal', _formatCurrency(subtotal)),
          if (widget.selectedPlan != null) ...[
            _buildSummaryRow('Down Payment (${(downPaymentPercentage * 100).toInt()}%)', _formatCurrency(downPayment), highlight: true),
            _buildSummaryRow('Loan Amount', _formatCurrency(loanAmount)),
            _buildSummaryRow('Processing Fee', _formatCurrency(processingFee)),
            _buildSummaryRow('Interest', '₹0 (0%)', valueColor: Colors.green),
            const Divider(height: 16),
            _buildSummaryRow('Monthly EMI', '${_formatCurrency(monthlyEmi)} x ${widget.selectedPlan!.tenure}',
                isBold: true, valueColor: AppTheme.primaryColor),
          ],
          const Divider(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedPaymentMethod == 'cod' ? 'Total (Pay on Delivery)' : 'Pay Now',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  _formatCurrency(widget.selectedPlan != null ? downPayment : context.read<CartProvider>().totalAmount),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
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
          _buildPaymentOption('cod', Iconsax.money, 'Cash on Delivery', 'Pay when you receive'),
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
          Row(
            children: [
              Icon(Iconsax.info_circle, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Razorpay will open with all UPI options',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ],
          ),
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
      child: Row(
        children: [
          Icon(Iconsax.info_circle, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Card details will be securely entered in Razorpay checkout',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetbankingSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Icon(Iconsax.info_circle, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'All banks will be available in Razorpay checkout',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Icon(Iconsax.truck, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cash on Delivery', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  'Pay with cash when your order arrives. No online payment required.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(double downPayment) {
    final cart = context.read<CartProvider>();
    final payAmount = widget.selectedPlan != null ? downPayment : cart.totalAmount;
    final isCod = _selectedPaymentMethod == 'cod';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: isCod ? Colors.orange : AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(
                isCod ? 'Place Order (COD)' : 'Pay ${_formatCurrency(payAmount)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    try {
      final cart = context.read<CartProvider>();

      // Prepare items for backend
      final items = cart.items.map((item) => {
        'productID': item.product.id,
        'productName': item.product.name,
        'quantity': item.quantity,
        'price': item.product.offerPrice ?? item.product.price,
      }).toList();

      if (_selectedPaymentMethod == 'cod') {
        // COD Flow - No Razorpay
        await _paymentService.placeCodOrder(
          items: items,
          shippingAddress: widget.shippingAddress,
          onSuccess: (orderId) {
            cart.clearCart();
            _navigateToSuccess(orderId);
          },
          onError: (error) {
            _showError(error);
            setState(() => _isLoading = false);
          },
        );
      } else {
        // Online Payment - Razorpay
        await _paymentService.initiatePayment(
          context: context,
          items: items,
          shippingAddress: widget.shippingAddress,
          paymentMethod: _selectedPaymentMethod,
          onSuccess: (orderId) {
            cart.clearCart();
            _navigateToSuccess(orderId);
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

  void _navigateToSuccess(String orderId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderConfirmationScreen(
          orderId: orderId,
          orderData: {
            'paymentMethod': _selectedPaymentMethod,
            'shippingAddress': widget.shippingAddress,
          },
          emiPlan: widget.selectedPlan,
        ),
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
