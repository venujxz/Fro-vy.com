import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'login_step2_screen.dart';

class LoginStep1Screen extends StatefulWidget {
  const LoginStep1Screen({super.key});

  @override
  State<LoginStep1Screen> createState() => _LoginStep1ScreenState();
}

class _LoginStep1ScreenState extends State<LoginStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: "John Doe");
  final _emailCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 18),
              Container(
                height: 56,
                width: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, size: 44, color: green),
              ),
              const SizedBox(height: 12),
              const Text(
                "Welcome!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: green,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Please provide your details to continue",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _stepDot(active: true, label: "1"),
                  _stepLine(),
                  _stepDot(active: false, label: "2"),
                  _stepLine(),
                  _stepDot(active: false, label: "3"),
                ],
              ),
              const SizedBox(height: 18),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("Full Name"),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: _input("Enter your full name"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _label("Email Address"),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: _input("Enter your email"),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email";
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _label("Date of Birth"),
                    TextFormField(
                      controller: _dobCtrl,
                      decoration: _input("Select your date of birth"),
                      readOnly: true,
                      onTap: _pickDob,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select your date of birth";
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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginStep2Screen(),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "Next",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- helpers ----

  static Widget _stepDot({required bool active, required String label}) {
    const green = Color(0xFF4CAF50);
    return Container(
      height: 28,
      width: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? green : const Color(0xFFE2E8F0),
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