import 'dart:async';
import 'package:flutter/material.dart';

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

    // Auto redirect after a short delay
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      // TODO: Replace this with your real dashboard screen
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));

      // For now: just go back to first screen OR show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Redirect (connect to Dashboard later)")),
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
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(Icons.mail_outline, color: green, size: 34),
              ),

              const SizedBox(height: 14),

              // Title
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

              // Subtitle with email
              Text(
                "We've sent a verification link to ${widget.email}",
                style: const TextStyle(fontSize: 15, color: Color(0xFF475569)),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 18),

              // Card
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
                child: Column(
                  children: [
                    const Text(
                      "Please check your email and click the\nverification link to complete your registration.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF334155),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Redirecting you to the dashboard...",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Optional button (helpful while dashboard isn't ready)
              TextButton(
                onPressed: () => Navigator.pop(context),
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
