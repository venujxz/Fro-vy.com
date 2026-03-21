import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'login_step2_screen.dart';

class LoginStep1Screen extends StatefulWidget {
  final List<CameraDescription>? cameras;

  const LoginStep1Screen({super.key, this.cameras});

  @override
  State<LoginStep1Screen> createState() => _LoginStep1ScreenState();
}

class _LoginStep1ScreenState extends State<LoginStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? Colors.grey[400]! : const Color(0xFF64748B);
    final inputFill = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9);
    final inputTextColor = isDark ? Colors.white : Colors.black;
    final inactiveDot = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
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
              Text(
                "welcome_title".tr(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: green,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "provide_details".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: subtitleColor),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _stepDot(active: true, label: "1", inactiveColor: inactiveDot, inactiveTextColor: subtitleColor),
                  _stepLine(inactiveColor: inactiveDot),
                  _stepDot(active: false, label: "2", inactiveColor: inactiveDot, inactiveTextColor: subtitleColor),
                  _stepLine(inactiveColor: inactiveDot),
                  _stepDot(active: false, label: "3", inactiveColor: inactiveDot, inactiveTextColor: subtitleColor),
                ],
              ),
              const SizedBox(height: 18),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("full_name_label".tr(), color: textColor),
                    TextFormField(
                      controller: _nameCtrl,
                      style: TextStyle(color: inputTextColor, fontWeight: FontWeight.w500),
                      decoration: _inputDeco("enter_full_name".tr(), fillColor: inputFill, hintColor: subtitleColor),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "please_enter_name".tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _label("email_label".tr(), color: textColor),
                    TextFormField(
                      controller: _emailCtrl,
                      style: TextStyle(color: inputTextColor, fontWeight: FontWeight.w500),
                      decoration: _inputDeco("enter_email".tr(), fillColor: inputFill, hintColor: subtitleColor),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "please_enter_email".tr();
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                          return "invalid_email".tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _label("dob_label".tr(), color: textColor),
                    TextFormField(
                      controller: _dobCtrl,
                      style: TextStyle(color: inputTextColor, fontWeight: FontWeight.w500),
                      decoration: _inputDeco("select_dob".tr(), fillColor: inputFill, hintColor: subtitleColor),
                      readOnly: true,
                      onTap: _pickDob,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "please_select_dob".tr();
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
                                builder: (_) => LoginStep2Screen(
                                  email: _emailCtrl.text.trim(),
                                  name: _nameCtrl.text.trim(),
                                  dob: _dobCtrl.text.trim(),
                                  cameras: widget.cameras,
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          "next".tr(),
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(child: Divider(color: subtitleColor.withAlpha(100))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "or".tr(),
                            style: TextStyle(color: subtitleColor, fontSize: 14),
                          ),
                        ),
                        Expanded(child: Divider(color: subtitleColor.withAlpha(100))),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: isDark ? Colors.grey[600]! : const Color(0xFFE2E8F0)),
                        ),
                        onPressed: () {
                          // TODO: Implement Google Sign-In
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("google_signin_coming_soon".tr())),
                          );
                        },
                        icon: Image.asset(
                          'assets/images/google_logo.png',
                          height: 20,
                          width: 20,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.g_mobiledata,
                            size: 24,
                            color: textColor,
                          ),
                        ),
                        label: Text(
                          "sign_in_google".tr(),
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
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

  static Widget _stepDot({
    required bool active,
    required String label,
    required Color inactiveColor,
    required Color inactiveTextColor,
  }) {
    const green = Color(0xFF4CAF50);
    return Container(
      height: 28,
      width: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? green : inactiveColor,
        shape: BoxShape.circle,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : inactiveTextColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static Widget _stepLine({required Color inactiveColor}) => Container(
        width: 56,
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: inactiveColor,
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
