import 'package:flutter/material.dart';
import 'checkout_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // Brand Colors
  static const Color frovyGreen = Color(0xFF6AA15E);
  static const Color frovyGold = Color(0xFFFFC107);
  static const Color frovyLightBg = Color(0xFFF8F9FA);

  // State Variable to track the active plan
  String _currentPlan = "Free"; // Defaults to Free

  // Logic to handle navigation and update state
  Future<void> _handleUpgrade(String planName, String price) async {
    // Wait for the checkout screen to return a result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          planName: planName,
          price: price,
          period: "Monthly",
        ),
      ),
    );

    // If we received a result (plan name), update the state
    if (result != null && result is String) {
      setState(() {
        _currentPlan = result;
      });
    }
  }

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
          "Premium Plans",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    "Upgrade Your Health Journey",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Choose the perfect plan for your needs",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Plan Cards
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: frovyLightBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // --- FREE PLAN ---
                  _buildPlanCard(
                    context,
                    title: "Free",
                    price: "\$0",
                    period: "forever",
                    icon: Icons.star_outline,
                    iconColor: Colors.grey,
                    features: [
                      "10 scans per month",
                      "Basic ingredient analysis",
                      "Manual ingredient entry",
                    ],
                    // Logic: If _currentPlan is Free, show "Current Plan"
                    // Otherwise, allow "Downgrade" (or switch)
                    isCurrent: _currentPlan == "Free",
                    buttonText:
                        _currentPlan == "Free" ? "Current Plan" : "Downgrade",
                    onTap: () => setState(() => _currentPlan = "Free"),
                  ),

                  const SizedBox(height: 24),

                  // --- PRO PLAN ---
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildPlanCard(
                        context,
                        title: "Pro",
                        price: "\$9.99",
                        period: "per month",
                        icon: Icons.bolt,
                        iconColor: frovyGreen,
                        features: [
                          "Unlimited scans",
                          "Barcode & OCR scanning",
                          "Detailed health insights",
                        ],
                        buttonColor: frovyGreen,
                        // Logic: Check if Pro is active
                        isCurrent: _currentPlan == "Pro",
                        buttonText: _currentPlan == "Pro"
                            ? "Current Plan"
                            : "Upgrade Now",
                        onTap: () {
                          if (_currentPlan != "Pro") {
                            _handleUpgrade("Pro", "\$9.99");
                          }
                        },
                      ),
                      Positioned(
                        top: -12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF7043),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text("Most Popular",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- PREMIUM PLAN ---
                  _buildPlanCard(
                    context,
                    title: "Premium",
                    price: "\$19.99",
                    period: "per month",
                    icon: Icons.workspace_premium,
                    iconColor: frovyGold,
                    features: [
                      "Everything in Pro",
                      "AI-powered recommendations",
                      "Direct dietitian consultation",
                    ],
                    buttonColor: frovyGold,
                    textColor: Colors.black87,
                    // Logic: Check if Premium is active
                    isCurrent: _currentPlan == "Premium",
                    buttonText: _currentPlan == "Premium"
                        ? "Current Plan"
                        : "Upgrade Now",
                    onTap: () {
                      if (_currentPlan != "Premium") {
                        _handleUpgrade("Premium", "\$19.99");
                      }
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required IconData icon,
    required Color iconColor,
    required List<String> features,
    required String buttonText,
    required VoidCallback onTap,
    Color? buttonColor,
    Color textColor = Colors.white,
    required bool isCurrent,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isCurrent ? Border.all(color: frovyGreen, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(period,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
              Text(price,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: features
                .map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check, size: 16, color: frovyGreen),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(feature,
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 13))),
                        ],
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                // Grey out the button if it's the current plan
                backgroundColor: isCurrent ? Colors.grey[300] : buttonColor,
                foregroundColor: isCurrent ? Colors.black54 : textColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(buttonText,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
