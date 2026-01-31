import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/user_kyc.dart';
import '../kyc/kyc_screen.dart';

class CreditDashboardScreen extends StatefulWidget {
  const CreditDashboardScreen({super.key});

  @override
  State<CreditDashboardScreen> createState() => _CreditDashboardScreenState();
}

class _CreditDashboardScreenState extends State<CreditDashboardScreen> {
  UserKyc? _kycData;
  bool _isLoading = true;
  String? _error;

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

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Credit Dashboard'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadKycStatus,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildCreditHeader(auth),
                        const SizedBox(height: 16),
                        _buildKycStatusCard(),
                        const SizedBox(height: 16),
                        _buildCreditFeatures(),
                        const SizedBox(height: 16),
                        if (_kycData?.verificationStatus == 'verified')
                          _buildActiveEmiSection(),
                      ],
                    ),
                  ),
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

  Widget _buildCreditHeader(AuthProvider auth) {
    final isVerified = _kycData?.verificationStatus == 'verified';
    final creditLimit = _kycData?.creditLimit ?? 0;
    final usedCredit = 0.0; // TODO: Calculate from active EMIs

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.card, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${auth.user?.name ?? 'User'}!',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                  const Text(
                    'Your Credit Dashboard',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Credit Limit Display
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  isVerified ? 'Available Credit' : 'Potential Credit',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${creditLimit.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
                if (isVerified && creditLimit > 0) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCreditStat('Used', '₹${usedCredit.toStringAsFixed(0)}', Colors.amber),
                      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                      _buildCreditStat('Available', '₹${(creditLimit - usedCredit).toStringAsFixed(0)}', Colors.green),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
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
        title = 'KYC Verified';
        subtitle = 'Your identity has been verified. Enjoy your credit limit!';
        break;
      case 'under_review':
        icon = Iconsax.clock;
        color = Colors.orange;
        title = 'KYC Under Review';
        subtitle = 'Your documents are being verified. This usually takes 24-48 hours.';
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
        subtitle = 'Verify your identity to unlock credit limit and shop on EMI.';
        action = ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KycScreen())),
          icon: const Icon(Iconsax.arrow_right_3),
          label: const Text('Start KYC'),
        );
    }

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

  Widget _buildCreditFeatures() {
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
          const Text('Credit Benefits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _buildFeatureRow(Iconsax.percentage_square, 'No-Cost EMI', '0% interest on all purchases'),
          _buildFeatureRow(Iconsax.clock, 'Flexible Tenure', '3 to 12 months EMI options'),
          _buildFeatureRow(Iconsax.card_slash, 'No Credit Card', 'Works with debit cards & UPI'),
          _buildFeatureRow(Iconsax.shield_tick, 'Secure', 'Bank-grade security & encryption'),
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEmiApplications();
  }

  Future<void> _loadEmiApplications() async {
    try {
      final response = await ApiService().get('${ApiService().toString()}/emi/my-applications');
      if (mounted && response['success'] == true) {
        setState(() {
          _emiApplications = response['data'] ?? [];
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
            const SizedBox(height: 8),
            Text('Your EMI applications will appear here', style: TextStyle(color: AppTheme.textHint)),
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
    final nextDueDate = emi['nextDueDate'];

    Color statusColor;
    switch (status) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'completed':
        statusColor = Colors.blue;
        break;
      case 'defaulted':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #${emi['orderId']?.substring(0, 8) ?? 'N/A'}', 
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toString().toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEmiStat('Monthly EMI', '₹${monthlyEmi.toString()}'),
              _buildEmiStat('Progress', '$paidInstallments / $totalInstallments'),
              _buildEmiStat('Total', '₹${(emi['totalAmount'] ?? 0).toString()}'),
            ],
          ),

          if (status == 'active' && nextDueDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.calendar, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Next due: ${DateTime.parse(nextDueDate).day}/${DateTime.parse(nextDueDate).month}/${DateTime.parse(nextDueDate).year}'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement payment
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Pay Now'),
                  ),
                ],
              ),
            ),
          ],

          // Progress bar
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: totalInstallments > 0 ? paidInstallments / totalInstallments : 0,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmiStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
