import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import 'product_detail_screen.dart';

/// Enum for different product views
enum ProductListType { all, bestSellers, deals }

/// Full page product listing with filters and sorting
class AllProductsScreen extends StatefulWidget {
  final ProductListType type;
  final String? title;

  const AllProductsScreen({
    super.key,
    this.type = ProductListType.all,
    this.title,
  });

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  String _sortBy = 'relevance';
  bool _isGridView = true;

  String get _pageTitle {
    if (widget.title != null) return widget.title!;
    switch (widget.type) {
      case ProductListType.bestSellers:
        return 'Best Sellers';
      case ProductListType.deals:
        return 'Deals & Offers';
      case ProductListType.all:
      default:
        return 'All Products';
    }
  }

  String get _pageSubtitle {
    switch (widget.type) {
      case ProductListType.bestSellers:
        return 'Top selling products loved by our customers';
      case ProductListType.deals:
        return 'Grab the best deals before they\'re gone!';
      case ProductListType.all:
      default:
        return 'Browse our complete collection';
    }
  }

  IconData get _pageIcon {
    switch (widget.type) {
      case ProductListType.bestSellers:
        return Iconsax.medal_star;
      case ProductListType.deals:
        return Iconsax.discount_shape;
      case ProductListType.all:
      default:
        return Iconsax.box;
    }
  }

  Color get _accentColor {
    switch (widget.type) {
      case ProductListType.bestSellers:
        return Colors.orange;
      case ProductListType.deals:
        return Colors.red;
      case ProductListType.all:
      default:
        return AppTheme.primaryColor;
    }
  }

  List<Product> _getProducts(ProductProvider provider) {
    List<Product> products;
    switch (widget.type) {
      case ProductListType.bestSellers:
        products = provider.bestSellers;
        break;
      case ProductListType.deals:
        products = provider.deals;
        break;
      case ProductListType.all:
      default:
        products = provider.products;
    }

    // Apply sorting
    switch (_sortBy) {
      case 'price_low':
        products.sort((a, b) => 
          (a.offerPrice ?? a.price).compareTo(b.offerPrice ?? b.price));
        break;
      case 'price_high':
        products.sort((a, b) => 
          (b.offerPrice ?? b.price).compareTo(a.offerPrice ?? a.price));
        break;
      case 'discount':
        products.sort((a, b) => b.discountPercentage.compareTo(a.discountPercentage));
        break;
      case 'newest':
        // Assuming newer products have higher IDs
        products.sort((a, b) => b.id.compareTo(a.id));
        break;
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          final products = _getProducts(productProvider);

          return CustomScrollView(
            slivers: [
              // App Bar with gradient
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: _accentColor,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_accentColor, _accentColor.withOpacity(0.7)],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(60, 20, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Icon(_pageIcon, color: Colors.white, size: 24),
                                const SizedBox(width: 10),
                                Text(
                                  _pageTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _pageSubtitle,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Stats Bar
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${products.length} Products',
                          style: TextStyle(
                            color: _accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // View Toggle
                      GestureDetector(
                        onTap: () => setState(() => _isGridView = !_isGridView),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _isGridView ? Iconsax.menu_1 : Iconsax.grid_2,
                            size: 20,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Sort Button
                      GestureDetector(
                        onTap: _showSortOptions,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Iconsax.sort, size: 18, color: Colors.grey.shade700),
                              const SizedBox(width: 6),
                              Text(
                                'Sort',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Products Grid/List
              if (products.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.box, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          widget.type == ProductListType.deals
                              ? 'No deals available right now'
                              : 'No products found',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back later for new arrivals!',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_isGridView)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];
                        return ProductCard(
                          imageUrl: product.primaryImage,
                          name: product.name,
                          price: product.offerPrice ?? product.price,
                          originalPrice: product.price,
                          emiPerMonth: product.emiPerMonth,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                          ),
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];
                        return _buildListItem(product);
                      },
                      childCount: products.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListItem(Product product) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.primaryImage.isNotEmpty
                    ? Image.network(
                        product.primaryImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.image,
                          color: Colors.grey.shade300,
                          size: 40,
                        ),
                      )
                    : Icon(Icons.image, color: Colors.grey.shade300, size: 40),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '₹${(product.offerPrice ?? product.price).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _accentColor,
                        ),
                      ),
                      if (product.offerPrice != null && product.offerPrice! < product.price) ...[
                        const SizedBox(width: 8),
                        Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${product.discountPercentage}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'EMI ₹${product.emiPerMonth.toStringAsFixed(0)}/mo',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Iconsax.arrow_right_3, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort By',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSortOption('relevance', 'Relevance', Iconsax.filter),
            _buildSortOption('price_low', 'Price: Low to High', Iconsax.arrow_up),
            _buildSortOption('price_high', 'Price: High to Low', Iconsax.arrow_down),
            _buildSortOption('discount', 'Discount', Iconsax.discount_shape),
            _buildSortOption('newest', 'Newest First', Iconsax.clock),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    final isSelected = _sortBy == value;
    return ListTile(
      leading: Icon(icon, color: isSelected ? _accentColor : Colors.grey),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? _accentColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: _accentColor)
          : null,
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
      },
    );
  }
}
