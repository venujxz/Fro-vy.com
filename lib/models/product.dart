/// Represents a product in the search database.
class Product {
  final String name;
  final String category; // Localization key e.g. "cat_dairy"
  final String status; // "SAFE", "UNSAFE", "CAUTION"
  final List<String> ingredients;

  const Product({
    required this.name,
    required this.category,
    required this.status,
    required this.ingredients,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'status': status,
    'ingredients': ingredients,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    name: json['name'] ?? '',
    category: json['category'] ?? 'cat_all',
    status: json['status'] ?? 'CAUTION',
    ingredients: (json['ingredients'] as List<dynamic>?)?.cast<String>() ?? [],
  );
}
