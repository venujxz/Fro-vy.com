import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORT FOR .tr()
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Brand Colors
  final Color frovyGreen = const Color(0xFF6AA15E);
  final Color frovyText = const Color(0xFF2C3E28);
  final Color frovyLightBg = const Color(0xFFF8F9FA);

  // --- STATE VARIABLES (Data that can change) ---
  String name = "John Doe";
  String email = "john.doe@example.com";
  String phone = "+94 77 123 4567";
  String dob = "2000-11-22";
  
  String allergies = "Peanuts, Shellfish";
  String conditions = "None";
  String sensitivities = "Lactose Intolerance";

  // --- FUNCTION TO HANDLE EDITING ---
  Future<void> _navigateAndEdit(int tabIndex) async {
    // Wait for the Edit Screen to return data
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen(initialIndex: tabIndex)),
    );

    // If data was returned, update the UI
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        name = result['name'];
        email = result['email'];
        phone = result['phone'];
        dob = result['dob'];
        
        // Handle the list of allergies
        List<String> allergyList = result['allergies'];
        allergies = allergyList.isEmpty ? "None" : allergyList.join(", ");
        
        conditions = result['conditions'];
        sensitivities = result['sensitivities'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: frovyLightBg,
      appBar: AppBar(
        backgroundColor: frovyGreen,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
                                  color: frovyGreen.withOpacity(0.2),
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
                              foregroundColor: Colors.grey[700],
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
                      _buildLabel("gender".tr(), "male".tr()), 

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      Text("account_statistics".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard("0", "scans_made".tr())),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard("free".tr(), "plan_type".tr())),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                        style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  
                  // Health Details
                  _buildHealthItem("allergies".tr(), allergies),
                  _buildHealthItem("medical_conditions".tr(), conditions),
                  _buildHealthItem("other_sensitivities".tr(), sensitivities),
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
            style: TextStyle(color: frovyText, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: frovyLightBg,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
        ],
      ),
    );
  }
}