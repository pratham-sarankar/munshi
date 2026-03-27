import 'package:munshi/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:munshi/features/transactions/models/transaction_filter.dart';
import 'package:munshi/features/transactions/models/transaction_with_category.dart';

/// Use case: retrieve a paginated page of transactions for a given filter.
class GetTransactionsUseCase {
  const GetTransactionsUseCase(this._repository);

  final TransactionRepository _repository;

  Future<List<TransactionWithCategory>> call({
    required int limit,
    required int offset,
    required TransactionFilter filter,
  }) =>
      _repository.getTransactionsPaged(
        limit: limit,
        offset: offset,
        filter: filter,
      );
}
