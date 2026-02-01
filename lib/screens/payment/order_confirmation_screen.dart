import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme.dart';
import '../../models/emi_plan.dart';
import '../home/home_screen.dart';
import '../credit/credit_dashboard_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;
  final EmiPlan? emiPlan;

  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
    required this.orderData,
    this.emiPlan,
  });

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = (orderData['totalAmount'] ?? 0).toDouble();
    final downPayment = (orderData['downPayment'] ?? 0).toDouble();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Success Animation
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.tick_circle, size: 80, color: Colors.green.shade600),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Payment Successful!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Order #${orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Order Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Order Total', _formatCurrency(totalAmount)),
                      _buildDetailRow('Paid Today', _formatCurrency(downPayment), valueColor: Colors.green),
                      if (emiPlan != null) ...[
                        const Divider(height: 24),
                        _buildDetailRow('EMI Plan', '${emiPlan!.tenure} Months @ 0%'),
                        _buildDetailRow(
                          'Monthly EMI',
                          _formatCurrency((totalAmount - downPayment) / emiPlan!.tenure),
                          valueColor: AppTheme.primaryColor,
                        ),
                        _buildDetailRow(
                          'Next Due Date',
                          _formatDate(DateTime.now().add(const Duration(days: 30))),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // EMI Schedule Preview
                if (emiPlan != null) _buildEmiSchedulePreview(totalAmount, downPayment),
                const SizedBox(height: 24),

                // Credit Update
                if (emiPlan != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.card, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Credit Updated', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                'Used: ${_formatCurrency(totalAmount - downPayment)}',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const CreditDashboardScreen()),
                          ),
                          child: const Text('View'),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MyEmisScreen()),
                    ),
                    icon: const Icon(Iconsax.receipt_2),
                    label: const Text('View My EMIs'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    ),
                    icon: const Icon(Iconsax.home),
                    label: const Text('Continue Shopping'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildEmiSchedulePreview(double totalAmount, double downPayment) {
    final loanAmount = totalAmount - downPayment;
    final monthlyEmi = loanAmount / emiPlan!.tenure;
    final now = DateTime.now();

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
          Row(
            children: [
              Icon(Iconsax.calendar, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text('EMI Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),

          // Show first 3 installments
          ...List.generate(
            emiPlan!.tenure > 3 ? 3 : emiPlan!.tenure,
            (index) {
              final dueDate = DateTime(now.year, now.month + index + 1, 5);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_formatDate(dueDate)),
                    ),
                    Text(
                      _formatCurrency(monthlyEmi),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),

          if (emiPlan!.tenure > 3)
            Center(
              child: Text(
                '+ ${emiPlan!.tenure - 3} more installments',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
