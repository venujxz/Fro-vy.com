import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ingredient_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Loads ALL ingredients from your Firestore 'ingredients' collection
  /// Returns a map of lowercase ingredient name → IngredientModel
  Future<Map<String, IngredientModel>> getAllIngredients() async {
    final snapshot = await _db.collection('ingredients').get();
    final map = <String, IngredientModel>{};
    for (var doc in snapshot.docs) {
      final ingredient = IngredientModel.fromMap(doc.data());
      map[ingredient.name.toLowerCase().trim()] = ingredient;
    }
    return map;
  }

  /// Gets a user's profile from Firestore using their UID
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  /// Saves a check to the user's search history
  Future<void> addToSearchHistory(
    String uid,
    Map<String, dynamic> entry,
  ) async {
    await _db.collection('users').doc(uid).update({
      'searchHistory': FieldValue.arrayUnion([entry]),
    });
  }

  /// Searches products by name (case insensitive, contains)
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final snapshot = await _db.collection('products').get();
    final products = snapshot.docs.map((doc) => doc.data()).toList();
    final lowerQuery = query.toLowerCase();
    return products.where((product) {
      final name = (product['productName'] as String?)?.toLowerCase() ?? '';
      return name.contains(lowerQuery);
    }).toList();
  }
}
