import 'package:munshi/features/transactions/domain/entities/transaction.dart';
import 'package:munshi/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:munshi/features/transactions/domain/value_objects/transaction_filter.dart';

/// Use case for fetching a paginated list of transactions with optional
/// filtering.
class GetTransactionsPage {
  /// Creates a new instance of [GetTransactionsPage].
  ///
  /// Requires a [TransactionRepository] to fetch transaction data.
  const GetTransactionsPage(this._repository);

  final TransactionRepository _repository;

  /// Executes the use case.
  ///
  /// [limit] – maximum number of results to return.
  /// [offset] – number of results to skip (for pagination).
  /// [filter] – optional filtering criteria (date range, type, category, amount).
  Future<List<Transaction>> call({
    required int limit,
    required int offset,
    required TransactionFilter filter,
  }) => _repository.getTransactionsPage(
    limit: limit,
    offset: offset,
    filter: filter,
  );
}
