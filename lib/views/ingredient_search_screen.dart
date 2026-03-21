import 'package:flutter/material.dart';
import '../util/app_colors.dart';
import '../services/api_service.dart';

class IngredientSearchScreen extends StatefulWidget {
  const IngredientSearchScreen({super.key});

  @override
  State<IngredientSearchScreen> createState() => _IngredientSearchScreenState();
}

class _IngredientSearchScreenState extends State<IngredientSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  String _selectedCategory = 'all';
  List<Map<String, dynamic>> _ingredients = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadIngredients() async {
    setState(() => _isLoading = true);

    try {
      final result = await _apiService.getAllIngredients(
        category: _selectedCategory,
        limit: 50,
      );

      setState(() {
        _ingredients = List<Map<String, dynamic>>.from(result['results'] ?? []);
        _hasSearched = true;
      });
    } on ApiException catch (e) {
      debugPrint('API Error: ${e.message}');
      _loadPlaceholderData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading ingredients: $e')),
        );
      }
      _loadPlaceholderData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadPlaceholderData() {
    setState(() {
      _ingredients = [
        {
          'name': 'Cane Sugar',
          'category': 'caution',
          'reason': 'A simple carbohydrate that provides "empty" calories. While safe in small amounts, frequent consumption can lead to blood glucose spikes.',
        },
        {
          'name': 'High Fructose Corn Syrup',
          'category': 'avoid',
          'reason': 'A highly processed sweetener linked to increased rates of fatty liver, insulin resistance, and obesity.',
        },
        {
          'name': 'Whole Meal Flour',
          'category': 'beneficial',
          'reason': 'Sources of carbohydrates and fiber; whole grains specifically provide B vitamins and aid digestion.',
        },
      ];
      _hasSearched = true;
    });
  }

  Future<void> _searchIngredients() async {
    if (_searchController.text.isEmpty) {
      _loadIngredients();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _apiService.searchIngredients(
        _searchController.text,
        category: _selectedCategory,
        limit: 20,
      );

      setState(() {
        _ingredients = List<Map<String, dynamic>>.from(result['results'] ?? []);
        _hasSearched = true;
      });
    } on ApiException catch (e) {
      debugPrint('API Error: ${e.message}');
      // Fallback to local filter
      final query = _searchController.text.toLowerCase();
      setState(() {
        _ingredients = _ingredients
            .where((ing) => ing['name'].toString().toLowerCase().contains(query))
            .toList();
        _hasSearched = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'beneficial':
        return AppColors.frovyGreen;
      case 'caution':
        return AppColors.frovyYellow;
      case 'avoid':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'beneficial':
        return Icons.check_circle;
      case 'caution':
        return Icons.warning;
      case 'avoid':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: AppColors.frovyGreen,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chevron_left_rounded,
                color: Colors.white, size: 28),
          ),
        ),
        title: const Text(
          'Ingredient Database',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.frovyGreen,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _searchIngredients(),
                    decoration: InputDecoration(
                      hintText: 'Search ingredients...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.frovyGreen),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _loadIngredients();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('all', 'All', Colors.white),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                          'beneficial', 'Beneficial', AppColors.frovyGreen),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                          'caution', 'Caution', AppColors.frovyYellow),
                      const SizedBox(width: 8),
                      _buildCategoryChip('avoid', 'Avoid', Colors.red),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : !_hasSearched
                    ? _buildEmptyState()
                    : _ingredients.isEmpty
                        ? _buildNoResults()
                        : _buildResults(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String value, String label, Color color) {
    final isSelected = _selectedCategory == value;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = value);
        _searchIngredients();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: color, width: 2)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Search for ingredients',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Learn about ingredient safety',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No ingredients found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = _ingredients[index];
        return _buildIngredientCard(ingredient, isDark);
      },
    );
  }

  Widget _buildIngredientCard(Map<String, dynamic> ingredient, bool isDark) {
    final category = ingredient['category'] as String;
    final categoryColor = _getCategoryColor(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: categoryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ingredient['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.frovyText,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ingredient['reason'],
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
