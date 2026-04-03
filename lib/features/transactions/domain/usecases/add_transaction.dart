import 'package:drift/drift.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/transactions/domain/repositories/transaction_repository.dart';

/// Use case that persists a new transaction to the data store.
///
/// Delegates the write operation to [TransactionRepository], keeping the
/// presentation layer free of storage implementation details.
class AddTransaction {
  /// Creates an [AddTransaction] use case backed by [repository].
  const AddTransaction(this._repository);

  final TransactionRepository _repository;

  /// Executes the use case by inserting [transaction] into the data store.
  Future<void> call(Insertable<Transaction> transaction) =>
      _repository.addTransaction(transaction);
}
