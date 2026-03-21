import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // Import localization
import 'result_screen.dart';
import 'dart:convert';
import '../util/app_colors.dart';
import '../util/page_transitions.dart';

class SearchProductsScreen extends StatefulWidget {
  const SearchProductsScreen({super.key});

  @override
  State<SearchProductsScreen> createState() => _SearchProductsScreenState();
}

class _SearchProductsScreenState extends State<SearchProductsScreen> {
  final Color frovyGreen = AppColors.frovyGreen;
  String selectedCategory = "cat_all";
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtered products based on category + search query
  List<Map<String, dynamic>> get _filteredProducts {
    return products.where((product) {
      final matchesCategory = selectedCategory == "cat_all" || product['category'] == selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          (product['productName'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Define categories using their localization keys
  final List<String> categories = [
    "cat_all", 
    "cat_dairy", 
    "cat_snacks", 
    "cat_beverages", 
    "cat_bakery"
  ];

  // Mock database using new beneficial/caution/avoid format
  final List<Map<String, dynamic>> products = [
    {
      "productName": "Greek Yogurt",
      "category": "cat_dairy",
      "beneficial": ["Probiotics", "Calcium", "Protein"],
      "caution": [],
      "avoid": [],
    },
    {
      "productName": "Milk Chocolate",
      "category": "cat_snacks",
      "beneficial": ["Iron"],
      "caution": ["Sugar", "Milk"],
      "avoid": ["Peanuts"],
    },
    {
      "productName": "Oat Milk",
      "category": "cat_dairy",
      "beneficial": ["Fiber", "Vitamin D", "Calcium"],
      "caution": [],
      "avoid": [],
    },
    {
      "productName": "Potato Chips",
      "category": "cat_snacks",
      "beneficial": [],
      "caution": ["Sodium", "MSG"],
      "avoid": ["Vegetable Oil"],
    },
  ];

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
          "search_title".tr(), 
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: "search_hint".tr(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = "");
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
                String catKey = categories[index];
                bool isSelected = selectedCategory == catKey;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(catKey.tr()), // Localized text
                    selected: isSelected,
                    onSelected: (val) => setState(() => selectedCategory = catKey),
                    selectedColor: frovyGreen,
                    backgroundColor: Colors.white,
                    shape: StadiumBorder(side: BorderSide(color: Colors.grey[200]!)),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // 3. Product List (filtered)
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          "no_results_found".tr(),
                          style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "try_different_search".tr(),
                          style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(_filteredProducts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(product['productName'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          (product['category'] as String).tr(), // Localize the category label in the card
          style: TextStyle(color: Colors.grey[600], fontSize: 12)
        ),
        trailing: Icon(Icons.chevron_right, color: frovyGreen),
        onTap: () {
          Navigator.push(
            context,
            PageTransitions.fade(
              ResultScreen(analysisResult: jsonEncode(product)),
            ),
          );
        },
      ),
    );
  }
}
