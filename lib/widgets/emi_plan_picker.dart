import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../core/theme.dart';
import '../models/emi_plan.dart';
import '../services/api_service.dart';

class EmiPlanPicker extends StatefulWidget {
  final double productPrice;
  final Function(EmiPlan?, double)? onPlanSelected;

  const EmiPlanPicker({
    super.key,
    required this.productPrice,
    this.onPlanSelected,
  });

  @override
  State<EmiPlanPicker> createState() => _EmiPlanPickerState();
}

class _EmiPlanPickerState extends State<EmiPlanPicker> {
  List<EmiPlan> _plans = [];
  bool _isLoading = true;
  EmiPlan? _selectedPlan;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await ApiService().getEmiPlans();
      if (mounted) {
        setState(() {
          _plans = plans.where((p) => 
            p.minOrderAmount <= widget.productPrice &&
            (p.maxOrderAmount == null || p.maxOrderAmount! >= widget.productPrice)
          ).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_plans.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Iconsax.info_circle, color: AppTheme.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No EMI plans available for this amount',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'No Cost EMI',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'from ₹${(widget.productPrice / 12).round()}/month',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Plan Cards
        ...(_plans.map((plan) => _buildPlanCard(plan))),

        // Selected Plan Summary
        if (_selectedPlan != null) ...[
          const SizedBox(height: 16),
          _buildPlanSummary(),
        ],
      ],
    );
  }

  Widget _buildPlanCard(EmiPlan plan) {
    final isSelected = _selectedPlan?.id == plan.id;
    final monthlyEmi = (widget.productPrice + (plan.processingFee ?? 0)) / plan.tenure;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedPlan = isSelected ? null : plan);
        widget.onPlanSelected?.call(_selectedPlan, monthlyEmi);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Plan details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${plan.tenure} Months',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (plan.interestRate == 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '0% Interest',
                            style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (plan.processingFee != null && plan.processingFee! > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '+₹${plan.processingFee} fee',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // EMI amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${monthlyEmi.round()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  '/month',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSummary() {
    final plan = _selectedPlan!;
    final monthlyEmi = (widget.productPrice + (plan.processingFee ?? 0)) / plan.tenure;
    final totalAmount = monthlyEmi * plan.tenure;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.receipt_text, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text('EMI Breakdown', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),
          _buildSummaryRow('Product Price', '₹${widget.productPrice.round()}'),
          _buildSummaryRow('Processing Fee', '₹${(plan.processingFee ?? 0).round()}'),
          _buildSummaryRow('Interest', '₹0 (0%)', valueColor: Colors.green),
          const Divider(height: 16),
          _buildSummaryRow('Total Amount', '₹${totalAmount.round()}', isBold: true),
          _buildSummaryRow('Monthly EMI', '₹${monthlyEmi.round()} x ${plan.tenure} months', 
              valueColor: AppTheme.primaryColor, isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Compact EMI badge for product cards
class EmiBadge extends StatelessWidget {
  final double price;

  const EmiBadge({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    final emiPerMonth = price / 12;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.percentage_square, size: 12, color: Colors.green.shade700),
          const SizedBox(width: 4),
          Text(
            'EMI ₹${emiPerMonth.round()}/mo',
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
