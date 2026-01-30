import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../cart/cart_screen.dart';
import '../auth/login_screen.dart';
import '../checkout/checkout_screen.dart';
import '../../providers/auth_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int selectedImageIndex = 0;
  int selectedEmiMonths = 3;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final hasDiscount = product.offerPrice != null && product.offerPrice! < product.price;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(icon: const Icon(Iconsax.share), onPressed: () {}),
          IconButton(icon: const Icon(Iconsax.heart), onPressed: () {}),
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
                  const SizedBox(height: 16),
                  
                  // EMI Options
                  _buildEmiSection(product),
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
              Icon(Icons.credit_card, color: AppTheme.primaryColor, size: 20),
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
