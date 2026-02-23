import 'package:flutter/material.dart';

// This class holds the current theme state (Light or Dark)
class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light); // Start with Light Mode by default

  // Function to switch the theme
  void toggleTheme(bool isDark) {
    value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

// Create a global instance so we can access it from any screen
final themeNotifier = ThemeNotifier();