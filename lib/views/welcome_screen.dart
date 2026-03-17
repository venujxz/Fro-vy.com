import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'login_step1_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final List<CameraDescription>? cameras;

  const WelcomeScreen({super.key, this.cameras});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1F1F1F), const Color(0xFF121212)]
                : [const Color(0xFF4CAF50), const Color(0xFFF4E04D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),

              // Logo Card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2C2C2C).withOpacity(0.9)
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Text(
                  "FRO-VY",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),

              Column(
                children: [
                  Text(
                    "welcome_tagline".tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "welcome_description".tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),

              // Get Started Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  foregroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginStep1Screen(cameras: cameras),
                    ),
                  );
                },
                child: Text(
                  "get_started".tr(),
                  style: const TextStyle(fontSize: 18),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  "copyright".tr(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
