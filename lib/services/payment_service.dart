import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import 'package:http/http.dart' as http;
import '../config/payhere_config.dart';

/// Payment result status
enum PaymentStatus {
  success,
  cancelled,
  failed,
}

/// Result of a payment attempt
class PaymentResult {
  final PaymentStatus status;
  final String? errorMessage;
  final String? paymentId;
  final String? orderId;

  PaymentResult({
    required this.status,
    this.errorMessage,
    this.paymentId,
    this.orderId,
  });

  bool get isSuccess => status == PaymentStatus.success;
}

/// Service for handling PayHere payments in Sri Lanka
class PaymentService {
  /// Initialize payment service
  static Future<void> initialize() async {
    // PayHere SDK doesn't require explicit initialization
    debugPrint('PayHere Payment Service initialized');
  }

  /// Create a one-time payment for subscription
  static Future<PaymentResult> createSubscription({
    required String planName,
    required String customerEmail,
    String? customerName,
    String? customerPhone,
  }) async {
    try {
      final planConfig = PayHereConfig.plans[planName];
      if (planConfig == null) {
        return PaymentResult(
          status: PaymentStatus.failed,
          errorMessage: 'Invalid plan: $planName',
        );
      }

      // Generate unique order ID
      final orderId = 'FROVY_${DateTime.now().millisecondsSinceEpoch}';

      // Get hash from backend (required for security)
      final hashResponse = await _generateHash(
        orderId: orderId,
        amount: planConfig.amountLKR,
        currency: planConfig.currency,
      );

      if (hashResponse == null) {
        return PaymentResult(
          status: PaymentStatus.failed,
          errorMessage: 'Failed to generate payment hash. Is the backend running?',
        );
      }

      // Prepare customer name
      final name = customerName ?? 'Customer';
      final nameParts = name.split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Create payment request map
      Map paymentObject = {
        "sandbox": PayHereConfig.isSandbox,
        "merchant_id": PayHereConfig.merchantId,
        "notify_url": PayHereConfig.notifyUrl,
        "order_id": orderId,
        "items": planConfig.itemName,
        "amount": planConfig.amountLKR.toStringAsFixed(2),
        "currency": planConfig.currency,
        "first_name": firstName,
        "last_name": lastName,
        "email": customerEmail,
        "phone": customerPhone ?? "",
        "address": "",
        "city": "",
        "country": "Sri Lanka",
        "custom_1": planName,
        "custom_2": "",
        "hash": hashResponse['hash'],
      };

      // Start payment
      final completer = Completer<PaymentResult>();

      PayHere.startPayment(
        paymentObject,
        (paymentId) {
          // Payment successful
          debugPrint('PayHere payment successful. Payment ID: $paymentId');
          completer.complete(PaymentResult(
            status: PaymentStatus.success,
            paymentId: paymentId,
            orderId: orderId,
          ));
        },
        (error) {
          // Payment failed
          debugPrint('PayHere payment failed: $error');
          completer.complete(PaymentResult(
            status: PaymentStatus.failed,
            errorMessage: error,
          ));
        },
        () {
          // Payment cancelled
          debugPrint('PayHere payment cancelled by user');
          completer.complete(PaymentResult(
            status: PaymentStatus.cancelled,
            errorMessage: 'Payment was cancelled',
          ));
        },
      );

      return completer.future;

    } catch (e) {
      debugPrint('Payment error: $e');
      return PaymentResult(
        status: PaymentStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  /// Generate payment hash on backend (required for security)
  static Future<Map<String, dynamic>?> _generateHash({
    required String orderId,
    required double amount,
    required String currency,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${PayHereConfig.backendUrl}/payhere/generate-hash'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'amount': amount.toStringAsFixed(2),
          'currency': currency,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      debugPrint('Hash generation failed: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Error generating hash: $e');
      return null;
    }
  }

  /// Verify payment status with backend
  static Future<bool> verifyPayment(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('${PayHereConfig.backendUrl}/payhere/verify/$orderId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['verified'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      return false;
    }
  }
}
