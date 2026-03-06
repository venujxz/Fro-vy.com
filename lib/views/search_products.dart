import 'package:flutter/material.dart';
import 'result_screen.dart';
import 'dart:convert';

class SearchProductsScreen extends StatefulWidget {
  const SearchProductsScreen({super.key});

  @override
  State<SearchProductsScreen> createState() => _SearchProductsScreenState();
}

class _SearchProductsScreenState extends State<SearchProductsScreen> {
  final Color frovyGreen = const Color(0xFF6AA15E);
  String selectedCategory = "All";
  
  final List<String> categories = ["All", "Dairy", "Snacks", "Beverages", "Bakery"];

  // Mock Database
  final List<Map<String, dynamic>> products = [
    {"name": "Greek Yogurt", "category": "Dairy", "status": "SAFE", "ingredients": ["Milk", "Live Cultures"]},
    {"name": "Milk Chocolate", "category": "Snacks", "status": "UNSAFE", "ingredients": ["Milk", "Sugar", "Cocoa Butter", "Peanuts"]},
    {"name": "Oat Milk", "category": "Dairy", "status": "SAFE", "ingredients": ["Water", "Oats", "Sea Salt"]},
    {"name": "Potato Chips", "category": "Snacks", "status": "CAUTION", "ingredients": ["Potatoes", "Vegetable Oil", "Salt", "MSG"]},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Search Products", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by brand or product name...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
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
          ),

          // 2. Categories
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedCategory == categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(categories[index]),
                    selected: isSelected,
                    onSelected: (val) => setState(() => selectedCategory = categories[index]),
                    selectedColor: frovyGreen,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // 3. Product List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                if (selectedCategory != "All" && product['category'] != selectedCategory) {
                  return const SizedBox.shrink();
                }
                return _buildProductCard(product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(product['category'], style: TextStyle(color: Colors.grey[600])),
        trailing: Icon(Icons.chevron_right, color: frovyGreen),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(analysisResult: jsonEncode(product)),
            ),
          );
        },
      ),
    );
  }
}