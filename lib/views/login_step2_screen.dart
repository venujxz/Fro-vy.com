import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import '../util/app_colors.dart';
import '../services/prefs_service.dart';
import '../models/user_profile.dart';
import '../models/health_profile.dart';
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
  // Brand colors
  final Color frovyGreen = AppColors.frovyGreen;
  final Color frovyLightBg = AppColors.frovyLightBg;

  // State for selected allergies
  final Set<String> _selectedAllergies = {};

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
    "No Known Allergies"
  ];

  // Medical conditions controller
  final TextEditingController _medicalConditionsController = TextEditingController();

  @override
  void dispose() {
    _medicalConditionsController.dispose();
    super.dispose();
  }

  void _toggleAllergy(String allergy) {
    setState(() {
      if (allergy == "No Known Allergies") {
        // Selecting "No Known Allergies" clears all others
        if (_selectedAllergies.contains(allergy)) {
          _selectedAllergies.remove(allergy);
        } else {
          _selectedAllergies.clear();
          _selectedAllergies.add(allergy);
        }
      } else {
        // Selecting any other allergy deselects "No Known Allergies"
        _selectedAllergies.remove("No Known Allergies");
        if (_selectedAllergies.contains(allergy)) {
          _selectedAllergies.remove(allergy);
        } else {
          _selectedAllergies.add(allergy);
        }
      }
    });
  }

  void _handleContinue() async {
    // Save user profile and health profile data
    await PrefsService.setUserProfile(UserProfile(
      name: widget.name,
      email: widget.email,
      dob: widget.dob,
    ));

    await PrefsService.setHealthProfile(HealthProfile(
      allergies: _selectedAllergies.toList(),
      medicalConditions: _medicalConditionsController.text.trim(),
      otherSensitivities: '',
    ));

    if (!mounted) return;

    // Navigate to HomeScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : frovyLightBg;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? Colors.grey[400]! : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header with back button and progress bar
            _buildModernHeader(context, isDark),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Large Bold Title
                    Text(
                      "health_profile_q".tr(),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.3,
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
                    _buildMedicalConditionsSection(isDark, textColor, subtitleColor),

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
    );
  }

  // Modern header with back button, title, and progress bar
  Widget _buildModernHeader(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? Colors.grey[400]! : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Back button and title row
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded, color: textColor, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  "Login Step 2",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Balance the back button space
            ],
          ),
          const SizedBox(height: 16),

          // Linear Progress Indicator
          LinearProgressIndicator(
            value: 1.0, // 100% for step 2/2
            backgroundColor: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(frovyGreen),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 10),

          // Step indicator text
          Text(
            "health_profile_setup".tr(),
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

  // Food Allergies Section
  Widget _buildAllergiesSection(bool isDark, Color textColor, Color subtitleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          "food_allergies_required".tr(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 0.5,
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
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _commonAllergies.map((allergy) {
            final isSelected = _selectedAllergies.contains(allergy);
            return _buildModernAllergyChip(allergy, isSelected, isDark);
          }).toList(),
        ),
      ],
    );
  }

  // Modern Allergy Chip with checkmark
  Widget _buildModernAllergyChip(String allergy, bool isSelected, bool isDark) {
    // Use localization for display
    final displayText = allergy.toLowerCase().replaceAll(' ', '_').tr();

    return InkWell(
      onTap: () => _toggleAllergy(allergy),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? frovyGreen
              : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F3EF)),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? frovyGreen
                : (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE8E4DC)),
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
            Text(
              displayText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF5A5A5A)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Medical Conditions Section
  Widget _buildMedicalConditionsSection(bool isDark, Color textColor, Color subtitleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          "medical_conditions_required".tr(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 0.5,
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
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F3EF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _medicalConditionsController,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
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
              fillColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F3EF),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            maxLines: 2,
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
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: frovyGreen,
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
    );
  }
}
