import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORT FOR .tr()
import '../util/app_colors.dart';
import '../util/validators.dart';

class EditProfileScreen extends StatefulWidget {
  final int initialIndex; // To open specific tab (0 = Personal, 1 = Health)

  const EditProfileScreen({super.key, this.initialIndex = 0});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  // Brand Colors
  final Color frovyGreen = AppColors.frovyGreen;
  final Color frovyLightBg = AppColors.frovyLightBg;

  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

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

  // Gender selection: store the KEY, not the translated string
  String _selectedGender = "male";
  final List<String> _genderKeys = ["male", "female", "other", "prefer_not_to_say"];

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? null : frovyGreen,
        elevation: 0,
        title: Text("edit_profile".tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // --- THE SAVE BUTTON LOGIC ---
          TextButton(
            onPressed: () {
              // Validate the form first
              if (_formKey.currentState?.validate() ?? false) {
                Map<String, dynamic> updatedData = {
                  "name": _nameController.text.trim(),
                  "email": _emailController.text.trim(),
                  "phone": _phoneController.text.trim(),
                  "dob": _dobController.text.trim(),
                  "gender": _selectedGender,
                  "allergies": _selectedAllergies.toList(),
                  "conditions": _medicalConditionsController.text.trim(),
                  "sensitivities": _otherSensitivitiesController.text.trim(),
                };

                Navigator.pop(context, updatedData);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("profile_updated".tr())),
                );
              }
            },
            child: Text("save".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: "personal_details".tr()),
            Tab(text: "health_profile".tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Personal Details Form
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildProfilePhoto(),
                  const SizedBox(height: 30),
                  _buildValidatedField("full_name".tr(), _nameController, Icons.person_outline,
                      validator: (v) => Validators.validateRequired(v, fieldName: "full_name".tr())),
                  _buildValidatedField("email".tr(), _emailController, Icons.email_outlined,
                      validator: Validators.validateEmail,
                      keyboardType: TextInputType.emailAddress),
                  _buildValidatedField("phone_number".tr(), _phoneController, Icons.phone_outlined,
                      validator: Validators.validatePhone,
                      keyboardType: TextInputType.phone),
                  // DOB with DatePicker
                  _buildDatePickerField(),
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
                      icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                      value: _selectedGender,
                      items: _genderKeys.map((key) => DropdownMenuItem(
                        value: key,
                        child: Text(key.tr()),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedGender = val);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),

          // TAB 2: Health Profile Form
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("food_allergies".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text("allergy_instruction".tr(), 
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                
                // Interactive Chip Grid (Ingredients stay in English or map to DB values later)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _commonAllergies.map((allergy) {
                    final isSelected = _selectedAllergies.contains(allergy);
                    return FilterChip(
                      label: Text(allergy),
                      selected: isSelected,
                      selectedColor: frovyGreen.withOpacity(0.2),
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
                
                Text("medical_conditions".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _buildValidatedField("enter_conditions".tr(), _medicalConditionsController, Icons.medical_services_outlined, maxLines: 2),

                const SizedBox(height: 10),

                Text("other_sensitivities".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _buildValidatedField("enter_sensitivities".tr(), _otherSensitivitiesController, Icons.warning_amber_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildValidatedField(String label, TextEditingController controller, IconData icon, {
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
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

  Widget _buildDatePickerField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextFormField(
        controller: _dobController,
        readOnly: true,
        validator: Validators.validateDate,
        decoration: InputDecoration(
          labelText: "date_of_birth".tr(),
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.tryParse(_dobController.text) ?? DateTime(2000, 1, 1),
            firstDate: DateTime(1920),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() {
              _dobController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
            });
          }
        },
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
              color: frovyGreen.withOpacity(0.2),
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