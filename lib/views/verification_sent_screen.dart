import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
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

    return Scaffold(
      backgroundColor: Colors.white,
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

              const Text(
                "Verification Email Sent!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: green,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                "We've sent a verification link to ${widget.email}",
                style: const TextStyle(fontSize: 15, color: Color(0xFF475569)),
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
                child: const Column(
                  children: [
                    Text(
                      "Please check your email and click the\nverification link to complete your registration.",
                      style: TextStyle(
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the email?",
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                        TextButton(
                          onPressed: null,
                          child: Text(
                            "Resend",
                            style: TextStyle(color: green),
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
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(
                        cameras: widget.cameras ?? [],
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Back",
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}