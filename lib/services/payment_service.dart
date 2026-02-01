import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'api_service.dart';

/// PaymentService - Handles Razorpay payment flow
/// 
/// Usage:
/// ```dart
/// final paymentService = PaymentService();
/// paymentService.initiatePayment(
///   context: context,
///   items: cartItems,
///   shippingAddress: address,
///   onSuccess: (orderId) => navigate to success,
///   onError: (error) => show error,
/// );
/// ```
class PaymentService {
  late Razorpay _razorpay;
  final ApiService _apiService = ApiService();
  
  String? _currentOrderId;
  String? _razorpayOrderId;
  Function(String orderId)? _onPaymentSuccess;
  Function(String error)? _onPaymentError;
  BuildContext? _context;

  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Dispose razorpay instance
  void dispose() {
    _razorpay.clear();
  }

  /// Initiate payment flow
  /// 1. Call backend to create order + razorpay order
  /// 2. Open Razorpay checkout
  /// 3. Handle success/failure
  Future<void> initiatePayment({
    required BuildContext context,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
    String? couponCode,
    required Function(String orderId) onSuccess,
    required Function(String error) onError,
  }) async {
    _context = context;
    _onPaymentSuccess = onSuccess;
    _onPaymentError = onError;

    try {
      // Step 1: Call backend to initiate order
      final response = await _apiService.post('/payment/initiate', {
        'items': items,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        'couponCode': couponCode,
      });

      if (response['success'] != true) {
        onError(response['message'] ?? 'Failed to initiate payment');
        return;
      }

      final data = response['data'];
      _currentOrderId = data['orderId'];

      // If COD, payment is done
      if (data['paymentStatus'] == 'cod') {
        onSuccess(_currentOrderId!);
        return;
      }

      _razorpayOrderId = data['razorpayOrderId'];

      // Step 2: Open Razorpay checkout
      var options = {
        'key': data['razorpayKeyId'],
        'amount': (data['amount'] * 100).toInt(), // In paise
        'currency': data['currency'] ?? 'INR',
        'name': data['name'] ?? 'AsBrand',
        'description': data['description'] ?? 'Order Payment',
        'order_id': _razorpayOrderId,
        'prefill': {
          'contact': shippingAddress['phone'] ?? '',
          'email': '', // Add email if available
        },
        'theme': {
          'color': '#006D77', // Primary color
        },
        'modal': {
          'confirm_close': true,
          'animation': true,
        },
      };

      _razorpay.open(options);
    } catch (e) {
      onError('Payment initiation failed: $e');
    }
  }

  /// Place COD order directly
  Future<void> placeCodOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shippingAddress,
    String? couponCode,
    required Function(String orderId) onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      final response = await _apiService.post('/payment/cod', {
        'items': items,
        'shippingAddress': shippingAddress,
        'couponCode': couponCode,
      });

      if (response['success'] == true) {
        onSuccess(response['data']['orderId']);
      } else {
        onError(response['message'] ?? 'Failed to place order');
      }
    } catch (e) {
      onError('Order failed: $e');
    }
  }

  /// Handle successful payment from Razorpay
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // Step 3: Verify payment on backend
      final verifyResponse = await _apiService.post('/payment/verify', {
        'orderId': _currentOrderId,
        'razorpay_order_id': response.orderId,
        'razorpay_payment_id': response.paymentId,
        'razorpay_signature': response.signature,
      });

      if (verifyResponse['success'] == true) {
        _onPaymentSuccess?.call(_currentOrderId!);
      } else {
        _onPaymentError?.call(verifyResponse['message'] ?? 'Payment verification failed');
      }
    } catch (e) {
      _onPaymentError?.call('Verification failed: $e');
    }
  }

  /// Handle payment error from Razorpay
  void _handlePaymentError(PaymentFailureResponse response) async {
    // Record failure on backend
    try {
      await _apiService.post('/payment/failure', {
        'orderId': _currentOrderId,
        'error_code': response.code,
        'error_description': response.message,
      });
    } catch (_) {}

    String errorMessage = 'Payment failed';
    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      errorMessage = 'Payment cancelled by user';
    } else if (response.message != null) {
      errorMessage = response.message!;
    }

    _onPaymentError?.call(errorMessage);
  }

  /// Handle external wallet (like Paytm, PhonePe)
  void _handleExternalWallet(ExternalWalletResponse response) {
    // External wallet selected - payment will be processed
    debugPrint('External wallet: ${response.walletName}');
  }
}
