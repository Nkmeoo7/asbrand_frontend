import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../cart/cart_screen.dart';
import '../auth/login_screen.dart';
import '../checkout/checkout_screen.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/similar_products_section.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int selectedImageIndex = 0;
  int selectedEmiMonths = 3;
  String? selectedVariant;

  void _shareProduct() {
    final product = widget.product;
    final shareText = '''
Check out ${product.name} on AsBrand!

💰 Price: ₹${(product.offerPrice ?? product.price).toStringAsFixed(0)}
📦 EMI from ₹${product.emiPerMonth.toStringAsFixed(0)}/month

Download AsBrand app to shop with easy EMI options!
''';
    
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product link copied to clipboard!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleWishlist() {
    final wishlist = context.read<WishlistProvider>();
    final added = wishlist.toggleWishlist(widget.product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(added ? 'Added to wishlist!' : 'Removed from wishlist'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: added ? AppTheme.primaryColor : Colors.grey[700],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final hasDiscount = product.offerPrice != null && product.offerPrice! < product.price;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.share),
            onPressed: _shareProduct,
            tooltip: 'Share',
          ),
          Consumer<WishlistProvider>(
            builder: (context, wishlist, _) {
              final isInWishlist = wishlist.isInWishlist(product.id);
              return IconButton(
                icon: Icon(
                  isInWishlist ? Icons.favorite : Iconsax.heart,
                  color: isInWishlist ? Colors.red : null,
                ),
                onPressed: _toggleWishlist,
                tooltip: isInWishlist ? 'Remove from wishlist' : 'Add to wishlist',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            _buildImageGallery(product),
            
            // Product Info
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Brand
                  if (product.category != null || product.brand != null)
                    Text(
                      '${product.brand?.name ?? ''} ${product.category?.name ?? ''}'.trim(),
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  const SizedBox(height: 4),
                  
                  // Name
                  Text(product.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  // Price
                  Row(
                    children: [
                      Text(
                        '₹${(product.offerPrice ?? product.price).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 8),
                        Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 16, decoration: TextDecoration.lineThrough, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                          child: Text('${product.discountPercentage}% OFF', style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Stock Status Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.isInStock 
                            ? (product.isLowStock ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1))
                            : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: product.isInStock 
                              ? (product.isLowStock ? Colors.orange : Colors.green)
                              : Colors.red,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              product.isInStock ? Iconsax.tick_circle : Iconsax.close_circle,
                              size: 14,
                              color: product.isInStock 
                                ? (product.isLowStock ? Colors.orange : Colors.green)
                                : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.stockLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: product.isInStock 
                                  ? (product.isLowStock ? Colors.orange : Colors.green)
                                  : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (product.emiEligible) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.purple),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Iconsax.card, size: 14, color: Colors.purple),
                              SizedBox(width: 4),
                              Text('EMI Available', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.purple)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // EMI Options - Hidden for now, will be enabled in future
                  // TODO: Enable EMI section when feature is ready
                  // _buildEmiSection(product),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Description
            if (product.description != null && product.description!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(product.description!, style: const TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            
            const SizedBox(height: 8),

            // Variant Selector (Sizes/Colors)
            if (product.variants.isNotEmpty)
              _buildVariantSelector(product),

            // Specifications Table
            if (product.specifications.isNotEmpty)
              _buildSpecificationsSection(product),

            // Product Info (SKU, Warranty, Weight)
            _buildProductInfoSection(product),

            // Tags
            if (product.tags.isNotEmpty)
              _buildTagsSection(product),
            
            // Frequently Bought Together Section
            SimilarProductsSection(
              currentProduct: product,
              title: 'Frequently Bought Together',
              showFrequentlyBought: true,
            ),

            // Similar Products Section  
            SimilarProductsSection(
              currentProduct: product,
              title: 'Similar Products',
              showFrequentlyBought: false,
            ),
            
            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(product),
    );
  }

  Widget _buildImageGallery(Product product) {
    final images = product.images.isNotEmpty ? product.images : [''];
    
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Main Image
          SizedBox(
            height: 300,
            child: images.isNotEmpty && images[selectedImageIndex].isNotEmpty
                ? Image.network(
                    images[selectedImageIndex],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 100, color: Colors.grey),
                  )
                : const Icon(Icons.image, size: 100, color: Colors.grey),
          ),
          
          // Thumbnail Strip
          if (images.length > 1)
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedImageIndex = index),
                    child: Container(
                      width: 50,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedImageIndex == index ? AppTheme.primaryColor : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 20),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmiSection(Product product) {
    final price = product.offerPrice ?? product.price;
    final emiOptions = [3, 6, 9, 12];
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.card, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text('Pay with EMI', style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(4)),
                child: const Text('0% Interest', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // EMI Duration Options
          Row(
            children: emiOptions.map((months) {
              final isSelected = selectedEmiMonths == months;
              final emi = price / months;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedEmiMonths = months),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primaryColor),
                    ),
                    child: Column(
                      children: [
                        Text('$months Mon', style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : AppTheme.primaryColor)),
                        Text('₹${emi.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppTheme.primaryColor)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Variant Selector (Sizes/Colors for clothes)
  Widget _buildVariantSelector(Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                product.variantType ?? 'Select Option',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (selectedVariant != null) ...[
                const SizedBox(width: 8),
                Text(': $selectedVariant', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w500)),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.variants.map((variant) {
              final isSelected = selectedVariant == variant;
              return GestureDetector(
                onTap: () => setState(() => selectedVariant = variant),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    variant,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Specifications Table (Material, Fabric, Care Instructions)
  Widget _buildSpecificationsSection(Product product) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Specifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...product.specifications.asMap().entries.map((entry) {
            final isEven = entry.key.isEven;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: isEven ? Colors.grey.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      entry.value.key,
                      style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: Text(entry.value.value, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Product Info (SKU, Warranty, Weight, Stock Status)
  Widget _buildProductInfoSection(Product product) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Product Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          // Stock Status
          _buildInfoRow(
            icon: product.isInStock ? Iconsax.tick_circle : Iconsax.close_circle,
            iconColor: product.isInStock ? Colors.green : Colors.red,
            label: 'Availability',
            value: product.stockLabel,
            valueColor: product.isLowStock ? Colors.orange : (product.isInStock ? Colors.green : Colors.red),
          ),
          
          // SKU
          if (product.sku != null && product.sku!.isNotEmpty)
            _buildInfoRow(icon: Iconsax.barcode, label: 'SKU', value: product.sku!),
          
          // Gender
          if (product.gender != null)
            _buildInfoRow(icon: Iconsax.user, label: 'Gender', value: product.gender!),
          
          // Warranty
          if (product.warranty != null && product.warranty!.isNotEmpty)
            _buildInfoRow(icon: Iconsax.shield_tick, label: 'Warranty', value: product.warranty!),
          
          // Weight
          if (product.weight != null && product.weight! > 0)
            _buildInfoRow(icon: Iconsax.weight, label: 'Weight', value: '${product.weight!.round()} grams'),
          
          // EMI Eligible
          if (product.emiEligible)
            _buildInfoRow(
              icon: Iconsax.card,
              iconColor: Colors.purple,
              label: 'EMI',
              value: 'Available • No Cost EMI',
              valueColor: Colors.purple,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor ?? AppTheme.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500, color: valueColor ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Tags Display
  Widget _buildTagsSection(Product product) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tags', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                final cart = context.read<CartProvider>();
                cart.addItem(product, emiMonths: selectedEmiMonths);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Added to cart!'),
                    backgroundColor: AppTheme.primaryColor,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    action: SnackBarAction(
                      label: 'VIEW CART',
                      textColor: Colors.white,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                    ),
                  ),
                );
              },
              icon: const Icon(Iconsax.shopping_cart),
              label: const Text('Add to Cart'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                final auth = context.read<AuthProvider>();
                if (!auth.isAuthenticated) {
                  // Redirect to login first
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  return;
                }
                // Add to cart and go to checkout
                final cart = context.read<CartProvider>();
                cart.addItem(product, emiMonths: selectedEmiMonths);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
              },
              icon: const Icon(Iconsax.flash_1),
              label: const Text('Buy Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
