import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart' show IconData, Color, Colors;
import 'package:icons_plus/icons_plus.dart' show Iconsax;
import 'package:munshi/core/database/converters/color_converter.dart';
import 'package:munshi/core/database/converters/icon_data_converter.dart';
import 'package:munshi/core/database/converters/transaction_type_converter.dart';
import 'package:munshi/core/database/converters/transaction_category_converter.dart';
import 'package:munshi/features/transactions/models/transaction_type.dart';
import 'package:path_provider/path_provider.dart';
import './tables/transactions.dart';
import 'tables/transaction_categories.dart';
import './daos/transaction_dao.dart';
import './daos/category_dao.dart';
part 'app_database.g.dart';

@DriftDatabase(
  tables: [Transactions, TransactionCategories],
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
          await m.createTable(transactionCategories);
          await _seedDefaultCategories();
        }
      },
    );
  }

  Future<void> _seedDefaultCategories() async {
    final categoriesDao = CategoriesDao(this);

    // Seed expense categories
    final expenseCategoriesToSeed = [
      TransactionCategoriesCompanion.insert(
        name: 'Food & Dining',
        icon: Iconsax.reserve_outline,
        color: Colors.redAccent,
        type: TransactionType.expense,
        isDefault: const Value(true),
      ),
      TransactionCategoriesCompanion.insert(
        name: 'Transportation',
        icon: Iconsax.car_outline,
        color: Colors.blueAccent,
        type: TransactionType.expense,
        isDefault: const Value(true),
      ),
      TransactionCategoriesCompanion.insert(
        name: 'Shopping',
        icon: Iconsax.shopping_bag_outline,
        color: Colors.purpleAccent,
        type: TransactionType.expense,
        isDefault: const Value(true),
      ),
      TransactionCategoriesCompanion.insert(
        name: 'Entertainment',
        icon: Iconsax.music_outline,
        color: Colors.orangeAccent,
        type: TransactionType.expense,
        isDefault: const Value(true),
      ),
      TransactionCategoriesCompanion.insert(
        name: 'Healthcare',
        icon: Iconsax.health_outline,
        color: Colors.greenAccent,
        type: TransactionType.expense,
        isDefault: const Value(true),
      ),
      TransactionCategoriesCompanion.insert(
        name: 'Utilities',
        icon: Iconsax.electricity_outline,
        color: Colors.tealAccent,
        type: TransactionType.expense,
        isDefault: const Value(true),
      ),
    ];

    // Seed income categories
    final incomeCategoriesToSeed = [
      TransactionCategoriesCompanion.insert(
        name: 'Salary',
        icon: Iconsax.briefcase_outline,
        color: Colors.blue,
        type: TransactionType.income,
        isDefault: const Value(true),
      ),
      TransactionCategoriesCompanion.insert(
        name: 'Freelance',
        icon: Iconsax.code_outline,
        color: Colors.green,
        type: TransactionType.income,
        isDefault: const Value(true),
      ),
      TransactionCategoriesCompanion.insert(
        name: 'Business',
        icon: Iconsax.shop_outline,
        color: Colors.orange,
        type: TransactionType.income,
        isDefault: const Value(true),
      ),
      TransactionCategoriesCompanion.insert(
        name: 'Investment',
        icon: Iconsax.chart_outline,
        color: Colors.purple,
        type: TransactionType.income,
        isDefault: const Value(true),
      ),
      TransactionCategoriesCompanion.insert(
        name: 'Rental',
        icon: Iconsax.home_outline,
        color: Colors.red,
        type: TransactionType.income,
        isDefault: const Value(true),
      ),
      TransactionCategoriesCompanion.insert(
        name: 'Bonus',
        icon: Iconsax.gift_outline,
        color: Colors.amber,
        type: TransactionType.income,
        isDefault: const Value(true),
      ),
      TransactionCategoriesCompanion.insert(
        name: 'Other',
        icon: Iconsax.more_outline,
        color: Colors.grey,
        type: TransactionType.income,
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
