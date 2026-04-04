import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocListener;
import 'package:munshi/features/transactions/domain/entities/grouped_transactions.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_filter.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_with_category.dart';
import 'package:munshi/features/transactions/presentation/bloc/transaction_bloc.dart' show TransactionBloc;

/// Describes the overall loading status of the transaction list.
enum TransactionStatus {
  /// No data has been loaded yet.
  initial,

  /// The first page is currently being fetched.
  loading,

  /// At least one page has been loaded successfully.
  success,

  /// An error occurred while fetching a page.
  failure,
}

/// Immutable snapshot of all state managed by [TransactionBloc].
///
/// Create modified copies via [copyWith] rather than mutating fields directly.
class TransactionState extends Equatable {
  /// Creates a [TransactionState] with the supplied field values.
  ///
  /// All parameters are optional and default to sensible initial values.
  const TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.currentFilter = const TransactionFilter(),
    this.error,
    this.transactionMutated = false,
  });

  /// Current loading status of the transaction list.
  final TransactionStatus status;

  /// Flat list of all loaded [TransactionWithCategory] items across all pages.
  final List<TransactionWithCategory> transactions;

  /// Whether additional pages are available to load.
  final bool hasMore;

  /// Whether a next-page fetch is currently in progress.
  final bool isLoadingMore;

  /// The filter that is currently applied to the transaction list.
  final TransactionFilter currentFilter;

  /// The most recent error, or `null` if no error has occurred.
  final Object? error;

  /// Flips to `true` for one state emission immediately after a successful
  /// add, update, or delete mutation.
  ///
  /// UI consumers can use a [BlocListener] to react to this flag (e.g. to
  /// trigger a dashboard refresh) and should treat it as a one-shot signal.
  final bool transactionMutated;

  /// Transactions grouped by calendar date, sorted newest-first.
  ///
  /// This is a computed property derived from [transactions]; it is not stored
  /// separately and therefore not included in [props].
  List<GroupedTransactions> get groupedTransactions {
    if (transactions.isEmpty) return const [];

    final groupedMap = <String, List<TransactionWithCategory>>{};
    for (final transaction in transactions) {
      final d = transaction.date;
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      groupedMap.putIfAbsent(key, () => []).add(transaction);
    }

    final sortedKeys = groupedMap.keys.toList()..sort((a, b) => b.compareTo(a));
    return sortedKeys
        .map(
          (key) => GroupedTransactions(
            date: DateTime.parse(key),
            transactions: groupedMap[key]!,
          ),
        )
        .toList();
  }

  /// Creates a copy of this state with the specified fields replaced.
  ///
  /// Pass `clearError: true` to explicitly set [error] to `null`, because a
  /// nullable [error] parameter alone cannot distinguish "keep existing" from
  /// "set to null".
  TransactionState copyWith({
    TransactionStatus? status,
    List<TransactionWithCategory>? transactions,
    bool? hasMore,
    bool? isLoadingMore,
    TransactionFilter? currentFilter,
    Object? error,
    bool clearError = false,
    bool? transactionMutated,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentFilter: currentFilter ?? this.currentFilter,
      error: clearError ? null : (error ?? this.error),
      transactionMutated: transactionMutated ?? false,
    );
  }

  @override
  List<Object?> get props => [
    status,
    transactions,
    hasMore,
    isLoadingMore,
    currentFilter,
    error,
    transactionMutated,
  ];
}
