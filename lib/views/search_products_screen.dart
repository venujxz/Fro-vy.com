import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'output/output_screen.dart';

class SearchProductsScreen extends StatefulWidget {
  const SearchProductsScreen({super.key});

  @override
  State<SearchProductsScreen> createState() => _SearchProductsScreenState();
}

class _SearchProductsScreenState extends State<SearchProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Test user data from home screen
  static const Map<String, dynamic> _testUserProfile = {
    'name': 'Kamal Perera',
    'gender': 'Male',
    'dob': '1990-05-15',
    'conditions': ['Diabetes', 'High Blood Pressure'],
    'foodAllergies': ['Peanuts', 'Dairy Intolerance'],
  };

  void _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _products = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final firestoreService = FirestoreService();
      final results = await firestoreService.searchProducts(query);
      setState(() {
        _products = results;
        _isLoading = false;
      });
    } catch (firebaseError) {
      debugPrint('Firebase searchProducts error: $firebaseError');
      // If search fails, show error and suggest manual entry
      setState(() {
        _errorMessage =
            'Could not connect to product database. Try manual entry instead.';
        _products = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
        backgroundColor: const Color(0xFF6AA15E),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _searchProducts,
            ),
          ),
          if (_isLoading)
            const CircularProgressIndicator()
          else if (_errorMessage.isNotEmpty)
            Text(_errorMessage, style: const TextStyle(color: Colors.red))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ListTile(
                    title: Text(product['productName'] ?? 'Unknown Product'),
                    subtitle: Text(product['brandName'] ?? 'Unknown Brand'),
                    onTap: () {
                      final ingredients = List<String>.from(
                        product['ingredients'] ?? [],
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OutputScreen(
                            ingredients: ingredients,
                            isProductSearch: true,
                            productName: product['productName'],
                            brandName: product['brandName'],
                            testUserData:
                                _testUserProfile, // Use test data as per user request
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
