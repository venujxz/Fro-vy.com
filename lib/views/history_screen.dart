import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'result_screen.dart';
import '../util/app_colors.dart';
import '../util/page_transitions.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> historyItems = [
    {
      "productName": "Almond Breeze Original",
      "date": "Nov 24, 2025",
      "status": "SAFE",
      "ingredients": ["Almondmilk", "Calcium Carbonate", "Sea Salt", "Sunflower Lecithin"],
      "warnings": [],
      "summary": "All 4 ingredients safe"
    },
    {
      "productName": "Skippy Peanut Butter",
      "date": "Nov 23, 2025",
      "status": "UNSAFE",
      "ingredients": ["Roasted Peanuts", "Sugar", "Hydrogenated Vegetable Oil", "Salt"],
      "warnings": ["Contains Peanuts (Allergen)", "High Sugar Content"],
      "summary": "2 of 4 ingredients flagged"
    },
    {
      "productName": "Coca-Cola Classic",
      "date": "Nov 22, 2025",
      "status": "CAUTION",
      "ingredients": ["Carbonated Water", "High Fructose Corn Syrup", "Caramel Color", "Phosphoric Acid", "Caffeine"],
      "warnings": ["High Fructose Corn Syrup (Sugar)", "Caffeine (Sensitivity)"],
      "summary": "2 of 5 ingredients flagged"
    },
  ];

  void _deleteItem(int index) {
    setState(() => historyItems.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("item_deleted".tr()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _clearAllHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("clear_history".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text("clear_history_desc".tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr(), style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => historyItems.clear());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.frovyRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text("clear_all".tr()),
          ),
        ],
      ),
    );
  }

  void _navigateToResult(Map<String, dynamic> item) {
    Navigator.push(
      context,
      PageTransitions.fade(
        ResultScreen(
          analysisResult: jsonEncode({
            "productName": item['productName'],
            "status": item['status'],
            "ingredients": item['ingredients'],
            "warnings": item['warnings'],
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int totalScans = historyItems.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.frovyGreen,
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
            child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
          ),
        ),
        title: Text(
          "analysis_history".tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── List Area ──────────────────────────────────
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF2F7F2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Section header
                  Padding(                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      children: [
                        Text(
                          "recent_scans".tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.frovyText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.frovyGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            totalScans.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.frovyGreen,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (historyItems.isNotEmpty)
                          GestureDetector(
                            onTap: _clearAllHistory,
                            child: Text(
                              "clear_all_history".tr(),
                              style: TextStyle(fontSize: 12, color: AppColors.frovyRed.withValues(alpha: 0.8)),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // List
                  Expanded(
                    child: historyItems.isEmpty
                        ? _buildEmptyState(isDark)
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                            itemCount: historyItems.length,
                            itemBuilder: (context, index) =>
                                _buildScanCard(index, historyItems[index], isDark),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Scan card ────────────────────────────────────────
  Widget _buildScanCard(int index, Map<String, dynamic> item, bool isDark) {
    final List<dynamic> ingredients = item['ingredients'] ?? [];
    final int extraCount = ingredients.length > 3 ? ingredients.length - 3 : 0;

    return GestureDetector(
      onTap: () => _navigateToResult(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: avatar + name/date
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.frovyGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.inventory_2_outlined,
                        color: AppColors.frovyGreen, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['productName'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.frovyText,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 11, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(
                              item['date'],
                              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Ingredient chips
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...ingredients.take(3).map(
                        (ing) => _buildChip(ing.toString(), isDark),
                      ),
                  if (extraCount > 0)
                    _buildChip('+$extraCount more', isDark, isMuted: true),
                ],
              ),

              const SizedBox(height: 14),

              // Footer
              Row(
                children: [
                  Icon(Icons.touch_app_outlined, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 6),
                  Text(
                    "tap_to_view_analysis".tr(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _deleteItem(index),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.frovyRed.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.frovyRed, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isDark, {bool isMuted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isMuted
            ? Colors.transparent
            : (isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMuted
              ? Colors.grey.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isMuted
              ? Colors.grey[500]
              : (isDark ? Colors.white70 : AppColors.frovyText),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.frovyGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_toggle_off_rounded,
                size: 56, color: AppColors.frovyGreen.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          Text(
            "no_scan_history".tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppColors.frovyText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "scan_to_see_here".tr(),
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }
}