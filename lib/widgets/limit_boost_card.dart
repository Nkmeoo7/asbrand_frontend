import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../core/theme.dart';

/// Gamification card showing next milestone to unlock higher credit limit
class LimitBoostCard extends StatelessWidget {
  final int onTimePayments;
  final int requiredPayments;
  final double currentLimit;
  final double nextLimit;
  final bool isUnlocked;

  const LimitBoostCard({
    super.key,
    required this.onTimePayments,
    required this.requiredPayments,
    required this.currentLimit,
    required this.nextLimit,
    this.isUnlocked = false,
  });

  double get progress => requiredPayments > 0 ? (onTimePayments / requiredPayments).clamp(0.0, 1.0) : 0;
  int get remainingPayments => (requiredPayments - onTimePayments).clamp(0, requiredPayments);

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(0)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isUnlocked
              ? [Colors.green.shade400, Colors.green.shade600]
              : [AppTheme.primaryColor, AppTheme.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isUnlocked ? Colors.green : AppTheme.primaryColor).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isUnlocked ? Iconsax.unlock : Iconsax.lock,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUnlocked ? 'Limit Unlocked! 🎉' : 'Unlock Higher Limit',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      isUnlocked
                          ? 'Your credit limit has been increased'
                          : 'Complete on-time payments to unlock',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+${_formatCurrency(nextLimit - currentLimit)}',
                  style: TextStyle(
                    color: isUnlocked ? Colors.green.shade600 : AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress Section
          if (!isUnlocked) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pay $remainingPayments more EMIs on time',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Progress bar
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '$onTimePayments/$requiredPayments',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Milestones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(requiredPayments.clamp(1, 5), (index) {
                final isCompleted = index < onTimePayments;
                final isCurrent = index == onTimePayments;
                return Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.white
                        : isCurrent
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: isCurrent ? Border.all(color: Colors.white, width: 2) : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(Iconsax.tick_circle, size: 20, color: AppTheme.primaryColor)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent ? Colors.white : Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  ),
                );
              }),
            ),
          ] else ...[
            // Unlocked state
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.chart_success, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'New Limit Active',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_formatCurrency(currentLimit)} → ${_formatCurrency(nextLimit)}',
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact version for dashboard
class LimitBoostBadge extends StatelessWidget {
  final int remainingPayments;
  final double extraLimit;

  const LimitBoostBadge({
    super.key,
    required this.remainingPayments,
    required this.extraLimit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.lock, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            '$remainingPayments EMIs to unlock +₹${(extraLimit / 1000).toStringAsFixed(0)}K',
            style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
