import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_screen.dart';
import '../util/app_colors.dart';
import '../util/page_transitions.dart';
import '../services/auth_service.dart';
import '../services/prefs_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── State vars — same names as original so every UI reference is unchanged ─
  String name = "";
  String email = "";
  String phone = "";
  String dob = "";
  String _gender = "";
  int _scanCount = 0;
  String _currentPlan = "Free";
  String allergies = "";
  String conditions = "";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ── Load: Firestore first, local prefs fallback ───────────────────────────
  Future<void> _loadProfile() async {
    final scanCount = await PrefsService.getScanCount();
    final currentPlan = await PrefsService.getCurrentPlan();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      try {
        final userData = await AuthService().getUserProfile(uid);
        if (userData != null && mounted) {
          final allergyList =
              List<String>.from(userData['foodAllergies'] ?? []);
          final conditionList =
              List<String>.from(userData['conditions'] ?? []);

          // AuthService applies the 4-level name fallback chain already.
          // Add one more safety net: check Firebase Auth displayName directly.
          String resolvedName =
              (userData['name'] as String? ?? '').trim();
          if (resolvedName.isEmpty) {
            await FirebaseAuth.instance.currentUser?.reload();
            resolvedName = (FirebaseAuth.instance.currentUser?.displayName ??
                    '')
                .trim();
          }

          // phone is now returned by the updated getUserProfile
          final resolvedPhone =
              (userData['phone'] as String? ?? '').trim();

          if (mounted) {
            setState(() {
              name = resolvedName;
              email = (userData['email'] as String? ?? '').trim();
              phone = resolvedPhone.isNotEmpty ? resolvedPhone : phone;
              dob = (userData['dob'] as String? ?? '').trim();
              _gender = (userData['gender'] as String? ?? '').trim();
              allergies =
                  allergyList.isEmpty ? "None" : allergyList.join(", ");
              conditions =
                  conditionList.isEmpty ? "None" : conditionList.join(", ");
              _scanCount = scanCount;
              _currentPlan = currentPlan;
            });
          }

          // Phone fallback from prefs if still empty
          if (phone.isEmpty) {
            final prefs = await PrefsService.getUserProfile();
            if (mounted) setState(() => phone = prefs.phone);
          }

          return; // Firestore succeeded
        }
      } catch (_) {
        // Firestore unavailable — fall through to prefs
      }
    }

    // Full prefs fallback
    final userProfile = await PrefsService.getUserProfile();
    final healthProfile = await PrefsService.getHealthProfile();

    // Even in the prefs fallback, apply Firebase Auth displayName if needed
    String fallbackName = userProfile.name.trim();
    if (fallbackName.isEmpty) {
      try {
        await FirebaseAuth.instance.currentUser?.reload();
        fallbackName =
            (FirebaseAuth.instance.currentUser?.displayName ?? '').trim();
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      name = fallbackName;
      email = userProfile.email;
      phone = userProfile.phone;
      dob = userProfile.dob;
      _gender = userProfile.gender;
      allergies = healthProfile.allergiesDisplay.isEmpty
          ? "None"
          : healthProfile.allergiesDisplay;
      conditions = healthProfile.medicalConditions.isEmpty
          ? "None"
          : healthProfile.medicalConditions;
      _scanCount = scanCount;
      _currentPlan = currentPlan;
    });
  }

  // ── Navigate to edit screen and apply returned data ───────────────────────
  Future<void> _navigateAndEdit(int tabIndex) async {
    final result = await Navigator.push(
      context,
      PageTransitions.slideUp<Map<String, dynamic>>(
          EditProfileScreen(initialIndex: tabIndex)),
    );

    if (result != null) {
      // EditProfileScreen.pop() returns:
      //   'name', 'email', 'phone', 'dob', 'gender' → Strings
      //   'allergies'  → List<String>
      //   'conditions' → List<String>
      setState(() {
        name = result['name'] as String? ?? name;
        email = result['email'] as String? ?? email;
        phone = result['phone'] as String? ?? phone;
        dob = result['dob'] as String? ?? dob;
        _gender = result['gender'] as String? ?? _gender;

        final allergyList =
            List<String>.from(result['allergies'] ?? []);
        allergies = allergyList.isEmpty ? "None" : allergyList.join(", ");

        // conditions can be List<String> (new) or String (legacy prefs)
        final rawConditions = result['conditions'];
        if (rawConditions is List) {
          final cl = List<String>.from(rawConditions);
          conditions = cl.isEmpty ? "None" : cl.join(", ");
        } else {
          final s = rawConditions?.toString() ?? '';
          conditions = s.isEmpty ? "None" : s;
        }
      });
    }
  }

  // =========================================================================
  // UI — unchanged from original
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.frovyGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chevron_left_rounded,
                color: Colors.white, size: 28),
          ),
        ),
        title: Text(
          "account_details".tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => _navigateAndEdit(0),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_outlined,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Avatar + name card ──────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color:
                              AppColors.frovyGreen.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_rounded,
                            size: 40, color: AppColors.frovyGreen),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isEmpty ? "—" : name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.frovyText,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          email.isEmpty ? "—" : email,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.frovyGreen
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _currentPlan,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.frovyGreen,
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

          // ── Scrollable body ────────────────────────
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFFF2F7F2),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            _scanCount.toString(),
                            "scans_made".tr(),
                            Icons.qr_code_scanner_rounded,
                            AppColors.frovyGreen,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            _currentPlan,
                            "plan_type".tr(),
                            Icons.workspace_premium_rounded,
                            AppColors.frovyGold,
                            isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Personal info card
                    _buildInfoCard(
                      title: "personal_details".tr(),
                      icon: Icons.person_outline_rounded,
                      onEdit: () => _navigateAndEdit(0),
                      isDark: isDark,
                      children: [
                        _buildInfoRow("full_name".tr(),
                            name.isEmpty ? "—" : name, isDark),
                        _buildInfoRow("phone_number".tr(),
                            phone.isEmpty ? "—" : phone, isDark),
                        _buildInfoRow("date_of_birth".tr(),
                            dob.isEmpty ? "—" : dob, isDark),
                        _buildInfoRow(
                          "gender".tr(),
                          _gender.isNotEmpty ? _gender.tr() : "—",
                          isDark,
                          isLast: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Health profile card
                    _buildInfoCard(
                      title: "health_profile".tr(),
                      icon: Icons.favorite_border_rounded,
                      onEdit: () => _navigateAndEdit(1),
                      isDark: isDark,
                      children: [
                        _buildInfoRow(
                            "allergies".tr(), allergies, isDark),
                        _buildInfoRow(
                            "medical_conditions".tr(), conditions, isDark,
                            isLast: true),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style:
                      TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.frovyGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      Icon(icon, color: AppColors.frovyGreen, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? Colors.white : AppColors.frovyText,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color:
                          AppColors.frovyGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined,
                            size: 12, color: AppColors.frovyGreen),
                        const SizedBox(width: 4),
                        Text(
                          "edit_profile".tr(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.frovyGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark,
      {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  label,
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.frovyText,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
              height: 1,
              color: Colors.grey.withValues(alpha: 0.1)),
      ],
    );
  }
}