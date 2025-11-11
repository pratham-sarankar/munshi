import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart' show IconData, Color, Colors;
import 'package:icons_plus/icons_plus.dart' show Iconsax;
import 'package:munshi/core/database/converters/color_converter.dart';
import 'package:munshi/core/database/converters/icon_data_converter.dart';
import 'package:munshi/core/database/converters/transaction_type_converter.dart';
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

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

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
        if (from < 3) {
          // Migrate from storing category object to categoryId foreign key
          await _migrateToCategoryId(m);
        }
        if (from < 4) {
          // Update default colors for Healthcare and Utilities categories
          await _updateCategoryColors();
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
        color: Colors.green,
        type: TransactionType.expense,
        isDefault: const Value(true),
      ),
      TransactionCategoriesCompanion.insert(
        name: 'Utilities',
        icon: Iconsax.electricity_outline,
        color: Colors.teal,
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

  Future<void> _migrateToCategoryId(Migrator m) async {
    // Step 1: Create new transactions table with categoryId
    await m.createTable(transactions);

    // Note: Since we're changing from storing category objects to categoryId,
    // existing transaction data would need manual migration if there was any.
    // For a clean migration, we'll start fresh with the new schema.
    // If you need to preserve existing data, you would need to:
    // 1. Read existing transactions
    // 2. Map category objects to category IDs
    // 3. Insert transactions with new schema
  }

  Future<void> _updateCategoryColors() async {
    // Update Healthcare category color from greenAccent (0xFF69F0AE) to green (0xFF4CAF50)
    await customStatement(
      '''
      UPDATE transaction_categories 
      SET color = ? 
      WHERE name = 'Healthcare' AND is_default = 1 AND color = ?
    ''',
      [Colors.green.toARGB32(), const Color(0xFF69F0AE).toARGB32()],
    );

    // Update Utilities category color from tealAccent (0xFF64FFDA) to teal (0xFF009688)
    await customStatement(
      '''
      UPDATE transaction_categories 
      SET color = ? 
      WHERE name = 'Utilities' AND is_default = 1 AND color = ?
    ''',
      [Colors.teal.toARGB32(), const Color(0xFF64FFDA).toARGB32()],
    );
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
