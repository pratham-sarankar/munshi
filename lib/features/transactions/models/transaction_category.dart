// Model
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';
import 'package:icons_plus/icons_plus.dart' show Iconsax;

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

final List<TransactionCategory> expenseCategories = [
  TransactionCategory(
    'Food & Dining',
    Iconsax.reserve_outline,
    Colors.redAccent,
  ),
  TransactionCategory('Transportation', Iconsax.car_outline, Colors.blueAccent),
  TransactionCategory(
    'Shopping',
    Iconsax.shopping_bag_outline,
    Colors.purpleAccent,
  ),
  TransactionCategory(
    'Entertainment',
    Iconsax.music_outline,
    Colors.orangeAccent,
  ),
  TransactionCategory('Healthcare', Iconsax.health_outline, Colors.green),
];

final List<TransactionCategory> incomeCategories = [
  TransactionCategory('Salary', Iconsax.briefcase_outline, Colors.green),
  TransactionCategory('Freelance', Iconsax.code_outline, Colors.blue),
  TransactionCategory('Business', Iconsax.shop_outline, Colors.purple),
  TransactionCategory('Investment', Iconsax.chart_outline, Colors.orange),
  TransactionCategory('Rental', Iconsax.home_outline, Colors.teal),
  TransactionCategory('Bonus', Iconsax.gift_outline, Colors.pink),
  TransactionCategory('Other', Iconsax.more_outline, Colors.grey),
];
