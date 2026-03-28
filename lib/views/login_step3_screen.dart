import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../util/app_colors.dart';
import '../services/auth_service.dart';
import '../services/prefs_service.dart';
import '../models/user_profile.dart';
import '../models/health_profile.dart';
import 'verification_sent_screen.dart';

class LoginStep3Screen extends StatefulWidget {
  final String email;
  final String name;
  final String dob;         // "yyyy-MM-dd" string from Step 1
  final List<String> allergies;
  final List<String> conditions; // ← Now List<String> (was medicalConditions String)
  final List<CameraDescription>? cameras;

  const LoginStep3Screen({
    super.key,
    required this.email,
    required this.name,
    required this.dob,
    required this.allergies,
    required this.conditions,
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
  bool _isLoading = false;

  @override
  void dispose() {
    _pwCtrl.dispose();
    _cpwCtrl.dispose();
    super.dispose();
  }

  // ── Registration logic ────────────────────────────────────────────────────

  Future<void> _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authService = AuthService();

      // Parse the dob string to DateTime for Firestore Timestamp storage
      DateTime dateOfBirth;
      try {
        dateOfBirth = DateFormat('yyyy-MM-dd').parse(widget.dob);
      } catch (_) {
        dateOfBirth = DateTime(2000, 1, 1);
      }

      // 1. Create Firebase Auth account + base Firestore document
      final String? uid = await authService.registerUser(
        email: widget.email,
        password: _pwCtrl.text.trim(),
        userName: widget.name,
        dateOfBirth: dateOfBirth,
        gender: 'prefer_not_to_say', // user can update in EditProfileScreen
      );

      if (!mounted) return;

      if (uid == null) {
        _showSnackBar('Registration failed. Email may already be in use.',
            isError: true);
        setState(() => _isLoading = false);
        return;
      }

      // 2. Save health profile to Firestore (encrypted)
      if (widget.conditions.isNotEmpty || widget.allergies.isNotEmpty) {
        await authService.saveHealthProfile(
          userId: uid,
          conditions: widget.conditions,
          allergies: widget.allergies,
        );
      }

      // 3. Also save to PrefsService for instant local access on HomeScreen
      await PrefsService.setUserProfile(UserProfile(
        name: widget.name,
        email: widget.email,
        dob: widget.dob,
        gender: 'prefer_not_to_say',
      ));
      await PrefsService.setHealthProfile(HealthProfile(
        allergies: widget.allergies,
        // Join for the local prefs string field
        medicalConditions: widget.conditions.join(', '),
        otherSensitivities: '',
      ));

      if (!mounted) return;
      setState(() => _isLoading = false);

      // 4. Navigate to email verification screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationSentScreen(
            email: widget.email,
            cameras: widget.cameras,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar(
        e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? AppColors.frovyRed : AppColors.frovyGreen,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : Colors.white;
    final cardColor =
        isDark ? AppColors.darkCard : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.lightText;
    final subtitleColor =
        isDark ? AppColors.darkSubtitle : AppColors.lightSubtitle;
    final inputFill =
        isDark ? AppColors.darkCard : const Color(0xFFF1F5F9);
    final inputTextColor = isDark ? Colors.white : AppColors.lightText;
    final inactiveDot =
        isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Icon
              Container(
                height: 56,
                width: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined,
                    color: AppColors.frovyGreen, size: 28),
              ),
              const SizedBox(height: 14),

              Text(
                "secure_account".tr(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.frovyGreen,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "create_strong_password".tr(),
                style: TextStyle(fontSize: 15, color: subtitleColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              // Step indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _doneCircle(),
                  _line(active: true, inactiveColor: inactiveDot),
                  _doneCircle(),
                  _line(active: true, inactiveColor: inactiveDot),
                  _numCircle('3',
                      active: true,
                      inactiveColor: inactiveDot,
                      inactiveTextColor: subtitleColor),
                ],
              ),
              const SizedBox(height: 18),

              // Form card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: cardColor,
                  border: isDark
                      ? Border.all(color: AppColors.darkBorder)
                      : Border.all(color: const Color(0xFFE2E8F0)),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Password field
                      _label("password_label".tr(), color: textColor),
                      TextFormField(
                        controller: _pwCtrl,
                        style: TextStyle(
                            color: inputTextColor,
                            fontWeight: FontWeight.w500),
                        obscureText: !_showPw,
                        decoration:
                            _inputDeco("enter_password".tr(), fillColor: inputFill, hintColor: subtitleColor)
                                .copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPw
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: subtitleColor,
                            ),
                            onPressed: () =>
                                setState(() => _showPw = !_showPw),
                          ),
                        ),
                        validator: (value) {
                          final pw = (value ?? '').trim();
                          if (pw.isEmpty) return "please_enter_password".tr();
                          if (pw.length < 8) return "password_min_length".tr();
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Confirm password field
                      _label("confirm_password_label".tr(), color: textColor),
                      TextFormField(
                        controller: _cpwCtrl,
                        style: TextStyle(
                            color: inputTextColor,
                            fontWeight: FontWeight.w500),
                        obscureText: !_showCpw,
                        decoration:
                            _inputDeco("confirm_password_hint".tr(), fillColor: inputFill, hintColor: subtitleColor)
                                .copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showCpw
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: subtitleColor,
                            ),
                            onPressed: () =>
                                setState(() => _showCpw = !_showCpw),
                          ),
                        ),
                        validator: (value) {
                          final cpw = (value ?? '').trim();
                          if (cpw.isEmpty) return "please_confirm_password".tr();
                          if (cpw != _pwCtrl.text.trim()) {
                            return "passwords_not_match".tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email info box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.frovyGreen.withValues(alpha: 0.12)
                              : const Color(0xFFF3EEDF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('📩',
                                style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'A verification link will be sent to\n${widget.email}',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF334155),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.frovyGreen,
                                side: const BorderSide(
                                    color: AppColors.frovyGreen),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              child: Text("back".tr()),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : _handleCreateAccount,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.frovyGreen,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.frovyGreen
                                    .withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                elevation: 0,
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
                                  : Text("create_account".tr()),
                            ),
                          ),
                        ],
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

  // ── UI helpers ────────────────────────────────────────────────────────────

  static Widget _doneCircle() => Container(
        height: 28,
        width: 28,
        decoration: const BoxDecoration(
          color: AppColors.frovyGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 18, color: Colors.white),
      );

  static Widget _numCircle(
    String n, {
    required bool active,
    required Color inactiveColor,
    required Color inactiveTextColor,
  }) =>
      Container(
        height: 28,
        width: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.frovyGreen : inactiveColor,
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

  static Widget _line(
          {required bool active, required Color inactiveColor}) =>
      Container(
        width: 56,
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.frovyGreen : inactiveColor,
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

  static InputDecoration _inputDeco(
    String hint, {
    required Color fillColor,
    required Color hintColor,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: hintColor, fontWeight: FontWeight.w400),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
      );
}