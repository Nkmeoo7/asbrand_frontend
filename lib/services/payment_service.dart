import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'api_service.dart';

/// PaymentService - Handles payment flow
/// COD works everywhere. Online payments only on mobile.
class PaymentService {
  final ApiService _apiService = ApiService();

  void dispose() {
    // No-op for web
  }

  /// Initiate payment - for online payments (mobile only)
  Future<void> initiatePayment({
    required BuildContext context,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
    String? couponCode,
    required Function(String orderId) onSuccess,
    required Function(String error) onError,
  }) async {
    // Web doesn't support Razorpay
    if (kIsWeb) {
      onError('Online payment is only available on mobile app.\n\nPlease select "Cash on Delivery" to place your order.');
      return;
    }

    // For mobile, we would call Razorpay here
    // But since we're testing on web, just show the message
    onError('Razorpay integration requires running on Android/iOS device.');
  }

  /// Place COD order directly (works on ALL platforms including web)
  Future<void> placeCodOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shippingAddress,
    String? couponCode,
    required Function(String orderId) onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      final response = await _apiService.post('${ApiConstants.payment}/cod', {
        'items': items,
        'shippingAddress': shippingAddress,
        'couponCode': couponCode,
      });

      if (response['success'] == true) {
        final orderId = response['data']['orderId'];
        onSuccess(orderId.toString());
      } else {
        onError(response['message'] ?? 'Failed to place order');
      }
    } catch (e) {
      onError('Order failed: $e');
    }
  }
}
