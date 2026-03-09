//--- only to test the app
import 'package:flutter/material.dart';
import '../output/output_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ── FAKE TEST DATA ─────────────────────────────────────────────────────────
  // These simulate what the real app would pass in.
  // Change these to test different scenarios.
  static const List<String> _testIngredients = [
    'Whole Milk',
    'Sugar',
    'Cane Sugar',
    'Natural Flavors',
    'Carrageenan-INS471',
    'Guar Gum-INS412',
    'Trisodium Phosphate',
    'Sodium Alginate',
    'Cocoa Powder',
    'Artificial Chocolate Flavours',
    'Vitamin D',
    'Some Unknown Ingredient XYZ',
    'Another Unknown ABC',
  ];

  static const Map<String, dynamic> _testUserProfile = {
    'name': 'Kamal Perera',
    'gender': 'Male',
    'dob': '1990-05-15',
    'conditions': ['Diabetes', 'High Blood Pressure'],
    'foodAllergies': ['Peanuts', 'Dairy Intolerance'],
  };
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      appBar: AppBar(
        title: const Text('Frovy — Output Test'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Test the Output Screen',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap a button below to simulate each entry method',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Simulate Product Search (shows product card at top)
              _buildButton(
                context,
                label: '🔍 Simulate Product Search',
                color: const Color(0xFF5C6BC0),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OutputScreen(
                      ingredients: _testIngredients,
                      isProductSearch: true,
                      productName: 'Chocolate Milk',
                      brandName: 'Kotmale',
                      testUserData: _testUserProfile,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Simulate Manual / Scan (no product card)
              _buildButton(
                context,
                label: '✏️ Simulate Manual / Scan Entry',
                color: const Color(0xFF26A69A),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OutputScreen(
                      ingredients: _testIngredients,
                      isProductSearch: false,
                      testUserData: _testUserProfile,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String label,
        required Color color,
        required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
