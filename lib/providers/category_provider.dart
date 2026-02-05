import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/poster.dart';
import '../services/api_service.dart';

class CategoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  List<SubCategory> _subCategories = [];
  List<SubCategory> get subCategories => _subCategories;

  List<Poster> _posters = [];
  List<Poster> get posters => _posters;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Fetch all categories - uses clothing categories + any clothing-related backend categories
  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final allCategories = await _apiService.getCategories();
      
      // Start with default clothing categories
      final clothingDefaults = Category.getDefaultClothingCategories();
      
      // Add any clothing-related categories from backend that aren't duplicates
      final backendClothingCategories = allCategories
          .where((cat) => Category.isClothingCategory(cat.name))
          .where((cat) => !clothingDefaults.any((def) => 
              def.name.toLowerCase() == cat.name.toLowerCase()))
          .toList();
      
      // Combine: defaults first, then any additional backend clothing categories
      _categories = [...clothingDefaults, ...backendClothingCategories];
    } catch (e) {
      // On error, use default clothing categories
      _categories = Category.getDefaultClothingCategories();
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch all subcategories
  Future<void> fetchSubCategories() async {
    try {
      _subCategories = await _apiService.getSubCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Fetch posters/banners
  Future<void> fetchPosters() async {
    try {
      _posters = await _apiService.getPosters();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Get subcategories for a specific category
  List<SubCategory> getSubCategoriesFor(String categoryId) {
    return _subCategories.where((sub) => sub.category?.id == categoryId).toList();
  }

  // Fetch all data at once
  Future<void> fetchAllData() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      fetchCategories(),
      fetchSubCategories(),
      fetchPosters(),
    ]);

    _isLoading = false;
    notifyListeners();
  }
}
