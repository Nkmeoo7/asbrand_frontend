import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme.dart';

/// Contact Screen - Shows contact information
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Contact Us'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.headphone, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'We\'re here to help!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reach out to us through any of these channels',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Contact Options
            _buildContactTile(
              context: context,
              icon: Iconsax.call,
              title: 'Phone',
              subtitle: '+91 98765 43210',
              copyText: '+919876543210',
            ),
            _buildContactTile(
              context: context,
              icon: Iconsax.sms,
              title: 'Email',
              subtitle: 'support@asbrand.com',
              copyText: 'support@asbrand.com',
            ),
            _buildContactTile(
              context: context,
              icon: Iconsax.message,
              title: 'WhatsApp',
              subtitle: '+91 98765 43210',
              copyText: '+919876543210',
            ),
            _buildContactTile(
              context: context,
              icon: Iconsax.location,
              title: 'Address',
              subtitle: 'AsBrand HQ, Mumbai, India - 400001',
              copyText: 'AsBrand HQ, Mumbai, India - 400001',
            ),
            const SizedBox(height: 24),
            // Support Hours
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  const Icon(Iconsax.clock, color: AppTheme.primaryColor, size: 32),
                  const SizedBox(height: 12),
                  const Text(
                    'Support Hours',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monday - Saturday\n9:00 AM - 6:00 PM IST',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String copyText,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        trailing: IconButton(
          icon: const Icon(Iconsax.copy, size: 20),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: copyText));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title copied to clipboard'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        onTap: () {
          Clipboard.setData(ClipboardData(text: copyText));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title copied to clipboard'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}
