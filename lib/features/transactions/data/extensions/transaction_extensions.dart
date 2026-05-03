import 'package:drift/drift.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/transactions/domain/entities/transaction.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';

/// Extension to convert a [TransactionRow] (Drift row) to a domain entity.
extension TransactionRowExtension on TransactionRow {
  /// Converts this database row to a [Transaction] entity, optionally attaching [category].
  Transaction toEntity({TransactionCategory? category}) {
    return Transaction(
      id: id,
      amount: amount,
      categoryId: categoryId,
      date: date,
      note: note,
      type: type,
      category: category,
    );
  }
}

/// Extension to convert a [Transaction] domain entity to an [Insertable] row.
extension TransactionExtension on Transaction {
  /// Returns an [Insertable] for persisting this transaction.
  ///
  /// When [id] is `null` (new transaction), the primary key is omitted so the
  /// database assigns an auto-increment value.  When [id] is non-null
  /// (existing transaction), the key is included so Drift can locate the row
  /// for updates and deletes.
  Insertable<TransactionRow> toRow() {
    return TransactionsCompanion(
      id: id == null ? const Value.absent() : Value(id!),
      amount: Value(amount),
      categoryId: Value(categoryId),
      date: Value(date),
      note: Value(note),
      type: Value(type),
    );
  }
}
