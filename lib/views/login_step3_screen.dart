import 'package:flutter/material.dart';
import 'verification_sent_screen.dart';

class LoginStep3Screen extends StatefulWidget {
  final String email; // show email in the info box

  const LoginStep3Screen({super.key, required this.email});

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                child: const Icon(
                  Icons.shield_outlined,
                  color: green,
                  size: 28,
                ),
              ),

              const SizedBox(height: 14),
              const Text(
                "Secure Your Account",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: green,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Create a strong password to protect your data",
                style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 18),

              // Step indicator (✓ ✓ 3)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _doneCircle(),
                  _line(active: true),
                  _doneCircle(),
                  _line(active: true),
                  _numCircle("3", active: true),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 10,
                      offset: Offset(0, 4),
                      color: Colors.black12,
                    ),
                  ],
                  color: Colors.white,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Password",
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
                        decoration: _input("Enter your password").copyWith(
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _showPw = !_showPw),
                            icon: Icon(
                              _showPw ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        validator: (v) {
                          final pw = (v ?? "").trim();
                          if (pw.isEmpty) return "Enter a password";
                          if (pw.length < 8) {
                            return "Password must be 8+ characters";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 8),
                      const Text(
                        "Must be at least 8 characters",
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        "Confirm Password",
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
                        decoration: _input("Re-enter your password").copyWith(
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _showCpw = !_showCpw),
                            icon: Icon(
                              _showCpw
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        validator: (v) {
                          final cpw = (v ?? "").trim();
                          final pw = _pwCtrl.text.trim();
                          if (cpw.isEmpty) return "Re-enter your password";
                          if (cpw != pw) return "Passwords do not match";
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Info box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3EEDF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("📩", style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "A verification link will be sent to\n${widget.email}",
                                style: const TextStyle(
                                  color: Color(0xFF334155),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: green,
                                side: const BorderSide(color: green),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text("Back"),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // ✅ Go to "Verification Email Sent" screen
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VerificationSentScreen(
                                        email: widget.email,
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text("Create Account"),
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

  static Widget _numCircle(String n, {required bool active}) => Container(
    height: 28,
    width: 28,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: active ? const Color(0xFF4CAF50) : const Color(0xFFE2E8F0),
      shape: BoxShape.circle,
    ),
    child: Text(
      n,
      style: TextStyle(
        color: active ? Colors.white : const Color(0xFF64748B),
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  static Widget _line({required bool active}) => Container(
    width: 56,
    height: 3,
    margin: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: active ? const Color(0xFF4CAF50) : const Color(0xFFE2E8F0),
      borderRadius: BorderRadius.circular(10),
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}
