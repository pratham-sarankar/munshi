import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:munshi/features/transactions/bloc/transaction_event.dart';
import 'package:munshi/features/transactions/bloc/transaction_state.dart';
import 'package:munshi/features/transactions/domain/usecases/get_transactions_use_case.dart';
import 'package:munshi/features/transactions/domain/usecases/transaction_mutation_use_cases.dart';
import 'package:munshi/features/transactions/models/transaction_filter.dart';
import 'package:munshi/features/transactions/models/transaction_with_category.dart';

/// Manages the state of the transactions list screen.
///
/// Supports paginated loading, filtering, and CRUD mutations.
/// An optional [onTransactionChanged] callback is invoked after any
/// successful mutation so that other parts of the app (e.g. dashboard)
/// can refresh their data.
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc({
    required GetTransactionsUseCase getTransactions,
    required AddTransactionUseCase addTransaction,
    required UpdateTransactionUseCase updateTransaction,
    required DeleteTransactionUseCase deleteTransaction,
    VoidCallback? onTransactionChanged,
  })  : _getTransactions = getTransactions,
        _addTransaction = addTransaction,
        _updateTransaction = updateTransaction,
        _deleteTransaction = deleteTransaction,
        _onTransactionChanged = onTransactionChanged,
        super(const TransactionState()) {
    on<TransactionLoadRequested>(_onLoadRequested);
    on<TransactionNextPageRequested>(_onNextPageRequested);
    on<TransactionFilterApplied>(_onFilterApplied);
    on<TransactionFilterCleared>(_onFilterCleared);
    on<TransactionAdded>(_onAdded);
    on<TransactionUpdated>(_onUpdated);
    on<TransactionDeleted>(_onDeleted);
  }

  static const int _pageSize = 20;

  final GetTransactionsUseCase _getTransactions;
  final AddTransactionUseCase _addTransaction;
  final UpdateTransactionUseCase _updateTransaction;
  final DeleteTransactionUseCase _deleteTransaction;
  final VoidCallback? _onTransactionChanged;

  // ---------------------------------------------------------------------------
  // Event handlers
  // ---------------------------------------------------------------------------

  Future<void> _onLoadRequested(
    TransactionLoadRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(
      status: TransactionStatus.loading,
      transactions: const [],
      hasMore: true,
      clearError: true,
    ));
    await _loadPage(emit, offset: 0, existingTransactions: const []);
  }

  Future<void> _onNextPageRequested(
    TransactionNextPageRequested event,
    Emitter<TransactionState> emit,
  ) async {
    if (state.status == TransactionStatus.loadingMore || !state.hasMore) {
      return;
    }
    emit(state.copyWith(status: TransactionStatus.loadingMore));
    await _loadPage(
      emit,
      offset: state.transactions.length,
      existingTransactions: state.transactions,
    );
  }

  Future<void> _onFilterApplied(
    TransactionFilterApplied event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(
      status: TransactionStatus.loading,
      transactions: const [],
      filter: event.filter,
      hasMore: true,
      clearError: true,
    ));
    await _loadPage(emit, offset: 0, existingTransactions: const []);
  }

  Future<void> _onFilterCleared(
    TransactionFilterCleared event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(
      status: TransactionStatus.loading,
      transactions: const [],
      filter: TransactionFilter.empty(),
      hasMore: true,
      clearError: true,
    ));
    await _loadPage(emit, offset: 0, existingTransactions: const []);
  }

  Future<void> _onAdded(
    TransactionAdded event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _addTransaction(event.transaction);
      _onTransactionChanged?.call();
      // Reload from scratch to reflect the new transaction.
      add(const TransactionLoadRequested());
    } on Object catch (e) {
      debugPrint('TransactionBloc: add failed: $e');
      emit(state.copyWith(status: TransactionStatus.failure, error: e));
    }
  }

  Future<void> _onUpdated(
    TransactionUpdated event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _updateTransaction(event.transaction);
      _onTransactionChanged?.call();
      add(const TransactionLoadRequested());
    } on Object catch (e) {
      debugPrint('TransactionBloc: update failed: $e');
      emit(state.copyWith(status: TransactionStatus.failure, error: e));
    }
  }

  Future<void> _onDeleted(
    TransactionDeleted event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _deleteTransaction(event.transaction.transaction);
      _onTransactionChanged?.call();
      add(const TransactionLoadRequested());
    } on Object catch (e) {
      debugPrint('TransactionBloc: delete failed: $e');
      emit(state.copyWith(status: TransactionStatus.failure, error: e));
    }
  }

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------

  Future<void> _loadPage(
    Emitter<TransactionState> emit, {
    required int offset,
    required List<TransactionWithCategory> existing,
  }) async {
    try {
      final results = await _getTransactions(
        limit: _pageSize,
        offset: offset,
        filter: state.filter,
      );
      emit(state.copyWith(
        status: TransactionStatus.loaded,
        transactions: [...existing, ...results],
        hasMore: results.length == _pageSize,
        clearError: true,
      ));
    } on Object catch (e) {
      debugPrint('TransactionBloc: load failed: $e');
      emit(state.copyWith(status: TransactionStatus.failure, error: e));
    }
  }
}
