import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'camera_screen.dart';
import 'profile_screen.dart';
import 'subscription_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'search_products_screen.dart';
import 'manual_entry_screen.dart';

import 'widgets/language_switcher.dart';
import '../util/app_colors.dart';
import '../util/page_transitions.dart';
import 'welcome_screen.dart';
import '../services/auth_service.dart';
import '../services/prefs_service.dart';

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomeScreen({super.key, required this.cameras});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color frovyGreen = AppColors.frovyGreen;
  static const Color frovyYellow = AppColors.frovyYellow;
  static const Color frovyLightBg = AppColors.frovyLightBg;

  String _userName = "";
  String _allergies = "None";
  String _conditions = "None";

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      try {
        final userData = await AuthService().getUserProfile(uid);
        if (userData != null && mounted) {
          final allergies =
              List<String>.from(userData['foodAllergies'] ?? []);
          final conditions =
              List<String>.from(userData['conditions'] ?? []);

          String resolvedName = (userData['name'] as String? ?? '').trim();
          if (resolvedName.isEmpty) {
            await FirebaseAuth.instance.currentUser?.reload();
            resolvedName =
                (FirebaseAuth.instance.currentUser?.displayName ?? '').trim();
          }

          if (mounted) {
            setState(() {
              _userName = resolvedName;
              _allergies =
                  allergies.isEmpty ? 'None' : allergies.join(', ');
              _conditions =
                  conditions.isEmpty ? 'None' : conditions.join(', ');
            });
          }
          return;
        }
      } catch (_) {}
    }

    final userProfile = await PrefsService.getUserProfile();
    final healthProfile = await PrefsService.getHealthProfile();

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
      _userName = fallbackName;
      _allergies = healthProfile.allergiesDisplay.isEmpty
          ? "None"
          : healthProfile.allergiesDisplay;
      _conditions = healthProfile.medicalConditions.isEmpty
          ? "None"
          : healthProfile.medicalConditions;
    });
  }

  Future<void> _handleLogout() async {
    await AuthService().logoutUser();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => WelcomeScreen(cameras: widget.cameras)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color headerColor = isDarkMode ? const Color(0xFF1F1F1F) : frovyGreen;
    final Color bodyColor = isDarkMode ? const Color(0xFF121212) : frovyLightBg;
    final Color cardColor = isDarkMode ? const Color(0xFF2C2C2C) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: headerColor,
      appBar: AppBar(
        backgroundColor: headerColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [LanguageSwitcher()],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("welcome_back".tr(),
                    style: const TextStyle(fontSize: 10, color: Colors.white)),
                Text(
                  _userName.isNotEmpty ? _userName : "user".tr(),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                    context, PageTransitions.slideRight(const ProfileScreen()));
                _loadProfiles();
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ],
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: headerColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // ── Drawer header uses logo icon ────────────────────
                  ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text("Fro-vy",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  Text("free_plan".tr(),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            ListTile(
                leading: const Icon(Icons.home),
                title: Text("home".tr()),
                onTap: () => Navigator.pop(context)),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text("account_details".tr()),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                    context,
                    PageTransitions.slideRight(const ProfileScreen()));
                _loadProfiles();
              },
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium,
                  color: Color(0xFFFFA000)),
              title: Text("premium_plans".tr()),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    PageTransitions.slideRight(const SubscriptionScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text("analysis_history".tr()),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    PageTransitions.slideRight(const HistoryScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text("settings".tr()),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    PageTransitions.slideRight(const SettingsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: Text("help_support".tr()),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    PageTransitions.slideRight(const HelpSupportScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text("logout".tr(),
                  style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("logout".tr()),
                    content: Text("logout_confirm".tr()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("cancel".tr()),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _handleLogout();
                        },
                        child: Text("logout".tr(),
                            style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
            width: double.infinity,
            color: headerColor,
            child: Column(
              children: [
                // ── FRO-VY Banner Image ────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF2C2C2C)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4))
                    ],
                  ),
                  child: Image.asset(
                    'assets/frovy_banner.png',
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "header_description".tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bodyColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Health Profile Summary
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (!isDarkMode)
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("health_profile".tr(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textColor)),
                              GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                      context,
                                      PageTransitions.slideRight(
                                          const ProfileScreen()));
                                  _loadProfiles();
                                },
                                child: Text("edit_profile".tr(),
                                    style: TextStyle(
                                        color: frovyGreen,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          _buildProfileRow(
                              "allergies".tr(), _allergies, textColor),
                          _buildProfileRow(
                              "medical_conditions".tr(), _conditions, textColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text("how_check_ingredients".tr(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 16),

                    _buildActionCard(
                      context,
                      icon: Icons.camera_alt_outlined,
                      title: "scan_ingredients".tr(),
                      subtitle: "scan_subtitle".tr(),
                      color: frovyGreen,
                      cardColor: cardColor,
                      textColor: textColor,
                      onTap: () => Navigator.push(
                        context,
                        PageTransitions.scale(
                            CameraScreen(cameras: widget.cameras)),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildActionCard(
                      context,
                      icon: Icons.search,
                      title: "search_products".tr(),
                      subtitle: "search_subtitle".tr(),
                      color: frovyGreen.withValues(alpha: 0.8),
                      cardColor: cardColor,
                      textColor: textColor,
                      onTap: () => Navigator.push(
                        context,
                        PageTransitions.slideRight(const SearchProductsScreen()),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildActionCard(
                      context,
                      icon: Icons.edit_note,
                      title: "manual_entry".tr(),
                      subtitle: "manual_subtitle".tr(),
                      color: frovyYellow,
                      iconColor: Colors.black87,
                      cardColor: cardColor,
                      textColor: textColor,
                      onTap: () => Navigator.push(
                        context,
                        PageTransitions.slideRight(const ManualEntryScreen()),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF2C2C2C)
                            : const Color(0xFFEEE8D6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("how_it_works".tr(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor)),
                          const SizedBox(height: 8),
                          Text("• ${"step_1".tr()}",
                              style: TextStyle(color: textColor)),
                          Text("• ${"step_2".tr()}",
                              style: TextStyle(color: textColor)),
                          Text("• ${"step_3".tr()}",
                              style: TextStyle(color: textColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12))),
          Expanded(
            child: Text(
              value,
              softWrap: true,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required Color cardColor,
    required Color textColor,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          boxShadow: [
            if (Theme.of(context).brightness == Brightness.light)
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 5,
                  offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}