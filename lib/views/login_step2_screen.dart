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
  // Text controllers
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _medicalConditionsController =
      TextEditingController();

  @override
  void dispose() {
    _allergiesController.dispose();
    _medicalConditionsController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    // Get allergies as list (split by comma)
    final allergiesText = _allergiesController.text.trim();
    final allergiesList = allergiesText.isEmpty
        ? <String>[]
        : allergiesText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    if (!mounted) return;

    // Navigate to Step 3 (password screen)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginStep3Screen(
          email: widget.email,
          name: widget.name,
          dob: widget.dob,
          allergies: allergiesList,
          medicalConditions: _medicalConditionsController.text.trim(),
          otherSensitivities: '',
          cameras: widget.cameras,
        ),
      ),
    );
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.darkBackground : AppColors.frovyLightBg;
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
              // Modern Header with back button and progress bar
              _buildModernHeader(context, isDark),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Large Bold Title
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

                      // Subtitle/Instruction
                      Text(
                        "health_profile_instruction".tr(),
                        style: TextStyle(
                          fontSize: 15,
                          color: subtitleColor,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Food Allergies Section
                      _buildAllergiesSection(isDark, textColor, subtitleColor),

                      const SizedBox(height: 32),

                      // Medical Conditions Section
                      _buildMedicalConditionsSection(
                          isDark, textColor, subtitleColor),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Modern Continue Button at bottom
              _buildModernContinueButton(isDark),
            ],
          ),
        ),
      ),
    );
  }

  // Modern header with back button, title, and progress bar
  Widget _buildModernHeader(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.lightText;
    final subtitleColor =
        isDark ? AppColors.darkSubtitle : AppColors.lightSubtitle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Back button and title row
          Row(
            children: [
              Semantics(
                button: true,
                label: 'Go back',
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_rounded,
                      color: textColor, size: 20),
                  tooltip: 'Back',
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
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
          const SizedBox(height: 16),

          // Linear Progress Indicator with ClipRRect for rounded corners
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: 0.66, // 66% for step 2/3
              backgroundColor:
                  isDark ? AppColors.darkBorder : AppColors.lightProgressBg,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.frovyGreen),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),

          // Step indicator text
          Semantics(
            label: 'Progress: Step 2 of 3',
            child: Text(
              "step_2_of_3".tr(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: subtitleColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Food Allergies Section
  Widget _buildAllergiesSection(
      bool isDark, Color textColor, Color subtitleColor) {
    final inputBgColor =
        isDark ? AppColors.darkCard : AppColors.lightChipBg;
    final inputTextColor = isDark ? Colors.white : AppColors.lightText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Semantics(
          header: true,
          child: Text(
            "food_allergies_optional".tr(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Instruction text
        Text(
          "food_allergy_text_instruction".tr(),
          style: TextStyle(
            fontSize: 13,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 16),

        // Text field for allergies
        Semantics(
          textField: true,
          label: 'Enter food allergies',
          child: Container(
            decoration: BoxDecoration(
              color: inputBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _allergiesController,
              style: TextStyle(
                color: inputTextColor,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: "enter_allergies".tr(),
                hintStyle: TextStyle(
                  color: subtitleColor,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.warning_amber_rounded,
                  color: subtitleColor,
                  size: 22,
                ),
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
              maxLines: 2,
            ),
          ),
        ),
      ],
    );
  }

  // Medical Conditions Section
  Widget _buildMedicalConditionsSection(
      bool isDark, Color textColor, Color subtitleColor) {
    final inputBgColor =
        isDark ? AppColors.darkCard : AppColors.lightChipBg;
    final inputTextColor = isDark ? Colors.white : AppColors.lightText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Semantics(
          header: true,
          child: Text(
            "medical_conditions_required".tr(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Instruction text
        Text(
          "medical_conditions_instruction".tr(),
          style: TextStyle(
            fontSize: 13,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 16),

        // Modern Flat Input Field
        Semantics(
          textField: true,
          label: 'Enter medical conditions',
          child: Container(
            decoration: BoxDecoration(
              color: inputBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _medicalConditionsController,
              style: TextStyle(
                color: inputTextColor,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: "enter_conditions".tr(),
                hintStyle: TextStyle(
                  color: subtitleColor,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: subtitleColor,
                  size: 22,
                ),
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
              maxLines: 2,
            ),
          ),
        ),
      ],
    );
  }

  // Modern Continue Button - Full width pill button with arrow
  Widget _buildModernContinueButton(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: Semantics(
          button: true,
          enabled: true,
          label: 'Continue to password setup',
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.frovyGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Pill shape
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
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
