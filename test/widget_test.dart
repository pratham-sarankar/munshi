// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:munshi/main.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    // Initialize shared preferences mock
    SharedPreferences.setMockInitialValues({});
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const Munshi());
    
    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify that the app loads and shows navigation
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Settings screen shows theme option', (WidgetTester tester) async {
    // Initialize shared preferences mock
    SharedPreferences.setMockInitialValues({});
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const Munshi());
    await tester.pumpAndSettle();

    // Navigate to settings screen
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Verify that the settings screen shows theme option
    expect(find.text('Theme'), findsOneWidget);
  });
}
