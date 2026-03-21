// Payment processing is not yet active.
// PayHere integration will be enabled in a future release.
// This stub keeps the rest of the codebase compiling cleanly.

enum PaymentStatus { success, cancelled, failed }

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

class PaymentService {
  static Future<void> initialize() async {}

  static Future<PaymentResult> createSubscription({
    required String planName,
    required String customerEmail,
    String? customerName,
    String? customerPhone,
  }) async {
    // Payments are not yet active — return a stub result.
    return PaymentResult(
      status: PaymentStatus.failed,
      errorMessage: 'Payments coming soon.',
    );
  }

  static Future<bool> verifyPayment(String orderId) async => false;
}
