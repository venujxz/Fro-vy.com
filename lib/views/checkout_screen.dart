import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final String planName;
  final String price;
  final String period;

  const CheckoutScreen({
    super.key,
    required this.planName,
    required this.price,
    required this.period,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Brand Colors
  final Color frovyGreen = const Color(0xFF6AA15E);
  final Color frovyLightBg = const Color(0xFFF8F9FA);

  int _selectedPaymentMethod = 0; // 0 = Card, 1 = PayPal, 2 = Apple Pay

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: frovyGreen,
      appBar: AppBar(
        backgroundColor: frovyGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Checkout",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // 1. Header Area
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            width: double.infinity,
            child: const Column(
              children: [
                Text(
                  "Complete Purchase",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Review your plan and select a payment method",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // 2. White Content Container
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: frovyLightBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Order Summary",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const Divider(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Fro-vy ${widget.planName}",
                                  style: const TextStyle(fontSize: 16)),
                              Text(widget.price,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text("Billed ${widget.period}",
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12)),
                          const Divider(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total Today",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text(widget.price,
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: frovyGreen)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Payment Method Section
                    const Text("Payment Method",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),

                    _buildPaymentOption(
                        0, "Credit / Debit Card", Icons.credit_card),
                    _buildPaymentOption(1, "PayPal",
                        Icons.payment), // Using generic icon for PayPal
                    _buildPaymentOption(2, "Apple Pay", Icons.phone_iphone),

                    const SizedBox(height: 40),

                    // Pay Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // Mock Payment Processing
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Processing Payment... (Mock)")),
                          );

                          // Simulate network delay
                          Future.delayed(const Duration(seconds: 2), () {
                            if (!mounted) return;
                            // 1. Send the plan name back to the previous screen
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context, widget.planName);

                            // 2. Show Success Message
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Welcome to Premium!")),
                            );
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: frovyGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Pay ${widget.price}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        "Cancel Anytime. Secure Payment.",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(int index, String title, IconData icon) {
    bool isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? frovyGreen : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? frovyGreen : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: frovyGreen, size: 20),
          ],
        ),
      ),
    );
  }
}
