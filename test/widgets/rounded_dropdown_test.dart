import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munshi/widgets/rounded_dropdown.dart';

void main() {
  group('RoundedDropdown Widget Tests', () {
    testWidgets('RoundedDropdown displays correctly with basic properties', (
      WidgetTester tester,
    ) async {
      const testOptions = ['Option 1', 'Option 2', 'Option 3'];
      String? selectedValue = testOptions[0];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoundedDropdown<String>(
              value: selectedValue,
              items: testOptions.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                selectedValue = newValue;
              },
            ),
          ),
        ),
      );

      // Verify the dropdown is rendered
      expect(find.byType(RoundedDropdown<String>), findsOneWidget);
      expect(find.text('Option 1'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
    });

    testWidgets('RoundedDropdown can be tapped to show options', (
      WidgetTester tester,
    ) async {
      const testOptions = ['Currency 1', 'Currency 2', 'Currency 3'];
      String? selectedValue = testOptions[0];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return RoundedDropdown<String>(
                  value: selectedValue,
                  items: testOptions.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Initially shows first option
      expect(find.text('Currency 1'), findsOneWidget);

      // Tap the dropdown to open it
      await tester.tap(find.byType(RoundedDropdown<String>));
      await tester.pumpAndSettle();

      // Verify all options are visible in the dropdown menu
      expect(find.text('Currency 1'), findsWidgets);
      expect(find.text('Currency 2'), findsOneWidget);
      expect(find.text('Currency 3'), findsOneWidget);
    });
  });
}
