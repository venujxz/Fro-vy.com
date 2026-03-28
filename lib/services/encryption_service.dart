import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provides AES-256 encryption / decryption for sensitive health data
/// (conditions, allergies) before they are written to Firestore.
///
/// The key is generated once per device and stored securely in the
/// platform keychain (iOS Keychain / Android Keystore).
class EncryptionService {
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'frovy_aes_key';

  // ── Get or generate the 256-bit AES key ───────────────────────────────
  static Future<enc.Key> _getKey() async {
    final String? storedKey = await _storage.read(key: _keyName);

    if (storedKey == null) {
      final key = enc.Key.fromSecureRandom(32);
      await _storage.write(
        key: _keyName,
        value: base64.encode(key.bytes),
      );
      return key;
    }

    return enc.Key(base64.decode(storedKey));
  }

  // ── Encrypt a single string ────────────────────────────────────────────
  // Produces: "<iv_base64>:<ciphertext_base64>"
  static Future<String> encrypt(String plainText) async {
    final key = await _getKey();
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  // ── Decrypt a single string ────────────────────────────────────────────
  static Future<String> decrypt(String encryptedText) async {
    final key = await _getKey();
    final parts = encryptedText.split(':');
    if (parts.length < 2) return encryptedText; // not encrypted
    final iv = enc.IV.fromBase64(parts[0]);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    return encrypter.decrypt64(parts[1], iv: iv);
  }

  // ── Encrypt a list of strings ──────────────────────────────────────────
  static Future<List<String>> encryptList(List<String> items) async {
    if (items.isEmpty) return [];
    return Future.wait(items.map(encrypt));
  }

  // ── Decrypt a list of strings ──────────────────────────────────────────
  static Future<List<String>> decryptList(List<String> items) async {
    if (items.isEmpty) return [];
    return Future.wait(items.map(decrypt));
  }
}