import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'login_step3_screen.dart';

class LoginStep2Screen extends StatefulWidget {
  final String email;
  final String name;
  final String dob;
  final List<CameraDescription>? cameras;

  const LoginStep2Screen({
    super.key,
    required this.email,
    required this.name,
    required this.dob,
    this.cameras,
  });

  @override
  State<LoginStep2Screen> createState() => _LoginStep2ScreenState();
}

class _LoginStep2ScreenState extends State<LoginStep2Screen> {
  final _medicalCtrl = TextEditingController();
  final _allergyCtrl = TextEditingController();
  final _otherCtrl = TextEditingController();

  final List<String> medical = [];
  final List<String> allergies = [];
  final List<String> other = [];

  @override
  void dispose() {
    _medicalCtrl.dispose();
    _allergyCtrl.dispose();
    _otherCtrl.dispose();
    super.dispose();
  }

  void _addItem(TextEditingController ctrl, List<String> list) {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      list.add(text);
      ctrl.clear();
    });
  }

  void _removeItem(List<String> list, int i) {
    setState(() => list.removeAt(i));
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4CAF50);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final subtitleColor = isDark ? Colors.grey[400]! : const Color(0xFF64748B);
    final inactiveDot = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.favorite_border, color: green, size: 30),
              ),
              const SizedBox(height: 14),
              Text(
                "health_profile_title".tr(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: green,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "health_profile_subtitle".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: subtitleColor),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _doneCircle(),
                  _line(active: true, inactiveColor: inactiveDot),
                  _numCircle("2", active: true, inactiveColor: inactiveDot, inactiveTextColor: subtitleColor),
                  _line(active: false, inactiveColor: inactiveDot),
                  _numCircle("3", active: false, inactiveColor: inactiveDot, inactiveTextColor: subtitleColor),
                ],
              ),
              const SizedBox(height: 18),
              _section(
                title: "medical_conditions_label".tr(),
                subtitle: "medical_conditions_hint".tr(),
                hintText: "add_medical_conditions".tr(),
                controller: _medicalCtrl,
                onAdd: () => _addItem(_medicalCtrl, medical),
                chips: medical,
                onRemove: (i) => _removeItem(medical, i),
                isDark: isDark,
              ),
              const SizedBox(height: 18),
              _section(
                title: "allergies_label".tr(),
                subtitle: "allergies_hint".tr(),
                hintText: "add_allergies".tr(),
                controller: _allergyCtrl,
                onAdd: () => _addItem(_allergyCtrl, allergies),
                chips: allergies,
                onRemove: (i) => _removeItem(allergies, i),
                isDark: isDark,
              ),
              const SizedBox(height: 18),
              _section(
                title: "other_notes_label".tr(),
                subtitle: "other_notes_hint".tr(),
                hintText: "add_other_notes".tr(),
                controller: _otherCtrl,
                onAdd: () => _addItem(_otherCtrl, other),
                chips: other,
                onRemove: (i) => _removeItem(other, i),
                isDark: isDark,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoginStep3Screen(
                          email: widget.email,
                          name: widget.name,
                          dob: widget.dob,
                          allergies: allergies,
                          medicalConditions: medical.join(', '),
                          otherSensitivities: other.join(', '),
                          cameras: widget.cameras,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "next".tr(),
                    style: const TextStyle(fontSize: 16, color: Colors.white),
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

  Widget _section({
    required String title,
    required String subtitle,
    required String hintText,
    required TextEditingController controller,
    required VoidCallback onAdd,
    required List<String> chips,
    required Function(int) onRemove,
    required bool isDark,
  }) {
    const green = Color(0xFF4CAF50);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? Colors.grey[400]! : const Color(0xFF64748B);
    final inputFill = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9);
    final inputTextColor = isDark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: subtitleColor)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: TextStyle(
                  color: inputTextColor,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: subtitleColor,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              width: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onAdd,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              chips.length,
              (i) => Chip(label: Text(chips[i]), onDeleted: () => onRemove(i)),
            ),
          ),
        ],
      ],
    );
  }
}
