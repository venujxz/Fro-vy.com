import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'encryption_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> signInWithGoogle() async {
  try {
    // Client ID is injected at build time via --dart-define=GOOGLE_CLIENT_ID=...
    // For Android this is usually not needed (uses google-services.json).
    // For Web / macOS / iOS set:  --dart-define=GOOGLE_CLIENT_ID=<your_client_id>
    const googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '');

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: googleClientId.isNotEmpty ? googleClientId : null,
      scopes: ['email', 'profile'],
    );

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null; // User cancelled

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    final String uid = userCredential.user!.uid;

    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) {
      await _db.collection('users').doc(uid).set({
        'profile': {
          'userName': googleUser.displayName ?? '',
          'email': googleUser.email,
          'accountCreatedDate': FieldValue.serverTimestamp(),
          'lastLoginDate': FieldValue.serverTimestamp(),
          'gender': '',
        },
        'healthProfile': {
          'conditions': [],
          'allergies': [],
          'concerns': [],
          'skinType': '',
        },
      });
    }

    return uid;
  } catch (e) {
    throw Exception('Google Sign In failed: $e');
  }
}

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
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = credential.user!.uid;

      await credential.user!.sendEmailVerification();

      await _db.collection('users').doc(uid).set({
        'profile': {
          'userName': userName,
          'email': email,
          'dateOfBirth': Timestamp.fromDate(dateOfBirth),
          'gender': gender,
          'accountCreatedDate': FieldValue.serverTimestamp(),
          'lastLoginDate': FieldValue.serverTimestamp(),
        },
        'healthProfile': {
          'conditions': [],
          'allergies': [],
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
      throw Exception('Something went wrong. Please try again.');
    }
  }

  // ─────────────────────────────────────────
  // FUNCTION 2: Save health profile
  // ─────────────────────────────────────────

  Future<bool> saveHealthProfile({
    required String userId,
    required List<String> conditions,
    required List<String> allergies,
    required List<String> concerns,
    required String skinType,
  }) async {
    try {
      final encryptedConditions =
          await EncryptionService.encryptList(conditions);
      final encryptedAllergies =
          await EncryptionService.encryptList(allergies);

      await _db.collection('users').doc(userId).update({
        'healthProfile': {
          'conditions': encryptedConditions,
          'allergies': encryptedAllergies,
          'concerns': concerns,
          'skinType': skinType,
        },
      });

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
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db
          .collection('users')
          .doc(credential.user!.uid)
          .update({
        'profile.lastLoginDate': FieldValue.serverTimestamp(),
      });

      return credential.user!.uid;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No account found with this email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Incorrect password. Please try again.');
      } else if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled.');
      } else if (e.code == 'too-many-requests') {
        throw Exception('Too many attempts. Please try again later.');
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Something went wrong. Please try again.');
    }
  }

  // ─────────────────────────────────────────
  // FUNCTION 4: Get user profile
  // ─────────────────────────────────────────

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      final profile = data['profile'] as Map<String, dynamic>;
      final health = data['healthProfile'] as Map<String, dynamic>;

      List<String> rawConditions =
          List<String>.from(health['conditions'] ?? []);
      List<String> rawAllergies =
          List<String>.from(health['allergies'] ?? []);

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
        'dateOfBirth': profile['dateOfBirth'],
        'gender': profile['gender'] ?? '',
        'accountCreatedDate': profile['accountCreatedDate'],
        'lastLoginDate': profile['lastLoginDate'],
        'conditions': decryptedConditions,
        'allergies': decryptedAllergies,
        'concerns': List<String>.from(health['concerns'] ?? []),
        'skinType': health['skinType'] ?? '',
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
      final encryptedConditions =
          await EncryptionService.encryptList(conditions);
      final encryptedAllergies =
          await EncryptionService.encryptList(allergies);

      await _db.collection('users').doc(userId).update({
        'healthProfile.conditions': encryptedConditions,
        'healthProfile.allergies': encryptedAllergies,
        'healthProfile.concerns': concerns,
        'healthProfile.skinType': skinType,
      });

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
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // ─────────────────────────────────────────
  // FUNCTION 7: Log out
  // ─────────────────────────────────────────

  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  // ─────────────────────────────────────────
  // FUNCTION 8: Get currently logged in user
  // ─────────────────────────────────────────

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // ─────────────────────────────────────────
  // FUNCTION 9: Send password reset email
  // ─────────────────────────────────────────

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

  // ─────────────────────────────────────────
  // FUNCTION 10: Check if email is verified
  // ─────────────────────────────────────────

  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // ─────────────────────────────────────────
  // FUNCTION 11: Resend verification email
  // ─────────────────────────────────────────

  Future<bool> resendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─────────────────────────────────────────
  // FUNCTION 12: Delete account
  // ─────────────────────────────────────────

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