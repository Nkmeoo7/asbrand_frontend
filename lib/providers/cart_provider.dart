import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

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

  CartProvider() {
    _loadFromStorage();
  }

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount => _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addItem(Product product, {int emiMonths = 3}) {
    // Check if product already in cart
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product, emiMonths: emiMonths));
    }
    _saveToStorage();
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    _saveToStorage();
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
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
