import 'package:drift/drift.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/database/daos/transaction_dao.dart';
import 'package:munshi/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_filter.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_with_category.dart';

/// Concrete [TransactionRepository] backed by the Drift (SQLite) database.
///
/// All data-access operations are delegated to [TransactionsDao], which
/// keeps the domain layer independent of the underlying storage technology.
class TransactionRepositoryImpl implements TransactionRepository {
  /// Creates a [TransactionRepositoryImpl] that uses [dao] for all queries.
  const TransactionRepositoryImpl(this._dao);

  final TransactionsDao _dao;

  @override
  Future<List<TransactionWithCategory>> getTransactionsPage({
    required int limit,
    required int offset,
    required TransactionFilter filter,
  }) {
    final categoryIds = filter.categories?.map((c) => c.id).toSet();
    return _dao.getTransactionsPaged(
      limit: limit,
      offset: offset,
      startDate: filter.effectiveStartDate,
      endDate: filter.effectiveEndDate,
      types: filter.types,
      minAmount: filter.minAmount,
      maxAmount: filter.maxAmount,
      categoryIds: categoryIds,
    );
  }

  @override
  Future<void> addTransaction(Insertable<Transaction> transaction) =>
      _dao.insertTransaction(transaction);

  @override
  Future<void> updateTransaction(Insertable<Transaction> transaction) =>
      _dao.updateTransaction(transaction);

  @override
  Future<void> deleteTransaction(TransactionWithCategory transaction) =>
      _dao.deleteTransaction(transaction.transaction);
}
