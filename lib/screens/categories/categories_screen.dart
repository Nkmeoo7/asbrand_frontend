import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/category.dart';
import '../product/product_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int selectedCategoryIndex = 0;

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
      body: Consumer2<CategoryProvider, ProductProvider>(
        builder: (context, categoryProvider, productProvider, _) {
          if (categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = categoryProvider.categories;
          final subCategories = categoryProvider.subCategories;

          if (categories.isEmpty) {
            return const Center(child: Text('No categories found'));
          }

          // Get selected category
          final selectedCategory = categories[selectedCategoryIndex];
          final filteredSubCategories = categoryProvider.getSubCategoriesFor(selectedCategory.id);
          final categoryProducts = productProvider.getProductsByCategory(selectedCategory.id);

          return Row(
            children: [
              // Left Sidebar
              Container(
                width: 80,
                color: Colors.white,
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == selectedCategoryIndex;
                    final cat = categories[index];
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategoryIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.surfaceColor : Colors.white,
                          border: Border(
                            left: BorderSide(
                              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Category image or icon
                            if (cat.image != null && cat.image!.isNotEmpty && cat.image != 'no_url')
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  cat.image!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.category,
                                    color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                                    size: 28,
                                  ),
                                ),
                              )
                            else
                              Icon(
                                Icons.category,
                                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                                size: 28,
                              ),
                            const SizedBox(height: 4),
                            Text(
                              cat.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Right Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Banner
                      _buildCategoryBanner(selectedCategory),
                      const SizedBox(height: 20),
                      // Subcategories
                      if (filteredSubCategories.isNotEmpty) ...[
                        _buildSubcategorySection('${selectedCategory.name} & Sub Categories', filteredSubCategories),
                        const SizedBox(height: 20),
                      ],
                      // All subcategories if no filtered ones
                      if (filteredSubCategories.isEmpty && subCategories.isNotEmpty) ...[
                        _buildSubcategorySection('All Sub Categories', subCategories.take(6).toList()),
                        const SizedBox(height: 20),
                      ],
                      // Products in this category
                      if (categoryProducts.isNotEmpty)
                        _buildProductSection('Products in ${selectedCategory.name}', categoryProducts),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryBanner(Category category) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.primaryDark]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('Pay as low as', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const Text('₹299 Now!', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Explore All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          if (category.image != null && category.image!.isNotEmpty && category.image != 'no_url')
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                category.image!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(width: 80),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubcategorySection(String title, List<SubCategory> subcategories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90, // Increased from 80 to fix overflow
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: subcategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final sub = subcategories[index];
              return SizedBox(
                width: 65,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.category, color: AppTheme.primaryColor, size: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sub.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, height: 1.2),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductSection(String title, List products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length > 5 ? 5 : products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.primaryImage.isNotEmpty
                      ? Image.network(
                          product.primaryImage,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[100],
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[100],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                ),
                title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '₹${(product.offerPrice ?? product.price).toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppTheme.primaryColor),
              ),
            );
          },
        ),
      ],
    );
  }
}
