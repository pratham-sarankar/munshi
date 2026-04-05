import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';

part 'transaction.freezed.dart';

/// Represents a financial transaction entity.
///
/// Contains transaction details including amount, date, type, and
/// optional category and note.
@freezed
abstract class Transaction with _$Transaction {
  /// Creates a new [Transaction] instance.
  const factory Transaction({
    int? id,
    required double amount,
    required DateTime date,
    required TransactionType type,
    int? categoryId,
    String? note,
    TransactionCategory? category,
  }) = _Transaction;
}
