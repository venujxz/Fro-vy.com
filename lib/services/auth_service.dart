import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Handles all Firebase Auth operations and Firestore user document management.
///
/// Firestore schema (nested):
/// users/{uid}
///   profile:      userName, email, dateOfBirth (Timestamp), gender, phone,
///                 accountCreatedDate, lastLoginDate
///   healthProfile: conditions: [String], allergies: [String]
///
/// NOTE: Health data is stored as PLAIN TEXT in Firestore.
/// Device-specific client-side encryption was removed because it broke
/// cross-device access and data recovery after reinstall.
/// Firestore security rules are the correct protection layer.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Name resolution helper ────────────────────────────────────────────────
  // 4-level fallback chain so legacy accounts always surface a readable name.
  //
  // Priority:
  //   1. profile.userName   — written by new registerUser()
  //   2. profile.name / root name — older schema versions
  //   3. Firebase Auth displayName — set by registerUser() and updatePersonalProfile()
  //   4. Email prefix       — "Venuja" derived from "venuja@example.com"
  static String _resolveName({
    required Map<String, dynamic> profile,
    required Map<String, dynamic> flatData,
    String? authDisplayName,
    String? email,
  }) {
    final fromUserName = (profile['userName'] as String? ?? '').trim();
    if (fromUserName.isNotEmpty) return fromUserName;

    final fromProfileName = (profile['name'] as String? ?? '').trim();
    if (fromProfileName.isNotEmpty) return fromProfileName;

    final fromFlatName = (flatData['name'] as String? ?? '').trim();
    if (fromFlatName.isNotEmpty) return fromFlatName;

    final fromDisplayName = (authDisplayName ?? '').trim();
    if (fromDisplayName.isNotEmpty) return fromDisplayName;

    final fromEmail = (email ?? '').trim();
    if (fromEmail.isNotEmpty) {
      final prefix = fromEmail.split('@').first;
      final cleaned = prefix
          .replaceAll(RegExp(r'[0-9._]'), ' ')
          .trim()
          .split(' ')
          .where((w) => w.isNotEmpty)
          .map((w) => w[0].toUpperCase() + w.substring(1))
          .join(' ');
      if (cleaned.isNotEmpty) return cleaned;
    }

    return '';
  }

  // ── Detect a legacy encrypted string ─────────────────────────────────────
  // Encrypted strings have the format "<base64_iv>:<base64_cipher>".
  // We detect them to skip/clear them rather than display garbled text.
  static bool _looksEncrypted(String s) {
    final parts = s.split(':');
    if (parts.length != 2) return false;
    final base64Re = RegExp(r'^[A-Za-z0-9+/=]+$');
    // IV is 16 bytes → 24 base64 chars (with padding). Cipher is longer.
    return base64Re.hasMatch(parts[0]) &&
        base64Re.hasMatch(parts[1]) &&
        parts[0].length >= 20 &&
        parts[1].length >= 24;
  }

  // ── Safe string reader ────────────────────────────────────────────────────
  // Returns the string as-is if plain text, or empty string if it looks like
  // an old encrypted value that can no longer be decrypted (key was lost).
  static String _safeReadString(String raw) {
    if (_looksEncrypted(raw)) return ''; // unrecoverable encrypted legacy value
    return raw.trim();
  }

  // ────────────────────────────────────────────────────────────────────────
  // FUNCTION 1 — Register a brand-new user
  // ────────────────────────────────────────────────────────────────────────
  Future<String?> registerUser({
    required String email,
    required String password,
    required String userName,
    required DateTime dateOfBirth,
    String gender = 'prefer_not_to_say',
  }) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = credential.user!.uid;

      // Store name in Firebase Auth displayName as a reliable backup.
      await credential.user!.updateDisplayName(userName);

      await credential.user!.sendEmailVerification();

      await _db.collection('users').doc(uid).set({
        'profile': {
          'userName': userName,
          'email': email,
          'dateOfBirth': Timestamp.fromDate(dateOfBirth),
          'gender': gender,
          'phone': '',
          'accountCreatedDate': FieldValue.serverTimestamp(),
          'lastLoginDate': FieldValue.serverTimestamp(),
        },
        'healthProfile': {
          'conditions': [],  // plain text List<String>
          'allergies': [],   // plain text List<String>
          'concerns': [],
          'skinType': '',
        },
      });

      return uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('An account with this email already exists.');
      } else if (e.code == 'weak-password') {
        throw Exception('Password is too weak. Use at least 8 characters.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else {
        throw Exception('Registration failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // FUNCTION 2 — Save health profile (plain text, no encryption)
  // ────────────────────────────────────────────────────────────────────────
  Future<bool> saveHealthProfile({
    required String userId,
    required List<String> conditions,
    required List<String> allergies,
    List<String> concerns = const [],
    String skinType = '',
  }) async {
    try {
      await _db.collection('users').doc(userId).update({
        'healthProfile': {
          'conditions': conditions,
          'allergies': allergies,
          'concerns': concerns,
          'skinType': skinType,
        },
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // FUNCTION 3 — Log in an existing user
  // Also backfills profile.userName for legacy accounts missing it.
  // ────────────────────────────────────────────────────────────────────────
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Backfill userName for legacy accounts (runs unawaited — never blocks)
      _backfillUserNameIfMissing(uid, credential.user!);

      _db.collection('users').doc(uid).update({
        'profile.lastLoginDate': FieldValue.serverTimestamp(),
      }).catchError((_) {});

      return uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No account found with this email.');
      } else if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        throw Exception('Incorrect password. Please try again.');
      } else if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled.');
      } else if (e.code == 'too-many-requests') {
        throw Exception('Too many attempts. Please try again later.');
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  Future<void> _backfillUserNameIfMissing(String uid, User user) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final profile =
          Map<String, dynamic>.from(data['profile'] as Map? ?? {});
      final currentName = (profile['userName'] as String? ?? '').trim();
      if (currentName.isNotEmpty) return;

      final resolvedName = _resolveName(
        profile: profile,
        flatData: data,
        authDisplayName: user.displayName,
        email: user.email,
      );
      if (resolvedName.isEmpty) return;

      await _db
          .collection('users')
          .doc(uid)
          .update({'profile.userName': resolvedName});

      if ((user.displayName ?? '').isEmpty) {
        await user.updateDisplayName(resolvedName);
      }
    } catch (_) {}
  }

  // ────────────────────────────────────────────────────────────────────────
  // FUNCTION 4 — Get user profile (flat map, plain text)
  //
  // Returns:
  //   'name', 'userName', 'email', 'phone', 'dob', 'gender',
  //   'conditions' (List<String>), 'foodAllergies' (List<String>)
  // ────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      await _auth.currentUser?.reload();
      final authUser = _auth.currentUser;

      final doc = await _db.collection('users').doc(userId).get();

      // No Firestore document — build from Firebase Auth alone
      if (!doc.exists) {
        final fallbackName = _resolveName(
          profile: {},
          flatData: {},
          authDisplayName: authUser?.displayName,
          email: authUser?.email,
        );
        return {
          'uid': userId,
          'name': fallbackName,
          'userName': fallbackName,
          'email': authUser?.email ?? '',
          'phone': '',
          'dob': '',
          'gender': '',
          'conditions': <String>[],
          'foodAllergies': <String>[],
          'concerns': <String>[],
          'skinType': '',
        };
      }

      final data = doc.data()!;

      final bool isNested = data.containsKey('profile');
      final profile = isNested
          ? Map<String, dynamic>.from(data['profile'] as Map? ?? {})
          : <String, dynamic>{};
      final health = isNested
          ? Map<String, dynamic>.from(data['healthProfile'] as Map? ?? {})
          : <String, dynamic>{};

      // ── Resolve name ───────────────────────────────────────────────────
      final resolvedName = _resolveName(
        profile: profile,
        flatData: data,
        authDisplayName: authUser?.displayName,
        email: authUser?.email ??
            (profile['email'] as String? ?? ''),
      );

      // ── Read health data (plain text, skip legacy encrypted values) ────
      final rawConditions = isNested
          ? List<String>.from(health['conditions'] ?? [])
          : List<String>.from(data['conditions'] ?? []);

      final rawAllergies = isNested
          ? List<String>.from(health['allergies'] ?? [])
          : List<String>.from(
              data['foodAllergies'] ?? data['allergies'] ?? []);

      // Filter each item: skip legacy encrypted strings, keep plain text
      final conditions = rawConditions
          .map(_safeReadString)
          .where((s) => s.isNotEmpty)
          .toList();

      final allergies = rawAllergies
          .map(_safeReadString)
          .where((s) => s.isNotEmpty)
          .toList();

      // ── DOB ────────────────────────────────────────────────────────────
      String dobStr = '';
      final dobValue =
          isNested ? profile['dateOfBirth'] : data['dateOfBirth'];
      if (dobValue is Timestamp) {
        dobStr = DateFormat('yyyy-MM-dd').format(dobValue.toDate());
      } else if (dobValue is String && dobValue.isNotEmpty) {
        dobStr = dobValue;
      }

      // ── Other fields ───────────────────────────────────────────────────
      final resolvedEmail = (profile['email'] as String? ??
              data['email'] as String? ??
              authUser?.email ??
              '')
          .trim();

      final resolvedGender = (profile['gender'] as String? ??
              data['gender'] as String? ??
              '')
          .trim();

      final resolvedPhone =
          (profile['phone'] as String? ?? data['phone'] as String? ?? '')
              .trim();

      // Resolve profile photo URL
      final resolvedPhotoUrl =
          (profile['photoUrl'] as String? ?? data['photoUrl'] as String? ?? '')
              .trim();

      return {
        'uid': userId,
        'name': resolvedName,
        'userName': resolvedName,
        'email': resolvedEmail,
        'phone': resolvedPhone,
        'dob': dobStr,
        'gender': resolvedGender,
        'conditions': conditions,
        'foodAllergies': allergies,
        'concerns':
            List<String>.from(health['concerns'] ?? data['concerns'] ?? []),
        'skinType': health['skinType'] as String? ??
            data['skinType'] as String? ??
            '',
        'photoUrl': resolvedPhotoUrl,
      };
    } catch (e) {
      // Last-resort: return what Firebase Auth knows
      try {
        await _auth.currentUser?.reload();
        final authUser = _auth.currentUser;
        final fallbackName = _resolveName(
          profile: {},
          flatData: {},
          authDisplayName: authUser?.displayName,
          email: authUser?.email,
        );
        return {
          'uid': userId,
          'name': fallbackName,
          'userName': fallbackName,
          'email': authUser?.email ?? '',
          'phone': '',
          'dob': '',
          'gender': '',
          'conditions': <String>[],
          'foodAllergies': <String>[],
          'concerns': <String>[],
          'skinType': '',
        };
      } catch (_) {
        return null;
      }
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // FUNCTION 5 — Update health profile (plain text, no encryption)
  // ────────────────────────────────────────────────────────────────────────
  Future<bool> updateHealthProfile({
    required String userId,
    required List<String> conditions,
    required List<String> allergies,
    List<String> concerns = const [],
    String skinType = '',
  }) async {
    try {
      await _db.collection('users').doc(userId).update({
        'healthProfile.conditions': conditions,
        'healthProfile.allergies': allergies,
        'healthProfile.concerns': concerns,
        'healthProfile.skinType': skinType,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // FUNCTION 6 — Update personal profile
  // ────────────────────────────────────────────────────────────────────────
  Future<bool> updatePersonalProfile({
    required String userId,
    required String userName,
    required String gender,
    String phone = '',
    String dob = '',
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'profile.userName': userName,
        'profile.gender': gender,
        'profile.phone': phone,
      };

      if (dob.isNotEmpty) {
        try {
          final parsedDate = DateFormat('yyyy-MM-dd').parse(dob);
          updates['profile.dateOfBirth'] = Timestamp.fromDate(parsedDate);
        } catch (_) {}
      }

      await _db.collection('users').doc(userId).update(updates);

      // Keep Firebase Auth displayName in sync
      await _auth.currentUser?.updateDisplayName(userName);

      return true;
    } catch (e) {
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // FUNCTION 7 — Log out
  // ────────────────────────────────────────────────────────────────────────
  Future<void> logoutUser() async => _auth.signOut();

  // ────────────────────────────────────────────────────────────────────────
  // FUNCTION 8 — Current user
  // ────────────────────────────────────────────────────────────────────────
  User? getCurrentUser() => _auth.currentUser;

  // ────────────────────────────────────────────────────────────────────────
  // FUNCTION 9 — Send password reset email
  // ────────────────────────────────────────────────────────────────────────
  Future<bool> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No account found with this email.');
      }
      throw Exception('Failed to send reset email: ${e.message}');
    } catch (e) {
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // FUNCTION 10 — Check email verification
  // ────────────────────────────────────────────────────────────────────────
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // ────────────────────────────────────────────────────────────────────────
  // FUNCTION 11 — Resend verification email
  // ────────────────────────────────────────────────────────────────────────
  Future<bool> resendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // FUNCTION 12 — Delete account
  // ────────────────────────────────────────────────────────────────────────
  Future<bool> deleteAccount(String userId) async {
    try {
      await _db.collection('users').doc(userId).delete();
      await _auth.currentUser?.delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}