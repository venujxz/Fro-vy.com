import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../util/app_colors.dart';

class ResultScreen extends StatefulWidget {
  final String analysisResult;

  const ResultScreen({super.key, required this.analysisResult});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    // Robust JSON parsing
    Map<String, dynamic> data;
    try {
      data = jsonDecode(widget.analysisResult);
    } catch (e) {
      data = {};
    }

    // Support both 'productName' (new format) and 'name' (search product fallback)
    String productName = data['productName'] ?? data['name'] ?? "scanned_product".tr();
    List<dynamic> beneficial = data['beneficial'] ?? [];
    List<dynamic> caution    = data['caution']    ?? [];
    List<dynamic> avoid      = data['avoid']      ?? [];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "analysis_results_title".tr(),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Product name
            Text(
              productName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Pie chart placeholder
            const Center(
              child: Icon(Icons.pie_chart, size: 100, color: AppColors.frovyGreen),
            ),

            const SizedBox(height: 30),

            // Three category tiles
            _buildExpansionTile(
              "result_beneficial".tr(), beneficial, AppColors.frovyGreen, isDark),
            _buildExpansionTile(
              "result_caution".tr(),    caution,    AppColors.frovyAmber,  isDark),
            _buildExpansionTile(
              "result_avoid".tr(),      avoid,      AppColors.frovyRed,    isDark),

            const SizedBox(height: 24),

            // Check another product button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.frovyGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "check_another_product".tr(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Medical disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.frovyBeige,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "medical_disclaimer".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey[700], height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(
      String title, List<dynamic> items, Color color, bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: isDark ? 0 : 1,
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        children: items.isEmpty
            ? [
                ListTile(
                  title: Text(
                    "—",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                )
              ]
            : items
                .map(
                  (item) => ListTile(
                    leading: Icon(Icons.circle, size: 8, color: color),
                    title: Text(
                      item.toString(),
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}