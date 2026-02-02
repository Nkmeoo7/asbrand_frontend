import 'package:flutter/material.dart';
import '../models/product.dart';

/// Manages wishlist state - stores favorited products
class WishlistProvider extends ChangeNotifier {
  final List<Product> _items = [];

  /// Get all wishlist items
  List<Product> get items => List.unmodifiable(_items);

  /// Get count of items in wishlist
  int get itemCount => _items.length;

  /// Check if a product is in wishlist
  bool isInWishlist(String productId) {
    return _items.any((p) => p.id == productId);
  }

  /// Add product to wishlist
  void addToWishlist(Product product) {
    if (!isInWishlist(product.id)) {
      _items.add(product);
      notifyListeners();
    }
  }

  /// Remove product from wishlist
  void removeFromWishlist(String productId) {
    _items.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  /// Toggle product in wishlist
  bool toggleWishlist(Product product) {
    if (isInWishlist(product.id)) {
      removeFromWishlist(product.id);
      return false;
    } else {
      addToWishlist(product);
      return true;
    }
  }

  /// Clear all items from wishlist
  void clearWishlist() {
    _items.clear();
    notifyListeners();
  }
}
