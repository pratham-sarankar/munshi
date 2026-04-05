import 'package:munshi/features/transactions/domain/entities/transaction.dart';
import 'package:munshi/features/transactions/domain/repositories/transaction_repository.dart';

/// Use case that persists a new transaction to the data store.
///
/// Delegates the write operation to [TransactionRepository], keeping the
/// presentation layer free of storage implementation details.
class AddTransaction {
  /// Creates an instance of [AddTransaction].
  ///
  /// Requires a [TransactionRepository] instance to perform the persistence
  /// operation.
  const AddTransaction(this._repository);

  final TransactionRepository _repository;

  /// Executes the use case by inserting [transaction] into the data store.
  Future<void> call(Transaction transaction) =>
      _repository.addTransaction(transaction);
}
