import 'package:flutter/material.dart';
import 'result_screen.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  
  // Brand Colors
  final Color frovyGreen = const Color(0xFF6AA15E);
  final Color frovyBeige = const Color(0xFFEEE8D6);
  final Color frovyText = const Color(0xFF2C3E28);

  void _analyzeText() {
    final String text = _ingredientController.text.trim();
    
    // FIXED: Changed 'lexl' typo to 'text'
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter some ingredients first.")),
      );
      return;
    }

    // Mock data for your new Analysis Screen
    String mockResult = '{"productName": "Manual Entry Item", "beneficial": ["Fiber", "Protein"], "caution": ["Sodium"], "avoid": ["Artificial Color"]}';
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultScreen(analysisResult: mockResult)),
    );
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Manual Entry", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _ingredientController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: "Type ingredients here...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _analyzeText,
                style: ElevatedButton.styleFrom(backgroundColor: frovyGreen),
                child: const Text("Analyze Ingredients", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}