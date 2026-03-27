import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/transactions/models/transaction_filter.dart';
import 'package:munshi/features/transactions/models/transaction_with_category.dart';

/// Base class for all transaction bloc events.
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Reload transactions from scratch (resets pagination).
class TransactionLoadRequested extends TransactionEvent {
  const TransactionLoadRequested();
}

/// Load the next page of transactions.
class TransactionNextPageRequested extends TransactionEvent {
  const TransactionNextPageRequested();
}

/// Apply a new [filter] and reload from the first page.
class TransactionFilterApplied extends TransactionEvent {
  const TransactionFilterApplied(this.filter);

  final TransactionFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Clear all filters and reload from the first page.
class TransactionFilterCleared extends TransactionEvent {
  const TransactionFilterCleared();
}

/// Add a new transaction.
class TransactionAdded extends TransactionEvent {
  const TransactionAdded(this.transaction);

  final Insertable<Transaction> transaction;

  @override
  List<Object?> get props => [transaction];
}

/// Update an existing transaction.
class TransactionUpdated extends TransactionEvent {
  const TransactionUpdated(this.transaction);

  final Insertable<Transaction> transaction;

  @override
  List<Object?> get props => [transaction];
}

/// Delete a transaction.
class TransactionDeleted extends TransactionEvent {
  const TransactionDeleted(this.transaction);

  final TransactionWithCategory transaction;

  @override
  List<Object?> get props => [transaction];
}
