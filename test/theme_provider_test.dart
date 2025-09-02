import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munshi/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('ThemeProvider initial state should be light theme', () {
      final themeProvider = ThemeProvider();
      expect(themeProvider.themeMode, ThemeMode.light);
      expect(themeProvider.themeModeString, 'Light');
    });

    test('ThemeProvider should change theme to dark', () {
      final themeProvider = ThemeProvider();
      themeProvider.setThemeMode('Dark');
      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(themeProvider.themeModeString, 'Dark');
    });

    test('ThemeProvider should change theme to auto/system', () {
      final themeProvider = ThemeProvider();
      themeProvider.setThemeMode('Auto');
      expect(themeProvider.themeMode, ThemeMode.system);
      expect(themeProvider.themeModeString, 'Auto');
    });

    test('ThemeProvider should notify listeners when theme changes', () {
      final themeProvider = ThemeProvider();
      bool notified = false;

      themeProvider.addListener(() {
        notified = true;
      });

      themeProvider.setThemeMode('Dark');
      expect(notified, true);
    });

    test(
      'ThemeProvider should not notify listeners when setting same theme',
      () {
        final themeProvider = ThemeProvider();
        themeProvider.setThemeMode('Light'); // Set to same theme

        bool notified = false;
        themeProvider.addListener(() {
          notified = true;
        });

        themeProvider.setThemeMode('Light'); // Set to same theme again
        expect(notified, false);
      },
    );
  });
}
