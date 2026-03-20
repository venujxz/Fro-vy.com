// ignore_for_file: deprecated_member_use, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'theme_notifier.dart';
import 'welcome_screen.dart';
import '../util/app_colors.dart';
import '../services/prefs_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailUpdates = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final push = await PrefsService.getPushNotifications();
    final email = await PrefsService.getEmailUpdates();
    if (mounted) {
      setState(() {
        _pushNotifications = push;
        _emailUpdates = email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.frovyGreen,
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
            child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
          ),
        ),
        title: Text(
          "settings".tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Spacer for top area
          const SizedBox(height: 8),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF2F7F2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ── Appearance ────────────────────
                    _buildSection(
                      isDark: isDark,
                      icon: Icons.palette_outlined,
                      iconColor: Colors.purple,
                      title: "appearance".tr(),
                      children: [
                        _buildToggleRow(
                          icon: isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          iconColor:
                              isDark ? Colors.indigo : Colors.orange,
                          title: "dark_mode".tr(),
                          subtitle: "switch_dark_theme".tr(),
                          value: isDark,
                          onChanged: (val) => themeNotifier.toggleTheme(val),
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Notifications ─────────────────
                    _buildSection(
                      isDark: isDark,
                      icon: Icons.notifications_outlined,
                      iconColor: const Color(0xFFFF8A65),
                      title: "notifications".tr(),
                      children: [
                        _buildToggleRow(
                          icon: Icons.phone_android_rounded,
                          iconColor: AppColors.frovyGreen,
                          title: "push_notifications".tr(),
                          subtitle: "receive_alerts".tr(),
                          value: _pushNotifications,
                          onChanged: (v) {
                            setState(() => _pushNotifications = v);
                            PrefsService.setPushNotifications(v);
                          },
                          isDark: isDark,
                        ),
                        Divider(
                            height: 1,
                            color: Colors.grey.withValues(alpha: 0.1),
                            indent: 52),
                        _buildToggleRow(
                          icon: Icons.email_outlined,
                          iconColor: Colors.blue,
                          title: "email_updates".tr(),
                          subtitle: "health_tips".tr(),
                          value: _emailUpdates,
                          onChanged: (v) {
                            setState(() => _emailUpdates = v);
                            PrefsService.setEmailUpdates(v);
                          },
                          isDark: isDark,
                          isLast: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Danger zone ───────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.frovyRed
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.warning_amber_rounded,
                                      color: AppColors.frovyRed, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "danger_zone".tr(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.frovyRed,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _showDeleteDialog(context),
                                icon: const Icon(Icons.delete_forever_rounded,
                                    size: 18),
                                label: Text("delete_account".tr()),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.frovyRed,
                                  side: BorderSide(
                                      color: AppColors.frovyRed
                                          .withValues(alpha: 0.4)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.frovyRed),
            const SizedBox(width: 8),
            Text("delete_account".tr(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text("delete_account_confirm".tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("cancel".tr(),
                style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              await PrefsService.clearAll();
              if (!context.mounted) return;
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.frovyRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text("delete_account_btn".tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : AppColors.frovyText,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.frovyText,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.frovyGreen,
            activeTrackColor: AppColors.frovyGreen.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}