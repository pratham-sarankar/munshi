import 'package:equatable/equatable.dart';
import 'package:munshi/features/transactions/models/grouped_transactions.dart';
import 'package:munshi/features/transactions/models/transaction_filter.dart';
import 'package:munshi/features/transactions/models/transaction_with_category.dart';

/// Status of the transaction list.
enum TransactionStatus {
  /// Initial state before any load has been attempted.
  initial,

  /// A full reload is in progress (e.g. after applying a filter).
  loading,

  /// Data loaded successfully.
  loaded,

  /// A paginated next-page load is in progress.
  loadingMore,

  /// An error occurred during the most recent load.
  failure,
}

/// Immutable state for the [TransactionBloc].
class TransactionState extends Equatable {
  const TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = const [],
    this.filter = const TransactionFilter(),
    this.hasMore = true,
    this.error,
  });

  /// Creates a copy with optional field overrides.
  TransactionState copyWith({
    TransactionStatus? status,
    List<TransactionWithCategory>? transactions,
    TransactionFilter? filter,
    bool? hasMore,
    Object? error,
    bool clearError = false,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      filter: filter ?? this.filter,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }

  final TransactionStatus status;
  final List<TransactionWithCategory> transactions;
  final TransactionFilter filter;
  final bool hasMore;
  final Object? error;

  /// Transactions grouped by date, sorted descending.
  List<GroupedTransactions> get groupedTransactions {
    if (transactions.isEmpty) return [];

    final groupedMap = <String, List<TransactionWithCategory>>{};
    for (final tx in transactions) {
      final d = tx.date;
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      groupedMap.putIfAbsent(key, () => []).add(tx);
    }

    final sortedKeys = groupedMap.keys.toList()..sort((a, b) => b.compareTo(a));
    return sortedKeys.map((key) {
      return GroupedTransactions(
        date: DateTime.parse(key),
        transactions: groupedMap[key]!,
      );
    }).toList();
  }

  @override
  List<Object?> get props => [status, transactions, filter, hasMore, error];
}
