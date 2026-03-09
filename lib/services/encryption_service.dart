import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'frovy_aes_key';

  // ─────────────────────────────────────────
  // Get or create the AES encryption key
  // Stored securely in device keychain
  // ─────────────────────────────────────────

  static Future<enc.Key> _getKey() async {
    final String? storedKey = await _storage.read(key: _keyName);

    if (storedKey == null) {
      final key = enc.Key.fromSecureRandom(32); // 256-bit key
      await _storage.write(
        key: _keyName,
        value: base64.encode(key.bytes),
      );
      return key;
    }

    return enc.Key(base64.decode(storedKey));
  }

  // ─────────────────────────────────────────
  // Encrypt a single string
  // Example: "diabetes" → "x7Gp2mK9:aB3nQ8rT..."
  // ─────────────────────────────────────────

  static Future<String> encrypt(String plainText) async {
    final key       = await _getKey();
    final iv        = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  // ─────────────────────────────────────────
  // Decrypt a single string back to readable
  // ─────────────────────────────────────────

  static Future<String> decrypt(String encryptedText) async {
    final key       = await _getKey();
    final parts     = encryptedText.split(':');
    final iv        = enc.IV.fromBase64(parts[0]);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    return encrypter.decrypt64(parts[1], iv: iv);
  }

  // ─────────────────────────────────────────
  // Encrypt a whole list
  // Used for conditions[] and allergies[]
  // ─────────────────────────────────────────

  static Future<List<String>> encryptList(List<String> items) async {
    if (items.isEmpty) return [];
    return Future.wait(items.map((item) => encrypt(item)));
  }

  // ─────────────────────────────────────────
  // Decrypt a whole list
  // ─────────────────────────────────────────

  static Future<List<String>> decryptList(List<String> items) async {
    if (items.isEmpty) return [];
    return Future.wait(items.map((item) => decrypt(item)));
  }
}