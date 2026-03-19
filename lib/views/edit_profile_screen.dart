import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final int initialIndex; // To open specific tab (0 = Personal, 1 = Health)

  const EditProfileScreen({super.key, this.initialIndex = 0});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  // Brand Colors
  final Color frovyGreen = const Color(0xFF6AA15E);
  final Color frovyLightBg = const Color(0xFFF8F9FA);

  late TabController _tabController;

  // Form Controllers (Personal)
  final TextEditingController _nameController = TextEditingController(text: "John Doe");
  final TextEditingController _emailController = TextEditingController(text: "john.doe@example.com");
  final TextEditingController _phoneController = TextEditingController(text: "+94 77 123 4567");
  final TextEditingController _dobController = TextEditingController(text: "2000-11-22");

  // Health Data State
  // We use a Set for allergies so we can toggle them on/off easily
  final Set<String> _selectedAllergies = {"Peanuts", "Shellfish"};
  final List<String> _commonAllergies = [
    "Peanuts", "Shellfish", "Milk", "Eggs", "Soy", "Wheat", "Fish", "Tree Nuts", "Gluten"
  ];

  final TextEditingController _medicalConditionsController = TextEditingController(text: "None");
  final TextEditingController _otherSensitivitiesController = TextEditingController(text: "Lactose Intolerance");

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _medicalConditionsController.dispose();
    _otherSensitivitiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: frovyLightBg,
      appBar: AppBar(
        backgroundColor: frovyGreen,
        elevation: 0,
        title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // --- THE SAVE BUTTON LOGIC ---
          TextButton(
            onPressed: () {
              // 1. Capture the updated data into a Map
              Map<String, dynamic> updatedData = {
                "name": _nameController.text,
                "email": _emailController.text,
                "phone": _phoneController.text,
                "dob": _dobController.text,
                "allergies": _selectedAllergies.toList(), // Convert Set to List
                "conditions": _medicalConditionsController.text,
                "sensitivities": _otherSensitivitiesController.text,
              };

              // 2. Send it back to the previous screen (ProfileScreen)
              Navigator.pop(context, updatedData); 
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile Updated Successfully!")),
              );
            },
            child: const Text("SAVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Personal Details"),
            Tab(text: "Health Profile"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Personal Details Form
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildProfilePhoto(),
                const SizedBox(height: 30),
                _buildTextField("Full Name", _nameController, Icons.person_outline),
                _buildTextField("Email", _emailController, Icons.email_outlined),
                _buildTextField("Phone Number", _phoneController, Icons.phone_outlined),
                _buildTextField("Date of Birth", _dobController, Icons.calendar_today),
                // Gender Dropdown
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: "Male",
                      items: ["Male", "Female", "Other", "Prefer not to say"]
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {},
                    ),
                  ),
                ),
              ],
            ),
          ),

          // TAB 2: Health Profile Form
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Food Allergies", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                const Text("Select all that apply. We will warn you if any product contains these ingredients.", 
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                
                // Interactive Chip Grid
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _commonAllergies.map((allergy) {
                    final isSelected = _selectedAllergies.contains(allergy);
                    return FilterChip(
                      label: Text(allergy),
                      selected: isSelected,
                      selectedColor: frovyGreen.withValues(alpha: 0.2),
                      checkmarkColor: frovyGreen,
                      labelStyle: TextStyle(
                        color: isSelected ? frovyGreen : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedAllergies.add(allergy);
                          } else {
                            _selectedAllergies.remove(allergy);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),
                
                const Text("Medical Conditions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _buildTextField("Enter conditions (e.g. Diabetes)", _medicalConditionsController, Icons.medical_services_outlined, maxLines: 2),

                const SizedBox(height: 10),

                const Text("Other Sensitivities", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _buildTextField("E.g. Lactose, Caffeine", _otherSensitivitiesController, Icons.warning_amber_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildProfilePhoto() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
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
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}