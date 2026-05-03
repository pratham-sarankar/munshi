import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app's [ThemeMode] and persists it via [SharedPreferences].
class ThemeProvider extends ChangeNotifier {
  /// Creates a ThemeProvider and loads the theme synchronously from SharedPreferences.
  ThemeProvider(this.prefs) {
    _loadThemeFromPrefs();
  }
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;

  /// The current [ThemeMode].
  ThemeMode get themeMode => _themeMode;

  /// A human-readable label for the current theme mode (e.g., `'Light'`).
  String get themeModeString {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'Auto';
    }
  }

  /// The [SharedPreferences] instance used to persist the theme.
  final SharedPreferences prefs;

  /// Sets the theme mode from a string label (`'Light'`, `'Dark'`, or `'Auto'`).
  void setThemeMode(String themeString) {
    ThemeMode newThemeMode;
    switch (themeString) {
      case 'Light':
        newThemeMode = ThemeMode.light;
      case 'Dark':
        newThemeMode = ThemeMode.dark;
      case 'Auto':
        newThemeMode = ThemeMode.system;
      default:
        newThemeMode = ThemeMode.light;
    }

    if (_themeMode != newThemeMode) {
      _themeMode = newThemeMode;
      _saveThemeToPrefs();
      notifyListeners();
    }
  }

  void _loadThemeFromPrefs() {
    final themeModeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    notifyListeners();
  }

  void _saveThemeToPrefs() {
    prefs.setInt(_themeKey, _themeMode.index);
  }
}
