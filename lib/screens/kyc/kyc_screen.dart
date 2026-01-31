import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isSubmitting = false;

  // Step 1: Phone Verification
  final _phoneController = TextEditingController();
  bool _phoneVerified = false;

  // Step 2: PAN & Personal Details
  final _fullNameController = TextEditingController();
  final _panController = TextEditingController();
  DateTime? _dateOfBirth;
  String _selectedGender = 'male';

  // Step 3: Address
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _emailController = TextEditingController();

  // Step 4: Bank Details (Optional)
  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _upiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      _phoneController.text = auth.user!.phone ?? '';
      _fullNameController.text = auth.user!.name;
      _emailController.text = auth.user!.email;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _fullNameController.dispose();
    _panController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _emailController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: 'As', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              TextSpan(text: 'Brand', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF83C5BE))),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Credit Limit Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryDark],
              ),
            ),
            child: Column(
              children: [
                const Icon(Iconsax.card, size: 40, color: Colors.white),
                const SizedBox(height: 12),
                const Text(
                  'Unlock up to ₹1,00,000 Credit',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete verification in ${4 - _currentStep} steps',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),

          // Step Indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStepIndicator(0, 'Phone', Iconsax.call),
                _buildStepLine(0),
                _buildStepIndicator(1, 'Identity', Iconsax.personalcard),
                _buildStepLine(1),
                _buildStepIndicator(2, 'Address', Iconsax.location),
                _buildStepLine(2),
                _buildStepIndicator(3, 'Bank', Iconsax.bank),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCurrentStep(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentStep >= step;
    final isCompleted = _currentStep > step;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Iconsax.tick_circle, color: Colors.white, size: 20)
                  : Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 20),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppTheme.primaryColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int afterStep) {
    final isActive = _currentStep > afterStep;
    return Container(
      width: 20,
      height: 2,
      color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPhoneStep();
      case 1:
        return _buildIdentityStep();
      case 2:
        return _buildAddressStep();
      case 3:
        return _buildBankStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStepCard({required String title, required String subtitle, required List<Widget> children}) {
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
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPhoneStep() {
    final auth = context.watch<AuthProvider>();
    final registeredPhone = auth.user?.phone ?? '';

    return _buildStepCard(
      title: 'Verify Your Phone',
      subtitle: 'Confirm your registered mobile number',
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Iconsax.mobile, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Registered Number', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(registeredPhone.isNotEmpty ? '+91 $registeredPhone' : 'Not available',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              if (_phoneVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    children: [
                      Icon(Iconsax.tick_circle, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('Verified', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: 'Enter phone number to verify',
            prefixIcon: const Icon(Iconsax.call),
            counterText: '',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : () {
              if (_phoneController.text == registeredPhone) {
                setState(() {
                  _phoneVerified = true;
                  _currentStep = 1;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Phone number does not match registered number'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Verify & Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),

        const SizedBox(height: 16),
        Center(
          child: Text(
            'We will verify this matches your registered number',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentityStep() {
    return _buildStepCard(
      title: 'Identity Verification',
      subtitle: 'Enter your PAN and personal details',
      children: [
        TextFormField(
          controller: _fullNameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Full Name (as per PAN)',
            prefixIcon: const Icon(Iconsax.user),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _panController,
          textCapitalization: TextCapitalization.characters,
          maxLength: 10,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            UpperCaseTextFormatter(),
          ],
          decoration: InputDecoration(
            labelText: 'PAN Number',
            hintText: 'ABCDE1234F',
            prefixIcon: const Icon(Iconsax.card),
            counterText: '',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),

        // Date of Birth
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime(1995),
              firstDate: DateTime(1950),
              lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
            );
            if (date != null) setState(() => _dateOfBirth = date);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Iconsax.calendar, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  _dateOfBirth != null
                      ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                      : 'Date of Birth',
                  style: TextStyle(
                    color: _dateOfBirth != null ? Colors.black : AppTheme.textHint,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Gender
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gender', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: ['male', 'female', 'other'].map((gender) => Expanded(
                  child: RadioListTile<String>(
                    title: Text(gender[0].toUpperCase() + gender.substring(1), style: const TextStyle(fontSize: 14)),
                    value: gender,
                    groupValue: _selectedGender,
                    onChanged: (v) => setState(() => _selectedGender = v!),
                    activeColor: AppTheme.primaryColor,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _buildNavigationButtons(
          onBack: () => setState(() => _currentStep = 0),
          onNext: () {
            if (_fullNameController.text.isEmpty) {
              _showError('Please enter your full name');
              return;
            }
            if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(_panController.text)) {
              _showError('Please enter a valid PAN number (e.g., ABCDE1234F)');
              return;
            }
            if (_dateOfBirth == null) {
              _showError('Please select your date of birth');
              return;
            }
            setState(() => _currentStep = 2);
          },
        ),
      ],
    );
  }

  Widget _buildAddressStep() {
    return _buildStepCard(
      title: 'Address Details',
      subtitle: 'Enter your current address',
      children: [
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email Address',
            prefixIcon: const Icon(Iconsax.sms),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _streetController,
          decoration: InputDecoration(
            labelText: 'Street Address',
            prefixIcon: const Icon(Iconsax.home),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                decoration: InputDecoration(
                  labelText: 'State',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _pincodeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Pincode',
            prefixIcon: const Icon(Iconsax.location),
            counterText: '',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 24),

        _buildNavigationButtons(
          onBack: () => setState(() => _currentStep = 1),
          onNext: () {
            if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
              _showError('Please enter a valid email');
              return;
            }
            if (_streetController.text.isEmpty) {
              _showError('Please enter street address');
              return;
            }
            if (_cityController.text.isEmpty || _stateController.text.isEmpty) {
              _showError('Please enter city and state');
              return;
            }
            if (_pincodeController.text.length != 6) {
              _showError('Please enter a valid 6-digit pincode');
              return;
            }
            setState(() => _currentStep = 3);
          },
        ),
      ],
    );
  }

  Widget _buildBankStep() {
    return _buildStepCard(
      title: 'Bank Details (Optional)',
      subtitle: 'For EMI auto-debit setup',
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Icon(Iconsax.info_circle, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bank details are optional. You can add them later.',
                  style: TextStyle(color: Colors.amber.shade800, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
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
        const SizedBox(height: 16),

        TextFormField(
          controller: _bankNameController,
          decoration: InputDecoration(
            labelText: 'Bank Name',
            prefixIcon: const Icon(Iconsax.bank),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _accountNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Account Number',
            prefixIcon: const Icon(Iconsax.card),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _ifscController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: 'IFSC Code',
            hintText: 'HDFC0001234',
            prefixIcon: const Icon(Iconsax.building),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('OR', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _upiController,
          decoration: InputDecoration(
            labelText: 'UPI ID',
            hintText: 'yourname@upi',
            prefixIcon: const Icon(Iconsax.money_send),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 2),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppTheme.primaryColor),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitKyc,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit KYC', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationButtons({required VoidCallback onBack, required VoidCallback onNext}) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppTheme.primaryColor),
            ),
            child: const Text('Back'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _submitKyc() async {
    setState(() => _isSubmitting = true);

    try {
      final kycData = {
        'fullName': _fullNameController.text,
        'panNumber': _panController.text,
        'dateOfBirth': _dateOfBirth!.toIso8601String(),
        'gender': _selectedGender,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': {
          'street': _streetController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'pincode': _pincodeController.text,
          'country': 'India',
        },
      };

      // Add bank details if provided
      if (_accountNumberController.text.isNotEmpty || _upiController.text.isNotEmpty) {
        kycData['bankDetails'] = {
          'accountHolderName': _accountHolderController.text,
          'bankName': _bankNameController.text,
          'accountNumber': _accountNumberController.text,
          'ifscCode': _ifscController.text,
          'upiId': _upiController.text,
        };
      }

      final response = await ApiService().submitKyc(kycData);

      if (mounted) {
        if (response['success'] == true) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.tick_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 16),
                  const Text('KYC Submitted!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Your application is under review.', textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    'Credit limit will be assigned within 24 hours.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Continue Shopping'),
                ),
              ],
            ),
          );
        } else {
          _showError(response['message'] ?? 'KYC submission failed');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

// Helper class for uppercase input
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
