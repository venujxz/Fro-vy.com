import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:frovy_app/util/app_colors.dart';
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
  // ── Allergy list state ────────────────────────────────────────────────────
  final TextEditingController _allergyInputController = TextEditingController();
  final FocusNode _allergyFocusNode = FocusNode();
  final List<String> _allergiesList = [];

  // ── Medical conditions list state ─────────────────────────────────────────
  final TextEditingController _conditionInputController =
      TextEditingController();
  final FocusNode _conditionFocusNode = FocusNode();
  final List<String> _conditionsList = [];

  @override
  void dispose() {
    _allergyInputController.dispose();
    _allergyFocusNode.dispose();
    _conditionInputController.dispose();
    _conditionFocusNode.dispose();
    super.dispose();
  }

  // ── Add / remove helpers ──────────────────────────────────────────────────

  void _addAllergy() {
    final text = _allergyInputController.text.trim();
    if (text.isEmpty) return;
    if (_allergiesList.any((e) => e.toLowerCase() == text.toLowerCase())) {
      _allergyInputController.clear();
      return;
    }
    setState(() => _allergiesList.add(text));
    _allergyInputController.clear();
    _allergyFocusNode.requestFocus();
  }

  void _removeAllergy(int index) =>
      setState(() => _allergiesList.removeAt(index));

  void _addCondition() {
    final text = _conditionInputController.text.trim();
    if (text.isEmpty) return;
    if (_conditionsList.any((e) => e.toLowerCase() == text.toLowerCase())) {
      _conditionInputController.clear();
      return;
    }
    setState(() => _conditionsList.add(text));
    _conditionInputController.clear();
    _conditionFocusNode.requestFocus();
  }

  void _removeCondition(int index) =>
      setState(() => _conditionsList.removeAt(index));

  // ── Navigation ────────────────────────────────────────────────────────────

  Future<void> _handleContinue() async {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginStep3Screen(
          email: widget.email,
          name: widget.name,
          dob: widget.dob,
          allergies: List<String>.from(_allergiesList),
          // ← Now passed as List<String> so AuthService can encrypt each item
          conditions: List<String>.from(_conditionsList),
          cameras: widget.cameras,
        ),
      ),
    );
  }

  void _dismissKeyboard() => FocusScope.of(context).unfocus();

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.frovyLightBg;
    final textColor = isDark ? Colors.white : AppColors.lightText;
    final subtitleColor =
        isDark ? AppColors.darkSubtitle : AppColors.lightSubtitle;

    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildModernHeader(context, isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Semantics(
                        header: true,
                        child: Text(
                          "health_profile_q".tr(),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "health_profile_instruction".tr(),
                        style: TextStyle(
                          fontSize: 15,
                          color: subtitleColor,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Food Allergies ─────────────────────────────────
                      _buildListBuilderSection(
                        isDark: isDark,
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                        title: "food_allergies_optional".tr(),
                        instruction: "food_allergy_text_instruction".tr(),
                        hintText: "enter_allergies".tr(),
                        prefixIcon: Icons.warning_amber_rounded,
                        controller: _allergyInputController,
                        focusNode: _allergyFocusNode,
                        items: _allergiesList,
                        chipColor: AppColors.frovyAmber,
                        chipBg: isDark
                            ? AppColors.frovyAmber.withValues(alpha: 0.18)
                            : const Color(0xFFFFF8E1),
                        onAdd: _addAllergy,
                        onRemove: _removeAllergy,
                        semanticsLabel: 'Enter food allergy',
                      ),

                      const SizedBox(height: 32),

                      // ── Medical Conditions ─────────────────────────────
                      _buildListBuilderSection(
                        isDark: isDark,
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                        title: "medical_conditions_required".tr(),
                        instruction: "medical_conditions_instruction".tr(),
                        hintText: "enter_conditions".tr(),
                        prefixIcon: Icons.medical_information_rounded,
                        controller: _conditionInputController,
                        focusNode: _conditionFocusNode,
                        items: _conditionsList,
                        chipColor: AppColors.frovyGreen,
                        chipBg: isDark
                            ? AppColors.frovyGreen.withValues(alpha: 0.18)
                            : AppColors.frovyLightGreen,
                        onAdd: _addCondition,
                        onRemove: _removeCondition,
                        semanticsLabel: 'Enter medical condition',
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              _buildModernContinueButton(isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ── Reusable list-builder section ─────────────────────────────────────────

  Widget _buildListBuilderSection({
    required bool isDark,
    required Color textColor,
    required Color subtitleColor,
    required String title,
    required String instruction,
    required String hintText,
    required IconData prefixIcon,
    required TextEditingController controller,
    required FocusNode focusNode,
    required List<String> items,
    required Color chipColor,
    required Color chipBg,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
    required String semanticsLabel,
  }) {
    final inputBgColor = isDark ? AppColors.darkCard : AppColors.lightChipBg;
    final inputTextColor = isDark ? Colors.white : AppColors.lightText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          instruction,
          style: TextStyle(fontSize: 13, color: subtitleColor),
        ),
        const SizedBox(height: 16),

        // Input row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Semantics(
                textField: true,
                label: semanticsLabel,
                child: Container(
                  decoration: BoxDecoration(
                    color: inputBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    style: TextStyle(color: inputTextColor, fontSize: 15),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => onAdd(),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: subtitleColor,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon:
                          Icon(prefixIcon, color: subtitleColor, size: 22),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: inputBgColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Semantics(
              button: true,
              label: 'Add item',
              child: GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.frovyGreen,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.frovyGreen.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 26),
                ),
              ),
            ),
          ],
        ),

        if (items.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              items.length,
              (index) => _buildDismissibleChip(
                label: items[index],
                chipColor: chipColor,
                chipBg: chipBg,
                onRemove: () => onRemove(index),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDismissibleChip({
    required String label,
    required Color chipColor,
    required Color chipBg,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: chipColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: chipColor,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 12, color: chipColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.lightText;
    final subtitleColor =
        isDark ? AppColors.darkSubtitle : AppColors.lightSubtitle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Semantics(
                button: true,
                label: 'Go back',
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_rounded,
                      color: textColor, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Text(
                  "health_profile_title".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: 0.66,
              backgroundColor:
                  isDark ? AppColors.darkBorder : AppColors.lightProgressBg,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.frovyGreen),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "step_2_of_3".tr(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: subtitleColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernContinueButton(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.frovyGreen,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          onPressed: _handleContinue,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "continue_btn".tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}