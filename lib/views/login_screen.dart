import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import '../util/app_colors.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_step1_screen.dart';
import 'welcome_screen.dart';

class LoginScreen extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const LoginScreen({super.key, this.cameras});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl   = TextEditingController();

  bool _showPw    = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final uid = await AuthService().loginUser(
        email:    _emailCtrl.text.trim(),
        password: _pwCtrl.text.trim(),
      );

      if (!mounted) return;
      if (uid == null) {
        _showError('Login failed. Please try again.');
        setState(() => _isLoading = false);
        return;
      }

      final verified = await AuthService().isEmailVerified();
      if (!mounted) return;
      if (!verified) {
        setState(() => _isLoading = false);
        _showError('Please verify your email before logging in.');
        return;
      }

      List<CameraDescription> cameras = widget.cameras ?? [];
      if (cameras.isEmpty) {
        try { cameras = await availableCameras(); } catch (_) {}
      }

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(cameras: cameras)),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ── Forgot password ───────────────────────────────────────────────────────
  Future<void> _handleForgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) { _showError('enter_email_first'.tr()); return; }
    try {
      await AuthService().sendPasswordReset(email);
      if (!mounted) return;
      _showSuccess('password_reset_sent'.tr(namedArgs: {'email': email}));
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg), backgroundColor: AppColors.frovyRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ),
  );

  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg), backgroundColor: AppColors.frovyGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ),
  );

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark        = Theme.of(context).brightness == Brightness.dark;
    final bgColor       = isDark ? AppColors.darkBackground : Colors.white;
    final textColor     = isDark ? Colors.white       : AppColors.lightText;
    final subtitleColor = isDark ? AppColors.darkSubtitle : AppColors.lightSubtitle;
    final inputFill     = isDark ? AppColors.darkCard  : const Color(0xFFF1F5F9);
    final inputTextColor = isDark ? Colors.white : AppColors.lightText;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          child: Column(
            children: [

              // ── TOP BRAND SECTION ────────────────────────────────────────
              // Small logo icon badge in the top-left corner, near the status bar
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 0),
                child: Row(
                  children: [
                    // ── image_1.png: circular badge icon (F + basket) ──────
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.frovyGreen.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Back to Welcome
                    TextButton.icon(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WelcomeScreen(cameras: widget.cameras)),
                        (route) => false,
                      ),
                      icon: Icon(Icons.arrow_back_ios_rounded,
                          size: 14, color: subtitleColor),
                      label: Text('back'.tr(),
                          style: TextStyle(color: subtitleColor, fontSize: 13)),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── image_0.png: full FRO-VY banner (badge + gradient text) ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkCard
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.frovyGreen.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.frovyGreen.withValues(alpha: 0.15),
                  ),
                ),
                child: Image.asset(
                  'assets/frovy_banner.png',
                  height: 52,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'welcome_back_subtitle'.tr(),
                style: TextStyle(fontSize: 15, color: subtitleColor),
              ),

              const SizedBox(height: 28),

              // ── FORM CARD ────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            color: Colors.black.withValues(alpha: 0.07),
                          ),
                        ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Email field ──────────────────────────────────────
                      _label('email_label'.tr(), textColor),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                            color: inputTextColor, fontWeight: FontWeight.w500),
                        decoration: _inputDeco(
                          'enter_email'.tr(),
                          fillColor: inputFill,
                          hintColor: subtitleColor,
                        ).copyWith(
                          // ── image_1.png badge as prefix inside email field ──
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/logo.png',
                                width: 28,
                                height: 28,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        validator: (v) {
                          final e = (v ?? '').trim();
                          if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(e)) {
                            return 'invalid_email'.tr();
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // ── Password field ───────────────────────────────────
                      _label('password_label'.tr(), textColor),
                      TextFormField(
                        controller: _pwCtrl,
                        obscureText: !_showPw,
                        style: TextStyle(
                            color: inputTextColor, fontWeight: FontWeight.w500),
                        decoration: _inputDeco(
                          'enter_password'.tr(),
                          fillColor: inputFill,
                          hintColor: subtitleColor,
                        ).copyWith(
                          prefixIcon: Icon(Icons.lock_outline_rounded,
                              color: subtitleColor, size: 20),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _showPw = !_showPw),
                            icon: Icon(
                              _showPw ? Icons.visibility_off : Icons.visibility,
                              color: subtitleColor,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) {
                            return 'please_enter_password'.tr();
                          }
                          return null;
                        },
                      ),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          child: Text(
                            'forgot_password'.tr(),
                            style: const TextStyle(
                              color: AppColors.frovyGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.frovyGreen,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppColors.frovyGreen.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text(
                                  'login_btn'.tr(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sign-up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('no_account'.tr(),
                      style: TextStyle(color: subtitleColor)),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              LoginStep1Screen(cameras: widget.cameras)),
                    ),
                    child: Text(
                      'sign_up'.tr(),
                      style: const TextStyle(
                          color: AppColors.frovyGreen,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _label(String text, Color color) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(text,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ),
      );

  static InputDecoration _inputDeco(
    String hint, {
    required Color fillColor,
    required Color hintColor,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.w400),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );
}