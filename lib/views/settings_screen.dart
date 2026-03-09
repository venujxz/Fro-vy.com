import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORT FOR .tr()
import 'theme_notifier.dart'; // Import the notifier

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Brand Colors
  Color get frovyGreen => const Color(0xFF6AA15E);
  Color get frovyRed => const Color(0xFFD32F2F);
  
  // Local state for notification toggles
  bool _pushNotifications = true;
  bool _emailUpdates = true;

  @override
  Widget build(BuildContext context) {
    // Check if the system is currently in dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? null : frovyGreen, 
      
      appBar: AppBar(
        backgroundColor: isDarkMode ? null : frovyGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "settings".tr(), // Localized Title
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isDarkMode 
            ? null 
            : BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [frovyGreen, const Color(0xFFFFF9C4)],
                ),
              ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 1. Appearance Section
              _buildSectionCard(
                context,
                title: "appearance".tr(),
                icon: Icons.dark_mode_outlined,
                iconColor: Colors.purple,
                children: [
                  _buildToggleTile(
                    "dark_mode".tr(), 
                    "dark_mode_desc".tr(), 
                    isDarkMode, 
                    (val) {
                       themeNotifier.toggleTheme(val);
                    }
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. Notifications Section
              _buildSectionCard(
                context,
                title: "notifications".tr(),
                icon: Icons.notifications_none,
                iconColor: const Color(0xFFFF8A65),
                children: [
                  _buildToggleTile(
                    "push_notifications".tr(), 
                    "receive_alerts".tr(), 
                    _pushNotifications, 
                    (v) => setState(() => _pushNotifications = v)
                  ),
                  _buildToggleTile(
                    "email_updates".tr(), 
                    "health_tips".tr(), 
                    _emailUpdates, 
                    (v) => setState(() => _emailUpdates = v)
                  ),
                ],
              ),
              
              const SizedBox(height: 20),

              // 3. Danger Zone
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("danger_zone".tr(), style: TextStyle(color: frovyRed, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // Action for account deletion
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: frovyRed, 
                          side: BorderSide(color: frovyRed)
                        ),
                        child: Text("delete_account".tr()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionCard(BuildContext context, {required String title, required IconData icon, required Color iconColor, required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark) 
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(children: [
            Icon(icon, color: iconColor), 
            const SizedBox(width: 10), 
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
          ]),
          const SizedBox(height: 10),
          ...children
        ],
      ),
    );
  }

  Widget _buildToggleTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Switch(
        value: value, 
        onChanged: onChanged, 
        activeColor: const Color(0xFF6AA15E)
      ),
    );
  }
}