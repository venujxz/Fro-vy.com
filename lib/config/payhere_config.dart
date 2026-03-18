class PayHereConfig {
  // Merchant ID from PayHere dashboard
  static const String merchantId = '1234576';

  // REMOVED merchantSecret - it is now ONLY safely stored in the backend .env file!

  // Backend server URL for hash generation
  static const String backendUrl = 'https://glowfly-cercarial-yetta.ngrok-free.dev';

  // Use sandbox for testing, set to false for production
  static const bool isSandbox = true;

  // Product/plan configurations
  static const Map<String, PlanConfig> plans = {
    'Pro': PlanConfig(
      itemId: 'frovy_pro_monthly',
      itemName: 'Fro-vy Pro Plan',
      amount: 2.99,  
      amountLKR: 900.00,  
      currency: 'LKR',  
    ),
    'Premium': PlanConfig(
      itemId: 'frovy_premium_monthly',
      itemName: 'Fro-vy Premium Plan',
      amount: 6.99,  
      amountLKR: 2100.00,  
      currency: 'LKR',
    ),
  };

  static String get notifyUrl => '$backendUrl/payhere/notify';
  static const String returnUrl = 'frovy://payment/return';
  static const String cancelUrl = 'frovy://payment/cancel';
}

class PlanConfig {
  final String itemId;
  final String itemName;
  final double amount;      
  final double amountLKR;   
  final String currency;

  const PlanConfig({
    required this.itemId,
    required this.itemName,
    required this.amount,
    required this.amountLKR,
    required this.currency,
  });
}