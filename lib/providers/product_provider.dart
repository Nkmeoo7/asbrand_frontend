import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _products = [];
  List<Product> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Fetch all products
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _apiService.getProducts();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get products by category
  List<Product> getProductsByCategory(String categoryId) {
    return _products.where((p) => p.category?.id == categoryId).toList();
  }

  // Get best sellers (products with highest discount)
  List<Product> get bestSellers {
    final sorted = [..._products];
    sorted.sort((a, b) => b.discountPercentage.compareTo(a.discountPercentage));
    return sorted.take(10).toList();
  }

  // Get deals (products with offer price)
  List<Product> get deals {
    return _products.where((p) => p.offerPrice != null && p.offerPrice! < p.price).toList();
  }
}
