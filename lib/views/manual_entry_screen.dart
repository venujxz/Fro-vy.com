import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORT
import 'result_screen.dart';
import 'dart:convert';
import '../util/app_colors.dart';
import '../util/page_transitions.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  
  final Color frovyGreen = AppColors.frovyGreen;

  void _analyzeText() {
    final String text = _ingredientController.text.trim();
    
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("error_empty".tr())), // LOCALIZED ERROR
      );
      return;
    }

    // Prepare mock data with localized product name
    Map<String, dynamic> mockData = {
      "productName": "manual_product_name".tr(),
      "status": "CAUTION", // Just for example
      "ingredients": text.split(','), // Simple split logic
      "warnings": ["Analysis based on text input"]
    };
    
    Navigator.push(
      context,
      PageTransitions.fade(
        ResultScreen(analysisResult: jsonEncode(mockData))
      ),
    );
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "manual_title".tr(), // LOCALIZED TITLE
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Added scroll view to prevent keyboard overflow
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _ingredientController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: "manual_hint".tr(), // LOCALIZED HINT
                filled: true,
                fillColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _analyzeText,
                style: ElevatedButton.styleFrom(
                  backgroundColor: frovyGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  "analyze_btn".tr(), // LOCALIZED BUTTON
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
