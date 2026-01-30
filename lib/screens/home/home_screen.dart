import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/category_chip.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../product/product_detail_screen.dart';
import '../auth/login_screen.dart';
import '../cart/cart_screen.dart';

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
            return const Center(child: CircularProgressIndicator());
          }

          if (productProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.grey),
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
                    _buildCreditLimitCard(context),
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
            TextSpan(text: 'snap', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            TextSpan(text: 'mint', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF83C5BE))),
          ],
        ),
      ),
      actions: [
        // Cart Button
        Consumer<CartProvider>(
          builder: (context, cart, _) => Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
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
        // Credit Button
        GestureDetector(
          onTap: () => _showAuthOrProfile(context),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.credit_card, size: 14, color: Colors.black),
                ),
                const SizedBox(width: 8),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auth.isAuthenticated ? 'Credit:₹50000' : 'Credit:₹0', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                      Text(auth.isAuthenticated ? 'Available' : 'Unlock: ₹50000', style: const TextStyle(fontSize: 10, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
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
              const Icon(Icons.check_circle, size: 60, color: Colors.green),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search for TV, Mobiles, Headphones & more...',
          hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: AppTheme.textHint),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
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
      if (lower.contains('mobile') || lower.contains('phone')) return Icons.phone_android;
      if (lower.contains('electronic')) return Icons.devices;
      if (lower.contains('tv') || lower.contains('appliance')) return Icons.tv;
      if (lower.contains('kitchen') || lower.contains('home')) return Icons.kitchen;
      if (lower.contains('health') || lower.contains('wellness')) return Icons.health_and_safety;
      if (lower.contains('fashion') || lower.contains('cloth')) return Icons.checkroom;
      if (lower.contains('baby') || lower.contains('kid')) return Icons.child_care;
      if (lower.contains('laptop') || lower.contains('computer')) return Icons.laptop;
      if (lower.contains('watch')) return Icons.watch;
      if (lower.contains('headphone') || lower.contains('audio')) return Icons.headphones;
      return Icons.category;
    }

    final allCategories = [
      {'id': null, 'name': 'All', 'icon': Icons.apps},
      ...categories.map((c) => {'id': c.id, 'name': c.name, 'icon': getCategoryIcon(c.name), 'image': c.image}),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = allCategories[index];
          final isSelected = _selectedCategoryId == cat['id'];
          return CategoryChip(
            label: cat['name'] as String,
            icon: cat['icon'] as IconData,
            imageUrl: cat['image'] as String?,
            isSelected: isSelected,
            onTap: () => setState(() => _selectedCategoryId = cat['id'] as String?),
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
              Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade300),
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
        separatorBuilder: (_, __) => const SizedBox(width: 12),
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
                const Text('snapmint', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
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
              leading: const Icon(Icons.login, color: AppTheme.primaryColor),
              title: const Text('Sign In / Register'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
            ),
          const ListTile(
            leading: Icon(Icons.favorite_border, color: AppTheme.primaryColor),
            title: Text('My Wishlist'),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined, color: AppTheme.primaryColor),
            title: const Text('My Cart'),
            trailing: const Icon(Icons.chevron_right),
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
            leading: const Icon(Icons.category, color: AppTheme.primaryColor),
            title: Text(cat.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedCategoryId = cat.id);
            },
          )),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryColor),
            title: Text('My Orders'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.phone, color: AppTheme.primaryColor),
            title: Text('Contact Us'),
            trailing: Icon(Icons.chevron_right),
          ),
          if (auth.isAuthenticated)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
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
