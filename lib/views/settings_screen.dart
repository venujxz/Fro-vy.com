import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isDeleting = false;

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

  // ── Account deletion flow ─────────────────────────────────────────────────
  //
  // Firebase requires a "recent login" to delete an account. If the user's
  // session is older than a few minutes, Firebase throws
  // [requires-recent-login]. We handle this by prompting re-authentication
  // with their email + password before retrying the deletion.

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.frovyRed),
            const SizedBox(width: 8),
            Text(
              "delete_account".tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
            onPressed: () {
              Navigator.pop(ctx);
              _attemptDeleteAccount();
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

  Future<void> _attemptDeleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isDeleting = true);

    try {
      // 1. Delete Firestore document first (while auth is still valid)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      // 2. Delete the Firebase Auth account
      await user.delete();

      // 3. Clear local prefs and navigate away
      await _wipeLocalAndNavigate();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);

      if (e.code == 'requires-recent-login') {
        // Session is stale — ask the user to re-authenticate first
        _showReauthDialog(user.email ?? '');
      } else {
        _showError(
            'Deletion failed: ${e.message ?? e.code}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      _showError('Something went wrong. Please try again.');
    }
  }

  // ── Re-authentication dialog ──────────────────────────────────────────────
  void _showReauthDialog(String prefillEmail) {
    final emailCtrl =
        TextEditingController(text: prefillEmail);
    final pwCtrl = TextEditingController();
    bool showPw = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Confirm Your Identity',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'For your security, please re-enter your password to permanently delete your account.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pwCtrl,
                obscureText: !showPw,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: Icon(showPw
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setDialogState(() => showPw = !showPw),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("cancel".tr(),
                  style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _reauthAndDelete(
                  emailCtrl.text.trim(),
                  pwCtrl.text,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.frovyRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('Confirm & Delete'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reauthAndDelete(
      String email, String password) async {
    if (!mounted) return;
    setState(() => _isDeleting = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Re-authenticate
      await user.reauthenticateWithCredential(credential);

      // Now safe to delete Firestore document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      // Delete Auth account
      await user.delete();

      await _wipeLocalAndNavigate();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        _showError('Incorrect password. Please try again.');
      } else {
        _showError(
            'Re-authentication failed: ${e.message ?? e.code}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      _showError('Something went wrong. Please try again.');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _wipeLocalAndNavigate() async {
    await PrefsService.clearAll();
    if (!mounted) return;
    setState(() => _isDeleting = false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.frovyRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Scaffold(
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
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFFF2F7F2),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // ── Appearance ──────────────────────────────────
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
                              iconColor: isDark
                                  ? Colors.indigo
                                  : Colors.orange,
                              title: "dark_mode".tr(),
                              subtitle: "switch_dark_theme".tr(),
                              value: isDark,
                              onChanged: (val) =>
                                  themeNotifier.toggleTheme(val),
                              isDark: isDark,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ── Notifications ───────────────────────────────
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
                                setState(
                                    () => _pushNotifications = v);
                                PrefsService.setPushNotifications(v);
                              },
                              isDark: isDark,
                            ),
                            Divider(
                                height: 1,
                                color: Colors.grey
                                    .withValues(alpha: 0.1),
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

                        // ── Danger zone ─────────────────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkCard
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.04),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.frovyRed
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(
                                                10),
                                      ),
                                      child: const Icon(
                                          Icons.warning_amber_rounded,
                                          color: AppColors.frovyRed,
                                          size: 18),
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
                                    onPressed: _isDeleting
                                        ? null
                                        : _showDeleteDialog,
                                    icon: const Icon(
                                        Icons.delete_forever_rounded,
                                        size: 18),
                                    label: Text(
                                        "delete_account".tr()),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          AppColors.frovyRed,
                                      side: BorderSide(
                                          color: AppColors.frovyRed
                                              .withValues(alpha: 0.4)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      padding:
                                          const EdgeInsets.symmetric(
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
        ),

        // ── Full-screen loading overlay during deletion ────────────────
        if (_isDeleting)
          Container(
            color: Colors.black.withValues(alpha: 0.55),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkCard
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                        color: AppColors.frovyRed),
                    SizedBox(height: 16),
                    Text(
                      'Deleting account…',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Section / row builders (unchanged) ───────────────────────────────────

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
                    color:
                        isDark ? Colors.white : AppColors.frovyText,
                  ),
                ),
              ],
            ),
          ),
          Divider(
              height: 1,
              color: Colors.grey.withValues(alpha: 0.1)),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
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
                    color: isDark
                        ? Colors.white
                        : AppColors.frovyText,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.frovyGreen,
            activeTrackColor:
                AppColors.frovyGreen.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}