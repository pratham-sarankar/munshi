import 'package:equatable/equatable.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';

/// Represents a financial transaction entity.
///
/// Contains transaction details including amount, date, type, and
/// optional category and note.
class Transaction extends Equatable {
  /// Creates a new [Transaction] instance.
  const Transaction({
    required this.amount,
    required this.date,
    required this.type,
    this.id,
    this.categoryId,
    this.note,
    this.category,
  });

  final double amount;
  final DateTime date;
  final TransactionType type;
  final int? id;
  final int? categoryId;
  final String? note;
  final TransactionCategory? category;

  @override
  List<Object?> get props => [
    id,
    amount,
    date,
    type,
    categoryId,
    note,
    category,
  ];

  Transaction copyWith({
    double? amount,
    DateTime? date,
    TransactionType? type,
    int? id,
    int? categoryId,
    String? note,
    TransactionCategory? category,
  }) {
    return Transaction(
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      category: category ?? this.category,
    );
  }
}
