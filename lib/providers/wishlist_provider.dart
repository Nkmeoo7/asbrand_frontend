import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

/// Manages wishlist state - stores favorited products with persistence
class WishlistProvider extends ChangeNotifier {
  static const String _storageKey = 'wishlist_items';
  final List<Product> _items = [];
  bool _isLoaded = false;

  WishlistProvider() {
    _loadFromStorage();
  }

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
      _saveToStorage();
      notifyListeners();
    }
  }

  /// Remove product from wishlist
  void removeFromWishlist(String productId) {
    _items.removeWhere((p) => p.id == productId);
    _saveToStorage();
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
    _saveToStorage();
    notifyListeners();
  }

  /// Load wishlist from SharedPreferences
  Future<void> _loadFromStorage() async {
    if (_isLoaded) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _items.clear();
        for (var item in jsonList) {
          _items.add(Product.fromJson(item));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    }
    
    _isLoaded = true;
  }

  /// Save wishlist to SharedPreferences
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = _items.map((p) => p.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving wishlist: $e');
    }
  }
}
