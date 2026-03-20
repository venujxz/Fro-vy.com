import '../models/ingredient_model.dart';

/// The result of checking a list of ingredients against the database
class CheckResult {
  final List<IngredientModel> beneficial;
  final List<IngredientModel> caution;
  final List<IngredientModel> avoid;
  final List<String> unknown; // ingredients NOT found in our database

  CheckResult({
    required this.beneficial,
    required this.caution,
    required this.avoid,
    required this.unknown,
  });

  int get total =>
      beneficial.length + caution.length + avoid.length + unknown.length;
}

class IngredientCheckerService {
  /// Matches each ingredient string against the database
  /// Uses exact match first, then partial match fallback
  CheckResult checkIngredients(
      List<String> ingredients,
      Map<String, IngredientModel> database,
      ) {
    final beneficial = <IngredientModel>[];
    final caution = <IngredientModel>[];
    final avoid = <IngredientModel>[];
    final unknown = <String>[];

    for (final raw in ingredients) {
      final key = raw.trim().toLowerCase();
      if (key.isEmpty) continue;

      IngredientModel? found = database[key];

      // Partial match fallback: check if any DB key is contained in ingredient or vice versa
      if (found == null) {
        for (final dbKey in database.keys) {
          if (key.contains(dbKey) || dbKey.contains(key)) {
            found = database[dbKey];
            break;
          }
        }
      }

      if (found != null) {
        switch (found.category) {
          case 'beneficial':
            beneficial.add(found);
            break;
          case 'caution':
            caution.add(found);
            break;
          case 'avoid':
            avoid.add(found);
            break;
          default:
            unknown.add(raw.trim());
        }
      } else {
        unknown.add(raw.trim());
      }
    }

    return CheckResult(
      beneficial: beneficial,
      caution: caution,
      avoid: avoid,
      unknown: unknown,
    );
  }
}
