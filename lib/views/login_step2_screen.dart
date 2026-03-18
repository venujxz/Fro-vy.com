import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:frovy_app/models/user_profile.dart';
import 'package:frovy_app/models/health_profile.dart';
import 'package:frovy_app/services/prefs_service.dart';
import 'package:frovy_app/util/app_colors.dart';
import 'home_screen.dart';

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
  // Constant for special allergy option
  static const String _noKnownAllergies = "No Known Allergies";

  // State for selected allergies
  final Set<String> _selectedAllergies = {};

  // Loading state
  bool _isLoading = false;

  // Common allergies list matching the requirements
  final List<String> _commonAllergies = [
    "Milk",
    "Shellfish",
    "Peanuts",
    "Eggs",
    "Tree Nuts",
    "Wheat",
    "Soy",
    "Fish",
    "Gluten",
    "Sesame",
    _noKnownAllergies,
  ];

  // Medical conditions controller
  final TextEditingController _medicalConditionsController =
      TextEditingController();

  @override
  void dispose() {
    _medicalConditionsController.dispose();
    super.dispose();
  }

  void _toggleAllergy(String allergy) {
    setState(() {
      if (allergy == _noKnownAllergies) {
        // Selecting "No Known Allergies" clears all others
        if (_selectedAllergies.contains(allergy)) {
          _selectedAllergies.remove(allergy);
        } else {
          _selectedAllergies.clear();
          _selectedAllergies.add(allergy);
        }
      } else {
        // Selecting any other allergy deselects "No Known Allergies"
        _selectedAllergies.remove(_noKnownAllergies);
        if (_selectedAllergies.contains(allergy)) {
          _selectedAllergies.remove(allergy);
        } else {
          _selectedAllergies.add(allergy);
        }
      }
    });
  }

  bool _validateForm() {
    if (_selectedAllergies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("food_allergy_select_instruction".tr()),
          backgroundColor: AppColors.frovyRed,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _handleContinue() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      // Save user profile
      await PrefsService.setUserProfile(UserProfile(
        name: widget.name,
        email: widget.email,
        dob: widget.dob,
      ));

      // Save health profile
      await PrefsService.setHealthProfile(HealthProfile(
        allergies: _selectedAllergies.toList(),
        medicalConditions: _medicalConditionsController.text.trim(),
        otherSensitivities: '', // Reserved for future use
      ));

      if (!mounted) return;

      // Navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(cameras: widget.cameras ?? []),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile. Please try again.'),
          backgroundColor: AppColors.frovyRed,
        ),
      );
    }
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
              value: 1.0, // 100% for step 2/2
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
            label: 'Progress: Step 2 of 2',
            child: Text(
              "step_2_of_2".tr(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Semantics(
          header: true,
          child: Text(
            "food_allergies_required".tr(),
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
          "food_allergy_select_instruction".tr(),
          style: TextStyle(
            fontSize: 13,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 16),

        // Modern Chip Grid
        Semantics(
          label: 'Allergy selection',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _commonAllergies.map((allergy) {
              final isSelected = _selectedAllergies.contains(allergy);
              return _buildModernAllergyChip(allergy, isSelected, isDark);
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Modern Allergy Chip with checkmark
  Widget _buildModernAllergyChip(String allergy, bool isSelected, bool isDark) {
    // Use localization for display
    final displayText = allergy.toLowerCase().replaceAll(' ', '_').tr();
    final chipBgColor =
        isDark ? AppColors.darkCard : AppColors.lightChipBg;
    final chipBorderColor =
        isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final unselectedTextColor =
        isDark ? Colors.white70 : AppColors.mutedText;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$displayText ${isSelected ? "selected" : "not selected"}',
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200),
        child: InkWell(
          onTap: () => _toggleAllergy(allergy),
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.frovyGreen : chipBgColor,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? AppColors.frovyGreen : chipBorderColor,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    displayText,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : unselectedTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
    final bool canContinue = _selectedAllergies.isNotEmpty && !_isLoading;

    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: Semantics(
          button: true,
          enabled: canContinue,
          label: _isLoading ? 'Saving...' : 'Continue to home',
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  canContinue ? AppColors.frovyGreen : AppColors.frovyGreen.withAlpha(128),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Pill shape
              ),
              elevation: 0,
            ),
            onPressed: canContinue ? _handleContinue : null,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
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
