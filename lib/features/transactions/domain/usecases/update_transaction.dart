import 'package:drift/drift.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/transactions/domain/repositories/transaction_repository.dart';

/// Use case that replaces an existing transaction with updated values.
///
/// Delegates the update operation to [TransactionRepository], keeping the
/// presentation layer free of storage implementation details.
class UpdateTransaction {
  /// Creates an [UpdateTransaction] use case backed by [repository].
  const UpdateTransaction(this._repository);

  final TransactionRepository _repository;

  /// Executes the use case by replacing the matching record with [transaction].
  Future<void> call(Insertable<Transaction> transaction) =>
      _repository.updateTransaction(transaction);
}
