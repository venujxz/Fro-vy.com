import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../util/app_colors.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

/// Shown after registration.
/// Polls Firebase every 3 seconds to detect when the user clicks the
/// verification link in their email, then automatically navigates to HomeScreen.
class VerificationSentScreen extends StatefulWidget {
  final String email;
  final List<CameraDescription>? cameras;

  const VerificationSentScreen({
    super.key,
    required this.email,
    this.cameras,
  });

  @override
  State<VerificationSentScreen> createState() =>
      _VerificationSentScreenState();
}

class _VerificationSentScreenState extends State<VerificationSentScreen> {
  Timer? _pollTimer;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  // ── Poll for email verification every 3 seconds ───────────────────────────

  void _startPolling() {
    _pollTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      // Reload the Firebase user to get the latest emailVerified status
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        timer.cancel();
        if (!mounted) return;
        _navigateToHome();
      }
    });
  }

  void _navigateToHome() {
    List<CameraDescription> cameras = widget.cameras ?? [];
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => HomeScreen(cameras: cameras),
      ),
      (route) => false,
    );
  }

  // ── Resend verification email ─────────────────────────────────────────────

  Future<void> _resendEmail() async {
    setState(() => _resending = true);
    final success = await AuthService().resendVerificationEmail();
    if (!mounted) return;
    setState(() => _resending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Verification email resent to ${widget.email}'
            : 'Failed to resend. Please try again.'),
        backgroundColor:
            success ? AppColors.frovyGreen : AppColors.frovyRed,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : Colors.white;
    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final subtitleColor =
        isDark ? AppColors.darkSubtitle : const Color(0xFF475569);
    final cardBorder =
        isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final bodyTextColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 100),

              // ── Icon ──────────────────────────────────────────────
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(Icons.mail_outline,
                    color: AppColors.frovyGreen, size: 34),
              ),
              const SizedBox(height: 14),

              // ── Title ─────────────────────────────────────────────
              Text(
                "verification_sent".tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.frovyGreen,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // ── Subtitle ──────────────────────────────────────────
              Text(
                "verification_link_sent"
                    .tr(namedArgs: {'email': widget.email}),
                style:
                    TextStyle(fontSize: 15, color: subtitleColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              // ── Info card ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder),
                  boxShadow: isDark
                      ? []
                      : const [
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
                      "check_email_instructions".tr(),
                      style: TextStyle(
                        height: 1.4,
                        color: bodyTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),

                    // Auto-redirect spinner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.frovyGreen,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Waiting for verification…",
                          style: TextStyle(
                            fontSize: 13,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Resend button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "didnt_receive".tr(),
                          style:
                              TextStyle(color: subtitleColor),
                        ),
                        TextButton(
                          onPressed: _resending ? null : _resendEmail,
                          child: _resending
                              ? const SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.frovyGreen,
                                  ),
                                )
                              : Text(
                                  "resend".tr(),
                                  style: const TextStyle(
                                    color: AppColors.frovyGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Manual "I've verified" skip button
              ElevatedButton(
                onPressed: () async {
                  final verified =
                      await AuthService().isEmailVerified();
                  if (!mounted) return;
                  if (verified) {
                    _navigateToHome();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Email not verified yet. Please click the link in your inbox.'),
                        backgroundColor: AppColors.frovyAmber,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.fromLTRB(
                            16, 0, 16, 16),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.frovyGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 12),
                ),
                child: const Text("I've Verified — Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}