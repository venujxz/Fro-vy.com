import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORT

class VerificationSentScreen extends StatefulWidget {
  final String email;

  const VerificationSentScreen({super.key, required this.email});

  @override
  State<VerificationSentScreen> createState() => _VerificationSentScreenState();
}

class _VerificationSentScreenState extends State<VerificationSentScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;

      // Placeholder for redirection logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("verify_redirect".tr())),
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 120),

              // Icon
              Container(
                height: 64, width: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(Icons.mail_outline, color: green, size: 34),
              ),

              const SizedBox(height: 14),

              // Title
              Text(
                "verify_title".tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: green,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle with email
              Text(
                "${"verify_subtitle".tr()} ${widget.email}",
                style: const TextStyle(fontSize: 15, color: Color(0xFF475569)),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 18),

              // Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 10,
                      offset: Offset(0, 4),
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "verify_instruction".tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF334155),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: green),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "verify_redirect".tr(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "back".tr(),
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}