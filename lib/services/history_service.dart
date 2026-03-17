import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─────────────────────────────────────────
  // Helper: get current user's history collection
  // users/{uid}/scanHistory/{scanId}
  // ─────────────────────────────────────────
  CollectionReference<Map<String, dynamic>>? _historyCollection() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('scanHistory');
  }

  // ─────────────────────────────────────────
  // FUNCTION 1: Save a new scan to history
  // Called from result_screen.dart after
  // a successful ingredient analysis
  //
  // Returns the new document ID if successful
  // Returns null if something went wrong
  // ─────────────────────────────────────────
  Future<String?> saveScan({
    required String productName,
    required String status, // SAFE, CAUTION, UNSAFE
    required List<String> ingredients,
    required List<String> warnings,
    required String summary,
  }) async {
    try {
      final collection = _historyCollection();
      if (collection == null) return null;

      final docRef = await collection.add({
        'productName': productName,
        'status': status,
        'ingredients': ingredients,
        'warnings': warnings,
        'summary': summary,
        'scannedAt': FieldValue.serverTimestamp(),
        // Store a readable date string too for easy display
        'date': _formatDate(DateTime.now()),
      });

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  // ─────────────────────────────────────────
  // FUNCTION 2: Get all scan history
  // Called from history_screen.dart to
  // load and display the user's history
  //
  // Returns list of scan maps, newest first
  // Returns empty list if none found
  // ─────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final collection = _historyCollection();
      if (collection == null) return [];

      final snapshot = await collection
          .orderBy('scannedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'productName': data['productName'] ?? 'Unknown Product',
          'status': data['status'] ?? 'UNKNOWN',
          'ingredients': List<String>.from(data['ingredients'] ?? []),
          'warnings': List<String>.from(data['warnings'] ?? []),
          'summary': data['summary'] ?? '',
          'date': data['date'] ?? '',
          'scannedAt': data['scannedAt'],
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ─────────────────────────────────────────
  // FUNCTION 3: Delete a single scan
  // Called from history_screen.dart when
  // user swipes or taps delete on a card
  // ─────────────────────────────────────────
  Future<bool> deleteScan(String scanId) async {
    try {
      final collection = _historyCollection();
      if (collection == null) return false;

      await collection.doc(scanId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─────────────────────────────────────────
  // FUNCTION 4: Clear all scan history
  // Called from history_screen.dart when
  // user taps "Clear All History"
  //
  // Deletes all docs in the subcollection
  // ─────────────────────────────────────────
  Future<bool> clearAllHistory() async {
    try {
      final collection = _historyCollection();
      if (collection == null) return false;

      // Firestore doesn't delete subcollections automatically
      // so we batch delete all documents
      final snapshot = await collection.get();

      if (snapshot.docs.isEmpty) return true;

      // Use batched writes for efficiency (max 500 per batch)
      final batches = <WriteBatch>[];
      WriteBatch batch = _db.batch();
      int count = 0;

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
        count++;

        if (count == 500) {
          batches.add(batch);
          batch = _db.batch();
          count = 0;
        }
      }

      if (count > 0) batches.add(batch);

      for (final b in batches) {
        await b.commit();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // ─────────────────────────────────────────
  // FUNCTION 5: Get scan count
  // Called from profile_screen.dart to
  // display "X Scans Made" in stats
  // ─────────────────────────────────────────
  Future<int> getScanCount() async {
    try {
      final collection = _historyCollection();
      if (collection == null) return 0;

      final snapshot = await collection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ─────────────────────────────────────────
  // FUNCTION 6: Stream history (real-time)
  // Use this instead of getHistory() if you
  // want the list to update live without
  // manual refresh
  // ─────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> streamHistory() {
    final collection = _historyCollection();
    if (collection == null) return Stream.value([]);

    return collection
        .orderBy('scannedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'productName': data['productName'] ?? 'Unknown Product',
                'status': data['status'] ?? 'UNKNOWN',
                'ingredients': List<String>.from(data['ingredients'] ?? []),
                'warnings': List<String>.from(data['warnings'] ?? []),
                'summary': data['summary'] ?? '',
                'date': data['date'] ?? '',
                'scannedAt': data['scannedAt'],
              };
            }).toList());
  }

  // ─────────────────────────────────────────
  // Helper: Format date for display
  // e.g. "Mar 17, 2026"
  // ─────────────────────────────────────────
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}