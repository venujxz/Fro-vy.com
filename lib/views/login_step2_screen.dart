import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'login_step3_screen.dart';

class LoginStep2Screen extends StatefulWidget {
  final List<CameraDescription>? cameras;

  const LoginStep2Screen({super.key, this.cameras});

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

    return Scaffold(
      backgroundColor: Colors.white,
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
              const Text(
                "Health Profile",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: green,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Add your medical conditions, allergies, and other notes",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _doneCircle(),
                  _line(active: true),
                  _numCircle("2", active: true),
                  _line(active: false),
                  _numCircle("3", active: false),
                ],
              ),
              const SizedBox(height: 18),
              _section(
                title: "Medical Conditions",
                subtitle: "E.g., Diabetes, Hypertension",
                controller: _medicalCtrl,
                onAdd: () => _addItem(_medicalCtrl, medical),
                chips: medical,
                onRemove: (i) => _removeItem(medical, i),
              ),
              const SizedBox(height: 18),
              _section(
                title: "Allergies",
                subtitle: "E.g., Peanuts, Shellfish",
                controller: _allergyCtrl,
                onAdd: () => _addItem(_allergyCtrl, allergies),
                chips: allergies,
                onRemove: (i) => _removeItem(allergies, i),
              ),
              const SizedBox(height: 18),
              _section(
                title: "Other Notes",
                subtitle: "E.g., Lactose Intolerant",
                controller: _otherCtrl,
                onAdd: () => _addItem(_otherCtrl, other),
                chips: other,
                onRemove: (i) => _removeItem(other, i),
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
                          email: "john.doe@example.com",
                          cameras: widget.cameras,
                        ),
                      ),
                    );
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

  Widget _section({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required VoidCallback onAdd,
    required List<String> chips,
    required Function(int) onRemove,
  }) {
    const green = Color(0xFF4CAF50);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Add $title",
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
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