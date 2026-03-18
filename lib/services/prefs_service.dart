import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/health_profile.dart';
import '../models/scan_result.dart';

/// Service to handle all local data persistence using SharedPreferences.
class PrefsService {
  static const String _keyUserProfile = 'user_profile';
  static const String _keyHealthProfile = 'health_profile';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyPushNotifications = 'push_notifications';
  static const String _keyEmailUpdates = 'email_updates';
  static const String _keyScanHistory = 'scan_history';
  static const String _keyCurrentPlan = 'current_plan';
  static const String _keyScanCount = 'scan_count';
  static const String _keySubscriptionId = 'subscription_id';
  static const String _keyUserEmail = 'user_email';

  // ── Theme ──────────────────────────────────────────────

  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyThemeMode);
    if (value == 'dark') return ThemeMode.dark;
    if (value == 'light') return ThemeMode.light;
    return ThemeMode.light;
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode == ThemeMode.dark ? 'dark' : 'light');
  }

  // ── User Profile ───────────────────────────────────────

  static Future<UserProfile> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyUserProfile);
    if (json != null) {
      return UserProfile.fromJson(jsonDecode(json));
    }
    return UserProfile(); // defaults
  }

  static Future<void> setUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserProfile, jsonEncode(profile.toJson()));
  }

  // ── Health Profile ─────────────────────────────────────

  static Future<HealthProfile> getHealthProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyHealthProfile);
    if (json != null) {
      return HealthProfile.fromJson(jsonDecode(json));
    }
    return HealthProfile(); // defaults
  }

  static Future<void> setHealthProfile(HealthProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHealthProfile, jsonEncode(profile.toJson()));
  }

  // ── Notification Settings ──────────────────────────────

  static Future<bool> getPushNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPushNotifications) ?? true;
  }

  static Future<void> setPushNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPushNotifications, value);
  }

  static Future<bool> getEmailUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEmailUpdates) ?? true;
  }

  static Future<void> setEmailUpdates(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEmailUpdates, value);
  }

  // ── Scan History ───────────────────────────────────────

  static Future<List<ScanResult>> getScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyScanHistory);
    if (json != null) {
      final List<dynamic> list = jsonDecode(json);
      return list.map((e) => ScanResult.fromJson(e)).toList();
    }
    return [];
  }

  static Future<void> setScanHistory(List<ScanResult> history) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(history.map((e) => e.toJson()).toList());
    await prefs.setString(_keyScanHistory, json);
  }

  static Future<void> addScanResult(ScanResult result) async {
    final history = await getScanHistory();
    history.insert(0, result); // newest first
    await setScanHistory(history);
  }

  static Future<void> clearScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyScanHistory);
  }

  // ── Subscription Plan ──────────────────────────────────

  static Future<String> getCurrentPlan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrentPlan) ?? 'Free';
  }

  static Future<void> setCurrentPlan(String plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrentPlan, plan);
  }

  // ── Scan Count ─────────────────────────────────────────

  static Future<int> getScanCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyScanCount) ?? 0;
  }

  static Future<void> incrementScanCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_keyScanCount) ?? 0;
    await prefs.setInt(_keyScanCount, count + 1);
  }

  // ── Subscription ──────────────────────────────────────

  static Future<String?> getSubscriptionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySubscriptionId);
  }

  static Future<void> setSubscriptionId(String subscriptionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySubscriptionId, subscriptionId);
  }

  static Future<void> clearSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySubscriptionId);
    await prefs.setString(_keyCurrentPlan, 'Free');
  }

  // ── User Email ────────────────────────────────────────

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  static Future<void> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserEmail, email);
  }

  // ── Clear All (for account deletion) ───────────────────

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
