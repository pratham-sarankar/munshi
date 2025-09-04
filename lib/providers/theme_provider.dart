import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

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

  final SharedPreferences prefs;

  /// Creates a ThemeProvider and loads the theme synchronously from SharedPreferences.
  ThemeProvider(this.prefs) {
    _loadThemeFromPrefs();
  }

  void setThemeMode(String themeString) {
    ThemeMode newThemeMode;
    switch (themeString) {
      case 'Light':
        newThemeMode = ThemeMode.light;
        break;
      case 'Dark':
        newThemeMode = ThemeMode.dark;
        break;
      case 'Auto':
        newThemeMode = ThemeMode.system;
        break;
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
