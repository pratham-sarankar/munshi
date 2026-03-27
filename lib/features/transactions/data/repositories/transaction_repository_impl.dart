import 'package:drift/drift.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/database/daos/transaction_dao.dart';
import 'package:munshi/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:munshi/features/transactions/models/transaction_filter.dart';
import 'package:munshi/features/transactions/models/transaction_with_category.dart';

/// Concrete implementation of [TransactionRepository] backed by [TransactionsDao].
class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._dao);

  final TransactionsDao _dao;

  @override
  Future<List<TransactionWithCategory>> getTransactionsPaged({
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
  Future<int> addTransaction(Insertable<Transaction> transaction) =>
      _dao.insertTransaction(transaction);

  @override
  Future<bool> updateTransaction(Insertable<Transaction> transaction) =>
      _dao.updateTransaction(transaction);

  @override
  Future<int> deleteTransaction(Insertable<Transaction> transaction) =>
      _dao.deleteTransaction(transaction);
}
