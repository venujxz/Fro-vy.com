<<<<<<< HEAD
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'verification_sent_screen.dart';
import '../services/auth_service.dart';

class LoginStep3Screen extends StatefulWidget {
  final String name;
  final String email;
  final DateTime dob;
  final List<String> conditions;
  final List<String> allergies;
  final List<String> concerns;

  const LoginStep3Screen({
    super.key,
    required this.name,
    required this.email,
    required this.dob,
    required this.conditions,
    required this.allergies,
    required this.concerns,
=======
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
>>>>>>> upstream/main
  });

  @override
  State<LoginStep3Screen> createState() => _LoginStep3ScreenState();
}

class _LoginStep3ScreenState extends State<LoginStep3Screen> {
<<<<<<< HEAD
  final _formKey  = GlobalKey<FormState>();
  final _pwCtrl   = TextEditingController();
  final _cpwCtrl  = TextEditingController();

  bool _showPw   = false;
  bool _showCpw  = false;
  bool _isLoading = false;

  static const Color _green = Color(0xFF4CAF50);

  // ─────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────
=======
  final _formKey = GlobalKey<FormState>();
  final _pwCtrl = TextEditingController();
  final _cpwCtrl = TextEditingController();

  bool _showPw = false;
  bool _showCpw = false;
>>>>>>> upstream/main

  @override
  void dispose() {
    _pwCtrl.dispose();
    _cpwCtrl.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  // ─────────────────────────────────────────
  // Registration Logic
  // ─────────────────────────────────────────

  Future<void> _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();

      // 1. Register user
      final String? uid = await authService.registerUser(
        email: widget.email,
        password: _pwCtrl.text.trim(),
        userName: widget.name,
        dateOfBirth: widget.dob,
        gender: 'prefer_not_to_say',
      );

      if (!mounted) return;

      if (uid == null) {
        _showSnackBar(
          'Registration failed. Email may already be in use.',
          isError: true,
        );
        setState(() => _isLoading = false);
        return;
      }

      // 2. Save health profile if user entered any
      if (widget.conditions.isNotEmpty ||
          widget.allergies.isNotEmpty ||
          widget.concerns.isNotEmpty) {
        await authService.saveHealthProfile(
          userId: uid,
          conditions: widget.conditions,
          allergies: widget.allergies,
          concerns: widget.concerns,
          skinType: '',
        );
      }

      if (!mounted) return;

      setState(() => _isLoading = false);

      // 3. Navigate to verification screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationSentScreen(email: widget.email),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  // ─────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
=======
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
>>>>>>> upstream/main
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),
<<<<<<< HEAD
              _buildIcon(),
              const SizedBox(height: 14),
              _buildTitle(),
              const SizedBox(height: 18),
              _buildStepIndicator(),
              const SizedBox(height: 18),
              _buildFormCard(),
=======
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
>>>>>>> upstream/main
            ],
          ),
        ),
      ),
    );
  }

<<<<<<< HEAD
  // ─────────────────────────────────────────
  // Section Widgets
  // ─────────────────────────────────────────

  Widget _buildIcon() {
    return Container(
      height: 56,
      width: 56,
      decoration: const BoxDecoration(
        color: Color(0xFFE8F5E9),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.shield_outlined, color: _green, size: 28),
    );
  }

  Widget _buildTitle() {
    return const Column(
      children: [
        Text(
          'Secure Your Account',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _green,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Create a strong password to protect your data',
          style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _doneCircle(),
        _line(active: true),
        _doneCircle(),
        _line(active: true),
        _numCircle('3', active: true),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Colors.black12,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPasswordField(),
            const SizedBox(height: 8),
            const Text(
              'Must be at least 8 characters',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            _buildConfirmPasswordField(),
            const SizedBox(height: 16),
            _buildEmailInfoBox(),
            const SizedBox(height: 22),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Form Fields
  // ─────────────────────────────────────────

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _pwCtrl,
          obscureText: !_showPw,
          decoration: _input('Enter your password').copyWith(
            suffixIcon: IconButton(
              onPressed: () => setState(() => _showPw = !_showPw),
              icon: Icon(
                _showPw ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          validator: (v) {
            final pw = (v ?? '').trim();
            if (pw.isEmpty) return 'Enter a password';
            if (pw.length < 8) return 'Password must be 8+ characters';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirm Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _cpwCtrl,
          obscureText: !_showCpw,
          decoration: _input('Re-enter your password').copyWith(
            suffixIcon: IconButton(
              onPressed: () => setState(() => _showCpw = !_showCpw),
              icon: Icon(
                _showCpw ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          validator: (v) {
            final cpw = (v ?? '').trim();
            if (cpw.isEmpty) return 'Re-enter your password';
            if (cpw != _pwCtrl.text.trim()) return 'Passwords do not match';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEDF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📩', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'A verification link will be sent to\n${widget.email}',
              style: const TextStyle(
                color: Color(0xFF334155),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: _green,
              side: const BorderSide(color: _green),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Back'),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleCreateAccount,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _green.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Create Account'),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // UI Helpers
  // ─────────────────────────────────────────

  static Widget _doneCircle() => Container(
        height: 28,
        width: 28,
        decoration: const BoxDecoration(
          color: _green,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 18, color: Colors.white),
      );

  static Widget _numCircle(String n, {required bool active}) => Container(
        height: 28,
        width: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? _green : const Color(0xFFE2E8F0),
          shape: BoxShape.circle,
        ),
        child: Text(
          n,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.w700,
=======
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
>>>>>>> upstream/main
          ),
        ),
      );

<<<<<<< HEAD
  static Widget _line({required bool active}) => Container(
        width: 56,
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: active ? _green : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(10),
        ),
      );

  static InputDecoration _input(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
=======
  static InputDecoration _inputDeco(String hint, {required Color fillColor, required Color hintColor}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: hintColor,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: fillColor,
>>>>>>> upstream/main
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
<<<<<<< HEAD
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );
}
=======
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );
}
>>>>>>> upstream/main
