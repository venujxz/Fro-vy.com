// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// --- IMPORTS FOR ALL APP SCREENS ---
import 'camera_screen.dart';
import 'profile_screen.dart';
import 'subscription_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const HomeScreen({super.key, required this.cameras});

  // Brand Colors
  static const Color frovyGreen  = Color(0xFF6AA15E);
  static const Color frovyYellow = Color(0xFFFBE156);
  static const Color frovyLightBg = Color(0xFFF8F9FA);

  // ─────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color headerColor = isDarkMode ? const Color(0xFF1F1F1F) : frovyGreen;
    final Color bodyColor   = isDarkMode ? const Color(0xFF121212) : frovyLightBg;
    final Color cardColor   = isDarkMode ? const Color(0xFF2C2C2C) : Colors.white;
    final Color textColor   = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: headerColor,
      appBar: _buildAppBar(context, headerColor),
      drawer: _buildDrawer(context, headerColor),
      body: Column(
        children: [
          _buildHeader(headerColor, isDarkMode),
          _buildBody(context, bodyColor, cardColor, textColor, isDarkMode),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // AppBar
  // ─────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context, Color headerColor) {
    return AppBar(
      backgroundColor: headerColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
              Text(
                'John Doe',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Drawer
  // ─────────────────────────────────────────

  Widget _buildDrawer(BuildContext context, Color headerColor) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: headerColor),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.eco, size: 40, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  'Fro-vy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Free Plan',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Account Details'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.workspace_premium,
              color: Color(0xFFFFA000),
            ),
            title: const Text('Premium Plans'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Analysis History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
              );
            },
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Body Sections
  // ─────────────────────────────────────────

  Widget _buildHeader(Color headerColor, bool isDarkMode) {
    return Container(
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
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.eco, color: frovyGreen),
                const SizedBox(width: 8),
                const Text(
                  'FRO-VY',
                  style: TextStyle(
                    color: frovyGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Scan, search, or enter ingredients to check if they're safe for you",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    Color bodyColor,
    Color cardColor,
    Color textColor,
    bool isDarkMode,
  ) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bodyColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHealthProfileCard(context, cardColor, textColor, isDarkMode),
              const SizedBox(height: 24),
              Text(
                'How would you like to check ingredients?',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 16),
              _buildActionCards(context, cardColor, textColor),
              const SizedBox(height: 30),
              _buildFooter(cardColor, textColor, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Cards
  // ─────────────────────────────────────────

  Widget _buildHealthProfileCard(
    BuildContext context,
    Color cardColor,
    Color textColor,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Health Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: frovyGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildProfileRow('Allergies', 'Peanuts, Shellfish', textColor),
          _buildProfileRow('Medical Conditions', 'None', textColor),
          _buildProfileRow('Other Sensitivities', 'Lactose', textColor),
        ],
      ),
    );
  }

  Widget _buildActionCards(
    BuildContext context,
    Color cardColor,
    Color textColor,
  ) {
    return Column(
      children: [
        // 1. Scan Ingredients
        _buildActionCard(
          context,
          icon: Icons.camera_alt_outlined,
          title: 'Scan Ingredients',
          subtitle: 'Use your camera to scan product labels',
          color: frovyGreen,
          cardColor: cardColor,
          textColor: textColor,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CameraScreen(cameras: cameras),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 2. Search Products (not yet implemented)
        _buildActionCard(
          context,
          icon: Icons.search,
          title: 'Search Products',
          subtitle: 'Search our database of popular products',
          color: frovyGreen.withOpacity(0.8),
          cardColor: cardColor,
          textColor: textColor,
          onTap: null, 
        ),
        const SizedBox(height: 12),

        // 3. Manual Entry (not yet implemented)
        _buildActionCard(
          context,
          icon: Icons.edit_note,
          title: 'Manual Entry',
          subtitle: 'Type in the ingredient list manually',
          color: frovyYellow,
          iconColor: Colors.black87,
          cardColor: cardColor,
          textColor: textColor,
          onTap: null, 
        ),
      ],
    );
  }

  Widget _buildFooter(Color cardColor, Color textColor, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFEEE8D6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How it works',
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 8),
          Text(
            '• Choose your preferred input method',
            style: TextStyle(color: textColor),
          ),
          Text(
            "• We'll analyze ingredients against your health profile",
            style: TextStyle(color: textColor),
          ),
          Text(
            '• Get instant risk assessment',
            style: TextStyle(color: textColor),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Helper Widgets
  // ─────────────────────────────────────────

  Widget _buildProfileRow(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: textColor,
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
    required Color cardColor,
    required Color textColor,
    VoidCallback? onTap, // nullable — null disables the tap safely
    Color iconColor = Colors.white,
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
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: onTap == null ? color.withOpacity(0.5) : color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: onTap == null
                          ? textColor.withOpacity(0.5)
                          : textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            if (onTap == null)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}