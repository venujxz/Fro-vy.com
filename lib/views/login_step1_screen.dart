// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'login_step2_screen.dart';

class LoginStep1Screen extends StatefulWidget {
  const LoginStep1Screen({super.key});

  @override
  State<LoginStep1Screen> createState() => _LoginStep1ScreenState();
}

class _LoginStep1ScreenState extends State<LoginStep1Screen> {
  final _formKey  = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _dobCtrl   = TextEditingController();

  DateTime? _dob;

  static const Color _green = Color(0xFF4CAF50);

  // ─────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────
  // Logic
  // ─────────────────────────────────────────

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (!mounted) return; // ← fix: check mounted after await

    if (picked != null) {
      setState(() {
        _dob = picked;
        _dobCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginStep2Screen(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            dob: _dob!,
          ),
        ),
      );
    }
  }

  // ─────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────

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
              _buildLogo(),
              const SizedBox(height: 12),
              _buildTitle(),
              const SizedBox(height: 18),
              _buildStepIndicator(),
              const SizedBox(height: 18),
              _buildFormCard(),
              const SizedBox(height: 18),
              _buildDivider(),
              const SizedBox(height: 14),
              _buildGoogleButton(),
              const SizedBox(height: 12),
              _buildAppleButton(),
              const SizedBox(height: 18),
              _buildLoginRow(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Section Widgets
  // ─────────────────────────────────────────

  Widget _buildLogo() {
    return Container(
      height: 88,
      width: 88,
      decoration: BoxDecoration(
        color: _green.withOpacity(0.25),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(Icons.person_outline, size: 44, color: _green),
    );
  }

  Widget _buildTitle() {
    return const Column(
      children: [
        Text(
          'FRO-VY',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _green,
          ),
        ),
        SizedBox(height: 14),
        Text(
          "Let's start by getting to know you",
          style: TextStyle(fontSize: 16, color: Color(0xFF475569)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepDot(active: true, label: '1'),
        _stepLine(),
        _stepDot(active: false, label: '2'),
        _stepLine(),
        _stepDot(active: false, label: '3'),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(18),
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
          children: [
            _label('Full Name'),
            TextFormField(
              controller: _nameCtrl,
              decoration: _input('John Doe'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter name' : null,
            ),
            const SizedBox(height: 14),
            _label('Date of Birth'),
            TextFormField(
              controller: _dobCtrl,
              readOnly: true,
              onTap: _pickDob,
              decoration: _input('Select date').copyWith(
                suffixIcon: const Icon(Icons.calendar_month),
              ),
              validator: (_) => (_dob == null) ? 'Select DOB' : null,
            ),
            const SizedBox(height: 14),
            _label('Email Address'),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _input('john.doe@example.com'),
              validator: (v) {
                final email = (v ?? '').trim();
                final ok = RegExp(r'^\S+@\S+\.\S+$').hasMatch(email);
                if (!ok) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _handleContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text('Or continue with'),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: null, // TODO: Implement Google Sign In
        icon: const Icon(Icons.g_mobiledata),
        label: const Text('Continue with Google'),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildAppleButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: null, // TODO: Implement Apple Sign In
        icon: const Icon(Icons.apple),
        label: const Text('Continue with Apple'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.black,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? "),
        TextButton(
          onPressed: null, // TODO: Navigate to Login screen
          child: const Text(
            'Log in',
            style: TextStyle(
              color: _green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // UI Helpers
  // ─────────────────────────────────────────

  static Widget _stepDot({required bool active, required String label}) {
    return Container(
      height: 28,
      width: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? _green : const Color(0xFFE2E8F0),
        shape: BoxShape.circle,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : const Color(0xFF64748B),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static Widget _stepLine() => Container(
        width: 56,
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(10),
        ),
      );

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