import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORT FOR .tr()
import '../util/app_colors.dart';
import '../util/validators.dart';
import '../services/prefs_service.dart';
import '../models/user_profile.dart';
import '../models/health_profile.dart';

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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  // Health Data State
  // We use a Set for allergies so we can toggle them on/off easily
  final Set<String> _selectedAllergies = {};
  final List<String> _commonAllergies = [
    "Peanuts", "Shellfish", "Milk", "Eggs", "Soy", "Wheat", "Fish", "Tree Nuts", "Gluten"
  ];

  final TextEditingController _medicalConditionsController = TextEditingController();

  // Gender selection: store the KEY, not the translated string
  String _selectedGender = "male";
  final List<String> _genderKeys = ["male", "female", "other", "prefer_not_to_say"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final userProfile = await PrefsService.getUserProfile();
    final healthProfile = await PrefsService.getHealthProfile();
    if (!mounted) return;
    setState(() {
      _nameController.text = userProfile.name;
      _emailController.text = userProfile.email;
      _phoneController.text = userProfile.phone;
      _dobController.text = userProfile.dob;
      _selectedGender = userProfile.gender.isNotEmpty ? userProfile.gender : "male";
      _selectedAllergies.addAll(healthProfile.allergies);
      _medicalConditionsController.text = healthProfile.medicalConditions;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _medicalConditionsController.dispose();
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
            onPressed: () async {
              // Validate form only if we're on the personal tab and form exists
              final isFormValid = _formKey.currentState?.validate() ?? true;

              if (!isFormValid && _tabController.index == 0) {
                // Only block save if on personal tab and validation fails
                return;
              }

              Map<String, dynamic> updatedData = {
                "name": _nameController.text.trim(),
                "email": _emailController.text.trim(),
                "phone": _phoneController.text.trim(),
                "dob": _dobController.text.trim(),
                "gender": _selectedGender,
                "allergies": _selectedAllergies.toList(),
                "conditions": _medicalConditionsController.text.trim(),
              };

              // Capture context-dependent objects before async gap
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              // Persist to PrefsService
              await PrefsService.setUserProfile(UserProfile(
                name: updatedData['name'],
                email: updatedData['email'],
                phone: updatedData['phone'],
                dob: updatedData['dob'],
                gender: updatedData['gender'],
              ));
              await PrefsService.setHealthProfile(HealthProfile(
                allergies: List<String>.from(updatedData['allergies']),
                medicalConditions: updatedData['conditions'],
                otherSensitivities: '',
              ));

              if (!mounted) return;
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text("profile_updated".tr())),
              );
              navigator.pop(updatedData);
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
                    color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
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
                      selectedColor: frovyGreen.withValues(alpha: 0.2),
                      checkmarkColor: frovyGreen,
                      labelStyle: TextStyle(
                        color: isSelected ? frovyGreen : (isDark ? Colors.white70 : Colors.black87),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
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
          fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDatePickerField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
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
          fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
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