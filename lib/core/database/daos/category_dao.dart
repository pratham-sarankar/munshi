import 'package:drift/drift.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/database/tables/transaction_categories.dart';
import 'package:munshi/core/database/tables/transactions.dart';
import 'package:munshi/features/transactions/models/transaction_type.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [TransactionCategories, Transactions])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  // Get all categories
  Future<List<TransactionCategory>> getAllCategories() =>
      select(transactionCategories).get();

  // Get categories by type
  Future<List<TransactionCategory>> getCategoriesByType(String type) => (select(
    transactionCategories,
  )..where((tbl) => tbl.type.equals(type))).get();

  // Get expense categories
  Future<List<TransactionCategory>> getExpenseCategories() =>
      getCategoriesByType('expense');

  // Get income categories
  Future<List<TransactionCategory>> getIncomeCategories() =>
      getCategoriesByType('income');

  // Get category by id
  Future<TransactionCategory?> getCategoryById(int id) => (select(
    transactionCategories,
  )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  // Insert category
  Future<int> insertCategory(TransactionCategoriesCompanion category) =>
      into(transactionCategories).insert(category);

  // Update category
  Future<bool> updateCategory(TransactionCategory category) =>
      update(transactionCategories).replace(category);

  // Delete category (will cascade delete all transactions with this category due to foreign key constraint)
  Future<int> deleteCategory(int id) =>
      (delete(transactionCategories)..where((tbl) => tbl.id.equals(id))).go();

  // Check if category has transactions
  Future<bool> categoryHasTransactions(int categoryId) async {
    final count =
        await (selectOnly(transactions)
              ..addColumns([transactions.id.count()])
              ..where(transactions.categoryId.equals(categoryId)))
            .getSingle();
    return count.read(transactions.id.count())! > 0;
  }

  // Get transaction count for category
  Future<int> getTransactionCountForCategory(int categoryId) async {
    final count =
        await (selectOnly(transactions)
              ..addColumns([transactions.id.count()])
              ..where(transactions.categoryId.equals(categoryId)))
            .getSingle();
    return count.read(transactions.id.count())!;
  }

  // Check if category name exists
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
