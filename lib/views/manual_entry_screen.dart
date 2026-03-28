import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../util/app_colors.dart';
import 'output/output_screen.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final List<String> _manualIngredients = [];

  // ── List management ───────────────────────────────────────────────────────

  void _addIngredient() {
    final text = _ingredientController.text.trim();
    if (text.isEmpty) return;
    if (_manualIngredients.any((e) => e.toLowerCase() == text.toLowerCase())) {
      _ingredientController.clear();
      return;
    }
    setState(() => _manualIngredients.add(text));
    _ingredientController.clear();
    _inputFocusNode.requestFocus();
  }

  void _removeIngredient(int index) =>
      setState(() => _manualIngredients.removeAt(index));

  // ── Navigate to OutputScreen ──────────────────────────────────────────────

  void _analyzeIngredients() {
    if (_manualIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("error_empty".tr()),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.frovyRed,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OutputScreen(
          ingredients: List<String>.from(_manualIngredients),
          isProductSearch: false,
          productName: null,
          brandName: null,
          analysisType: 'manual_entry',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentBg =
        isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF2F7F2);
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final subtitleColor =
        isDark ? AppColors.darkSubtitle : AppColors.lightSubtitle;
    final inputBg = isDark ? AppColors.darkCard : const Color(0xFFF5F3EF);
    final inputTextColor = isDark ? Colors.white : AppColors.lightText;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
            "manual_title".tr(),
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
                  color: contentBg,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  children: [
                    // ── Instruction card ─────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: AppColors.frovyGreen
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                                Icons.add_circle_outline_rounded,
                                color: AppColors.frovyGreen,
                                size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "manual_hint".tr(),
                              style: TextStyle(
                                fontSize: 13,
                                color: subtitleColor,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Input row ─────────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "manual_example".tr(),
                            style: TextStyle(
                              fontSize: 12,
                              color: subtitleColor,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: inputBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: _ingredientController,
                                    focusNode: _inputFocusNode,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: inputTextColor,
                                      height: 1.4,
                                    ),
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _addIngredient(),
                                    decoration: InputDecoration(
                                      hintText:
                                          'e.g. Sugar, Palm Oil, Lecithin…',
                                      hintStyle: TextStyle(
                                        color: subtitleColor,
                                        fontSize: 13,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.science_outlined,
                                        color: subtitleColor,
                                        size: 20,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: inputBg,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: _addIngredient,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.frovyGreen,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.frovyGreen
                                            .withValues(alpha: 0.35),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Ingredients list card ─────────────────────────────
                    if (_manualIngredients.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: AppColors.frovyGreen
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.checklist_rounded,
                                    color: AppColors.frovyGreen,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Added Ingredients',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.frovyText,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.frovyGreen
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_manualIngredients.length}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.frovyGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(
                                _manualIngredients.length,
                                (index) => _buildIngredientChip(
                                  label: _manualIngredients[index],
                                  index: index,
                                  isDark: isDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(
                              Icons.playlist_add_rounded,
                              size: 40,
                              color: subtitleColor.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No ingredients added yet.\nType an ingredient above and tap +',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: subtitleColor,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        // ── Analyse button pinned at bottom ───────────────────────────────
        bottomNavigationBar: Container(
          color: contentBg,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _analyzeIngredients,
              icon: const Icon(Icons.search_rounded, size: 20),
              label: Text(
                "analyze_btn".tr(),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _manualIngredients.isEmpty
                    ? AppColors.frovyGreen.withValues(alpha: 0.45)
                    : AppColors.frovyGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientChip({
    required String label,
    required int index,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.frovyGreen.withValues(alpha: 0.18)
            : AppColors.frovyLightGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.frovyGreen.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.frovyGreen),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeIngredient(index),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.frovyGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  size: 12, color: AppColors.frovyGreen),
            ),
          ),
        ],
      ),
    );
  }
}