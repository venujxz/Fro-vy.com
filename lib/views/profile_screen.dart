import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORT FOR .tr()
import 'edit_profile_screen.dart';
import '../util/app_colors.dart';
import '../util/page_transitions.dart';
import '../services/prefs_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Brand Colors
  final Color frovyGreen = AppColors.frovyGreen;
  final Color frovyText = AppColors.frovyText;
  final Color frovyLightBg = AppColors.frovyLightBg;

  // --- STATE VARIABLES (Data that can change) ---
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

  Future<void> _loadProfile() async {
    final userProfile = await PrefsService.getUserProfile();
    final healthProfile = await PrefsService.getHealthProfile();
    final scanCount = await PrefsService.getScanCount();
    final currentPlan = await PrefsService.getCurrentPlan();
    if (!mounted) return;
    setState(() {
      name = userProfile.name;
      email = userProfile.email;
      phone = userProfile.phone;
      dob = userProfile.dob;
      _gender = userProfile.gender;
      allergies = healthProfile.allergiesDisplay.isEmpty ? "None" : healthProfile.allergiesDisplay;
      conditions = healthProfile.medicalConditions.isEmpty ? "None" : healthProfile.medicalConditions;
      _scanCount = scanCount;
      _currentPlan = currentPlan;
    });
  }

  // --- FUNCTION TO HANDLE EDITING ---
  Future<void> _navigateAndEdit(int tabIndex) async {
    // Wait for the Edit Screen to return data
    final result = await Navigator.push(
      context,
      PageTransitions.slideUp<Map<String, dynamic>>(EditProfileScreen(initialIndex: tabIndex)),
    );

    // If data was returned, update the UI and persist
    if (result != null) {
      setState(() {
        name = result['name'];
        email = result['email'];
        phone = result['phone'];
        dob = result['dob'];
        _gender = result['gender'];

        // Handle the list of allergies
        List<String> allergyList = result['allergies'];
        allergies = allergyList.isEmpty ? "None" : allergyList.join(", ");

        conditions = result['conditions'].toString().isEmpty ? "None" : result['conditions'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? null : frovyGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "account_details".tr(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. The Green Header & Profile Card Stack
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Green Background Block
                Container(
                  height: 100,
                  width: double.infinity,
                  color: frovyGreen,
                ),
                // The White Profile Card
                Container(
                  margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar and Edit Button Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: frovyGreen.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.person, size: 60, color: frovyGreen),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                ),
                              )
                            ],
                          ),
                          // Edit Profile Button
                          OutlinedButton.icon(
                            onPressed: () => _navigateAndEdit(0), // 0 = Personal Tab
                            icon: const Icon(Icons.edit, size: 14),
                            label: Text("edit_profile".tr(), style: const TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Colors.grey[300] : Colors.grey[700],
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // User Details 
                      _buildLabel("full_name".tr(), name),
                      _buildLabel("email".tr(), email),
                      _buildLabel("phone_number".tr(), phone),
                      _buildLabel("date_of_birth".tr(), dob),
                      _buildLabel("gender".tr(), _gender.isNotEmpty ? _gender.tr() : ""), 

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      Text("account_statistics".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard("$_scanCount", "scans_made".tr())),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard(_currentPlan.toLowerCase().tr(), "plan_type".tr())),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 2. Health Profile Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
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
                        "health_profile".tr(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      // Edit Health Button
                      TextButton.icon(
                        onPressed: () => _navigateAndEdit(1), // 1 = Health Tab
                        icon: const Icon(Icons.edit, size: 16),
                        label: Text("edit_profile".tr()),
                        style: TextButton.styleFrom(foregroundColor: isDark ? Colors.grey[300] : Colors.grey[700]),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  
                  // Health Details
                  _buildHealthItem("allergies".tr(), allergies),
                  _buildHealthItem("medical_conditions".tr(), conditions),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildLabel(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: isDark ? Colors.white : frovyText, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : frovyLightBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: frovyGreen, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthItem(String title, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 14),
          ),
        ],
      ),
    );
  }
}