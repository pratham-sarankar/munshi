import 'package:drift/drift.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_filter.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_with_category.dart';

/// Abstract repository contract for all transaction data-access operations.
///
/// The domain layer depends only on this interface, keeping business logic
/// independent of any specific storage technology (e.g. Drift/SQLite).
abstract interface class TransactionRepository {
  /// Returns a paginated slice of transactions that match [filter].
  ///
  /// [limit] is the maximum number of items to return.
  /// [offset] is the number of items to skip before collecting results.
  /// [filter] optionally restricts results by date, type, category, or amount.
  Future<List<TransactionWithCategory>> getTransactionsPage({
    required int limit,
    required int offset,
    required TransactionFilter filter,
  });

  /// Persists a new [transaction] in the data store.
  Future<void> addTransaction(Insertable<Transaction> transaction);

  /// Replaces an existing transaction with the values provided by [transaction].
  Future<void> updateTransaction(Insertable<Transaction> transaction);

  /// Permanently removes [transaction] from the data store.
  Future<void> deleteTransaction(TransactionWithCategory transaction);
}
