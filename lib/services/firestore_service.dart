import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ingredient_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Loads ALL ingredients from your Firestore 'ingredients' collection
  /// Returns a map of lowercase ingredient name → IngredientModel
  Future<Map<String, IngredientModel>> getAllIngredients() async {
    try {
      final snapshot = await _db.collection('ingredients').get();
      final map = <String, IngredientModel>{};
      for (var doc in snapshot.docs) {
        try {
          final ingredient = IngredientModel.fromMap(doc.data());
          map[ingredient.name.toLowerCase().trim()] = ingredient;
        } catch (e) {
          // Skip bad documents in the collection
          debugPrint('Skipping malformed ingredient: $e');
        }
      }
      return map;
    } catch (e) {
      debugPrint('Firebase getAllIngredients error: $e');
      rethrow; // Let the caller handle this
    }
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
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final snapshot = await _db.collection('products').get();

      if (snapshot.docs.isEmpty) {
        debugPrint('No products found in Firestore');
        return [];
      }

      final products = snapshot.docs
          .map((doc) {
            try {
              return doc.data();
            } catch (e) {
              debugPrint('Skipping malformed product document: $e');
              return null;
            }
          })
          .whereType<Map<String, dynamic>>()
          .toList();

      final lowerQuery = query.toLowerCase().trim();
      return products.where((product) {
        try {
          final name = (product['productName'] as String?)?.toLowerCase() ?? '';
          final brand = (product['brandName'] as String?)?.toLowerCase() ?? '';
          return name.contains(lowerQuery) || brand.contains(lowerQuery);
        } catch (e) {
          debugPrint('Error filtering product: $e');
          return false;
        }
      }).toList();
    } catch (e) {
      debugPrint('Firebase searchProducts error: $e');
      rethrow; // Let the UI handle this with a fallback
    }
  }
}
