import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ingredient_model.dart';
import '../services/ingredient_checker_service.dart';

// ── Serialisable history item ─────────────────────────────────────────────────

class HistoryItem {
  final String id;

  /// "product_search" | "manual_entry" | "product_scan"
  final String analysisType;

  final DateTime timestamp;

  /// Filled for product_search; empty string otherwise.
  final String productName;
  final String brandName;

  /// All ingredients that were analysed.
  final List<String> ingredients;

  /// Serialised CheckResult — reconstructed when tapping the item.
  final Map<String, dynamic> checkResult;

  /// Cached AI warnings (null = AI was never requested for this scan).
  final List<String>? aiWarnings;

  const HistoryItem({
    required this.id,
    required this.analysisType,
    required this.timestamp,
    this.productName = '',
    this.brandName = '',
    required this.ingredients,
    required this.checkResult,
    this.aiWarnings,
  });

  // ── Display helpers ─────────────────────────────────────────────────────────

  /// Human-readable label shown prominently on the card.
  String get typeLabel {
    switch (analysisType) {
      case 'product_search':
        return 'Product Search';
      case 'product_scan':
        return 'Product Scan';
      default:
        return 'Manual Entry';
    }
  }

  /// Icon for the card header.
  String get typeEmoji {
    switch (analysisType) {
      case 'product_search':
        return 'search';
      case 'product_scan':
        return 'scan';
      default:
        return 'edit';
    }
  }

  /// "Mar 21, 2025 · 14:32"
  String get formattedDateTime {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    return '${months[timestamp.month - 1]} ${timestamp.day}, '
        '${timestamp.year} · $h:$m';
  }

  /// Short ingredient preview for manual/scan cards.
  String get ingredientPreview {
    if (ingredients.isEmpty) return '';
    const maxChars = 60;
    final joined = ingredients.join(', ');
    if (joined.length <= maxChars) return joined;
    return '${joined.substring(0, maxChars)}…';
  }

  // ── Firestore serialisation ─────────────────────────────────────────────────

  factory HistoryItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return HistoryItem(
      id: doc.id,
      analysisType: d['analysisType'] as String? ?? 'manual_entry',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      productName: d['productName'] as String? ?? '',
      brandName: d['brandName'] as String? ?? '',
      ingredients: List<String>.from(d['ingredients'] ?? []),
      checkResult:
          Map<String, dynamic>.from(d['checkResult'] as Map? ?? {}),
      aiWarnings: d['aiWarnings'] != null
          ? List<String>.from(d['aiWarnings'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'analysisType': analysisType,
        'timestamp': Timestamp.fromDate(timestamp),
        'productName': productName,
        'brandName': brandName,
        'ingredients': ingredients,
        'checkResult': checkResult,
        if (aiWarnings != null) 'aiWarnings': aiWarnings,
      };

  // ── Restore CheckResult from cached map ─────────────────────────────────────

  CheckResult restoreCheckResult() {
    List<IngredientModel> _parseList(dynamic raw) {
      if (raw == null) return [];
      return (raw as List)
          .map((e) => IngredientModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return CheckResult(
      beneficial: _parseList(checkResult['beneficial']),
      caution: _parseList(checkResult['caution']),
      avoid: _parseList(checkResult['avoid']),
      unknown: List<String>.from(checkResult['unknown'] ?? []),
    );
  }
}

// ── Serialise a fresh CheckResult for storage ─────────────────────────────────

Map<String, dynamic> serializeCheckResult(CheckResult r) {
  Map<String, dynamic> _ing(IngredientModel m) =>
      {'name': m.name, 'category': m.category, 'reason': m.reason};

  return {
    'beneficial': r.beneficial.map(_ing).toList(),
    'caution': r.caution.map(_ing).toList(),
    'avoid': r.avoid.map(_ing).toList(),
    'unknown': r.unknown,
  };
}

// ── HistoryService ────────────────────────────────────────────────────────────

class HistoryService {
  /// users/{uid}/history
  static CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('history');

  // ── Fetch ─────────────────────────────────────────────────────────────────

  static Future<List<HistoryItem>> fetchItems(String uid) async {
    final snapshot = await _col(uid)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();
    return snapshot.docs.map(HistoryItem.fromFirestore).toList();
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  /// Call this from OutputScreen after a successful analysis.
  static Future<String> saveItem({
    required String uid,
    required String analysisType,
    required List<String> ingredients,
    required CheckResult checkResult,
    String productName = '',
    String brandName = '',
    List<String>? aiWarnings,
  }) async {
    final item = HistoryItem(
      id: '', // Firestore assigns the id
      analysisType: analysisType,
      timestamp: DateTime.now(),
      productName: productName,
      brandName: brandName,
      ingredients: ingredients,
      checkResult: serializeCheckResult(checkResult),
      aiWarnings: aiWarnings,
    );

    final docRef = await _col(uid).add(item.toFirestore());
    return docRef.id;
  }

  /// Call this when AI warnings arrive, to update the existing history doc.
  static Future<void> updateAiWarnings({
    required String uid,
    required String historyId,
    required List<String> aiWarnings,
  }) async {
    await _col(uid).doc(historyId).update({'aiWarnings': aiWarnings});
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  static Future<void> deleteItem(String uid, String id) async {
    await _col(uid).doc(id).delete();
  }

  static Future<void> clearAll(String uid) async {
    const batchSize = 500;
    QuerySnapshot snapshot;
    do {
      snapshot = await _col(uid).limit(batchSize).get();
      if (snapshot.docs.isEmpty) break;
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } while (snapshot.docs.length == batchSize);
  }
}