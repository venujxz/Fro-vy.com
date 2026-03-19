/// Represents a single scan/analysis result.
class ScanResult {
  final String productName;
  final String status; // "SAFE", "UNSAFE", or "CAUTION"
  final List<String> ingredients;
  final String date;
  final String? analysisJson; // Full backend response JSON for ResultScreen

  ScanResult({
    required this.productName,
    required this.status,
    required this.ingredients,
    required this.date,
    this.analysisJson,
  });

  Map<String, dynamic> toJson() => {
    'productName': productName,
    'status': status,
    'ingredients': ingredients,
    'date': date,
    'analysisJson': analysisJson,
  };

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
    productName: json['productName'] ?? 'Unknown Product',
    status: json['status'] ?? 'CAUTION',
    ingredients: (json['ingredients'] as List<dynamic>?)?.cast<String>() ?? [],
    date: json['date'] ?? '',
    analysisJson: json['analysisJson'],
  );
}
