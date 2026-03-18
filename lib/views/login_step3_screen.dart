import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'verification_sent_screen.dart';
import '../services/prefs_service.dart';
import '../models/user_profile.dart';
import '../models/health_profile.dart';

class LoginStep3Screen extends StatefulWidget {
  final String email;
  final String name;
  final String dob;
  final List<String> allergies;
  final String medicalConditions;
  final String otherSensitivities;
  final List<CameraDescription>? cameras;

  const LoginStep3Screen({
    super.key,
    required this.email,
    required this.name,
    required this.dob,
    required this.allergies,
    required this.medicalConditions,
    required this.otherSensitivities,
    this.cameras,
  });

  @override
  State<LoginStep3Screen> createState() => _LoginStep3ScreenState();
}

class _LoginStep3ScreenState extends State<LoginStep3Screen> {
  final _formKey = GlobalKey<FormState>();
  final _pwCtrl = TextEditingController();
  final _cpwCtrl = TextEditingController();

  bool _showPw = false;
  bool _showCpw = false;

  @override
  void dispose() {
    _pwCtrl.dispose();
    _cpwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4CAF50);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final cardColor = isDark ? const Color(0xFF1F1F1F) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? Colors.grey[400]! : const Color(0xFF64748B);
    final inputFill = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9);
    final inputTextColor = isDark ? Colors.white : Colors.black;
    final inactiveDot = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                height: 56,
                width: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: green,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "secure_account".tr(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: green,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "create_strong_password".tr(),
                style: TextStyle(fontSize: 15, color: subtitleColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _doneCircle(),
                  _line(active: true, inactiveColor: inactiveDot),
                  _doneCircle(),
                  _line(active: true, inactiveColor: inactiveDot),
                  _numCircle("3", active: true, inactiveColor: inactiveDot, inactiveTextColor: subtitleColor),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: cardColor,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("password_label".tr(), color: textColor),
                      TextFormField(
                        controller: _pwCtrl,
                        style: TextStyle(
                          color: inputTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                        obscureText: !_showPw,
                        decoration: _inputDeco("enter_password".tr(), fillColor: inputFill, hintColor: subtitleColor).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPw ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => _showPw = !_showPw);
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "please_enter_password".tr();
                          }
                          if (value.length < 8) {
                            return "password_min_length".tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _label("confirm_password_label".tr(), color: textColor),
                      TextFormField(
                        controller: _cpwCtrl,
                        style: TextStyle(
                          color: inputTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                        obscureText: !_showCpw,
                        decoration: _inputDeco("confirm_password_hint".tr(), fillColor: inputFill, hintColor: subtitleColor).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showCpw ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => _showCpw = !_showCpw);
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "please_confirm_password".tr();
                          }
                          if (value != _pwCtrl.text) {
                            return "passwords_not_match".tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Capture navigator before async gap
                              final navigator = Navigator.of(context);

                              await PrefsService.setUserProfile(UserProfile(
                                name: widget.name,
                                email: widget.email,
                                dob: widget.dob,
                              ));
                              await PrefsService.setHealthProfile(HealthProfile(
                                allergies: widget.allergies,
                                medicalConditions: widget.medicalConditions,
                                otherSensitivities: widget.otherSensitivities,
                              ));

                              if (!mounted) return;
                              navigator.push(
                                MaterialPageRoute(
                                  builder: (_) => VerificationSentScreen(
                                    email: widget.email,
                                    cameras: widget.cameras,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            "submit".tr(),
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- UI helpers ----------
  static Widget _doneCircle() => Container(
    height: 28,
    width: 28,
    decoration: const BoxDecoration(
      color: Color(0xFF4CAF50),
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.check, size: 18, color: Colors.white),
  );

  static Widget _numCircle(String n, {
    required bool active,
    required Color inactiveColor,
    required Color inactiveTextColor,
  }) => Container(
    height: 28,
    width: 28,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: active ? const Color(0xFF4CAF50) : inactiveColor,
      shape: BoxShape.circle,
    ),
    child: Text(
      n,
      style: TextStyle(
        color: active ? Colors.white : inactiveTextColor,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  static Widget _line({required bool active, required Color inactiveColor}) => Container(
    width: 56,
    height: 3,
    margin: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: active ? const Color(0xFF4CAF50) : inactiveColor,
      borderRadius: BorderRadius.circular(10),
    ),
  );

  static Widget _label(String text, {required Color color}) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      );

  static InputDecoration _inputDeco(String hint, {required Color fillColor, required Color hintColor}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: hintColor,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );
}
