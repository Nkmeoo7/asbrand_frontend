import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/poster.dart';
import '../models/order.dart';
import '../models/brand.dart';
import '../models/coupon.dart';
import '../models/emi_plan.dart';
import '../models/user_kyc.dart';
import '../models/notification.dart';

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

  // Generic DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(Uri.parse(endpoint), headers: headers);
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
    final response = await get(ApiConstants.subCategories);
    if (response['success'] == true && response['data'] != null) {
      return (response['data'] as List)
          .map((json) => SubCategory.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<List<Brand>> getBrands() async {
    final response = await get(ApiConstants.brands);
    if (response['success'] == true && response['data'] != null) {
      return (response['data'] as List)
          .map((json) => Brand.fromJson(json))
          .toList();
    }
    return [];
  }

  // ============================================================
  // POSTER ENDPOINTS
  // ============================================================

  Future<List<Poster>> getPosters() async {
    final response = await get(ApiConstants.posters);
    if (response['success'] == true && response['data'] != null) {
      return (response['data'] as List)
          .map((json) => Poster.fromJson(json))
          .toList();
    }
    return [];
  }

  // ============================================================
  // ORDER ENDPOINTS
  // ============================================================

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    return await post(ApiConstants.orders, orderData);
  }

  Future<List<Order>> getMyOrders() async {
    final response = await get('${ApiConstants.orders}/my-orders');
    if (response['success'] == true && response['data'] != null) {
      return (response['data'] as List)
          .map((json) => Order.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<Order?> getOrderById(String id) async {
    final response = await get('${ApiConstants.orders}/$id');
    if (response['success'] == true && response['data'] != null) {
      return Order.fromJson(response['data']);
    }
    return null;
  }

  // ============================================================
  // COUPON ENDPOINTS
  // ============================================================

  Future<List<Coupon>> getCoupons() async {
    final response = await get(ApiConstants.coupons);
    if (response['success'] == true && response['data'] != null) {
      return (response['data'] as List)
          .map((json) => Coupon.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> validateCoupon(String code, double cartTotal) async {
    return await post('${ApiConstants.coupons}/check-coupon', {
      'couponCode': code,
      'purchaseAmount': cartTotal,
    });
  }

  // ============================================================
  // EMI ENDPOINTS
  // ============================================================

  Future<List<EmiPlan>> getEmiPlans() async {
    final response = await get(ApiConstants.emiPlans);
    if (response['success'] == true && response['data'] != null) {
      return (response['data'] as List)
          .map((json) => EmiPlan.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> applyForEmi(String orderId, String planId, double amount) async {
    return await post(ApiConstants.emiApply, {
      'orderId': orderId,
      'emiPlanId': planId,
      'principalAmount': amount,
    });
  }

  // ============================================================
  // KYC ENDPOINTS
  // ============================================================

  Future<UserKyc?> getKycStatus() async {
    final response = await get(ApiConstants.kycStatus);
    if (response['success'] == true && response['data'] != null) {
      return UserKyc.fromJson(response['data']);
    }
    return null;
  }

  Future<Map<String, dynamic>> submitKyc(Map<String, dynamic> kycData) async {
    return await post(ApiConstants.kycSubmit, kycData);
  }

  // ============================================================
  // NOTIFICATION ENDPOINTS
  // ============================================================

  Future<List<AppNotification>> getNotifications() async {
    final response = await get(ApiConstants.notifications);
    if (response['success'] == true && response['data'] != null) {
      return (response['data'] as List)
          .map((json) => AppNotification.fromJson(json))
          .toList();
    }
    return [];
  }
}
