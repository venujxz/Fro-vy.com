import 'dart:convert';
import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  final String analysisResult;

  const ResultScreen({super.key, required this.analysisResult});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // Brand Colors from your design
  static const Color frovyGreen = Color(0xFF6AA15E);
  static const Color frovyRed = Color(0xFFD32F2F);
  static const Color frovyAmber = Color(0xFFFFA000);
  static const Color frovyBeige = Color(0xFFEEE8D6);
  static const Color frovyLightGreen = Color(0xFFE8F5E9);
  static const Color frovyLightRed = Color(0xFFFFEBEE);
  static const Color frovyLightAmber = Color(0xFFFFF8E1);

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
    String productName = data['productName'] ?? "Scanned Product";
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
      mainTitle = "Safe to Consume";
      mainDescription =
          "This product does not contain any ingredients that conflict with your health profile. It appears safe for you to consume.";
    } else if (status == "UNSAFE") {
      statusColor = frovyRed;
      statusBgColor = frovyLightRed;
      statusIcon = Icons.cancel;
      mainTitle = "Avoid This Product";
      // Construct dynamic warning message from list
      mainDescription = warnings.isNotEmpty
          ? warnings.join("\n") // Lists allergies or toxins
          : "This product contains ingredients that may be harmful to you.";
    } else {
      // CAUTION (e.g., Drug Interactions or ambiguous ingredients)
      statusColor = frovyAmber;
      statusBgColor = frovyLightAmber;
      statusIcon = Icons.warning_amber_rounded;
      mainTitle = "Use with Caution";
      mainDescription = warnings.isNotEmpty
          ? warnings.join("\n")
          : "Some ingredients may interact with your medication or have moderate toxicity.";
    }

    return Scaffold(
      backgroundColor: Colors.white, // Clean white background like screenshot
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Analysis Results",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // 3. The Main Status Card (Visual Badge)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: statusBgColor, // Light background (Green/Red/Amber)
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.5),
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
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                    "All Ingredients (${ingredients.length})",
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
                child: const Text(
                  "Check Another Product",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 6. Medical Disclaimer (Required by Report Logic)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: frovyBeige, // The beige color from your UI
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "This analysis is based on your health profile and our ingredient database. Always consult with a healthcare professional for medical advice.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}