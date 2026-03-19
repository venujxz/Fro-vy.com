import 'dart:io';
import 'package:flutter/foundation.dart';

/// Platform-agnostic configuration utility
/// Provides cross-platform support for all device types
class PlatformConfig {
  // Private constructor to prevent instantiation
  PlatformConfig._();

  /// Get the backend URL based on the current platform
  /// This handles the differences between:
  /// - Android Emulator (10.0.2.2:3000)
  /// - iOS/macOS (localhost:3000)
  /// - Windows/Linux (localhost:3000)
  /// - Web (relative URL or deployed backend)
  static String getBackendUrl({String path = '/personalize-analysis'}) {
    String baseUrl;

    if (kIsWeb) {
      // Web: use relative URL or your deployed backend
      // In production, replace with your actual backend domain
      baseUrl = 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      // Android Emulator: use 10.0.2.2 to connect to host machine's localhost
      // For physical devices, use your actual backend server URL
      baseUrl = 'http://10.0.2.2:3000';
    } else if (Platform.isIOS || Platform.isMacOS) {
      // iOS and macOS: use localhost directly
      baseUrl = 'http://localhost:3000';
    } else if (Platform.isWindows || Platform.isLinux) {
      // Windows and Linux: use localhost directly
      baseUrl = 'http://localhost:3000';
    } else {
      // Fallback for unknown platforms
      baseUrl = 'http://localhost:3000';
    }

    return baseUrl + path;
  }

  /// Check if the platform supports camera functionality
  static bool supportsCameraFeature() {
    // Web doesn't support native camera access in the same way
    if (kIsWeb) return false;

    // Camera is supported on mobile platforms
    if (Platform.isAndroid || Platform.isIOS) return true;

    // Desktop platforms have limited camera support
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return true; // Can use image picker on desktop
    }

    return false;
  }

  /// Get human-readable platform name
  static String getPlatformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Check if the app is running on a mobile platform
  static bool isMobilePlatform() {
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Check if the app is running on a desktop platform
  static bool isDesktopPlatform() {
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  /// Get the appropriate HTTP timeout based on platform
  /// Mobile networks may need longer timeouts
  static Duration getHttpTimeout() {
    if (isMobilePlatform()) {
      return const Duration(seconds: 30);
    }
    return const Duration(seconds: 15);
  }
}
