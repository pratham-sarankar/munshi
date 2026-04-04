import 'package:munshi/features/transactions/domain/entities/transaction_with_category.dart';
import 'package:munshi/features/transactions/domain/repositories/transaction_repository.dart';

/// Use case that permanently removes a transaction from the data store.
///
/// Delegates the delete operation to [TransactionRepository], keeping the
/// presentation layer free of storage implementation details.
class DeleteTransaction {
  /// Creates a [DeleteTransaction] use case backed by [repository].
  const DeleteTransaction(this._repository);

  final TransactionRepository _repository;

  /// Executes the use case by deleting [transaction] from the data store.
  Future<void> call(TransactionWithCategory transaction) =>
      _repository.deleteTransaction(transaction);
}
