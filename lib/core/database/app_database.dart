import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:icons_plus/icons_plus.dart' show Iconsax;
import 'package:munshi/core/database/converters/transaction_type_converter.dart';
import 'package:munshi/core/database/converters/transaction_category_converter.dart';
import 'package:munshi/features/transactions/models/transaction_category.dart';
import 'package:munshi/features/transactions/models/transaction_type.dart';
import 'package:path_provider/path_provider.dart';
import './tables/transactions.dart';
import './tables/categories.dart';
import './daos/transaction_dao.dart';
import './daos/category_dao.dart';
part 'app_database.g.dart';

@DriftDatabase(
  tables: [Transactions, Categories],
  daos: [TransactionsDao, CategoriesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDefaultCategories();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Add categories table
          await m.createTable(categories);
          await _seedDefaultCategories();
        }
      },
    );
  }

  Future<void> _seedDefaultCategories() async {
    final categoriesDao = CategoriesDao(this);

    // Seed expense categories
    final expenseCategoriesToSeed = [
      CategoriesCompanion.insert(
        name: 'Food & Dining',
        iconCodePoint: Iconsax.reserve_outline.codePoint,
        iconFontFamily: Value(Iconsax.reserve_outline.fontFamily),
        iconFontPackage: Value(Iconsax.reserve_outline.fontPackage),
        colorValue: Colors.redAccent.value,
        type: 'expense',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Transportation',
        iconCodePoint: Iconsax.car_outline.codePoint,
        iconFontFamily: Value(Iconsax.car_outline.fontFamily),
        iconFontPackage: Value(Iconsax.car_outline.fontPackage),
        colorValue: Colors.blueAccent.value,
        type: 'expense',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Shopping',
        iconCodePoint: Iconsax.shopping_bag_outline.codePoint,
        iconFontFamily: Value(Iconsax.shopping_bag_outline.fontFamily),
        iconFontPackage: Value(Iconsax.shopping_bag_outline.fontPackage),
        colorValue: Colors.purpleAccent.value,
        type: 'expense',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Entertainment',
        iconCodePoint: Iconsax.music_outline.codePoint,
        iconFontFamily: Value(Iconsax.music_outline.fontFamily),
        iconFontPackage: Value(Iconsax.music_outline.fontPackage),
        colorValue: Colors.orangeAccent.value,
        type: 'expense',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Healthcare',
        iconCodePoint: Iconsax.health_outline.codePoint,
        iconFontFamily: Value(Iconsax.health_outline.fontFamily),
        iconFontPackage: Value(Iconsax.health_outline.fontPackage),
        colorValue: Colors.green.value,
        type: 'expense',
        isDefault: const Value(true),
      ),
    ];

    // Seed income categories
    final incomeCategoriesToSeed = [
      CategoriesCompanion.insert(
        name: 'Salary',
        iconCodePoint: Iconsax.briefcase_outline.codePoint,
        iconFontFamily: Value(Iconsax.briefcase_outline.fontFamily),
        iconFontPackage: Value(Iconsax.briefcase_outline.fontPackage),
        colorValue: Colors.blue.value,
        type: 'income',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Freelance',
        iconCodePoint: Iconsax.code_outline.codePoint,
        iconFontFamily: Value(Iconsax.code_outline.fontFamily),
        iconFontPackage: Value(Iconsax.code_outline.fontPackage),
        colorValue: Colors.green.value,
        type: 'income',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Business',
        iconCodePoint: Iconsax.shop_outline.codePoint,
        iconFontFamily: Value(Iconsax.shop_outline.fontFamily),
        iconFontPackage: Value(Iconsax.shop_outline.fontPackage),
        colorValue: Colors.orange.value,
        type: 'income',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Investment',
        iconCodePoint: Iconsax.chart_outline.codePoint,
        iconFontFamily: Value(Iconsax.chart_outline.fontFamily),
        iconFontPackage: Value(Iconsax.chart_outline.fontPackage),
        colorValue: Colors.purple.value,
        type: 'income',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Rental',
        iconCodePoint: Iconsax.home_outline.codePoint,
        iconFontFamily: Value(Iconsax.home_outline.fontFamily),
        iconFontPackage: Value(Iconsax.home_outline.fontPackage),
        colorValue: Colors.red.value,
        type: 'income',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Bonus',
        iconCodePoint: Iconsax.gift_outline.codePoint,
        iconFontFamily: Value(Iconsax.gift_outline.fontFamily),
        iconFontPackage: Value(Iconsax.gift_outline.fontPackage),
        colorValue: Colors.amber.value,
        type: 'income',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Other',
        iconCodePoint: Iconsax.more_outline.codePoint,
        iconFontFamily: Value(Iconsax.more_outline.fontFamily),
        iconFontPackage: Value(Iconsax.more_outline.fontPackage),
        colorValue: Colors.grey.value,
        type: 'income',
        isDefault: const Value(true),
      ),
    ];

    for (final category in expenseCategoriesToSeed) {
      await categoriesDao.insertCategory(category);
    }

    for (final category in incomeCategoriesToSeed) {
      await categoriesDao.insertCategory(category);
    }
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'munshi_database',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
