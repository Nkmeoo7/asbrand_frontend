import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/address_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/wishlist/wishlist_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/orders/my_orders_screen.dart';
import '../screens/categories/category_products_screen.dart';
import '../screens/contact/contact_screen.dart';
import '../screens/credit/credit_dashboard_screen.dart';

class PremiumDrawer extends StatelessWidget {
  const PremiumDrawer({super.key});

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('mobile') || lower.contains('phone') || lower.contains('smartphone')) return Iconsax.mobile;
    if (lower.contains('laptop') || lower.contains('computer')) return Iconsax.monitor;
    if (lower.contains('tv') || lower.contains('display')) return Iconsax.monitor_mobbile;
    if (lower.contains('home') || lower.contains('appliance')) return Iconsax.home_1;
    if (lower.contains('audio') || lower.contains('headphone')) return Iconsax.headphone;
    if (lower.contains('wearable') || lower.contains('watch')) return Iconsax.watch;
    if (lower.contains('fashion') || lower.contains('cloth')) return Iconsax.bag_2;
    return Iconsax.category;
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    final auth = context.watch<AuthProvider>();

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Premium Gradient Header
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, left: 20, right: 20, bottom: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryColor, AppTheme.primaryDark, Color(0xFF003D42)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: const TextSpan(children: [
                        TextSpan(text: 'As', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        TextSpan(text: 'Brand', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF83C5BE))),
                      ]),
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                      child: IconButton(
                        icon: const Icon(Iconsax.close_circle, color: Colors.white, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // User Card with Glassmorphism
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF83C5BE), Color(0xFF006D77)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            auth.isAuthenticated ? (auth.user?.name?.isNotEmpty == true ? auth.user!.name![0].toUpperCase() : 'U') : '?',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.isAuthenticated ? 'Welcome back!' : 'Welcome, Guest!',
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              auth.isAuthenticated ? (auth.user?.name ?? 'User') : 'Sign in to continue',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      if (!auth.isAuthenticated)
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                            child: const Text('Sign In', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Quick Actions Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildQuickAction(context, Iconsax.heart, 'Wishlist', Colors.red, () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()));
                }),
                const SizedBox(width: 12),
                _buildQuickAction(context, Iconsax.shopping_cart, 'Cart', Colors.orange, () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                }),
                const SizedBox(width: 12),
                _buildQuickAction(context, Iconsax.box, 'Orders', Colors.blue, () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen()));
                }),
              ],
            ),
          ),

          // Categories Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 12),
                  child: Text('CATEGORIES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                ),
                ...categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final cat = entry.value;
                  final colors = [
                    [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                    [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
                    [const Color(0xFF11998E), const Color(0xFF38EF7D)],
                    [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
                    [const Color(0xFFF093FB), const Color(0xFFF5576C)],
                    [const Color(0xFFFFE53B), const Color(0xFFFF2525)],
                    [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                    [const Color(0xFF11998E), const Color(0xFF38EF7D)],
                  ];
                  final gradientColors = colors[index % colors.length];
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      leading: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: gradientColors[0].withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
                        ),
                        child: Icon(_getCategoryIcon(cat.name), color: Colors.white, size: 20),
                      ),
                      title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      trailing: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Iconsax.arrow_right_3, size: 16, color: AppTheme.primaryColor),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryProductsScreen(category: cat)));
                      },
                    ),
                  );
                }),
                
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // More Options
                _buildMenuItem(context, Iconsax.call, 'Contact Us', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactScreen()));
                }),
                if (auth.isAuthenticated) ...[
                  _buildMenuItem(context, Iconsax.receipt_2, 'My EMIs', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyEmisScreen()));
                  }),
                  const SizedBox(height: 8),
                  // Logout Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[100]!),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Iconsax.logout, color: Colors.red, size: 20),
                      ),
                      title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                      onTap: () async {
                        await auth.logout();
                        if (context.mounted) {
                          context.read<CartProvider>().clearCart();
                          context.read<WishlistProvider>().clearWishlist();
                          context.read<AddressProvider>().clearAddresses();
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Iconsax.arrow_right_3, size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
