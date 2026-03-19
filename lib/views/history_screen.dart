import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORT FOR .tr()
import 'result_screen.dart'; 
import '../util/app_colors.dart';
import '../util/page_transitions.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Brand Colors
  final Color frovyGreen = AppColors.frovyGreen;
  final Color frovyRed = AppColors.frovyRed;
  final Color frovyAmber = AppColors.frovyAmber;

  // --- MOCK DATA: List of History Items ---
  // In a real app, this would come from a database (SQLite/Firebase)
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

  // --- LOGIC: Delete Single Item ---
  void _deleteItem(int index) {
    setState(() {
      historyItems.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("item_deleted".tr()), duration: const Duration(seconds: 1)),
    );
  }

  // --- LOGIC: Clear All History ---
  void _clearAllHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("clear_history".tr()),
        content: Text("clear_history_desc".tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr()),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                historyItems.clear();
              });
              Navigator.pop(context);
            },
            child: Text("clear_all".tr(), style: TextStyle(color: frovyRed)),
          ),
        ],
      ),
    );
  }

  // --- LOGIC: Navigate to Details ---
  void _navigateToResult(Map<String, dynamic> item) {
    Map<String, dynamic> resultData = {
      "productName": item['productName'],
      "status": item['status'],
      "ingredients": item['ingredients'],
      "warnings": item['warnings']
    };

    Navigator.push(
      context,
      PageTransitions.fade(
        ResultScreen(analysisResult: jsonEncode(resultData)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate Summary Stats dynamically
    int totalScans = historyItems.length;
    int safeCount = historyItems.where((i) => i['status'] == 'SAFE').length;
    int flaggedCount = historyItems.where((i) => i['status'] != 'SAFE').length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? null : frovyGreen,
      appBar: AppBar(
        backgroundColor: isDark ? null : frovyGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "analysis_history".tr(),
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // 1. Summary Statistics Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("summary".tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(totalScans.toString(), "total_scans".tr()),
                      _buildSummaryItem(safeCount.toString(), "safe_products".tr(), color: frovyGreen),
                      _buildSummaryItem(flaggedCount.toString(), "flagged".tr(), color: frovyRed),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 2. The List of History Items
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: isDark
                  ? null
                  : BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [frovyGreen, frovyGreen.withValues(alpha: 0.8), const Color(0xFFFFF9C4)],
                      ),
                    ),
              child: historyItems.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      itemCount: historyItems.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = historyItems[index];
                        return _buildHistoryCard(index, item);
                      },
                    ),
            ),
          ),
          
          // 3. Clear History Button 
          if (historyItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _clearAllHistory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("clear_all_history".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.white.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            "no_scan_history".tr(),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "scan_to_see_here".tr(),
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, {Color color = Colors.black}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(int index, Map<String, dynamic> item) {
    String status = item['status'];
    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    if (status == "SAFE") {
      statusColor = frovyGreen;
      statusIcon = Icons.check_circle_outline;
      statusLabel = "status_good".tr();
    } else if (status == "UNSAFE") {
      statusColor = frovyRed;
      statusIcon = Icons.cancel_outlined;
      statusLabel = "status_bad".tr();
    } else {
      statusColor = frovyAmber;
      statusIcon = Icons.warning_amber_rounded;
      statusLabel = "status_medium".tr();
    }

    return GestureDetector(
      onTap: () => _navigateToResult(item), 
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2C2C2C)
              : Colors.white,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['productName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(item['date'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel, 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['summary'],
                  style: TextStyle(
                    color: status == "UNSAFE"
                        ? Colors.red[700]
                        : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[700]),
                    fontSize: 13,
                  ),
                ),
                // Delete Icon Button
                InkWell(
                  onTap: () => _deleteItem(index),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}