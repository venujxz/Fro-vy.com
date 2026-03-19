import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

// This class holds the current theme state (Light or Dark)
class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    // Load saved theme preference on startup
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    value = await PrefsService.getThemeMode();
  }

  // Function to switch the theme and persist the choice
  Future<void> toggleTheme(bool isDark) async {
    value = isDark ? ThemeMode.dark : ThemeMode.light;
    await PrefsService.setThemeMode(value);
  }
}

// Create a global instance so we can access it from any screen
final themeNotifier = ThemeNotifier();