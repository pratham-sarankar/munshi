import 'package:drift/drift.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/transactions/models/transaction_filter.dart';
import 'package:munshi/features/transactions/models/transaction_with_category.dart';

/// Abstract repository interface for the transactions domain layer.
///
/// Defines the contract for fetching and mutating transaction data,
/// decoupling the domain from any specific data source implementation.
abstract class TransactionRepository {
  /// Returns a page of [TransactionWithCategory] items matching [filter].
  ///
  /// [limit] is the maximum number of items to return.
  /// [offset] is the number of items to skip before returning results.
  Future<List<TransactionWithCategory>> getTransactionsPaged({
    required int limit,
    required int offset,
    required TransactionFilter filter,
  });

  /// Inserts a new transaction and returns its auto-generated id.
  Future<int> addTransaction(Insertable<Transaction> transaction);

  /// Replaces an existing transaction. Returns `true` on success.
  Future<bool> updateTransaction(Insertable<Transaction> transaction);

  /// Removes the given [transaction] row.
  Future<int> deleteTransaction(Insertable<Transaction> transaction);
}
