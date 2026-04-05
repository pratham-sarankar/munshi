import 'package:drift/drift.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/database/tables/transaction_categories.dart';
import 'package:munshi/core/database/tables/transactions.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/features/transactions/data/extensions/transaction_category_extensions.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';

part 'category_local_datasource.g.dart';

/// Local data source for managing transaction categories in the database.
///
/// Provides methods to perform CRUD operations on transaction categories,
/// including retrieval by type, insertion, updates, and deletion.
@DriftAccessor(tables: [TransactionCategories, Transactions])
class CategoryLocalDataSource extends DatabaseAccessor<AppDatabase>
    with _$CategoryLocalDataSourceMixin {
  CategoryLocalDataSource(super.db);

  /// Retrieves all transaction categories from the database.
  Future<List<TransactionCategory>> getAllCategories() async {
    final rows = await select(transactionCategories).get();
    return rows.map((row) => row.toEntity()).toList();
  }

  /// Retrieves all transaction categories filtered by the specified [type].
  Future<List<TransactionCategory>> getCategoriesByType(String type) async {
    final rows = await (select(
      transactionCategories,
    )..where((tbl) => tbl.type.equals(type))).get();
    return rows.map((row) => row.toEntity()).toList();
  }

  /// Retrieves all expense categories.
  Future<List<TransactionCategory>> getExpenseCategories() =>
      getCategoriesByType('expense');

  /// Retrieves all income categories.
  Future<List<TransactionCategory>> getIncomeCategories() =>
      getCategoriesByType('income');

  /// Retrieves a single transaction category by its [id].
  Future<TransactionCategory?> getCategoryById(int id) async {
    final row = await (select(
      transactionCategories,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    return row?.toEntity();
  }

  /// Inserts a new transaction category into the database.
  Future<int> insertCategory(TransactionCategoriesCompanion category) =>
      into(transactionCategories).insert(category);

  /// Updates an existing transaction [category] in the database.
  Future<bool> updateCategory(TransactionCategory category) async {
    final updated = await update(
      transactionCategories,
    ).replace(category.toRow());
    return updated;
  }

  /// Deletes a transaction category by its [id]. Cascades to delete all
  /// transactions with this category due to foreign key constraint.
  Future<int> deleteCategory(int id) =>
      (delete(transactionCategories)..where((tbl) => tbl.id.equals(id))).go();

  /// Checks if a category with the specified [categoryId] has any
  /// associated transactions.
  Future<bool> categoryHasTransactions(int categoryId) async {
    final count =
        await (selectOnly(transactions)
              ..addColumns([transactions.id.count()])
              ..where(transactions.categoryId.equals(categoryId)))
            .getSingle();
    return count.read(transactions.id.count())! > 0;
  }

  /// Gets the total transaction count for the category with the specified
  /// [categoryId].
  Future<int> getTransactionCountForCategory(int categoryId) async {
    final count =
        await (selectOnly(transactions)
              ..addColumns([transactions.id.count()])
              ..where(transactions.categoryId.equals(categoryId)))
            .getSingle();
    return count.read(transactions.id.count())!;
  }

  /// Checks if a category with the specified [name] and [type] already
  /// exists. Optionally excludes a category by [excludeId] from the check.
  Future<bool> categoryNameExists(
    String name,
    TransactionType type, {
    int? excludeId,
  }) async {
    final query = select(transactionCategories)
      ..where((tbl) => tbl.name.equals(name) & tbl.type.equals(type.name));

    if (excludeId != null) {
      query.where((tbl) => tbl.id.equals(excludeId).not());
    }

    final result = await query.getSingleOrNull();
    return result != null;
  }
}
