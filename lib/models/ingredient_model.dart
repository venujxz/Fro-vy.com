class IngredientModel {
  final String name;
  final String category; // 'beneficial', 'caution', 'avoid'
  final String reason;

  IngredientModel({
    required this.name,
    required this.category,
    required this.reason,
  });

  factory IngredientModel.fromMap(Map<String, dynamic> map) {
    return IngredientModel(
      name: map['name'] ?? '',
      category: (map['category'] ?? 'unknown').toString().toLowerCase(),
      reason: map['reason'] ?? 'No reason provided.',
    );
  }
}
