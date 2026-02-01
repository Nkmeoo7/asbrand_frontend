import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../core/constants.dart';
import 'api_service.dart';

class PaymentService {
  final ApiService _apiService = ApiService();
  late Razorpay _razorpay;

  late Function(String orderId) _onSuccess;
  late Function(String error) _onError;

  late String _dbOrderId; // 🔥 MongoDB order ID

  PaymentService() {
    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleWallet);
    }
  }

  void dispose() {
    if (!kIsWeb) {
      _razorpay.clear();
    }
  }

  // ===========================================================================
  // INITIATE PAYMENT
  // ===========================================================================
  Future<void> initiatePayment({
    required BuildContext context,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod, // "online" or "cod"
    String? couponCode,
    required Function(String orderId) onSuccess,
    required Function(String error) onError,
  }) async {
    if (kIsWeb) {
      onError('Online payment is not supported on web');
      return;
    }

    try {
      _onSuccess = onSuccess;
      _onError = onError;

      final response = await _apiService.post(
        ApiConstants.initiateOrder,
        {
          'items': items,
          'shippingAddress': shippingAddress,
          'paymentMethod': paymentMethod,
          'couponCode': couponCode,
        },
      );

      if (response['success'] != true) {
        onError(response['message'] ?? 'Payment initiation failed');
        return;
      }

      final data = response['data'];

      // 🔥 Save DB order ID (IMPORTANT)
      _dbOrderId = data['orderId'];

      final options = {
        'key': data['razorpayKeyId'],
        'order_id': data['razorpayOrderId'],
        'amount': (data['amount'] * 100).toInt(),
        'currency': data['currency'],
        'name': data['name'],
        'description': data['description'],
        'prefill': {
          'contact': shippingAddress['phone'],
          'email': shippingAddress['email'],
        },
        'theme': {'color': '#667EEA'},
      };

      _razorpay.open(options);
    } catch (e, stack) {
      debugPrint('PAYMENT INIT ERROR: $e');
      debugPrint(stack.toString());
      onError('Unable to start payment. Check backend connection.');
    }
  }

  // ===========================================================================
  // PAYMENT SUCCESS → VERIFY
  // ===========================================================================
  void _handleSuccess(PaymentSuccessResponse response) async {
    try {
      final verifyResponse = await _apiService.post(
        ApiConstants.verifyPayment,
        {
          'orderId': _dbOrderId, // ✅ MongoDB ID
          'razorpay_order_id': response.orderId,
          'razorpay_payment_id': response.paymentId,
          'razorpay_signature': response.signature,
        },
      );

      if (verifyResponse['success'] == true) {
        _onSuccess(_dbOrderId);
      } else {
        _onError('Payment verification failed');
      }
    } catch (e) {
      _onError('Payment verification error');
    }
  }

  void _handleError(PaymentFailureResponse response) {
    _onError(response.message ?? 'Payment failed');
  }

  void _handleWallet(ExternalWalletResponse response) {
    _onError('Payment cancelled (${response.walletName})');
  }

  // ===========================================================================
  // CASH ON DELIVERY
  // ===========================================================================
  Future<void> placeCodOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shippingAddress,
    String? couponCode,
    required Function(String orderId) onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.cod,
        {
          'items': items,
          'shippingAddress': shippingAddress,
          'couponCode': couponCode,
        },
      );

      if (response['success'] == true) {
        onSuccess(response['data']['orderId']);
      } else {
        onError(response['message'] ?? 'COD order failed');
      }
    } catch (e) {
      onError('COD order failed');
    }
  }
}
