import 'dart:convert';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../services/history_service.dart';
=======
import 'package:easy_localization/easy_localization.dart';
import '../util/app_colors.dart';
>>>>>>> upstream/main

class ResultScreen extends StatefulWidget {
  final String analysisResult;
  const ResultScreen({super.key, required this.analysisResult});
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

<<<<<<< HEAD
class _ResultScreenState extends State<ResultScreen> {
  static const Color frovyGreen = Color(0xFF6AA15E);
  static const Color frovyRed = Color(0xFFD32F2F);
  static const Color frovyAmber = Color(0xFFFFA000);
  static const Color frovyBeige = Color(0xFFEEE8D6);
  static const Color frovyLightGreen = Color(0xFFE8F5E9);
  static const Color frovyLightRed = Color(0xFFFFEBEE);
  static const Color frovyLightAmber = Color(0xFFFFF8E1);
=======
class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
>>>>>>> upstream/main

  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    if (_saved) return;
    _saved = true;
    Map<String, dynamic> data;
    try {
      data = jsonDecode(widget.analysisResult);
    } catch (e) {
      return;
    }
    final String status = data['status'] ?? 'UNKNOWN';
    final String productName = data['productName'] ?? 'Scanned Product';
    final List<String> ingredients = List<String>.from(data['ingredients'] ?? []);
    final List<String> warnings = List<String>.from(data['warnings'] ?? []);
    String summary;
    if (status == 'SAFE') {
      summary = "All ${ingredients.length} ingredients reviewed — looks great!";
    } else if (status == 'UNSAFE') {
      summary = "${warnings.length} flagged issue${warnings.length == 1 ? '' : 's'} — best to avoid this product.";
    } else {
      summary = "${warnings.length} ingredient${warnings.length == 1 ? '' : 's'} need your attention.";
    }
    await HistoryService().saveScan(
      productName: productName,
      status: status,
      ingredients: ingredients,
      warnings: warnings,
      summary: summary,
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(widget.analysisResult);
    } catch (_) {
      data = {};
    }

<<<<<<< HEAD
    String productName = data['productName'] ?? "Scanned Product";
    String status = data['status'] ?? "UNKNOWN";
    List<dynamic> ingredients = data['ingredients'] ?? [];
    List<dynamic> warnings = data['warnings'] ?? [];

    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;
    String mainTitle;
    String mainDescription;

    if (status == "SAFE") {
      statusColor = frovyGreen;
      statusBgColor = frovyLightGreen;
      statusIcon = Icons.check_circle;
      mainTitle = "Safe to Consume";
      mainDescription = "This product does not contain any ingredients that conflict with your health profile. It appears safe for you to consume.";
    } else if (status == "UNSAFE") {
      statusColor = frovyRed;
      statusBgColor = frovyLightRed;
      statusIcon = Icons.cancel;
      mainTitle = "Avoid This Product";
      mainDescription = warnings.isNotEmpty ? warnings.join("\n") : "This product contains ingredients that may be harmful to you.";
    } else {
      statusColor = frovyAmber;
      statusBgColor = frovyLightAmber;
      statusIcon = Icons.warning_amber_rounded;
      mainTitle = "Use with Caution";
      mainDescription = warnings.isNotEmpty ? warnings.join("\n") : "Some ingredients may interact with your medication or have moderate toxicity.";
    }

    return Scaffold(
      backgroundColor: Colors.white,
=======
    final String productName = data['productName'] ?? data['name'] ?? "scanned_product".tr();
    final List<dynamic> beneficial = data['beneficial'] ?? [];
    final List<dynamic> caution = data['caution'] ?? [];
    final List<dynamic> avoid = data['avoid'] ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine overall status
    final _OverallStatus overallStatus = avoid.isNotEmpty
        ? _OverallStatus.avoid
        : caution.isNotEmpty
            ? _OverallStatus.caution
            : _OverallStatus.safe;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.frovyGreen,
>>>>>>> upstream/main
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
<<<<<<< HEAD
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Analysis Results", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
=======
>>>>>>> upstream/main
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
          ),
        ),
        title: Text(
          "analysis_results_title".tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: Column(
          children: [
<<<<<<< HEAD
            Text(productName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Column(
                children: [
                  Icon(statusIcon, size: 64, color: statusColor),
                  const SizedBox(height: 16),
                  Text(mainTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: statusColor)),
                  const SizedBox(height: 12),
                  Text(mainDescription, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text("All Ingredients (${ingredients.length})", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
=======
            // ── Hero summary card ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
>>>>>>> upstream/main
                  children: [
                    // Status circle
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: overallStatus.lightBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(overallStatus.icon, color: overallStatus.color, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
<<<<<<< HEAD
                          const Divider(),
                          ...ingredients.map((ing) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.circle, size: 6, color: Colors.grey[400]),
                                const SizedBox(width: 8),
                                Expanded(child: Text(ing.toString(), style: TextStyle(color: Colors.grey[700]))),
                              ],
                            ),
                          )),
=======
                          Text(
                            productName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.frovyText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: overallStatus.color,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              overallStatus.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
>>>>>>> upstream/main
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
<<<<<<< HEAD
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: frovyGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Check Another Product", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: frovyBeige, borderRadius: BorderRadius.circular(8)),
              child: Text(
                "This analysis is based on your health profile and our ingredient database. Always consult with a healthcare professional for medical advice.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4),
=======

            // ── Ingredient breakdown ───────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF2F7F2),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ingredient count chips row
                      Row(
                        children: [
                          _buildCountChip(
                            beneficial.length, "result_beneficial".tr(), AppColors.frovyGreen, isDark),
                          const SizedBox(width: 8),
                          _buildCountChip(
                            caution.length, "result_caution".tr(), AppColors.frovyAmber, isDark),
                          const SizedBox(width: 8),
                          _buildCountChip(
                            avoid.length, "result_avoid".tr(), AppColors.frovyRed, isDark),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Category cards
                      _buildCategoryCard(
                        context,
                        title: "result_beneficial".tr(),
                        items: beneficial,
                        color: AppColors.frovyGreen,
                        lightBg: AppColors.frovyLightGreen,
                        icon: Icons.check_circle_rounded,
                        emptyMsg: "no_concerns_here".tr(),
                        isDark: isDark,
                      ),

                      const SizedBox(height: 12),

                      _buildCategoryCard(
                        context,
                        title: "result_caution".tr(),
                        items: caution,
                        color: AppColors.frovyAmber,
                        lightBg: AppColors.frovyLightAmber,
                        icon: Icons.warning_amber_rounded,
                        emptyMsg: "no_concerns_here".tr(),
                        isDark: isDark,
                      ),

                      const SizedBox(height: 12),

                      _buildCategoryCard(
                        context,
                        title: "result_avoid".tr(),
                        items: avoid,
                        color: AppColors.frovyRed,
                        lightBg: AppColors.frovyLightRed,
                        icon: Icons.block_rounded,
                        emptyMsg: "no_concerns_here".tr(),
                        isDark: isDark,
                      ),

                      const SizedBox(height: 24),

                      // CTA Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                          label: Text(
                            "check_another_product".tr(),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.frovyGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Disclaimer
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : AppColors.frovyBeige,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 16, color: Colors.grey[500]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "medical_disclaimer".tr(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
>>>>>>> upstream/main
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountChip(int count, String label, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required List<dynamic> items,
    required Color color,
    required Color lightBg,
    required IconData icon,
    required String emptyMsg,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          initiallyExpanded: items.isNotEmpty,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: lightBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              items.length.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          iconColor: color,
          collapsedIconColor: Colors.grey,
          children: [
            const Divider(height: 1, indent: 16, endIndent: 16),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(emptyMsg,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13)),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items.map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: lightBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.toString(),
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OverallStatus {
  final Color color;
  final Color lightBg;
  final IconData icon;
  final String label;

  const _OverallStatus._({
    required this.color,
    required this.lightBg,
    required this.icon,
    required this.label,
  });

  static _OverallStatus get avoid => _OverallStatus._(
    color: AppColors.frovyRed,
    lightBg: AppColors.frovyLightRed,
    icon: Icons.cancel_rounded,
    label: 'status_avoid'.tr(),
  );
  static _OverallStatus get caution => _OverallStatus._(
    color: AppColors.frovyAmber,
    lightBg: AppColors.frovyLightAmber,
    icon: Icons.warning_amber_rounded,
    label: 'status_caution'.tr(),
  );
  static _OverallStatus get safe => _OverallStatus._(
    color: AppColors.frovyGreen,
    lightBg: AppColors.frovyLightGreen,
    icon: Icons.verified_rounded,
    label: 'status_safe'.tr(),
  );
}