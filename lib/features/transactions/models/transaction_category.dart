// Model
import 'package:flutter/widgets.dart';

class TransactionCategory {
  final String name;
  final IconData icon;
  final Color color;

  TransactionCategory(this.name, this.icon, this.color);

  // Serialize to JSON
  Map<String, dynamic> toJson() => {
    'name': name,
    'iconCodePoint': icon.codePoint,
    'iconFontFamily': icon.fontFamily,
    'iconFontPackage': icon.fontPackage,
    'color': color.toARGB32(),
  };

  // Deserialize from JSON
  static TransactionCategory fromJson(Map<String, dynamic> json) =>
      TransactionCategory(
        json['name'],
        IconData(
          json['iconCodePoint'],
          fontFamily: json['iconFontFamily'],
          fontPackage: json['iconFontPackage'],
        ),
        Color(json['color']),
      );
}
