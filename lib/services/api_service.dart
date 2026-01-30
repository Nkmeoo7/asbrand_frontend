import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/poster.dart';

class ApiService {
  final _storage = const FlutterSecureStorage();

  // Helper to get headers with token
  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Generic GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(endpoint), headers: headers);
      return _processResponse(response);
    } catch (e) {
      throw Exception('Connection Error: $e');
    }
  }

  // Generic POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Connection Error: $e');
    }
  }

  // Generic PUT request
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Connection Error: $e');
    }
  }

  // Helper to process response
  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      String message = 'Unknown Error';
      try {
        final body = jsonDecode(response.body);
        message = body['message'] ?? response.reasonPhrase;
      } catch (_) {
        message = response.reasonPhrase ?? 'Error ${response.statusCode}';
      }
      throw Exception(message);
    }
  }

  // ============================================================
  // PRODUCT ENDPOINTS
  // ============================================================

  Future<List<Product>> getProducts() async {
    final response = await get(ApiConstants.products);
    if (response['success'] == true && response['data'] != null) {
      return (response['data'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<Product?> getProductById(String id) async {
    final response = await get('${ApiConstants.products}/$id');
    if (response['success'] == true && response['data'] != null) {
      return Product.fromJson(response['data']);
    }
    return null;
  }

  // ============================================================
  // CATEGORY ENDPOINTS
  // ============================================================

  Future<List<Category>> getCategories() async {
    final response = await get(ApiConstants.categories);
    if (response['success'] == true && response['data'] != null) {
      return (response['data'] as List)
          .map((json) => Category.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<List<SubCategory>> getSubCategories() async {
    final response = await get('${ApiConstants.baseUrl}/subCategories');
    if (response['success'] == true && response['data'] != null) {
      return (response['data'] as List)
          .map((json) => SubCategory.fromJson(json))
          .toList();
    }
    return [];
  }

  // ============================================================
  // POSTER ENDPOINTS
  // ============================================================

  Future<List<Poster>> getPosters() async {
    final response = await get('${ApiConstants.baseUrl}/posters');
    if (response['success'] == true && response['data'] != null) {
      return (response['data'] as List)
          .map((json) => Poster.fromJson(json))
          .toList();
    }
    return [];
  }

  // ============================================================
  // AUTH ENDPOINTS
  // ============================================================

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await post(ApiConstants.login, {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    return await post(ApiConstants.register, {'name': name, 'email': email, 'password': password});
  }

  // ============================================================
  // ORDER ENDPOINTS
  // ============================================================

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    return await post(ApiConstants.orders, orderData);
  }
}
