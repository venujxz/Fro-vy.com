import 'dart:convert';
import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  final String analysisResult;

  const ResultScreen({super.key, required this.analysisResult});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  static const Color frovyGreen = Color(0xFF6AA15E);
  static const Color frovyRed = Color(0xFFD32F2F);
  static const Color frovyAmber = Color(0xFFFFA000);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = jsonDecode(widget.analysisResult);
    String productName = data['productName'] ?? "Product";
    
    // Ensure these are treated as Lists
    List<dynamic> beneficial = data['beneficial'] ?? [];
    List<dynamic> caution = data['caution'] ?? [];
    List<dynamic> avoid = data['avoid'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Analysis Results", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(productName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Placeholder for Pie Chart (Add fl_chart for the real one)
            const Center(child: Icon(Icons.pie_chart, size: 100, color: frovyGreen)),
            
            const SizedBox(height: 30),
            _buildExpansionTile("Beneficial", beneficial, frovyGreen),
            _buildExpansionTile("Caution", caution, frovyAmber),
            _buildExpansionTile("Avoid", avoid, frovyRed),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(String title, List<dynamic> items, Color color) {
    return Card(
      child: ExpansionTile(
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        children: items.map((i) => ListTile(title: Text(i.toString()))).toList(),
      ),
    );
  }
}