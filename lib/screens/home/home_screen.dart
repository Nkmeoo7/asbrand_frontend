import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/category_chip.dart';
import '../../models/category.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: _buildAppBar(),
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
                  Text('Error: ${productProvider.error}'),
                  const SizedBox(height: 16),
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
                  _buildPromoBanner(categoryProvider.posters),
                  _buildCreditLimitCard(),
                  _buildSectionHeader('Best Sellers', onViewAll: () {}),
                  _buildProductGrid(productProvider.bestSellers),
                  const SizedBox(height: 20),
                  _buildSectionHeader('Deals: Pay Only ₹19', onViewAll: () {}),
                  _buildProductGrid(productProvider.deals),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
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
        Container(
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
              const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Credit:₹0', style: TextStyle(fontSize: 10, color: Colors.black54)),
                  Text('Unlock: ₹50000', style: TextStyle(fontSize: 10, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
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
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search for TV, Mobiles, Headphones & more...',
          hintStyle: TextStyle(color: AppTheme.textHint, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: AppTheme.textHint),
          border: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }

  Widget _buildCategoryChips(List<Category> categories) {
    if (categories.isEmpty) {
      // Fallback to demo categories
      return SizedBox(
        height: 100,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: const [
            CategoryChip(label: 'Mobiles', icon: Icons.phone_android),
            SizedBox(width: 12),
            CategoryChip(label: 'Electronics', icon: Icons.devices),
            SizedBox(width: 12),
            CategoryChip(label: 'Appliances', icon: Icons.kitchen),
          ],
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return CategoryChip(
            label: cat.name,
            imageUrl: cat.image,
            icon: Icons.category,
            isSelected: index == 0,
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

  Widget _buildCreditLimitCard() {
    return Container(
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
          ElevatedButton(onPressed: () {}, child: const Text('GET LIMIT')),
        ],
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

  Widget _buildProductGrid(List products) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No products available', style: TextStyle(color: AppTheme.textSecondary)),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.primaryColor),
            child: Text('snapmint', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const ListTile(
            leading: Icon(Icons.favorite_border, color: AppTheme.primaryColor),
            title: Text('My Wishlist'),
            trailing: Icon(Icons.chevron_right),
          ),
          ...categories.map((cat) => ListTile(
            leading: const Icon(Icons.category, color: AppTheme.primaryColor),
            title: Text(cat.name),
            trailing: const Icon(Icons.chevron_right),
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
        ],
      ),
    );
  }
}
