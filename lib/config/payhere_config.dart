/// PayHere configuration for Sri Lanka
///
/// IMPORTANT: Replace these with your actual PayHere credentials
/// Get your credentials from https://sandbox.payhere.lk (sandbox) or https://www.payhere.lk (production)
class PayHereConfig {
  // Merchant ID from PayHere dashboard
  static const String merchantId = '4OVybuzvTQe4JH5Ex67puH3Tc';

  // Merchant Secret (keep this private - only use on backend for hash generation)
  static const String merchantSecret = '4Pb1UIhvL9x4PVs5GrfKJp8MSO9yeeayS4kmeNRrDwna';

  // Backend server URL for hash generation
  // Use localhost for emulator, or your computer's IP for real device testing
  // To find your IP: run `ipconfig getifaddr en0` on Mac
  static const String backendUrl = 'http://192.168.1.40:3000';

  // Use sandbox for testing, set to false for production
  static const bool isSandbox = true;

  // Product/plan configurations
  static const Map<String, PlanConfig> plans = {
    'Pro': PlanConfig(
      itemId: 'frovy_pro_monthly',
      itemName: 'Fro-vy Pro Plan',
      amount: 2.99,  // USD price
      amountLKR: 900.00,  // Approximate LKR price
      currency: 'LKR',  // PayHere primarily uses LKR
    ),
    'Premium': PlanConfig(
      itemId: 'frovy_premium_monthly',
      itemName: 'Fro-vy Premium Plan',
      amount: 6.99,  // USD price
      amountLKR: 2100.00,  // Approximate LKR price
      currency: 'LKR',
    ),
  };

  // Notification URL for payment status updates (your backend endpoint)
  static String get notifyUrl => '$backendUrl/payhere/notify';

  // Return URL after payment (deep link back to app)
  static const String returnUrl = 'frovy://payment/return';

  // Cancel URL if user cancels payment
  static const String cancelUrl = 'frovy://payment/cancel';
}

class PlanConfig {
  final String itemId;
  final String itemName;
  final double amount;      // Price in USD (for display)
  final double amountLKR;   // Price in LKR (for payment)
  final String currency;

  const PlanConfig({
    required this.itemId,
    required this.itemName,
    required this.amount,
    required this.amountLKR,
    required this.currency,
  });
}
