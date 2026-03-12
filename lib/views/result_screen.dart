import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORT FOR .tr()
import '../util/app_colors.dart';

class ResultScreen extends StatefulWidget {
  final String analysisResult;

  const ResultScreen({super.key, required this.analysisResult});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // Brand Colors from centralized AppColors
  static const Color frovyGreen = AppColors.frovyGreen;
  static const Color frovyRed = AppColors.frovyRed;
  static const Color frovyAmber = AppColors.frovyAmber;
  static const Color frovyBeige = AppColors.frovyBeige;
  static const Color frovyLightGreen = AppColors.frovyLightGreen;
  static const Color frovyLightRed = AppColors.frovyLightRed;
  static const Color frovyLightAmber = AppColors.frovyLightAmber;

  @override
  Widget build(BuildContext context) {
    // 1. Parse Data (Robust parsing for Safety)
    Map<String, dynamic> data;
    try {
      data = jsonDecode(widget.analysisResult);
    } catch (e) {
      data = {};
    }

    // Default values if data is missing
    String productName = data['productName'] ?? "scanned_product".tr();
    String status = data['status'] ?? "UNKNOWN"; // SAFE, UNSAFE, CAUTION
    List<dynamic> ingredients = data['ingredients'] ?? [];
    List<dynamic> warnings = data['warnings'] ?? []; 
    // Warnings can be specific: "Contains Peanuts", "Interacts with Aspirin"

    // 2. Determine Theme based on Report Logic (Toxicity, Allergy, Meds)
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;
    String mainTitle;
    String mainDescription;

    if (status == "SAFE") {
      statusColor = frovyGreen;
      statusBgColor = frovyLightGreen;
      statusIcon = Icons.check_circle;
      mainTitle = "safe_title".tr();
      mainDescription = "safe_desc".tr();
    } else if (status == "UNSAFE") {
      statusColor = frovyRed;
      statusBgColor = frovyLightRed;
      statusIcon = Icons.cancel;
      mainTitle = "unsafe_title".tr();
      mainDescription = warnings.isNotEmpty ? warnings.join("\n") : "unsafe_desc".tr();
    } else {
      // CAUTION (e.g., Drug Interactions or ambiguous ingredients)
      statusColor = frovyAmber;
      statusBgColor = frovyLightAmber;
      statusIcon = Icons.warning_amber_rounded;
      mainTitle = "caution_title".tr();
      mainDescription = warnings.isNotEmpty ? warnings.join("\n") : "caution_desc".tr();
    }

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
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name Header
            Text(
              productName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // 3. The Main Status Card (Visual Badge)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: statusBgColor, 
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
              ),
              child: Column(
                children: [
                  Icon(statusIcon, size: 64, color: statusColor),
                  const SizedBox(height: 16),
                  Text(
                    mainTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    mainDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4. Ingredients Dropdown (Expansion Logic)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                    "${"all_ingredients".tr()} (${ingredients.length})",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          // List ingredients nicely
                          ...ingredients.map((ing) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.circle, size: 6, color: Colors.grey[400]),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        ing.toString(),
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 5. "Check Another Product" Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: frovyGreen,
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

            // 6. Medical Disclaimer (Required by Report Logic)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: frovyBeige, 
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
}