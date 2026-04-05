import 'package:flutter/foundation.dart' show listEquals;
import 'package:munshi/features/transactions/domain/entities/transaction.dart';

/// A group of [transactions] that all share the same calendar [date].
///
/// Used by `TransactionState.groupedTransactions` to expose the flat
/// transaction list in a date-bucketed form without requiring consumers to
/// navigate a `Map<DateTime, List<Transaction>>` with a single entry.
class DailyTransactions {
  /// Creates a [DailyTransactions] with [date] and [transactions].
  const DailyTransactions({required this.date, required this.transactions});

  /// The calendar date shared by all [transactions].
  final DateTime date;

  /// The transactions recorded on [date].
  final List<Transaction> transactions;

  @override
  bool operator ==(Object other) =>
      other is DailyTransactions &&
      other.date == date &&
      listEquals(other.transactions, transactions);

  @override
  int get hashCode => Object.hash(date, Object.hashAll(transactions));

  @override
  String toString() =>
      'DailyTransactions(date: $date, transactions: $transactions)';
}
