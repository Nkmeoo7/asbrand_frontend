import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/user_kyc.dart';
import '../../widgets/credit_speedometer.dart';
import '../../widgets/limit_boost_card.dart';
import '../kyc/kyc_screen.dart';
import 'repayment_calendar_screen.dart';

class CreditDashboardScreen extends StatefulWidget {
  const CreditDashboardScreen({super.key});

  @override
  State<CreditDashboardScreen> createState() => _CreditDashboardScreenState();
}

class _CreditDashboardScreenState extends State<CreditDashboardScreen> {
  UserKyc? _kycData;
  bool _isLoading = true;
  String? _error;

  // Mock data for demo
  final double _usedCredit = 25000;
  final int _onTimePayments = 3;
  final int _requiredPayments = 5;

  @override
  void initState() {
    super.initState();
    _loadKycStatus();
  }

  Future<void> _loadKycStatus() async {
    try {
      final kyc = await ApiService().getKycStatus();
      if (mounted) {
        setState(() {
          _kycData = kyc;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isVerified = _kycData?.verificationStatus == 'verified';
    final creditLimit = _kycData?.creditLimit ?? 100000;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Credit Dashboard'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const RepaymentCalendarScreen()),
            ),
            icon: const Icon(Iconsax.calendar),
            tooltip: 'Payment Calendar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadKycStatus,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Welcome Header
                        _buildWelcomeHeader(auth),
                        const SizedBox(height: 20),

                        // Credit Speedometer
                        if (isVerified)
                          CreditSpeedometer(
                            totalLimit: creditLimit,
                            usedCredit: _usedCredit,
                          ),
                        const SizedBox(height: 20),

                        // Limit Boost Card
                        if (isVerified && _onTimePayments < _requiredPayments)
                          LimitBoostCard(
                            onTimePayments: _onTimePayments,
                            requiredPayments: _requiredPayments,
                            currentLimit: creditLimit,
                            nextLimit: creditLimit + 20000,
                          ),
                        if (isVerified && _onTimePayments < _requiredPayments)
                          const SizedBox(height: 20),

                        // KYC Status Card
                        _buildKycStatusCard(),
                        const SizedBox(height: 20),

                        // Quick Actions
                        _buildQuickActions(),
                        const SizedBox(height: 20),

                        // Credit Features
                        _buildCreditFeatures(),
                        const SizedBox(height: 20),

                        // Active EMIs
                        if (isVerified) _buildActiveEmiSection(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildWelcomeHeader(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.user, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${auth.user?.name ?? 'User'}!',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _kycData?.verificationStatus == 'verified' 
                      ? 'Your credit is ready to use'
                      : 'Complete KYC to unlock credit',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _kycData?.verificationStatus == 'verified' ? Iconsax.verify : Iconsax.lock,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.warning_2, size: 60, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text('Failed to load data', style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadKycStatus();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildKycStatusCard() {
    final status = _kycData?.verificationStatus ?? 'not_submitted';
    
    IconData icon;
    Color color;
    String title;
    String subtitle;
    Widget? action;

    switch (status) {
      case 'verified':
        icon = Iconsax.tick_circle;
        color = Colors.green;
        title = 'KYC Verified ✓';
        subtitle = 'Your identity is verified. Shop on EMI anytime!';
        break;
      case 'under_review':
        icon = Iconsax.clock;
        color = Colors.orange;
        title = 'KYC Under Review';
        subtitle = 'Verification in progress (24-48 hours).';
        break;
      case 'rejected':
        icon = Iconsax.close_circle;
        color = Colors.red;
        title = 'KYC Rejected';
        subtitle = _kycData?.rejectionReason ?? 'Please re-submit your documents.';
        action = ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KycScreen())),
          child: const Text('Re-submit KYC'),
        );
        break;
      default:
        icon = Iconsax.card_add;
        color = AppTheme.primaryColor;
        title = 'Complete KYC';
        subtitle = 'Verify identity to unlock ₹1 Lakh credit limit.';
        action = ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KycScreen())),
          icon: const Icon(Iconsax.arrow_right_3),
          label: const Text('Start KYC'),
        );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                if (action != null) ...[
                  const SizedBox(height: 12),
                  action,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(child: _buildActionCard(Iconsax.calendar, 'Payment\nCalendar', 
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RepaymentCalendarScreen())))),
        const SizedBox(width: 12),
        Expanded(child: _buildActionCard(Iconsax.receipt_2, 'My\nEMIs', 
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyEmisScreen())))),
        const SizedBox(width: 12),
        Expanded(child: _buildActionCard(Iconsax.document, 'Loan\nDocs', () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Loan documents coming soon')),
          );
        })),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 28),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditFeatures() {
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
          const Text('Credit Benefits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _buildFeatureRow(Iconsax.percentage_square, 'No-Cost EMI', '0% interest on all purchases'),
          _buildFeatureRow(Iconsax.clock, 'Flexible Tenure', '3 to 12 months EMI options'),
          _buildFeatureRow(Iconsax.card_slash, 'No Credit Card', 'Works with debit cards & UPI'),
          _buildFeatureRow(Iconsax.shield_tick, 'Secure', 'Bank-grade security'),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(subtitle, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveEmiSection() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active EMIs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyEmisScreen()),
                ),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                Icon(Iconsax.receipt_item, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Text('No active EMIs', style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== MY EMIS SCREEN ====================

class MyEmisScreen extends StatefulWidget {
  const MyEmisScreen({super.key});

  @override
  State<MyEmisScreen> createState() => _MyEmisScreenState();
}

class _MyEmisScreenState extends State<MyEmisScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _emiApplications = [];
  bool _isLoading = true;

  // Mock data for demo
  final List<Map<String, dynamic>> _mockEmis = [
    {
      'orderId': 'ORD12345ABC',
      'productName': 'iPhone 15 Pro',
      'status': 'active',
      'tenure': 6,
      'paidInstallments': 2,
      'monthlyEmi': 20833,
      'totalAmount': 125000,
      'remainingAmount': 83332,
      'nextDueDate': '2026-02-05',
    },
    {
      'orderId': 'ORD67890XYZ',
      'productName': 'Samsung TV 55"',
      'status': 'active',
      'tenure': 3,
      'paidInstallments': 1,
      'monthlyEmi': 15000,
      'totalAmount': 45000,
      'remainingAmount': 30000,
      'nextDueDate': '2026-02-05',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEmiApplications();
  }

  Future<void> _loadEmiApplications() async {
    // Use mock data for demo
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _emiApplications = _mockEmis;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('My EMIs'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildEmiList(_emiApplications.where((e) => e['status'] == 'active').toList()),
                _buildEmiList(_emiApplications.where((e) => e['status'] == 'completed').toList()),
                _buildEmiList(_emiApplications),
              ],
            ),
    );
  }

  Widget _buildEmiList(List<dynamic> emis) {
    if (emis.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.receipt_2, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No EMIs found', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: emis.length,
      itemBuilder: (context, index) => _buildEmiCard(emis[index]),
    );
  }

  Widget _buildEmiCard(Map<String, dynamic> emi) {
    final status = emi['status'] ?? 'pending';
    final paidInstallments = emi['paidInstallments'] ?? 0;
    final totalInstallments = emi['tenure'] ?? 0;
    final monthlyEmi = emi['monthlyEmi'] ?? 0;
    final remainingAmount = emi['remainingAmount'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(emi['productName'] ?? 'Product', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Order #${emi['orderId']?.substring(0, 8) ?? 'N/A'}', 
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toString().toUpperCase(),
                  style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$paidInstallments of $totalInstallments paid', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: totalInstallments > 0 ? paidInstallments / totalInstallments : 0,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹$monthlyEmi', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Text('/month', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Actions Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showForecloseDialog(emi),
                  icon: const Icon(Iconsax.money_send, size: 18),
                  label: const Text('Foreclose'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Redirecting to payment...')),
                    );
                  },
                  icon: const Icon(Iconsax.card, size: 18),
                  label: const Text('Pay EMI'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showForecloseDialog(Map<String, dynamic> emi) {
    final remainingAmount = emi['remainingAmount'] ?? 0;
    final paidInstallments = emi['paidInstallments'] ?? 0;
    final totalInstallments = emi['tenure'] ?? 0;
    final remainingInstallments = totalInstallments - paidInstallments;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.money_send, color: Colors.green.shade600),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Foreclose Loan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Pay remaining amount to close', style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildBreakdownRow('Remaining Installments', '$remainingInstallments'),
                  _buildBreakdownRow('Outstanding Principal', '₹$remainingAmount'),
                  _buildBreakdownRow('Foreclosure Fee', '₹0 (Waived)'),
                  const Divider(),
                  _buildBreakdownRow('Total Payable', '₹$remainingAmount', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Benefits
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.tick_circle, color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text('Credit limit restored immediately', style: TextStyle(color: Colors.green.shade700)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Redirecting to payment...'), backgroundColor: Colors.green),
                      );
                    },
                    child: Text('Pay ₹$remainingAmount'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isBold ? null : AppTheme.textSecondary)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
