import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme.dart';

/// Privacy Policy Screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Iconsax.shield_tick, color: AppTheme.primaryColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Privacy Matters',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last updated: February 2026',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '1. Information We Collect',
              content: '''We collect information you provide directly to us, such as:
• Personal information (name, email, phone number)
• Delivery address for order fulfillment
• Payment information (processed securely via third-party providers)
• Order history and preferences''',
            ),
            
            _buildSection(
              title: '2. How We Use Your Information',
              content: '''Your information helps us:
• Process and fulfill your orders
• Send order updates and notifications
• Improve our products and services
• Provide personalized recommendations
• Communicate about promotions and offers''',
            ),
            
            _buildSection(
              title: '3. Data Security',
              content: '''We implement industry-standard security measures to protect your data:
• SSL encryption for all data transmission
• Secure storage with access controls
• Regular security audits
• Payment data handled by PCI-compliant processors''',
            ),
            
            _buildSection(
              title: '4. Data Sharing',
              content: '''We do not sell your personal information. We may share data with:
• Delivery partners for order fulfillment
• Payment processors for transactions
• Service providers who assist our operations
• Law enforcement when required by law''',
            ),
            
            _buildSection(
              title: '5. Your Rights',
              content: '''You have the right to:
• Access your personal data
• Correct inaccurate information
• Delete your account and data
• Opt-out of marketing communications
• Request data portability''',
            ),
            
            _buildSection(
              title: '6. Cookies & Tracking',
              content: '''We use cookies to:
• Remember your preferences
• Analyze app usage
• Improve user experience
• Serve relevant content''',
            ),
            
            _buildSection(
              title: '7. Contact Us',
              content: '''For privacy-related questions, contact us at:
Email: privacy@asbrand.com
Phone: +91 1800-123-4567''',
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.6,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
