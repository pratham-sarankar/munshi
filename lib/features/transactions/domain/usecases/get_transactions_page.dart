import 'package:munshi/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_filter.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_with_category.dart';

/// Use case that retrieves a paginated page of [TransactionWithCategory] items.
///
/// Encapsulates the business rule for fetching transactions with optional
/// filtering, keeping the presentation layer free of data-access concerns.
class GetTransactionsPage {
  /// Creates a [GetTransactionsPage] use case backed by [repository].
  const GetTransactionsPage(this._repository);

  final TransactionRepository _repository;

  /// Executes the use case.
  ///
  /// [limit] – maximum number of results to return.
  /// [offset] – number of results to skip (for pagination).
  /// [filter] – optional filtering criteria (date range, type, category, amount).
  Future<List<TransactionWithCategory>> call({
    required int limit,
    required int offset,
    required TransactionFilter filter,
  }) => _repository.getTransactionsPage(
    limit: limit,
    offset: offset,
    filter: filter,
  );
}
