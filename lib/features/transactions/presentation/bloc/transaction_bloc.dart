import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:munshi/features/transactions/domain/usecases/add_transaction.dart';
import 'package:munshi/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:munshi/features/transactions/domain/usecases/get_transactions_page.dart';
import 'package:munshi/features/transactions/domain/usecases/update_transaction.dart';
import 'package:munshi/features/transactions/domain/value_objects/transaction_filter.dart';
import 'package:munshi/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:munshi/features/transactions/presentation/bloc/transaction_state.dart';

/// BLoC for managing transaction state and operations.
///
/// Handles transaction listing with pagination, filtering, and CRUD operations.
/// Emits [TransactionState] in response to [TransactionEvent] events.
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  /// Creates a [TransactionBloc] with the given use cases.
  /// The first page of transactions is requested immediately upon construction.
  TransactionBloc({
    required GetTransactionsPage getTransactionsPage,
    required AddTransaction addTransaction,
    required UpdateTransaction updateTransaction,
    required DeleteTransaction deleteTransaction,
  }) : _getTransactionsPage = getTransactionsPage,
       _addTransaction = addTransaction,
       _updateTransaction = updateTransaction,
       _deleteTransaction = deleteTransaction,
       super(const TransactionState()) {
    // Page/filter fetches: restartable so a newer request cancels an older one.
    on<TransactionPageRequested>(_onPageRequested, transformer: restartable());
    on<TransactionFilterApplied>(_onFilterApplied, transformer: restartable());
    on<TransactionFilterCleared>(_onFilterCleared, transformer: restartable());

    // Next-page: droppable so rapid scrolling events are ignored while loading.
    on<TransactionNextPageRequested>(
      _onNextPageRequested,
      transformer: droppable(),
    );

    // Mutations: sequential so writes are never interleaved and each refresh
    // follows its own committed write.
    on<TransactionAdded>(_onAdded, transformer: sequential());
    on<TransactionUpdated>(_onUpdated, transformer: sequential());
    on<TransactionDeleted>(_onDeleted, transformer: sequential());

    // Trigger initial data load.
    add(const TransactionPageRequested());
  }

  static const int _pageSize = 20;

  final GetTransactionsPage _getTransactionsPage;
  final AddTransaction _addTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;

  // ---------------------------------------------------------------------------
  // Event handlers
  // ---------------------------------------------------------------------------

  Future<void> _onPageRequested(
    TransactionPageRequested event,
    Emitter<TransactionState> emit,
  ) async {
    await _fetchFirstPage(emit);
  }

  Future<void> _onNextPageRequested(
    TransactionNextPageRequested event,
    Emitter<TransactionState> emit,
  ) async {
    await _fetchNextPage(emit);
  }

  Future<void> _onFilterApplied(
    TransactionFilterApplied event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(currentFilter: event.filter));
    await _fetchFirstPage(emit);
  }

  Future<void> _onFilterCleared(
    TransactionFilterCleared event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(currentFilter: const TransactionFilter()));
    await _fetchFirstPage(emit);
  }

  Future<void> _onAdded(
    TransactionAdded event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _addTransaction(event.transaction);
      emit(state.copyWith(transactionMutated: true));
      await _fetchFirstPage(emit);
    } on Exception catch (error) {
      debugPrint('TransactionBloc: failed to add transaction: $error');
      emit(state.copyWith(error: error));
    }
  }

  Future<void> _onUpdated(
    TransactionUpdated event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _updateTransaction(event.transaction);
      emit(state.copyWith(transactionMutated: true));
      await _fetchFirstPage(emit);
    } on Exception catch (error) {
      debugPrint('TransactionBloc: failed to update transaction: $error');
      emit(state.copyWith(error: error));
    }
  }

  Future<void> _onDeleted(
    TransactionDeleted event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _deleteTransaction(event.transaction);
      emit(state.copyWith(transactionMutated: true));
      await _fetchFirstPage(emit);
    } on Exception catch (error) {
      debugPrint('TransactionBloc: failed to delete transaction: $error');
      emit(state.copyWith(error: error));
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Resets pagination and loads the first page using [state.currentFilter].
  ///
  /// Always clears [TransactionState.isLoadingMore] so an in-flight next-page
  /// request cannot leave the indicator stuck after a refresh, filter change,
  /// or mutation triggers a first-page reload.
  Future<void> _fetchFirstPage(Emitter<TransactionState> emit) async {
    emit(
      state.copyWith(
        status: TransactionStatus.loading,
        transactions: const [],
        hasMore: true,
        isLoadingMore: false,
        clearError: true,
      ),
    );
    try {
      final results = await _getTransactionsPage(
        limit: _pageSize,
        offset: 0,
        filter: state.currentFilter,
      );
      emit(
        state.copyWith(
          status: TransactionStatus.success,
          transactions: results,
          hasMore: results.length == _pageSize,
          isLoadingMore: false,
        ),
      );
    } on Exception catch (error) {
      debugPrint('TransactionBloc: failed to load page: $error');
      emit(
        state.copyWith(
          status: TransactionStatus.failure,
          isLoadingMore: false,
          error: error,
        ),
      );
    }
  }

  /// Appends the next page to [state.transactions].
  ///
  /// No-op when [TransactionState.isLoadingMore] is `true` or
  /// [TransactionState.hasMore] is `false`.
  Future<void> _fetchNextPage(Emitter<TransactionState> emit) async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true, clearError: true));
    final offset = state.transactions.length;
    try {
      final results = await _getTransactionsPage(
        limit: _pageSize,
        offset: offset,
        filter: state.currentFilter,
      );
      emit(
        state.copyWith(
          isLoadingMore: false,
          transactions: [...state.transactions, ...results],
          hasMore: results.length == _pageSize,
        ),
      );
    } on Exception catch (error) {
      debugPrint('TransactionBloc: failed to load next page: $error');
      emit(state.copyWith(isLoadingMore: false, error: error));
    }
  }
}
