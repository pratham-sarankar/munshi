import 'package:equatable/equatable.dart';
import 'package:munshi/features/transactions/domain/entities/transaction.dart';
import 'package:munshi/features/transactions/presentation/bloc/transaction_bloc.dart'
    show TransactionBloc;
import 'package:munshi/features/transactions/presentation/bloc/transaction_state.dart'
    show TransactionState;
import 'package:munshi/features/transactions/presentation/transaction_filter.dart';

/// Base class for all events handled by [TransactionBloc].
///
/// All events are immutable value objects that describe what has happened
/// or what action the UI is requesting.
sealed class TransactionEvent extends Equatable {
  /// Creates a [TransactionEvent].
  const TransactionEvent();

  @override
  List<Object?> get props => const [];
}

/// Requests the first page of transactions (or a full refresh).
///
/// Dispatched on initial load and after any mutation (add/update/delete) to
/// keep the displayed list in sync with the data store.
final class TransactionPageRequested extends TransactionEvent {
  /// Creates a [TransactionPageRequested] event.
  const TransactionPageRequested();
}

/// Requests the next page of transactions for infinite scrolling.
///
/// The bloc ignores this event when a load is already in progress or when
/// there are no more pages available ([TransactionState.hasMore] is false).
final class TransactionNextPageRequested extends TransactionEvent {
  /// Creates a [TransactionNextPageRequested] event.
  const TransactionNextPageRequested();
}

/// Applies [filter] to the transaction list and reloads from page one.
final class TransactionFilterApplied extends TransactionEvent {
  /// Creates a [TransactionFilterApplied] event with [filter].
  const TransactionFilterApplied(this.filter);

  /// The new filter to apply.
  final TransactionFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Clears all active filters and reloads from page one.
final class TransactionFilterCleared extends TransactionEvent {
  /// Creates a [TransactionFilterCleared] event.
  const TransactionFilterCleared();
}

/// Requests that [transaction] be inserted into the data store.
final class TransactionAdded extends TransactionEvent {
  /// Creates a [TransactionAdded] event for [transaction].
  const TransactionAdded(this.transaction);

  /// The transaction data to persist.
  final Transaction transaction;

  @override
  List<Object?> get props => [transaction];
}

/// Requests that the matching record be replaced with [transaction].
final class TransactionUpdated extends TransactionEvent {
  /// Creates a [TransactionUpdated] event for [transaction].
  const TransactionUpdated(this.transaction);

  /// The updated transaction data to persist.
  final Transaction transaction;

  @override
  List<Object?> get props => [transaction];
}

/// Requests that [transaction] be permanently removed from the data store.
final class TransactionDeleted extends TransactionEvent {
  /// Creates a [TransactionDeleted] event for [transaction].
  const TransactionDeleted(this.transaction);

  /// The transaction to remove.
  final Transaction transaction;

  @override
  List<Object?> get props => [transaction];
}
