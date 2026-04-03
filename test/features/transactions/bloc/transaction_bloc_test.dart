import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/transactions/bloc/transaction_bloc.dart';
import 'package:munshi/features/transactions/bloc/transaction_event.dart';
import 'package:munshi/features/transactions/bloc/transaction_state.dart';
import 'package:munshi/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:munshi/features/transactions/domain/usecases/add_transaction.dart';
import 'package:munshi/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:munshi/features/transactions/domain/usecases/get_transactions_page.dart';
import 'package:munshi/features/transactions/domain/usecases/update_transaction.dart';
import 'package:munshi/features/transactions/models/transaction_filter.dart';
import 'package:munshi/features/transactions/models/transaction_type.dart';
import 'package:munshi/features/transactions/models/transaction_with_category.dart';

// ---------------------------------------------------------------------------
// Stub repository used across all tests
// ---------------------------------------------------------------------------

/// A stub [TransactionRepository] whose behaviour can be configured per-test.
class _StubRepository implements TransactionRepository {
  /// Results to return from [getTransactionsPage].
  List<TransactionWithCategory> pageResults = [];

  /// Whether calls should throw an [Exception].
  bool shouldThrow = false;

  /// Records the filters applied on each [getTransactionsPage] call.
  final List<TransactionFilter> appliedFilters = [];

  @override
  Future<List<TransactionWithCategory>> getTransactionsPage({
    required int limit,
    required int offset,
    required TransactionFilter filter,
  }) async {
    if (shouldThrow) throw Exception('fetch error');
    appliedFilters.add(filter);
    return pageResults;
  }

  @override
  Future<void> addTransaction(Insertable<Transaction> transaction) async {
    if (shouldThrow) throw Exception('add error');
  }

  @override
  Future<void> updateTransaction(Insertable<Transaction> transaction) async {
    if (shouldThrow) throw Exception('update error');
  }

  @override
  Future<void> deleteTransaction(TransactionWithCategory transaction) async {
    if (shouldThrow) throw Exception('delete error');
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

TransactionBloc _makeBloc(_StubRepository repo) {
  return TransactionBloc(
    getTransactionsPage: GetTransactionsPage(repo),
    addTransaction: AddTransaction(repo),
    updateTransaction: UpdateTransaction(repo),
    deleteTransaction: DeleteTransaction(repo),
  );
}

/// Minimal [TransactionWithCategory] stub for tests.
TransactionWithCategory _stubTx(int id) {
  return TransactionWithCategory(
    transaction: Transaction(
      id: id,
      amount: 100,
      type: TransactionType.expense,
      date: DateTime(2024),
      categoryId: null,
      note: null,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TransactionBloc', () {
    late _StubRepository repo;

    setUp(() {
      repo = _StubRepository();
    });

    tearDown(() async {});

    // -----------------------------------------------------------------------
    // Initial state
    // -----------------------------------------------------------------------
    test('initial state is TransactionState with initial status', () {
      final bloc = _makeBloc(repo);
      // Before the auto-loaded TransactionPageRequested completes, check
      // the raw initial value.
      expect(bloc.state.status, TransactionStatus.initial);
      bloc.close();
    });

    // -----------------------------------------------------------------------
    // TransactionPageRequested
    // -----------------------------------------------------------------------
    group('TransactionPageRequested', () {
      test('emits success state with results on successful fetch', () async {
        final txs = [_stubTx(1), _stubTx(2)];
        repo.pageResults = txs;

        final bloc = _makeBloc(repo);

        // Wait for the auto-dispatched event to settle
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.status, TransactionStatus.success);
        expect(bloc.state.transactions, txs);
        expect(bloc.state.hasMore, isFalse); // 2 < pageSize (20)
        await bloc.close();
      });

      test('sets hasMore=true when page is full', () async {
        // Return 20 items (equal to pageSize) → hasMore should be true
        repo.pageResults = List.generate(20, _stubTx);

        final bloc = _makeBloc(repo);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.hasMore, isTrue);
        await bloc.close();
      });

      test('emits failure state when repository throws', () async {
        repo.shouldThrow = true;

        final bloc = _makeBloc(repo);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.status, TransactionStatus.failure);
        expect(bloc.state.error, isNotNull);
        await bloc.close();
      });

      test('resets transactions list on refresh', () async {
        repo.pageResults = [_stubTx(1)];

        final bloc = _makeBloc(repo);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        repo.pageResults = [_stubTx(2)];
        bloc.add(const TransactionPageRequested());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.transactions.map((t) => t.id), [2]);
        await bloc.close();
      });
    });

    // -----------------------------------------------------------------------
    // TransactionNextPageRequested
    // -----------------------------------------------------------------------
    group('TransactionNextPageRequested', () {
      test('appends results to existing transactions', () async {
        repo.pageResults = List.generate(20, _stubTx);
        final bloc = _makeBloc(repo);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Now load more with different items
        repo.pageResults = [_stubTx(99)];
        bloc.add(const TransactionNextPageRequested());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.transactions.length, 21);
        expect(bloc.state.transactions.last.id, 99);
        await bloc.close();
      });

      test('is no-op when hasMore is false', () async {
        repo.pageResults = [_stubTx(1)]; // fewer than pageSize → hasMore=false
        final bloc = _makeBloc(repo);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.hasMore, isFalse);
        repo.appliedFilters.clear();

        bloc.add(const TransactionNextPageRequested());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // No additional queries should have been made
        expect(repo.appliedFilters, isEmpty);
        await bloc.close();
      });
    });

    // -----------------------------------------------------------------------
    // TransactionFilterApplied
    // -----------------------------------------------------------------------
    group('TransactionFilterApplied', () {
      test('updates currentFilter and reloads', () async {
        repo.pageResults = [];
        final bloc = _makeBloc(repo);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final filter = TransactionFilter(
          types: {TransactionType.income},
        );
        bloc.add(TransactionFilterApplied(filter));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.currentFilter, filter);
        expect(bloc.state.status, TransactionStatus.success);
        await bloc.close();
      });

      test('passes new filter to repository', () async {
        repo.pageResults = [];
        final bloc = _makeBloc(repo);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        repo.appliedFilters.clear();

        final filter = TransactionFilter(minAmount: 50);
        bloc.add(TransactionFilterApplied(filter));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(repo.appliedFilters.last, filter);
        await bloc.close();
      });
    });

    // -----------------------------------------------------------------------
    // TransactionFilterCleared
    // -----------------------------------------------------------------------
    group('TransactionFilterCleared', () {
      test('resets filter to empty and reloads', () async {
        repo.pageResults = [];
        final bloc = _makeBloc(repo);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // First apply a filter
        bloc.add(
          TransactionFilterApplied(TransactionFilter(minAmount: 100)),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Then clear it
        bloc.add(const TransactionFilterCleared());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.currentFilter, const TransactionFilter());
        await bloc.close();
      });
    });

    // -----------------------------------------------------------------------
    // TransactionAdded
    // -----------------------------------------------------------------------
    group('TransactionAdded', () {
      test('sets transactionMutated flag and refreshes list', () async {
        final states = <TransactionState>[];

        repo.pageResults = [_stubTx(1)];
        final bloc = _makeBloc(repo);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final subscription = bloc.stream.listen(states.add);

        final companion = TransactionsCompanion.insert(
          amount: 50,
          type: TransactionType.expense,
          date: DateTime(2024),
        );
        bloc.add(TransactionAdded(companion));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        await subscription.cancel();

        // At least one emission should have transactionMutated == true
        expect(states.any((s) => s.transactionMutated), isTrue);
        // Final state should have the refreshed list
        expect(bloc.state.transactions, [_stubTx(1)]);
        await bloc.close();
      });

      test('emits error when repository throws', () async {
        repo.pageResults = [];
        final bloc = _makeBloc(repo);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        repo.shouldThrow = true;

        bloc.add(
          TransactionAdded(
            TransactionsCompanion.insert(
              amount: 10,
              type: TransactionType.expense,
              date: DateTime(2024),
            ),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.error, isNotNull);
        await bloc.close();
      });
    });

    // -----------------------------------------------------------------------
    // TransactionDeleted
    // -----------------------------------------------------------------------
    group('TransactionDeleted', () {
      test('sets transactionMutated and refreshes list', () async {
        final tx = _stubTx(5);
        final states = <TransactionState>[];

        repo.pageResults = [];
        final bloc = _makeBloc(repo);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final subscription = bloc.stream.listen(states.add);

        bloc.add(TransactionDeleted(tx));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        await subscription.cancel();

        expect(states.any((s) => s.transactionMutated), isTrue);
        await bloc.close();
      });
    });

    // -----------------------------------------------------------------------
    // TransactionUpdated
    // -----------------------------------------------------------------------
    group('TransactionUpdated', () {
      test('sets transactionMutated and refreshes list', () async {
        final states = <TransactionState>[];

        repo.pageResults = [_stubTx(7)];
        final bloc = _makeBloc(repo);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final subscription = bloc.stream.listen(states.add);

        final companion = TransactionsCompanion(
          id: const Value(7),
          amount: const Value(200.0),
          type: const Value(TransactionType.expense),
          date: Value(DateTime(2024)),
        );
        bloc.add(TransactionUpdated(companion));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        await subscription.cancel();

        expect(states.any((s) => s.transactionMutated), isTrue);
        await bloc.close();
      });
    });

    // -----------------------------------------------------------------------
    // groupedTransactions
    // -----------------------------------------------------------------------
    group('TransactionState.groupedTransactions', () {
      test('returns empty list when transactions is empty', () {
        const state = TransactionState();
        expect(state.groupedTransactions, isEmpty);
      });

      test('groups transactions by calendar date', () {
        final day1 = DateTime(2024, 1, 15, 10);
        final day2 = DateTime(2024, 1, 16, 9);

        final txDay1 = TransactionWithCategory(
          transaction: Transaction(
            id: 1,
            amount: 50,
            type: TransactionType.expense,
            date: day1,
            categoryId: null,
            note: null,
          ),
        );
        final txDay2 = TransactionWithCategory(
          transaction: Transaction(
            id: 2,
            amount: 75,
            type: TransactionType.income,
            date: day2,
            categoryId: null,
            note: null,
          ),
        );

        final state = TransactionState(transactions: [txDay1, txDay2]);
        final groups = state.groupedTransactions;

        expect(groups.length, 2);
        // Groups are sorted newest-first
        expect(groups.first.date, DateTime(2024, 1, 16));
        expect(groups.last.date, DateTime(2024, 1, 15));
      });

      test('places same-day transactions in one group', () {
        final date = DateTime(2024, 3, 10);
        final txs = List.generate(
          3,
          (i) => TransactionWithCategory(
            transaction: Transaction(
              id: i,
              amount: i * 10,
              type: TransactionType.expense,
              date: date.add(Duration(hours: i)),
              categoryId: null,
              note: null,
            ),
          ),
        );

        final state = TransactionState(transactions: txs);
        expect(state.groupedTransactions.length, 1);
        expect(state.groupedTransactions.first.transactions.length, 3);
      });
    });

    // -----------------------------------------------------------------------
    // TransactionState.copyWith
    // -----------------------------------------------------------------------
    group('TransactionState.copyWith', () {
      test('preserves unchanged fields', () {
        const original = TransactionState(
          status: TransactionStatus.success,
          hasMore: false,
        );

        final copy = original.copyWith(isLoadingMore: true);

        expect(copy.status, TransactionStatus.success);
        expect(copy.hasMore, isFalse);
        expect(copy.isLoadingMore, isTrue);
      });

      test('clears error when clearError is true', () {
        final original = TransactionState(error: Exception('oops'));
        final copy = original.copyWith(clearError: true);
        expect(copy.error, isNull);
      });

      test('preserves error when clearError is false and error is null', () {
        final original = TransactionState(error: Exception('keep'));
        final copy = original.copyWith();
        expect(copy.error, isNotNull);
      });

      test('resets transactionMutated to false by default', () {
        const original = TransactionState(transactionMutated: true);
        final copy = original.copyWith();
        expect(copy.transactionMutated, isFalse);
      });
    });
  });
}
