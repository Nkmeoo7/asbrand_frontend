import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../core/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages wishlist state - stores favorited products with persistence
class WishlistProvider extends ChangeNotifier {
  static const String _storageKey = 'wishlist_items';
  final List<Product> _items = [];
  bool _isLoaded = false;

  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  WishlistProvider() {
    _loadFromStorage().then((_) => syncWithBackend());
  }

  /// Check if user is logged in
  Future<bool> get _isLoggedIn async {
    String? token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  /// Initial backend sync
  Future<void> syncWithBackend() async {
    if (await _isLoggedIn) {
      // If we have local items, sync them to backend first
      for (var item in _items) {
         try {
           await _apiService.post('${ApiConstants.wishlist}/add', {'productId': item.id});
         } catch (_) {}
      }
      
      // Then fetch latest from backend
      await fetchWishlistFromBackend();
    }
  }

  /// Fetch wishlist from backend
  Future<void> fetchWishlistFromBackend() async {
    if (!(await _isLoggedIn)) return;

    try {
      final response = await _apiService.get(ApiConstants.wishlist);
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final List<dynamic> products = data['products'] ?? [];
        
        _items.clear();
        for (var item in products) {
           _items.add(Product.fromJson(item));
        }
        _saveToStorage();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching wishlist: $e');
    }
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
  Future<void> addToWishlist(Product product) async {
    if (!isInWishlist(product.id)) {
      _items.add(product);
      _saveToStorage();
      notifyListeners();

      // Sync with backend
      if (await _isLoggedIn) {
        try {
          await _apiService.post('${ApiConstants.wishlist}/add', {
            'productId': product.id
          });
        } catch (e) {
          debugPrint('Error adding to backend wishlist: $e');
        }
      }
    }
  }

  /// Remove product from wishlist
  Future<void> removeFromWishlist(String productId) async {
    _items.removeWhere((p) => p.id == productId);
    _saveToStorage();
    notifyListeners();

    // Sync with backend
    if (await _isLoggedIn) {
      try {
        await _apiService.delete('${ApiConstants.wishlist}/remove/$productId');
      } catch (e) {
        debugPrint('Error removing from backend wishlist: $e');
      }
    }
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
