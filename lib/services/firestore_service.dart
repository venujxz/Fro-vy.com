import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/ingredient_model.dart';
import '../models/user_model.dart';

/// NOTE: Health data is stored as plain text in Firestore.
/// Legacy encrypted strings (format "<base64>:<base64>") are automatically
/// detected and skipped, so old accounts display empty rather than garbled text.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Detect legacy encrypted string ───────────────────────────────────────
  static bool _looksEncrypted(String s) {
    final parts = s.split(':');
    if (parts.length != 2) return false;
    final base64Re = RegExp(r'^[A-Za-z0-9+/=]+$');
    return base64Re.hasMatch(parts[0]) &&
        base64Re.hasMatch(parts[1]) &&
        parts[0].length >= 20 &&
        parts[1].length >= 24;
  }

  static String _safeRead(String raw) {
    if (_looksEncrypted(raw)) return '';
    return raw.trim();
  }

  // ── Ingredients ───────────────────────────────────────────────────────────

  Future<Map<String, IngredientModel>> getAllIngredients() async {
    try {
      final snapshot = await _db.collection('ingredients').get();
      final map = <String, IngredientModel>{};
      for (var doc in snapshot.docs) {
        try {
          final ingredient = IngredientModel.fromMap(doc.data());
          map[ingredient.name.toLowerCase().trim()] = ingredient;
        } catch (e) {
          debugPrint('Skipping malformed ingredient: $e');
        }
      }
      return map;
    } catch (e) {
      debugPrint('Firebase getAllIngredients error: $e');
      rethrow;
    }
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  /// Reads the user document and returns a flat [UserModel].
  /// Handles both the new nested schema (profile / healthProfile sub-maps)
  /// and the old flat schema gracefully.
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;

      if (data.containsKey('profile')) {
        return _parseNestedSchema(uid, data);
      } else {
        return _parseFlatSchema(uid, data);
      }
    } catch (e) {
      debugPrint('FirestoreService.getUser error: $e');
      return null;
    }
  }

  UserModel _parseNestedSchema(String uid, Map<String, dynamic> data) {
    final profile =
        Map<String, dynamic>.from(data['profile'] as Map? ?? {});
    final health =
        Map<String, dynamic>.from(data['healthProfile'] as Map? ?? {});

    // Read as plain text, skip any legacy encrypted values
    final conditions = List<String>.from(health['conditions'] ?? [])
        .map(_safeRead)
        .where((s) => s.isNotEmpty)
        .toList();

    final allergies = List<String>.from(health['allergies'] ?? [])
        .map(_safeRead)
        .where((s) => s.isNotEmpty)
        .toList();

    // DOB: Timestamp → string
    String dobStr = '';
    final dobValue = profile['dateOfBirth'];
    if (dobValue is Timestamp) {
      dobStr = DateFormat('yyyy-MM-dd').format(dobValue.toDate());
    } else if (dobValue is String) {
      dobStr = dobValue;
    }

    // Name: prefer userName, fall back to name field
    final name = ((profile['userName'] as String? ?? '').isNotEmpty
            ? profile['userName'] as String
            : profile['name'] as String? ?? '')
        .trim();

    return UserModel(
      uid: uid,
      name: name,
      email: profile['email'] as String? ?? '',
      gender: profile['gender'] as String? ?? '',
      dob: dobStr,
      conditions: conditions,
      foodAllergies: allergies,
    );
  }

  UserModel _parseFlatSchema(String uid, Map<String, dynamic> data) {
    final conditions = List<String>.from(data['conditions'] ?? [])
        .map(_safeRead)
        .where((s) => s.isNotEmpty)
        .toList();

    final allergies =
        List<String>.from(data['foodAllergies'] ?? data['allergies'] ?? [])
            .map(_safeRead)
            .where((s) => s.isNotEmpty)
            .toList();

    return UserModel(
      uid: uid,
      name: (data['name'] as String? ?? '').trim(),
      email: data['email'] as String? ?? '',
      gender: data['gender'] as String? ?? '',
      dob: data['dob'] as String? ?? '',
      conditions: conditions,
      foodAllergies: allergies,
    );
  }

  // ── History ───────────────────────────────────────────────────────────────

  Future<void> addToSearchHistory(
      String uid, Map<String, dynamic> entry) async {
    await _db.collection('users').doc(uid).update({
      'searchHistory': FieldValue.arrayUnion([entry]),
    });
  }

  // ── Products ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      if (query.trim().isEmpty) return [];

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
          final name =
              (product['productName'] as String?)?.toLowerCase() ?? '';
          final brand =
              (product['brandName'] as String?)?.toLowerCase() ?? '';
          return name.contains(lowerQuery) || brand.contains(lowerQuery);
        } catch (e) {
          debugPrint('Error filtering product: $e');
          return false;
        }
      }).toList();
    } catch (e) {
      debugPrint('Firebase searchProducts error: $e');
      rethrow;
    }
  }
}