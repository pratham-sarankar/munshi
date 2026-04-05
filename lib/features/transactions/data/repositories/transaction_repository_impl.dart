import 'package:munshi/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:munshi/features/transactions/data/extensions/transaction_extensions.dart';
import 'package:munshi/features/transactions/domain/entities/transaction.dart';
import 'package:munshi/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:munshi/features/transactions/domain/value_objects/transaction_filter.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._dataSource);

  final TransactionLocalDataSource _dataSource;

  @override
  Future<List<Transaction>> getTransactionsPage({
    required int limit,
    required int offset,
    required TransactionFilter filter,
  }) {
    final categoryIds = filter.categories?.map((c) => c.id).toSet();
    return _dataSource.getTransactionsPaged(
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
  Future<void> addTransaction(Transaction transaction) =>
      _dataSource.insertTransaction(transaction.toRow());

  @override
  Future<void> updateTransaction(Transaction transaction) =>
      _dataSource.updateTransaction(transaction.toRow());

  @override
  Future<void> deleteTransaction(Transaction transaction) =>
      _dataSource.deleteTransaction(transaction.toRow());
}
