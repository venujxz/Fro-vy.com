import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_step1_screen.dart';
import 'package:camera/camera.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();

  bool _showPw = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  static const green = Color(0xFF4CAF50);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  // ── Email / Password Login ─────────────────────────────────
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final uid = await authService.loginUser(
        email: _emailCtrl.text.trim(),
        password: _pwCtrl.text.trim(),
      );

      if (uid == null) {
        _showError("Login failed. Please try again.");
        setState(() => _isLoading = false);
        return;
      }

      if (!mounted) return;

      // Navigate to HomeScreen
      List<CameraDescription> cameras = [];
      try {
        cameras = await availableCameras();
      } catch (_) {}

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(cameras: cameras)),
        (route) => false,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ── Google Login ───────────────────────────────────────────
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    try {
      final authService = AuthService();
      final uid = await authService.signInWithGoogle();

      if (uid == null) {
        setState(() => _isGoogleLoading = false);
        return;
      }

      if (!mounted) return;

      List<CameraDescription> cameras = [];
      try {
        cameras = await availableCameras();
      } catch (_) {}

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(cameras: cameras)),
        (route) => false,
      );
    } catch (e) {
      setState(() => _isGoogleLoading = false);
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 18),

              // Logo
              Container(
                height: 88,
                width: 88,
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.eco, size: 44, color: green),
              ),

              const SizedBox(height: 12),
              const Text(
                'FRO-VY',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: green,
                ),
              ),

              const SizedBox(height: 6),
              const Text(
                'Welcome back',
                style: TextStyle(fontSize: 16, color: Color(0xFF475569)),
              ),

              const SizedBox(height: 28),

              // Form Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
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
                      // Email
                      _label('Email Address'),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _input('john.doe@example.com'),
                        validator: (v) {
                          final email = (v ?? '').trim();
                          if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Password
                      _label('Password'),
                      TextFormField(
                        controller: _pwCtrl,
                        obscureText: !_showPw,
                        decoration: _input('Enter your password').copyWith(
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _showPw = !_showPw),
                            icon: Icon(
                              _showPw
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) {
                            return 'Enter your password';
                          }
                          return null;
                        },
                      ),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: green,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                              : const Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Divider
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Or continue with'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 16),

              // Google Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                  icon: _isGoogleLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.g_mobiledata),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginStep1Screen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Forgot Password ────────────────────────────────────────
  Future<void> _handleForgotPassword() async {
    final email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      _showError('Enter your email address first');
      return;
    }

    try {
      await AuthService().sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $email'),
          backgroundColor: green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ── Helpers ────────────────────────────────────────────────
  static Widget _label(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      );

  static InputDecoration _input(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );
}