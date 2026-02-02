import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../core/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CartItem {
  final Product product;
  int quantity;
  int emiMonths;

  CartItem({required this.product, this.quantity = 1, this.emiMonths = 3});

  double get totalPrice => (product.offerPrice ?? product.price) * quantity;
  double get emiPerMonth => totalPrice / emiMonths;

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'emiMonths': emiMonths,
  };

  /// Create from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product: Product.fromJson(json['product']),
    quantity: json['quantity'] ?? 1,
    emiMonths: json['emiMonths'] ?? 3,
  );
}

class CartProvider extends ChangeNotifier {
  static const String _storageKey = 'cart_items';
  final List<CartItem> _items = [];
  bool _isLoaded = false;

  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  CartProvider() {
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
      if (_items.isNotEmpty) {
        await _syncLocalToBackend();
      }
      // Then fetch latest from backend
      await fetchCartFromBackend();
    }
  }

  /// Fetch cart from backend
  Future<void> fetchCartFromBackend() async {
    if (!(await _isLoggedIn)) return;

    try {
      final response = await _apiService.get(ApiConstants.cart);
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final List<dynamic> items = data['items'] ?? [];
        
        _items.clear();
        for (var item in items) {
          if (item['product'] != null) {
            final product = Product.fromJson(item['product']);
            _items.add(CartItem(
              product: product,
              quantity: item['quantity'] ?? 1,
              emiMonths: item['emiMonths'] ?? 3
            ));
          }
        }
        _saveToStorage();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching cart: $e');
    }
  }

  /// Sync local items to backend (e.g. after login)
  Future<void> _syncLocalToBackend() async {
    try {
      final itemsData = _items.map((item) => {
        'productId': item.product.id,
        'quantity': item.quantity,
        'emiMonths': item.emiMonths
      }).toList();
      
      await _apiService.post('${ApiConstants.cart}/sync', {'items': itemsData});
    } catch (e) {
      debugPrint('Error syncing cart: $e');
    }
  }

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount => _items.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> addItem(Product product, {int emiMonths = 3}) async {
    // Check if product already in cart
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product, emiMonths: emiMonths));
    }
    _saveToStorage();
    notifyListeners();

    // Sync with backend
    if (await _isLoggedIn) {
      try {
        await _apiService.post('${ApiConstants.cart}/add', {
          'productId': product.id,
          'quantity': 1,
          'emiMonths': emiMonths
        });
      } catch (e) {
        debugPrint('Error adding to backend cart: $e');
      }
    }
  }

  Future<void> removeItem(String productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    _saveToStorage();
    notifyListeners();

    // Sync with backend
    if (await _isLoggedIn) {
      try {
        await _apiService.delete('${ApiConstants.cart}/remove/$productId');
      } catch (e) {
        debugPrint('Error removing from backend cart: $e');
      }
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
        // Remove from backend too
        if (await _isLoggedIn) {
           try {
             await _apiService.delete('${ApiConstants.cart}/remove/$productId');
           } catch (e) { debugPrint('Error removing: $e'); }
        }
      } else {
        _items[index].quantity = quantity;
        
        // Update backend
        if (await _isLoggedIn) {
          try {
            await _apiService.put('${ApiConstants.cart}/update', {
              'productId': productId,
              'quantity': quantity
            });
          } catch (e) {
             debugPrint('Error updating quantity: $e');
          }
        }
      }
      _saveToStorage();
      notifyListeners();
    }
  }

  void updateEmiMonths(String productId, int months) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].emiMonths = months;
      _saveToStorage();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _saveToStorage();
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  /// Load cart from SharedPreferences
  Future<void> _loadFromStorage() async {
    if (_isLoaded) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _items.clear();
        for (var item in jsonList) {
          _items.add(CartItem.fromJson(item));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
    
    _isLoaded = true;
  }

  /// Save cart to SharedPreferences
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = _items.map((item) => item.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }
}
