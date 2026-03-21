import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../util/app_colors.dart';
import '../services/payment_service.dart';
import '../services/prefs_service.dart';

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
  final Color frovyGreen = AppColors.frovyGreen;
  final Color frovyLightBg = AppColors.frovyLightBg;

  bool _isProcessing = false;

  Future<void> _processPayment() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    // Show processing message
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("processing_payment".tr())),
    );

    // Get customer info from prefs
    final userEmail = await PrefsService.getUserEmail();
    final userProfile = await PrefsService.getUserProfile();

    // Process the payment via PayHere
    final result = await PaymentService.createSubscription(
      planName: widget.planName,
      customerEmail: userEmail ?? 'customer@example.com',
      customerName: userProfile.name,
      customerPhone: userProfile.phone,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    // Clear any existing snackbar
    ScaffoldMessenger.of(context).clearSnackBars();

    switch (result.status) {
      case PaymentStatus.success:
        // Save payment ID if returned
        if (result.paymentId != null) {
          await PrefsService.setSubscriptionId(result.paymentId!);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("welcome_premium".tr()),
            backgroundColor: frovyGreen,
          ),
        );
        // Send the plan name back to the previous screen
        Navigator.pop(context, widget.planName);
        break;

      case PaymentStatus.cancelled:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("payment_cancelled".tr()),
            backgroundColor: Colors.orange,
          ),
        );
        break;

      case PaymentStatus.failed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? "payment_failed".tr()),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? null : frovyGreen,
      appBar: AppBar(
        backgroundColor: isDark ? null : frovyGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
        ),
        title: Text(
          'checkout'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [],
      ),
      body: Column(
        children: [
          // 1. Header Area
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  "complete_purchase".tr(),
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "review_plan_payment".tr(),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
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
                color: isDark ? const Color(0xFF1A1A1A) : frovyLightBg,
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
                        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("order_summary".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Divider(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Fro-vy ${widget.planName}", style: const TextStyle(fontSize: 16)),
                              Text(widget.price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text("${"billed".tr()} ${widget.period}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          const Divider(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("total_today".tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(widget.price, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: frovyGreen)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Payment Info Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock, color: frovyGreen, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "secure_payment_payhere".tr(),
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Pay Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: frovyGreen,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: frovyGreen.withValues(alpha: 0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "${"pay".tr()} ${widget.price}",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        "cancel_anytime".tr(),
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
}
