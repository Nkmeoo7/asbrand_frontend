import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../core/theme.dart';

/// A circular speedometer widget showing credit limit usage
class CreditSpeedometer extends StatelessWidget {
  final double totalLimit;
  final double usedCredit;
  final double size;

  const CreditSpeedometer({
    super.key,
    required this.totalLimit,
    required this.usedCredit,
    this.size = 200,
  });

  double get availableCredit => totalLimit - usedCredit;
  double get usagePercentage => totalLimit > 0 ? (usedCredit / totalLimit) : 0;

  Color get statusColor {
    if (usagePercentage < 0.5) return Colors.green;
    if (usagePercentage < 0.75) return Colors.orange;
    return Colors.red;
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Icon(Iconsax.card, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Credit Limit',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  usagePercentage < 0.5 ? 'Healthy' : usagePercentage < 0.75 ? 'Moderate' : 'High Usage',
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Speedometer
          SizedBox(
            width: size,
            height: size * 0.6,
            child: CustomPaint(
              painter: _SpeedometerPainter(
                percentage: usagePercentage,
                statusColor: statusColor,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      _formatCurrency(availableCredit),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      'Available',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('Used', _formatCurrency(usedCredit), Colors.red.shade400),
              Container(width: 1, height: 40, color: Colors.grey.shade200),
              _buildStat('Total', _formatCurrency(totalLimit), AppTheme.primaryColor),
              Container(width: 1, height: 40, color: Colors.grey.shade200),
              _buildStat('Usage', '${(usagePercentage * 100).toInt()}%', statusColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }
}

class _SpeedometerPainter extends CustomPainter {
  final double percentage;
  final Color statusColor;

  _SpeedometerPainter({required this.percentage, required this.statusColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 20;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    // Gradient arc
    final gradient = SweepGradient(
      startAngle: math.pi,
      endAngle: 2 * math.pi,
      colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
      stops: const [0.0, 0.33, 0.66, 1.0],
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * percentage.clamp(0.0, 1.0),
      false,
      progressPaint,
    );

    // Needle
    final needleAngle = math.pi + (math.pi * percentage.clamp(0.0, 1.0));
    final needleLength = radius - 30;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = statusColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    // Center dot
    canvas.drawCircle(center, 8, Paint()..color = statusColor);
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);

    // Scale markers
    final markerPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2;

    for (int i = 0; i <= 4; i++) {
      final angle = math.pi + (math.pi * i / 4);
      final outerPoint = Offset(
        center.dx + (radius + 10) * math.cos(angle),
        center.dy + (radius + 10) * math.sin(angle),
      );
      final innerPoint = Offset(
        center.dx + (radius - 5) * math.cos(angle),
        center.dy + (radius - 5) * math.sin(angle),
      );
      canvas.drawLine(innerPoint, outerPoint, markerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
