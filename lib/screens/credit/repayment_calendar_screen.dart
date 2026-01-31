import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme.dart';

class RepaymentCalendarScreen extends StatefulWidget {
  const RepaymentCalendarScreen({super.key});

  @override
  State<RepaymentCalendarScreen> createState() => _RepaymentCalendarScreenState();
}

class _RepaymentCalendarScreenState extends State<RepaymentCalendarScreen> {
  DateTime _selectedMonth = DateTime.now();

  // Mock data - In real app, fetch from API
  final List<Map<String, dynamic>> _emiSchedule = [
    {'date': DateTime(2026, 2, 5), 'amount': 4167, 'status': 'upcoming', 'product': 'iPhone 15'},
    {'date': DateTime(2026, 2, 5), 'amount': 2500, 'status': 'upcoming', 'product': 'Samsung TV'},
    {'date': DateTime(2026, 3, 5), 'amount': 4167, 'status': 'scheduled', 'product': 'iPhone 15'},
    {'date': DateTime(2026, 3, 5), 'amount': 2500, 'status': 'scheduled', 'product': 'Samsung TV'},
    {'date': DateTime(2026, 4, 5), 'amount': 4167, 'status': 'scheduled', 'product': 'iPhone 15'},
  ];

  List<Map<String, dynamic>> get _currentMonthEmis => _emiSchedule
      .where((e) => (e['date'] as DateTime).month == _selectedMonth.month && 
                    (e['date'] as DateTime).year == _selectedMonth.year)
      .toList();

  double get _currentMonthTotal => _currentMonthEmis.fold(0, (sum, e) => sum + (e['amount'] as int));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Repayment Calendar'),
      ),
      body: Column(
        children: [
          // Month Selector & Summary
          _buildMonthHeader(),

          // Calendar Grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCalendarGrid(),
                  const SizedBox(height: 24),
                  _buildUpcomingPayments(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1)),
                icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
              ),
              Text(
                '${months[_selectedMonth.month - 1]} ${_selectedMonth.year}',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1)),
                icon: const Icon(Iconsax.arrow_right_3, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('EMIs Due', '${_currentMonthEmis.length}', Iconsax.calendar),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildSummaryItem('Total Amount', '₹${_currentMonthTotal.toStringAsFixed(0)}', Iconsax.money),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildSummaryItem('Auto-Debit', '5th', Iconsax.autobrightness),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // Sunday = 0
    
    final days = <Widget>[];
    
    // Week day headers
    const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    for (final day in weekDays) {
      days.add(Center(
        child: Text(day, style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500, fontSize: 12)),
      ));
    }
    
    // Empty cells before first day
    for (int i = 0; i < startWeekday; i++) {
      days.add(const SizedBox());
    }
    
    // Days of month
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      final hasEmi = _emiSchedule.any((e) => 
        (e['date'] as DateTime).day == day && 
        (e['date'] as DateTime).month == _selectedMonth.month &&
        (e['date'] as DateTime).year == _selectedMonth.year
      );
      final isToday = DateTime.now().day == day && 
                      DateTime.now().month == _selectedMonth.month && 
                      DateTime.now().year == _selectedMonth.year;
      final isPast = date.isBefore(DateTime.now());
      
      days.add(
        Container(
          decoration: BoxDecoration(
            color: hasEmi 
                ? (isPast ? Colors.green.shade50 : AppTheme.primaryColor.withOpacity(0.1))
                : isToday 
                    ? Colors.grey.shade100 
                    : null,
            borderRadius: BorderRadius.circular(8),
            border: isToday ? Border.all(color: AppTheme.primaryColor, width: 2) : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  fontWeight: hasEmi || isToday ? FontWeight.bold : FontWeight.normal,
                  color: hasEmi ? AppTheme.primaryColor : null,
                ),
              ),
              if (hasEmi)
                Positioned(
                  bottom: 4,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isPast ? Colors.green : AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        childAspectRatio: 1,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: days,
      ),
    );
  }

  Widget _buildUpcomingPayments() {
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
              Icon(Iconsax.calendar_tick, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text('Upcoming Payments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          if (_currentMonthEmis.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Iconsax.calendar_remove, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text('No EMIs due this month', style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            )
          else
            ...(_currentMonthEmis.map((emi) => _buildPaymentItem(emi))),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> emi) {
    final date = emi['date'] as DateTime;
    final status = emi['status'] as String;
    final isPaid = status == 'paid';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPaid ? Colors.green.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isPaid ? Colors.green.shade100 : AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPaid ? Colors.green : AppTheme.primaryColor,
                  ),
                ),
                Text(
                  _getMonthName(date.month),
                  style: TextStyle(
                    fontSize: 10,
                    color: isPaid ? Colors.green : AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emi['product'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  status == 'upcoming' ? 'Auto-debit scheduled' : status == 'paid' ? 'Paid' : 'Scheduled',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${emi['amount']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPaid ? Colors.green : null,
                ),
              ),
              if (isPaid)
                Row(
                  children: [
                    Icon(Iconsax.tick_circle, size: 12, color: Colors.green),
                    const SizedBox(width: 4),
                    const Text('Paid', style: TextStyle(color: Colors.green, fontSize: 11)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
