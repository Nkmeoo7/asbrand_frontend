import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme.dart';

class MandateSetupScreen extends StatefulWidget {
  final Function(String mandateId)? onMandateCreated;

  const MandateSetupScreen({super.key, this.onMandateCreated});

  @override
  State<MandateSetupScreen> createState() => _MandateSetupScreenState();
}

class _MandateSetupScreenState extends State<MandateSetupScreen> {
  String _selectedMethod = 'upi_autopay';
  bool _isLoading = false;
  bool _mandateCreated = false;

  // Bank details for e-NACH
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _accountHolderController = TextEditingController();

  // UPI for AutoPay
  final _upiController = TextEditingController();

  @override
  void dispose() {
    _accountNumberController.dispose();
    _ifscController.dispose();
    _accountHolderController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Setup Auto-Debit'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.autobrightness, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Automatic EMI Payments', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Never miss a payment. EMIs will be auto-debited on the 5th of every month.',
                              style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Method Selection
              const Text('Choose Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _buildMethodOption(
                'upi_autopay',
                Iconsax.mobile,
                'UPI AutoPay',
                'Link your UPI ID for automatic payments',
                isRecommended: true,
              ),
              _buildMethodOption(
                'enach',
                Iconsax.bank,
                'e-NACH (Bank Auto-Debit)',
                'Authorize bank to auto-debit your account',
              ),
              const SizedBox(height: 24),

              // Method Details
              if (_selectedMethod == 'upi_autopay') _buildUpiAutoPaySection(),
              if (_selectedMethod == 'enach') _buildENachSection(),

              const SizedBox(height: 24),

              // Security Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.shield_tick, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bank-Grade Security', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                          Text('Your payment details are encrypted and secure. You can cancel anytime.',
                              style: TextStyle(color: Colors.green.shade600, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildMethodOption(String value, IconData icon, String title, String subtitle, {bool isRecommended = false}) {
    final isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                  Row(
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppTheme.primaryColor : null)),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Recommended', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  Text(subtitle, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiAutoPaySection() {
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
          const Text('Enter UPI ID', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('This UPI will be used for monthly auto-debit', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
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
          Row(
            children: [
              Icon(Iconsax.info_circle, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You will receive a mandate request on your UPI app to authorize.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildENachSection() {
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
          const Text('Bank Account Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('e-NACH will auto-debit EMI from this account', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),

          TextFormField(
            controller: _accountHolderController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Account Holder Name',
              prefixIcon: const Icon(Iconsax.user),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _accountNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Account Number',
              prefixIcon: const Icon(Iconsax.card),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _ifscController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'IFSC Code',
              hintText: 'HDFC0001234',
              prefixIcon: const Icon(Iconsax.bank),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Iconsax.info_circle, size: 16, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A mandate of max ₹50,000/month will be registered. You will receive a confirmation via SMS.',
                    style: TextStyle(color: Colors.amber.shade800, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_mandateCreated) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.tick_circle, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Text('Mandate created successfully!', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading || _mandateCreated ? null : _setupMandate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(
                      _mandateCreated ? 'Mandate Active' : 'Authorize Auto-Debit',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_mandateCreated ? 'Continue' : 'Skip for Now', style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  Future<void> _setupMandate() async {
    // Validate inputs
    if (_selectedMethod == 'upi_autopay' && _upiController.text.isEmpty) {
      _showError('Please enter your UPI ID');
      return;
    }
    if (_selectedMethod == 'enach') {
      if (_accountHolderController.text.isEmpty ||
          _accountNumberController.text.isEmpty ||
          _ifscController.text.isEmpty) {
        _showError('Please fill all bank details');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // Simulate mandate creation
      await Future.delayed(const Duration(seconds: 2));

      // In real implementation, call Razorpay/Cashfree mandate API
      final mandateId = 'mandate_${DateTime.now().millisecondsSinceEpoch}';

      if (mounted) {
        setState(() {
          _mandateCreated = true;
          _isLoading = false;
        });

        widget.onMandateCreated?.call(mandateId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Auto-debit mandate created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to create mandate: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
