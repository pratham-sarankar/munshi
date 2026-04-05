import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/transactions/domain/entities/transaction.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';

extension TransactionRowExtension on TransactionRow {
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

extension TransactionExtension on Transaction {
  TransactionRow toRow() {
    return TransactionRow(
      id: id,
      amount: amount,
      categoryId: categoryId,
      date: date,
      note: note,
      type: type,
    );
  }
}
