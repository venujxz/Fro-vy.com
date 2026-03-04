import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; 
import 'package:easy_localization/easy_localization.dart'; // IMPORT FOR .tr()

// --- IMPORTS FOR ALL APP SCREENS ---
import 'camera_screen.dart';       // 1. Camera Feature
import 'profile_screen.dart';      // 2. Account Details
import 'subscription_screen.dart'; // 3. Premium Plans
import 'history_screen.dart';      // 4. Analysis History
import 'settings_screen.dart';     // 5. Settings
import 'help_support_screen.dart'; // 6. Help & Support

class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const HomeScreen({super.key, required this.cameras});

  // Brand Colors
  static const Color frovyGreen = Color(0xFF6AA15E);
  static const Color frovyYellow = Color(0xFFFBE156);
  static const Color frovyLightBg = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    // 1. CHECK THEME STATUS
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // 2. DEFINE DYNAMIC COLORS
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("welcome_back".tr(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                const Text("John Doe", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)), // Kept name hardcoded
              ],
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      
      // --- THE SIDEBAR (DRAWER) ---
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
                  const Icon(Icons.eco, size: 40, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text("Fro-vy", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("free_plan".tr(), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            ListTile(leading: const Icon(Icons.home), title: Text("home".tr()), onTap: () => Navigator.pop(context)),
            ListTile(
              leading: const Icon(Icons.person), 
              title: Text("account_details".tr()), 
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium, color: Color(0xFFFFA000)), 
              title: Text("premium_plans".tr()), 
              onTap: () {
                Navigator.pop(context); 
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history), 
              title: Text("analysis_history".tr()),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings), 
              title: Text("settings".tr()),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline), 
              title: Text("help_support".tr()),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
              },
            ),
            const Divider(),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: Text("logout".tr(), style: const TextStyle(color: Colors.red))),
          ],
        ),
      ),

      // --- MAIN BODY DASHBOARD ---
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
            width: double.infinity,
            color: headerColor,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white, 
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.eco, color: frovyGreen),
                      const SizedBox(width: 8),
                      Text("FRO-VY", style: TextStyle(color: frovyGreen, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
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

          // Content Area (White/Dark Card)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bodyColor, 
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
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
                           if (!isDarkMode) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("health_profile".tr(), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                                },
                                child: Text("edit_profile".tr(), style: TextStyle(color: frovyGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          _buildProfileRow("allergies".tr(), "Peanuts, Shellfish", textColor),
                          _buildProfileRow("medical_conditions".tr(), "None", textColor),
                          _buildProfileRow("other_sensitivities".tr(), "Lactose", textColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text("how_check_ingredients".tr(), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 16),

                    // --- BIG ACTION BUTTONS ---
                    
                    // 1. Scan Ingredients
                    _buildActionCard(
                      context,
                      icon: Icons.camera_alt_outlined,
                      title: "scan_ingredients".tr(),
                      subtitle: "scan_subtitle".tr(),
                      color: frovyGreen,
                      cardColor: cardColor, 
                      textColor: textColor, 
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CameraScreen(cameras: cameras)),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // 2. Search Products
                    _buildActionCard(
                      context,
                      icon: Icons.search,
                      title: "search_products".tr(),
                      subtitle: "search_subtitle".tr(),
                      color: frovyGreen.withOpacity(0.8),
                      cardColor: cardColor,
                      textColor: textColor,
                      onTap: () {
                        // TODO: Navigate to Search
                      },
                    ),

                    const SizedBox(height: 12),

                    // 3. Manual Entry
                    _buildActionCard(
                      context,
                      icon: Icons.edit_note,
                      title: "manual_entry".tr(),
                      subtitle: "manual_subtitle".tr(),
                      color: frovyYellow,
                      iconColor: Colors.black87,
                      cardColor: cardColor,
                      textColor: textColor,
                      onTap: () {
                        // TODO: Navigate to Manual Entry
                      },
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Footer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFEEE8D6),
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("how_it_works".tr(), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 8),
                          // String interpolation handles the bullets nicely
                          Text("• ${"step_1".tr()}", style: TextStyle(color: textColor)),
                          Text("• ${"step_2".tr()}", style: TextStyle(color: textColor)),
                          Text("• ${"step_3".tr()}", style: TextStyle(color: textColor)),
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

  // Helper: Profile Row
  Widget _buildProfileRow(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12))),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: textColor)),
        ],
      ),
    );
  }

  // Helper: Action Card
  Widget _buildActionCard(BuildContext context, {
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required Color color, 
    required VoidCallback onTap, 
    required Color cardColor,
    required Color textColor,
    Color iconColor = Colors.white
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
             if (Theme.of(context).brightness == Brightness.light)
               BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))
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
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}