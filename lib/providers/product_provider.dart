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

  // Filter State
  double? _minPrice;
  double? _maxPrice;
  String? _sort; // price_asc, price_desc, newest
  String? _categoryId;
  String? _searchKeyword;
  String? _gender;
  List<String> _selectedBrands = [];
  int? _minDiscount;

  // Getters for filter state
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String? get sort => _sort;
  String? get categoryId => _categoryId;
  String? get searchKeyword => _searchKeyword;
  String? get gender => _gender;
  List<String> get selectedBrands => _selectedBrands;
  int? get minDiscount => _minDiscount;

  void setFilters({
    double? min, 
    double? max, 
    String? sortOrder, 
    String? category,
    String? gender,
    List<String>? brands,
    int? discount,
  }) {
    _minPrice = min;
    _maxPrice = max;
    if (sortOrder != null) _sort = sortOrder;
    if (category != null) _categoryId = category;
    if (gender != null) _gender = gender;
    if (brands != null) _selectedBrands = brands;
    if (discount != null) _minDiscount = discount;
    fetchProducts();
  }

  void setSearch(String query) {
    _searchKeyword = query;
    fetchProducts();
  }

  void clearFilters() {
    _minPrice = null;
    _maxPrice = null;
    _sort = null;
    _categoryId = null;
    _searchKeyword = null;
    _gender = null;
    _selectedBrands = [];
    _minDiscount = null;
    fetchProducts();
  }

  // Fetch all products
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Map<String, dynamic> params = {};
      if (_minPrice != null) params['minPrice'] = _minPrice.toString();
      if (_maxPrice != null) params['maxPrice'] = _maxPrice.toString();
      if (_sort != null) params['sort'] = _sort;
      if (_categoryId != null) params['category'] = _categoryId;
      if (_searchKeyword != null && _searchKeyword!.isNotEmpty) params['keyword'] = _searchKeyword;
      if (_gender != null) params['gender'] = _gender;
      if (_selectedBrands.isNotEmpty) params['brand'] = _selectedBrands.join(',');
      if (_minDiscount != null) params['minDiscount'] = _minDiscount.toString();

      _products = await _apiService.getProducts(params: params);
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

  /// Get similar products by category and subcategory
  /// Excludes the current product from results
  List<Product> getSimilarProducts(String? categoryId, String? subCategoryId, String excludeProductId) {
    if (categoryId == null) return [];
    
    // First try to match both category and subcategory
    var similar = _products.where((p) =>
      p.id != excludeProductId &&
      p.category?.id == categoryId &&
      (subCategoryId == null || p.subCategory?.id == subCategoryId)
    ).toList();
    
    // If not enough products, just match category
    if (similar.length < 4) {
      similar = _products.where((p) =>
        p.id != excludeProductId &&
        p.category?.id == categoryId
      ).toList();
    }
    
    return similar.take(10).toList();
  }

  /// Get frequently bought together products (simulated)
  /// Returns products from same category with similar price range
  List<Product> getFrequentlyBoughtTogether(Product product) {
    final priceRange = product.price * 0.5; // Within 50% price range
    final targetPrice = product.offerPrice ?? product.price;
    
    return _products.where((p) =>
      p.id != product.id &&
      p.category?.id == product.category?.id &&
      (p.offerPrice ?? p.price) >= targetPrice - priceRange &&
      (p.offerPrice ?? p.price) <= targetPrice + priceRange
    ).take(4).toList();
  }
}
