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

  /// The monetary value of this transaction.
  final double amount;

  /// The date and time when this transaction occurred.
  final DateTime date;

  /// Whether this transaction is an [TransactionType.income] or
  /// [TransactionType.expense].
  final TransactionType type;

  /// The unique identifier for this transaction.
  ///
  /// `null` for transactions that have not yet been persisted.
  final int? id;

  /// The identifier of the [TransactionCategory] associated with this
  /// transaction, or `null` if no category has been assigned.
  final int? categoryId;

  /// An optional free-text note describing this transaction.
  final String? note;

  /// The fully resolved [TransactionCategory] for this transaction.
  ///
  /// May be `null` when only [categoryId] is stored (e.g. in a list view
  /// where categories are not eagerly loaded).
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

  /// Returns a copy of this transaction with the given fields replaced.
  ///
  /// Omitted fields retain their current values.
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
