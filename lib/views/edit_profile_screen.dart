import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../util/app_colors.dart';
import '../util/validators.dart';
import '../services/prefs_service.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';
import '../models/health_profile.dart';

class EditProfileScreen extends StatefulWidget {
  final int initialIndex; // 0 = Personal tab, 1 = Health tab

  const EditProfileScreen({super.key, this.initialIndex = 0});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // ── Personal form controllers ─────────────────────────────────────────────
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  // ── Gender ────────────────────────────────────────────────────────────────
  String _selectedGender = 'male';
  final List<String> _genderKeys = [
    'male', 'female', 'other', 'prefer_not_to_say'
  ];

  // ── Allergies — list-builder state (mirrors login_step2_screen) ───────────
  final TextEditingController _allergyInputController =
      TextEditingController();
  final FocusNode _allergyFocusNode = FocusNode();
  final List<String> _allergiesList = [];

  // ── Medical conditions — list-builder state ───────────────────────────────
  final TextEditingController _conditionInputController =
      TextEditingController();
  final FocusNode _conditionFocusNode = FocusNode();
  final List<String> _conditionsList = [];

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _allergyInputController.dispose();
    _allergyFocusNode.dispose();
    _conditionInputController.dispose();
    _conditionFocusNode.dispose();
    super.dispose();
  }

  // ── Load: Firestore first, local prefs fallback ───────────────────────────

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final userData = await AuthService().getUserProfile(uid);
        if (userData != null && mounted) {
          setState(() {
            _nameController.text = userData['name'] as String? ?? '';
            _emailController.text = userData['email'] as String? ?? '';
            _dobController.text = userData['dob'] as String? ?? '';
            _selectedGender = (userData['gender'] as String?)?.isNotEmpty == true
                ? userData['gender'] as String
                : 'male';
            _allergiesList
              ..clear()
              ..addAll(List<String>.from(userData['foodAllergies'] ?? []));
            _conditionsList
              ..clear()
              ..addAll(List<String>.from(userData['conditions'] ?? []));
          });
          return;
        }
      } catch (_) {
        // Fall through to prefs
      }
    }
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
      _selectedGender =
          userProfile.gender.isNotEmpty ? userProfile.gender : 'male';
      _allergiesList
        ..clear()
        ..addAll(healthProfile.allergies);
      // medicalConditions is comma-joined in prefs → split back to list
      _conditionsList
        ..clear()
        ..addAll(
          healthProfile.medicalConditions
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
        );
    });
  }

  // ── List-builder add / remove helpers ────────────────────────────────────

  void _addAllergy() {
    final text = _allergyInputController.text.trim();
    if (text.isEmpty) return;
    if (_allergiesList.any((e) => e.toLowerCase() == text.toLowerCase())) {
      _allergyInputController.clear();
      return;
    }
    setState(() => _allergiesList.add(text));
    _allergyInputController.clear();
    _allergyFocusNode.requestFocus();
  }

  void _removeAllergy(int index) =>
      setState(() => _allergiesList.removeAt(index));

  void _addCondition() {
    final text = _conditionInputController.text.trim();
    if (text.isEmpty) return;
    if (_conditionsList.any((e) => e.toLowerCase() == text.toLowerCase())) {
      _conditionInputController.clear();
      return;
    }
    setState(() => _conditionsList.add(text));
    _conditionInputController.clear();
    _conditionFocusNode.requestFocus();
  }

  void _removeCondition(int index) =>
      setState(() => _conditionsList.removeAt(index));

  // ── Save: write to Firestore AND local prefs atomically ───────────────────

  Future<void> _handleSave() async {
    final isFormValid = _formKey.currentState?.validate() ?? true;
    if (!isFormValid && _tabController.index == 0) return;

    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final dob = _dobController.text.trim();
    final allergies = List<String>.from(_allergiesList);
    final conditions = List<String>.from(_conditionsList);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      // 1. Local prefs — instant, offline-safe
      await PrefsService.setUserProfile(UserProfile(
        name: name,
        email: email,
        phone: phone,
        dob: dob,
        gender: _selectedGender,
      ));
      await PrefsService.setHealthProfile(HealthProfile(
        allergies: allergies,
        medicalConditions: conditions.join(', '),
        otherSensitivities: '',
      ));

      // 2. Firestore — encrypted health data via AuthService
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final authService = AuthService();
        await authService.updatePersonalProfile(
          userId: uid,
          userName: name,
          gender: _selectedGender,
          phone: phone,
          dob: dob,
        );
        await authService.updateHealthProfile(
          userId: uid,
          conditions: conditions,
          allergies: allergies,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
              'Save failed: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppColors.frovyRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('profile_updated'.tr()),
        backgroundColor: AppColors.frovyGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );

    navigator.pop({
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dob,
      'gender': _selectedGender,
      'allergies': allergies,
      'conditions': conditions,
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.lightText;
    final subtitleColor =
        isDark ? AppColors.darkSubtitle : AppColors.lightSubtitle;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:
              isDark ? null : AppColors.frovyGreen,
          elevation: 0,
          title: Text(
            'edit_profile'.tr(),
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _isSaving
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: _handleSave,
                      child: Text(
                        'save'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'personal_details'.tr()),
              Tab(text: 'health_profile'.tr()),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // ── TAB 1: Personal Details ───────────────────────────────
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildProfilePhoto(),
                    const SizedBox(height: 30),
                    _buildValidatedField(
                      'full_name'.tr(),
                      _nameController,
                      Icons.person_outline,
                      validator: (v) => Validators.validateRequired(v,
                          fieldName: 'full_name'.tr()),
                    ),
                    _buildValidatedField(
                      'email'.tr(),
                      _emailController,
                      Icons.email_outlined,
                      validator: Validators.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildValidatedField(
                      'phone_number'.tr(),
                      _phoneController,
                      Icons.phone_outlined,
                      validator: Validators.validatePhone,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildDatePickerField(),
                    // Gender dropdown
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCard
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down,
                              color: Colors.grey[600]),
                          value: _selectedGender,
                          dropdownColor: isDark
                              ? AppColors.darkCard
                              : Colors.white,
                          items: _genderKeys
                              .map((key) => DropdownMenuItem(
                                    value: key,
                                    child: Text(key.tr(),
                                        style:
                                            TextStyle(color: textColor)),
                                  ))
                              .toList(),
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

            // ── TAB 2: Health Profile ─────────────────────────────────
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Allergies list-builder ────────────────────────
                  _buildListBuilderSection(
                    isDark: isDark,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    title: 'food_allergies_optional'.tr(),
                    instruction: 'food_allergy_text_instruction'.tr(),
                    hintText: 'enter_allergies'.tr(),
                    prefixIcon: Icons.warning_amber_rounded,
                    controller: _allergyInputController,
                    focusNode: _allergyFocusNode,
                    items: _allergiesList,
                    chipColor: AppColors.frovyAmber,
                    chipBg: isDark
                        ? AppColors.frovyAmber.withValues(alpha: 0.18)
                        : const Color(0xFFFFF8E1),
                    onAdd: _addAllergy,
                    onRemove: _removeAllergy,
                    semanticsLabel: 'Enter food allergy',
                  ),

                  const SizedBox(height: 32),

                  // ── Conditions list-builder ───────────────────────
                  _buildListBuilderSection(
                    isDark: isDark,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    title: 'medical_conditions_required'.tr(),
                    instruction: 'medical_conditions_instruction'.tr(),
                    hintText: 'enter_conditions'.tr(),
                    prefixIcon: Icons.medical_information_rounded,
                    controller: _conditionInputController,
                    focusNode: _conditionFocusNode,
                    items: _conditionsList,
                    chipColor: AppColors.frovyGreen,
                    chipBg: isDark
                        ? AppColors.frovyGreen.withValues(alpha: 0.18)
                        : AppColors.frovyLightGreen,
                    onAdd: _addCondition,
                    onRemove: _removeCondition,
                    semanticsLabel: 'Enter medical condition',
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable list-builder section (identical pattern to login_step2) ──────

  Widget _buildListBuilderSection({
    required bool isDark,
    required Color textColor,
    required Color subtitleColor,
    required String title,
    required String instruction,
    required String hintText,
    required IconData prefixIcon,
    required TextEditingController controller,
    required FocusNode focusNode,
    required List<String> items,
    required Color chipColor,
    required Color chipBg,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
    required String semanticsLabel,
  }) {
    final inputBgColor = isDark ? AppColors.darkCard : AppColors.lightChipBg;
    final inputTextColor = isDark ? Colors.white : AppColors.lightText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Semantics(
          header: true,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Instruction
        Text(
          instruction,
          style: TextStyle(fontSize: 13, color: subtitleColor),
        ),
        const SizedBox(height: 16),

        // Input row: TextField + "+" button
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Semantics(
                textField: true,
                label: semanticsLabel,
                child: Container(
                  decoration: BoxDecoration(
                    color: inputBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    style:
                        TextStyle(color: inputTextColor, fontSize: 15),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => onAdd(),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: subtitleColor,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(prefixIcon,
                          color: subtitleColor, size: 22),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: inputBgColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // "+" Add button — identical to login_step2
            Semantics(
              button: true,
              label: 'Add item',
              child: GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.frovyGreen,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColors.frovyGreen.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 26),
                ),
              ),
            ),
          ],
        ),

        // Chips — identical to login_step2
        if (items.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              items.length,
              (index) => _buildDismissibleChip(
                label: items[index],
                chipColor: chipColor,
                chipBg: chipBg,
                onRemove: () => onRemove(index),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Dismissible chip (identical to login_step2) ───────────────────────────

  Widget _buildDismissibleChip({
    required String label,
    required Color chipColor,
    required Color chipBg,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: chipColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: chipColor,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded,
                  size: 12, color: chipColor),
            ),
          ),
        ],
      ),
    );
  }

  // ── Personal tab helpers ──────────────────────────────────────────────────

  Widget _buildValidatedField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.lightText,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? AppColors.darkSubtitle : Colors.grey,
          ),
          prefixIcon: Icon(icon, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark ? AppColors.darkCard : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDatePickerField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: TextFormField(
        controller: _dobController,
        readOnly: true,
        validator: Validators.validateDate,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.lightText,
        ),
        decoration: InputDecoration(
          labelText: 'date_of_birth'.tr(),
          labelStyle: TextStyle(
            color: isDark ? AppColors.darkSubtitle : Colors.grey,
          ),
          prefixIcon:
              const Icon(Icons.calendar_today, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark ? AppColors.darkCard : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16),
        ),
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate:
                DateTime.tryParse(_dobController.text) ??
                    DateTime(2000, 1, 1),
            firstDate: DateTime(1920),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() {
              _dobController.text =
                  '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
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
              color: AppColors.frovyGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person,
                size: 60, color: AppColors.frovyGreen),
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
              child: const Icon(Icons.camera_alt,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}