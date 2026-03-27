import 'package:drift/drift.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/transactions/domain/repositories/transaction_repository.dart';

/// Use case: add a new transaction.
class AddTransactionUseCase {
  const AddTransactionUseCase(this._repository);

  final TransactionRepository _repository;

  Future<int> call(Insertable<Transaction> transaction) =>
      _repository.addTransaction(transaction);
}

/// Use case: update an existing transaction.
class UpdateTransactionUseCase {
  const UpdateTransactionUseCase(this._repository);

  final TransactionRepository _repository;

  Future<bool> call(Insertable<Transaction> transaction) =>
      _repository.updateTransaction(transaction);
}

/// Use case: delete a transaction.
class DeleteTransactionUseCase {
  const DeleteTransactionUseCase(this._repository);

  final TransactionRepository _repository;

  Future<int> call(Insertable<Transaction> transaction) =>
      _repository.deleteTransaction(transaction);
}
