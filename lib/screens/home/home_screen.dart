import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/shimmer_loading.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../product/product_detail_screen.dart';
import '../auth/login_screen.dart';
import '../cart/cart_screen.dart';
import '../checkout/checkout_screen.dart';
import '../kyc/kyc_screen.dart';
import '../credit/credit_dashboard_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../orders/my_orders_screen.dart';
import '../contact/contact_screen.dart';
import '../categories/category_products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    var filtered = products;
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (p.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    
    // Filter by category
    if (_selectedCategoryId != null) {
      filtered = filtered.where((p) => p.category?.id == _selectedCategoryId).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: Consumer2<ProductProvider, CategoryProvider>(
        builder: (context, productProvider, categoryProvider, _) {
          if (productProvider.isLoading || categoryProvider.isLoading) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 16),
                  // Search bar skeleton
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _SearchBarSkeleton(),
                  ),
                  SizedBox(height: 16),
                  // Category chips skeleton
                  CategoryChipsSkeleton(),
                  SizedBox(height: 16),
                  // Banner skeleton
                  BannerSkeleton(),
                  SizedBox(height: 16),
                  // Credit card skeleton
                  _CreditCardSkeleton(),
                  SizedBox(height: 20),
                  // Section header skeleton
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _SectionHeaderSkeleton(),
                  ),
                  SizedBox(height: 12),
                  // Product grid skeleton
                  ProductGridSkeleton(),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _SectionHeaderSkeleton(),
                  ),
                  SizedBox(height: 12),
                  ProductGridSkeleton(),
                ],
              ),
            );
          }

          if (productProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.warning_2, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Error loading data', style: TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      productProvider.fetchProducts();
                      categoryProvider.fetchAllData();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredProducts = _getFilteredProducts(productProvider.products);

          return RefreshIndicator(
            onRefresh: () async {
              await productProvider.fetchProducts();
              await categoryProvider.fetchAllData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  _buildCategoryChips(categoryProvider.categories),
                  
                  // Show search results if searching
                  if (_searchQuery.isNotEmpty) ...[
                    _buildSectionHeader('Search Results (${filteredProducts.length})', onViewAll: () => setState(() => _searchQuery = '')),
                    _buildProductGrid(filteredProducts),
                  ] else ...[
                    _buildPromoBanner(categoryProvider.posters),
                    // Credit limit card removed - moved to profile button in app bar
                    _buildSectionHeader('Best Sellers', onViewAll: () {}),
                    _buildProductGrid(productProvider.bestSellers),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Deals', onViewAll: () {}),
                    _buildProductGrid(productProvider.deals.isEmpty ? productProvider.products.take(10).toList() : productProvider.deals),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: RichText(
        text: const TextSpan(
          children: [
            TextSpan(text: 'As', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            TextSpan(text: 'Brand', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF83C5BE))),
          ],
        ),
      ),
      actions: [
        // Cart Button
        Consumer<CartProvider>(
          builder: (context, cart, _) => Stack(
            children: [
              IconButton(
                icon: const Icon(Iconsax.shopping_cart),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('${cart.itemCount}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ),
            ],
          ),
        ),
        // Profile Button
        Consumer<AuthProvider>(
          builder: (context, auth, _) => GestureDetector(
            onTap: () => _showAuthOrProfile(context),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: auth.isAuthenticated ? AppTheme.primaryColor : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                auth.isAuthenticated ? Iconsax.user : Iconsax.profile_add,
                size: 18,
                color: auth.isAuthenticated ? Colors.white : AppTheme.primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAuthOrProfile(BuildContext context) {
    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated) {
      // Show profile or credit details
      showModalBottomSheet(
        context: context,
        builder: (_) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.tick_circle, size: 60, color: Colors.green),
              const SizedBox(height: 16),
              Text('Welcome, ${auth.user?.name ?? 'User'}!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Your credit limit: ₹50,000', style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search for products, brands & more...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Iconsax.search_normal_1, color: AppTheme.primaryColor, size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Iconsax.close_circle, color: Colors.grey.shade400),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : Icon(Iconsax.microphone, color: Colors.grey.shade400, size: 22),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }

  Widget _buildCategoryChips(List<Category> categories) {
    // Map category names to icons
    IconData getCategoryIcon(String name) {
      final lower = name.toLowerCase();
      if (lower.contains('mobile') || lower.contains('phone')) return Iconsax.mobile;
      if (lower.contains('electronic')) return Iconsax.cpu;
      if (lower.contains('tv') || lower.contains('appliance')) return Iconsax.monitor;
      if (lower.contains('kitchen') || lower.contains('home')) return Iconsax.home;
      if (lower.contains('health') || lower.contains('wellness')) return Iconsax.health;
      if (lower.contains('fashion') || lower.contains('cloth')) return Iconsax.bag_2;
      if (lower.contains('baby') || lower.contains('kid')) return Iconsax.happyemoji;
      if (lower.contains('laptop') || lower.contains('computer')) return Iconsax.monitor;
      if (lower.contains('watch')) return Iconsax.watch;
      if (lower.contains('headphone') || lower.contains('audio')) return Iconsax.headphone;
      return Iconsax.category;
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1, // +1 for 'All'
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          // First item is 'All' - just filters on home screen
          if (index == 0) {
            return CategoryChip(
              label: 'All',
              icon: Iconsax.element_4,
              imageUrl: null,
              isSelected: _selectedCategoryId == null,
              onTap: () => setState(() => _selectedCategoryId = null),
            );
          }
          
          // Other categories navigate to CategoryProductsScreen
          final category = categories[index - 1];
          return CategoryChip(
            label: category.name,
            icon: getCategoryIcon(category.name),
            imageUrl: category.image,
            isSelected: false, // Not used since we navigate away
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CategoryProductsScreen(category: category)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromoBanner(List posters) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [Color(0xFF006D77), Color(0xFF004D55)]),
      ),
      child: Stack(
        children: [
          if (posters.isNotEmpty)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  posters.first.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('₹299/-', style: TextStyle(color: Colors.white70, fontSize: 14, decoration: TextDecoration.lineThrough)),
                const Text('₹149', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  child: const Text('Shop on 0% EMI', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditLimitCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAuthOrProfile(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Unlock to get up to ₹1,00,000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Credit limit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('Name, Email, Date of birth required', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            ElevatedButton(onPressed: () => _showAuthOrProfile(context), child: const Text('GET LIMIT')),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          TextButton(onPressed: onViewAll, child: const Text('View All', style: TextStyle(color: AppTheme.primaryColor))),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Icon(Iconsax.box, size: 60, color: Colors.grey.shade300),
              const SizedBox(height: 8),
              const Text('No products found', style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final product = products[index];
          return SizedBox(
            width: 150,
            child: ProductCard(
              imageUrl: product.primaryImage,
              name: product.name,
              price: product.offerPrice ?? product.price,
              originalPrice: product.price,
              emiPerMonth: product.emiPerMonth,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    final auth = context.watch<AuthProvider>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('AsBrand', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  auth.isAuthenticated ? 'Welcome, ${auth.user?.name ?? 'User'}!' : 'Sign in to unlock credit',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          if (!auth.isAuthenticated)
            ListTile(
              leading: const Icon(Iconsax.login, color: AppTheme.primaryColor),
              title: const Text('Sign In / Register'),
              trailing: const Icon(Iconsax.arrow_right_3),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
            ),
          ListTile(
            leading: const Icon(Iconsax.heart, color: AppTheme.primaryColor),
            title: const Text('My Wishlist'),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.shopping_cart, color: AppTheme.primaryColor),
            title: const Text('My Cart'),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Text('Categories', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          ),
          ...categories.map((cat) => ListTile(
            leading: const Icon(Iconsax.category, color: AppTheme.primaryColor),
            title: Text(cat.name),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CategoryProductsScreen(category: cat)),
              );
            },
          )),
          const Divider(),
          if (auth.isAuthenticated) ...[  
            ListTile(
              leading: const Icon(Iconsax.card, color: AppTheme.primaryColor),
              title: const Text('Credit Dashboard'),
              trailing: const Icon(Iconsax.arrow_right_3),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CreditDashboardScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.receipt_2, color: AppTheme.primaryColor),
              title: const Text('My EMIs'),
              trailing: const Icon(Iconsax.arrow_right_3),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyEmisScreen()));
              },
            ),
          ],
          ListTile(
            leading: const Icon(Iconsax.bag_2, color: AppTheme.primaryColor),
            title: const Text('My Orders'),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.call, color: AppTheme.primaryColor),
            title: const Text('Contact Us'),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactScreen()));
            },
          ),
          if (auth.isAuthenticated)
            ListTile(
              leading: const Icon(Iconsax.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await auth.logout();
                if (context.mounted) Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}

// Helper skeleton widgets for loading state
class _SearchBarSkeleton extends StatelessWidget {
  const _SearchBarSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _CreditCardSkeleton extends StatelessWidget {
  const _CreditCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _SectionHeaderSkeleton extends StatelessWidget {
  const _SectionHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 18,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            height: 14,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
