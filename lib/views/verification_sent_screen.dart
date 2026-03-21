import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'home_screen.dart';

class VerificationSentScreen extends StatefulWidget {
  final String email;
  final List<CameraDescription>? cameras;

  const VerificationSentScreen({
    super.key,
    required this.email,
    this.cameras,
  });

  @override
  State<VerificationSentScreen> createState() => _VerificationSentScreenState();
}

class _VerificationSentScreenState extends State<VerificationSentScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Schedule navigation after a short delay
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      debugPrint("Timer completed. Navigating to HomeScreen...");
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            cameras: widget.cameras ?? [],
          ),
        ),
        (route) => false,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4CAF50);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final cardColor = isDark ? const Color(0xFF1F1F1F) : Colors.white;
    final subtitleColor = isDark ? Colors.grey[400]! : const Color(0xFF475569);
    final cardBorder = isDark ? Colors.grey[700]! : const Color(0xFFE2E8F0);
    final bodyTextColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 120),

              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(Icons.mail_outline, color: green, size: 34),
              ),

              const SizedBox(height: 14),

              Text(
                "verification_sent".tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: green,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                "verification_link_sent".tr(namedArgs: {'email': widget.email}),
                style: TextStyle(fontSize: 15, color: subtitleColor),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder),
                  boxShadow: [
                    if (!isDark)
                      const BoxShadow(
                        blurRadius: 10,
                        offset: Offset(0, 4),
                        color: Colors.black12,
                      ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "check_email_instructions".tr(),
                      style: TextStyle(
                        height: 1.4,
                        color: bodyTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "didnt_receive".tr(),
                          style: TextStyle(color: subtitleColor),
                        ),
                        TextButton(
                          onPressed: null,
                          child: Text(
                            "resend".tr(),
                            style: const TextStyle(color: green),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  _timer?.cancel();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(
                        cameras: widget.cameras ?? [],
                      ),
                    ),
                  );
                },
                child: Text(
                  "back".tr(),
                  style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
