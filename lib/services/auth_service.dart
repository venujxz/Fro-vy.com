import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'encryption_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─────────────────────────────────────────
  // FUNCTION 1: Register a brand new user
  // ─────────────────────────────────────────
  Future<String?> registerUser({
    required String email,
    required String password,
    required String userName,
    required DateTime dateOfBirth,
    required String gender,
  }) async {
    try {
      // STEP A: Create the Firebase Auth account
      UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception(
              'Connection timed out. Check your internet and try again.',
            ),
          );

      String uid = credential.user!.uid;

      // STEP B: Write the Firestore document
      // Uses merge:true so a partial write doesn't leave a broken document
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
          'conditions': [],
          'allergies': [],
          'concerns': [],
          'skinType': '',
        },
        'meta': {
          'planType': 'Free',
          'totalScans': 0,
          'emailVerified': false,
        },
      }, SetOptions(merge: true)).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception(
          'Could not save profile. Check your internet and try again.',
        ),
      );

      // STEP C: Send verification email — fire-and-forget so it never blocks
      // If this fails, user can request resend later
      credential.user!.sendEmailVerification().catchError((_) {});

      return uid;

    } on FirebaseAuthException catch (e) {
      // These are specific, actionable errors we can show the user
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('An account with this email already exists.');
        case 'weak-password':
          throw Exception('Password is too weak. Use at least 8 characters.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        case 'network-request-failed':
          throw Exception('No internet connection. Please check your network.');
        case 'operation-not-allowed':
          throw Exception('Email/password sign-in is not enabled in Firebase Console.');
        default:
          // NOW we surface the real Firebase error code so you can debug it
          throw Exception('Registration failed [${e.code}]: ${e.message}');
      }
    } on Exception {
      // Re-throw exceptions we already constructed above (timeout, Firestore)
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ─────────────────────────────────────────
  // FUNCTION 2: Save health profile
  // Encrypts conditions + allergies before storing
  // ─────────────────────────────────────────
  Future<bool> saveHealthProfile({
    required String userId,
    required List<String> conditions,
    required List<String> allergies,
    required List<String> concerns,
    required String skinType,
  }) async {
    try {
      final encryptedConditions = await EncryptionService.encryptList(conditions);
      final encryptedAllergies = await EncryptionService.encryptList(allergies);

      await _db.collection('users').doc(userId).update({
        'healthProfile.conditions': encryptedConditions,
        'healthProfile.allergies': encryptedAllergies,
        'healthProfile.concerns': concerns,
        'healthProfile.skinType': skinType,
      }).timeout(const Duration(seconds: 15));

      return true;
    } catch (e) {
      return false;
    }
  }

  // ─────────────────────────────────────────
  // FUNCTION 3: Log in existing user
  // ─────────────────────────────────────────
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 15));

      await _db.collection('users').doc(credential.user!.uid).update({
        'profile.lastLoginDate': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10));

      return credential.user!.uid;

    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account found with this email.');
        case 'wrong-password':
          throw Exception('Incorrect password. Please try again.');
        case 'invalid-credential':
          throw Exception('Incorrect email or password.');
        case 'user-disabled':
          throw Exception('This account has been disabled.');
        case 'too-many-requests':
          throw Exception('Too many attempts. Please try again later.');
        case 'network-request-failed':
          throw Exception('No internet connection. Please check your network.');
        default:
          throw Exception('Login failed [${e.code}]: ${e.message}');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ─────────────────────────────────────────
  // FUNCTION 4: Get user profile (with decryption)
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(userId)
          .get()
          .timeout(const Duration(seconds: 15));

      if (!doc.exists) return null;

      final data = doc.data()!;
      final profile = data['profile'] as Map<String, dynamic>? ?? {};
      final health = data['healthProfile'] as Map<String, dynamic>? ?? {};
      final meta = data['meta'] as Map<String, dynamic>? ?? {};

      List<String> rawConditions = List<String>.from(health['conditions'] ?? []);
      List<String> rawAllergies = List<String>.from(health['allergies'] ?? []);

      final decryptedConditions = rawConditions.isEmpty
          ? <String>[]
          : await EncryptionService.decryptList(rawConditions);

      final decryptedAllergies = rawAllergies.isEmpty
          ? <String>[]
          : await EncryptionService.decryptList(rawAllergies);

      return {
        'userId': userId,
        'userName': profile['userName'] ?? '',
        'email': profile['email'] ?? '',
        'phone': profile['phone'] ?? '',
        'dateOfBirth': profile['dateOfBirth'],
        'gender': profile['gender'] ?? '',
        'accountCreatedDate': profile['accountCreatedDate'],
        'lastLoginDate': profile['lastLoginDate'],
        'conditions': decryptedConditions,
        'allergies': decryptedAllergies,
        'concerns': List<String>.from(health['concerns'] ?? []),
        'skinType': health['skinType'] ?? '',
        'planType': meta['planType'] ?? 'Free',
        'totalScans': meta['totalScans'] ?? 0,
      };
    } catch (e) {
      return null;
    }
  }

  // ─────────────────────────────────────────
  // FUNCTION 5: Update health profile
  // ─────────────────────────────────────────
  Future<bool> updateHealthProfile({
    required String userId,
    required List<String> conditions,
    required List<String> allergies,
    required List<String> concerns,
    String skinType = '',
  }) async {
    try {
      final encryptedConditions = await EncryptionService.encryptList(conditions);
      final encryptedAllergies = await EncryptionService.encryptList(allergies);

      await _db.collection('users').doc(userId).update({
        'healthProfile.conditions': encryptedConditions,
        'healthProfile.allergies': encryptedAllergies,
        'healthProfile.concerns': concerns,
        'healthProfile.skinType': skinType,
      }).timeout(const Duration(seconds: 15));

      return true;
    } catch (e) {
      return false;
    }
  }

  // ─────────────────────────────────────────
  // FUNCTION 6: Update personal profile
  // ─────────────────────────────────────────
  Future<bool> updatePersonalProfile({
    required String userId,
    required String userName,
    required String gender,
    String phone = '',
  }) async {
    try {
      await _db.collection('users').doc(userId).update({
        'profile.userName': userName,
        'profile.gender': gender,
        'profile.phone': phone,
      }).timeout(const Duration(seconds: 15));

      return true;
    } catch (e) {
      return false;
    }
  }

  // ─────────────────────────────────────────
  // FUNCTION 7: Increment scan count
  // Call this every time a scan succeeds
  // ─────────────────────────────────────────
  Future<void> incrementScanCount(String userId) async {
    try {
      await _db.collection('users').doc(userId).update({
        'meta.totalScans': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  // ─────────────────────────────────────────
  // FUNCTION 8–12: Auth utilities (unchanged)
  // ─────────────────────────────────────────

  Future<void> logoutUser() async => await _auth.signOut();

  User? getCurrentUser() => _auth.currentUser;

  Future<bool> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No account found with this email.');
      }
      throw Exception('Failed to send reset email: ${e.message}');
    } catch (_) {
      return false;
    }
  }

  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<bool> resendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteAccount(String userId) async {
    try {
      await _db.collection('users').doc(userId).delete();
      await _auth.currentUser?.delete();
      return true;
    } catch (_) {
      return false;
    }
  }
}