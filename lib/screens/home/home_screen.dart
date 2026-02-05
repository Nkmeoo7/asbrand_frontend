import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/address_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/shimmer_loading.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../product/product_detail_screen.dart';
import '../auth/login_screen.dart';
import '../cart/cart_screen.dart';
import '../checkout/checkout_screen.dart';
import '../kyc/kyc_screen.dart';
import '../credit/credit_dashboard_screen.dart';
import '../orders/my_orders_screen.dart';
import '../profile/profile_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../orders/my_orders_screen.dart';
import '../contact/contact_screen.dart';
import '../categories/category_products_screen.dart';
import '../product/all_products_screen.dart';
import '../../widgets/premium_drawer.dart';

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

  @override
  void initState() {
    super.initState();
    // Ensure data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ProductProvider>().products.isEmpty) {
        context.read<ProductProvider>().fetchProducts();
        context.read<CategoryProvider>().fetchAllData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: _buildAppBar(context),
      drawer: const PremiumDrawer(),
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

          // Products are now filtered in the backend
          final productList = productProvider.products;

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
                  
                  // Show search results if searching (using provider state check could be better, but query string works)
                  if (_searchQuery.isNotEmpty) ...[
                    _buildSectionHeader('Search Results (${productList.length})', onViewAll: () => setState(() => _searchQuery = '')),
                    _buildProductGrid(productList),
                  ] else ...[
                    // 4 Sale Banners in horizontal scroll
                    _buildSaleBannersSection(),
                    // Credit limit card removed - moved to profile button in app bar
                    _buildSectionHeader('Best Sellers', onViewAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllProductsScreen(type: ProductListType.bestSellers),
                        ),
                      );
                    }),
                    _buildProductGrid(productProvider.bestSellers),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Deals', onViewAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllProductsScreen(type: ProductListType.deals),
                        ),
                      );
                    }),
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
        // Profile / Login Button
        Consumer<AuthProvider>(
          builder: (context, auth, _) {
             if (auth.isAuthenticated) {
               return GestureDetector(
                onTap: () => _showAuthOrProfile(context),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // Glassy effect
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.user, size: 18, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(auth.user?.name.split(' ')[0] ?? 'User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
             } else {
               return Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                 child: ElevatedButton(
                   onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.white,
                     foregroundColor: AppTheme.primaryColor,
                     elevation: 0,
                     padding: const EdgeInsets.symmetric(horizontal: 16),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // Flipkart style sharp login
                   ),
                   child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
                 ),
               );
             }
          },
        ),
      ],
    );
  }

  void _showAuthOrProfile(BuildContext context) {
    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated) {
      // Show profile screen
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
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
        onSubmitted: (value) => context.read<ProductProvider>().setSearch(value),
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search for shirts, dresses, jeans & more...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Iconsax.search_normal_1, color: AppTheme.primaryColor, size: 22),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: Icon(Iconsax.close_circle, color: Colors.grey.shade400),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    context.read<ProductProvider>().setSearch('');
                  },
                ),
              // Filter Button
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Iconsax.setting_4, color: AppTheme.primaryColor),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const FilterBottomSheet(),
                    );
                  },
                ),
              ),
            ],
          ),
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
      // Women's clothing
      if (lower.contains('women') || lower.contains('ladies')) return Iconsax.woman;
      if (lower.contains('dress') || lower.contains('gown')) return Iconsax.lovely;
      if (lower.contains('kurta') || lower.contains('kurti') || lower.contains('ethnic')) return Iconsax.gift;
      if (lower.contains('saree') || lower.contains('lehenga')) return Iconsax.star;
      // Men's clothing
      if (lower.contains('men') || lower.contains('gents')) return Iconsax.man;
      if (lower.contains('shirt') || lower.contains('top') || lower.contains('tee')) return Iconsax.box;
      if (lower.contains('suit') || lower.contains('blazer') || lower.contains('formal')) return Iconsax.briefcase;
      // Common clothing
      if (lower.contains('jeans') || lower.contains('pants') || lower.contains('bottom')) return Iconsax.tag;
      if (lower.contains('fashion') || lower.contains('cloth')) return Iconsax.bag_2;
      if (lower.contains('winter') || lower.contains('jacket') || lower.contains('sweater')) return Iconsax.cloud_snow;
      // Kids
      if (lower.contains('baby') || lower.contains('kid') || lower.contains('child')) return Iconsax.happyemoji;
      // Footwear & Accessories
      if (lower.contains('shoe') || lower.contains('footwear') || lower.contains('sneaker')) return Iconsax.activity;
      if (lower.contains('watch')) return Iconsax.watch;
      if (lower.contains('bag') || lower.contains('handbag') || lower.contains('purse')) return Iconsax.shopping_bag;
      if (lower.contains('accessori') || lower.contains('jewel')) return Iconsax.diamonds;
      // Sports
      if (lower.contains('sport') || lower.contains('active') || lower.contains('gym')) return Iconsax.weight;
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

  Widget _buildSaleBannersSection() {
    final banners = [
      {'title': 'END OF SEASON', 'subtitle': 'Up to 70% Off', 'discount': '70%', 'gradient': [const Color(0xFF006D77), const Color(0xFF004D55)], 'tag': 'Limited Time'},
      {'title': 'NEW ARRIVALS', 'subtitle': 'Latest Collection', 'discount': 'NEW', 'gradient': [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)], 'tag': 'Just In'},
      {'title': 'FASHION WEEK', 'subtitle': 'Buy 2 Get 1 Free', 'discount': '60%', 'gradient': [const Color(0xFF667EEA), const Color(0xFF764BA2)], 'tag': 'Trending'},
      {'title': 'WINTER WEAR', 'subtitle': 'Flat 40% Off', 'discount': '40%', 'gradient': [const Color(0xFF11998E), const Color(0xFF38EF7D)], 'tag': 'Cozy Deals'},
    ];

    return Column(
      children: [
        SizedBox(
          height: 178,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              final gradientColors = banner['gradient'] as List<Color>;
              return Container(
                width: 280,
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: [BoxShadow(color: gradientColors.first.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: Stack(
                  children: [
                    Positioned(right: -10, bottom: -15, child: Text(banner['discount'] as String, style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.15)))),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
                            child: Text(banner['tag'] as String, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                          const Spacer(),
                          Text(banner['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          Text(banner['subtitle'] as String, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                            child: Text('Shop Now', style: TextStyle(color: gradientColors.first, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 9),
      ],
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
