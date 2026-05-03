import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/features/transactions/domain/entities/transaction.dart';
import 'package:munshi/features/transactions/domain/usecases/add_transaction.dart';
import 'package:munshi/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:munshi/features/transactions/domain/usecases/get_transactions_page.dart';
import 'package:munshi/features/transactions/domain/usecases/update_transaction.dart';
import 'package:munshi/features/transactions/domain/value_objects/transaction_filter.dart';
import 'package:munshi/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:munshi/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:munshi/features/transactions/presentation/bloc/transaction_state.dart';

// ── Mocks ──────────────────────────────────────────────────────

class MockGetTransactionsPage extends Mock implements GetTransactionsPage {}

class MockAddTransaction extends Mock implements AddTransaction {}

class MockUpdateTransaction extends Mock implements UpdateTransaction {}

class MockDeleteTransaction extends Mock implements DeleteTransaction {}

// ── Helpers ────────────────────────────────────────────────────

/// Collects all states emitted while [action] runs, then cancels.
Future<List<TransactionState>> collectStates(
  TransactionBloc bloc,
  Future<void> Function() action,
) async {
  final states = <TransactionState>[];
  final sub = bloc.stream.listen(states.add);
  await action();
  await sub.cancel();
  return states;
}

// Page size mirrors the private constant in TransactionBloc.
const _pageSize = 20;

void main() {
  late MockGetTransactionsPage mockGet;
  late MockAddTransaction mockAdd;
  late MockUpdateTransaction mockUpdate;
  late MockDeleteTransaction mockDelete;

  final tDate = DateTime(2026, 5);

  final tTransaction = Transaction(
    id: 1,
    amount: 100,
    date: tDate,
    note: 'Test',
    type: TransactionType.expense,
  );

  // Build a list of [count] distinct transactions.
  List<Transaction> makeTransactions(int count) => List.generate(
    count,
    (i) => Transaction(
      id: i + 1,
      amount: (i + 1) * 10.0,
      date: tDate,
      note: 'tx $i',
      type: TransactionType.expense,
    ),
  );

  // Stub the get use case to return [transactions] for any arguments.
  void stubGet(List<Transaction> transactions) {
    when(
      () => mockGet(
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
        filter: any(named: 'filter'),
      ),
    ).thenAnswer((_) async => transactions);
  }

  // Stub get to throw.
  void stubGetThrows([Exception? error]) {
    when(
      () => mockGet(
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
        filter: any(named: 'filter'),
      ),
    ).thenAnswer((_) async => throw (error ?? Exception('fetch error')));
  }

  setUpAll(() {
    registerFallbackValue(TransactionFilter.empty());
    registerFallbackValue(tTransaction);
  });

  setUp(() {
    mockGet = MockGetTransactionsPage();
    mockAdd = MockAddTransaction();
    mockUpdate = MockUpdateTransaction();
    mockDelete = MockDeleteTransaction();
  });

  // Convenience factory: stubs get before the bloc's constructor add fires.
  TransactionBloc makeBloc({List<Transaction>? initialPage}) {
    stubGet(initialPage ?? [tTransaction]);
    return TransactionBloc(
      getTransactionsPage: mockGet,
      addTransaction: mockAdd,
      updateTransaction: mockUpdate,
      deleteTransaction: mockDelete,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TransactionState
  // ─────────────────────────────────────────────────────────────

  group('TransactionState', () {
    test('initial state has sensible defaults', () {
      const s = TransactionState();
      expect(s.status, TransactionStatus.initial);
      expect(s.transactions, isEmpty);
      expect(s.hasMore, isTrue);
      expect(s.isLoadingMore, isFalse);
      expect(s.currentFilter, TransactionFilter.empty());
      expect(s.error, isNull);
      expect(s.transactionMutated, isFalse);
    });

    test('copyWith preserves unchanged fields', () {
      const base = TransactionState(status: TransactionStatus.success);
      final copy = base.copyWith(isLoadingMore: true);
      expect(copy.status, TransactionStatus.success);
      expect(copy.isLoadingMore, isTrue);
    });

    test('copyWith clearError sets error to null', () {
      const base = TransactionState(error: 'oops');
      final copy = base.copyWith(clearError: true);
      expect(copy.error, isNull);
    });

    test('transactionMutated resets to false on every copyWith', () {
      const base = TransactionState(transactionMutated: true);
      // Not passing transactionMutated → defaults to false.
      expect(base.copyWith().transactionMutated, isFalse);
    });

    group('groupedTransactions', () {
      test('returns empty list when transactions is empty', () {
        expect(const TransactionState().groupedTransactions, isEmpty);
      });

      test('groups transactions by date newest-first', () {
        final older = Transaction(
          id: 1,
          amount: 10,
          date: DateTime(2026),
          type: TransactionType.expense,
        );
        final newer = Transaction(
          id: 2,
          amount: 20,
          date: DateTime(2026, 3),
          type: TransactionType.expense,
        );
        final state = TransactionState(transactions: [older, newer]);
        final groups = state.groupedTransactions;

        expect(groups, hasLength(2));
        expect(groups[0].date, DateTime(2026, 3));
        expect(groups[1].date, DateTime(2026));
      });

      test('transactions on the same date are in the same group', () {
        final t1 = Transaction(
          id: 1,
          amount: 10,
          date: DateTime(2026, 5, 1, 9),
          type: TransactionType.expense,
        );
        final t2 = Transaction(
          id: 2,
          amount: 20,
          date: DateTime(2026, 5, 1, 18),
          type: TransactionType.expense,
        );
        final state = TransactionState(transactions: [t1, t2]);
        final groups = state.groupedTransactions;

        expect(groups, hasLength(1));
        expect(groups[0].transactions, hasLength(2));
      });
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Initial load (TransactionPageRequested fired in constructor)
  // ─────────────────────────────────────────────────────────────

  group('initial load on construction', () {
    test('emits loading → success with transactions', () async {
      final bloc = makeBloc(initialPage: [tTransaction]);

      final states = await collectStates(bloc, pumpEventQueue);

      expect(states[0].status, TransactionStatus.loading);
      expect(states[1].status, TransactionStatus.success);
      expect(states[1].transactions, [tTransaction]);

      await bloc.close();
    });

    test('emits loading → failure on datasource error', () async {
      stubGetThrows();
      final bloc = TransactionBloc(
        getTransactionsPage: mockGet,
        addTransaction: mockAdd,
        updateTransaction: mockUpdate,
        deleteTransaction: mockDelete,
      );

      final states = await collectStates(bloc, pumpEventQueue);

      expect(states.last.status, TransactionStatus.failure);
      expect(states.last.error, isNotNull);

      await bloc.close();
    });

    test('hasMore is false when result count is less than page size', () async {
      final bloc = makeBloc(initialPage: [tTransaction]); // 1 < 20

      final states = await collectStates(bloc, pumpEventQueue);
      expect(states.last.hasMore, isFalse);

      await bloc.close();
    });

    test('hasMore is true when result count equals page size', () async {
      final fullPage = makeTransactions(_pageSize);
      final bloc = makeBloc(initialPage: fullPage);

      final states = await collectStates(bloc, pumpEventQueue);
      expect(states.last.hasMore, isTrue);

      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────────────────
  // TransactionPageRequested
  // ─────────────────────────────────────────────────────────────

  group('TransactionPageRequested', () {
    test('re-fetches from offset 0 and replaces existing list', () async {
      final bloc = makeBloc(initialPage: [tTransaction]);
      await pumpEventQueue(); // settle initial load

      final newTx = tTransaction.copyWith(id: 99, note: 'refreshed');
      stubGet([newTx]);

      final states = await collectStates(bloc, () async {
        bloc.add(const TransactionPageRequested());
        await pumpEventQueue();
      });

      final successState = states.lastWhere(
        (s) => s.status == TransactionStatus.success,
      );
      expect(successState.transactions, [newTx]);

      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────────────────
  // TransactionNextPageRequested
  // ─────────────────────────────────────────────────────────────

  group('TransactionNextPageRequested', () {
    test('appends results to existing list', () async {
      final firstPage = makeTransactions(_pageSize);
      final bloc = makeBloc(initialPage: firstPage);
      await pumpEventQueue();

      final secondPage = makeTransactions(
        5,
      ).map((t) => t.copyWith(id: t.id! + 100)).toList();
      stubGet(secondPage);

      final states = await collectStates(bloc, () async {
        bloc.add(const TransactionNextPageRequested());
        await pumpEventQueue();
      });

      final last = states.last;
      expect(last.transactions.length, firstPage.length + secondPage.length);

      await bloc.close();
    });

    test('is ignored when hasMore is false', () async {
      final bloc = makeBloc(initialPage: [tTransaction]); // hasMore = false
      await pumpEventQueue();

      final states = await collectStates(bloc, () async {
        bloc.add(const TransactionNextPageRequested());
        await pumpEventQueue();
      });

      // No new states emitted (the handler returns early).
      expect(states, isEmpty);

      await bloc.close();
    });

    test('is ignored when already loading more', () async {
      final firstPage = makeTransactions(_pageSize);
      final bloc = makeBloc(initialPage: firstPage);
      await pumpEventQueue();

      // Stub a slow response to keep isLoadingMore = true.
      when(
        () => mockGet(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          filter: any(named: 'filter'),
        ),
      ).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return [];
      });

      // Fire two next-page events rapidly.
      bloc
        ..add(const TransactionNextPageRequested())
        ..add(const TransactionNextPageRequested());
      await pumpEventQueue();

      // Droppable transformer means get is called exactly once per fast burst.
      verify(
        () => mockGet(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          filter: any(named: 'filter'),
        ),
      ).called(greaterThanOrEqualTo(1));

      await bloc.close();
    });

    test('offset passed equals current transactions count', () async {
      final firstPage = makeTransactions(_pageSize);
      final bloc = makeBloc(initialPage: firstPage);
      await pumpEventQueue();

      stubGet([]);
      bloc.add(const TransactionNextPageRequested());
      await pumpEventQueue();

      verify(
        () => mockGet(
          limit: _pageSize,
          offset: _pageSize,
          filter: any(named: 'filter'),
        ),
      ).called(1);

      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────────────────
  // TransactionFilterApplied
  // ─────────────────────────────────────────────────────────────

  group('TransactionFilterApplied', () {
    test('updates currentFilter and re-fetches from offset 0', () async {
      final bloc = makeBloc();
      await pumpEventQueue();

      final filter = TransactionFilter.fromTimeframe('This Month');
      stubGet([tTransaction]);

      final states = await collectStates(bloc, () async {
        bloc.add(TransactionFilterApplied(filter));
        await pumpEventQueue();
      });

      final successState = states.lastWhere(
        (s) => s.status == TransactionStatus.success,
      );
      expect(successState.currentFilter, filter);

      verify(
        () => mockGet(
          limit: any(named: 'limit'),
          offset: 0,
          filter: filter,
        ),
      ).called(1);

      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────────────────
  // TransactionFilterCleared
  // ─────────────────────────────────────────────────────────────

  group('TransactionFilterCleared', () {
    test('resets filter to empty and re-fetches', () async {
      final bloc = makeBloc();
      await pumpEventQueue();

      // Apply a filter first.
      final filter = TransactionFilter.fromTimeframe('Today');
      stubGet([tTransaction]);
      bloc.add(TransactionFilterApplied(filter));
      await pumpEventQueue();

      // Now clear it.
      stubGet([tTransaction]);
      final states = await collectStates(bloc, () async {
        bloc.add(const TransactionFilterCleared());
        await pumpEventQueue();
      });

      final successState = states.lastWhere(
        (s) => s.status == TransactionStatus.success,
      );
      expect(successState.currentFilter, TransactionFilter.empty());

      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────────────────
  // TransactionAdded
  // ─────────────────────────────────────────────────────────────

  group('TransactionAdded', () {
    setUp(() {
      when(() => mockAdd(any())).thenAnswer((_) async {});
    });

    test(
      'calls addTransaction use case and emits transactionMutated = true',
      () async {
        final bloc = makeBloc();
        await pumpEventQueue();

        stubGet([tTransaction]);

        final states = await collectStates(bloc, () async {
          bloc.add(TransactionAdded(tTransaction));
          await pumpEventQueue();
        });

        verify(() => mockAdd(tTransaction)).called(1);
        expect(states.any((s) => s.transactionMutated), isTrue);

        await bloc.close();
      },
    );

    test('refreshes the list after a successful add', () async {
      final bloc = makeBloc();
      await pumpEventQueue();

      final updatedList = [tTransaction, tTransaction.copyWith(id: 2)];
      stubGet(updatedList);

      final states = await collectStates(bloc, () async {
        bloc.add(TransactionAdded(tTransaction));
        await pumpEventQueue();
      });

      final successState = states.lastWhere(
        (s) => s.status == TransactionStatus.success,
      );
      expect(successState.transactions, updatedList);

      await bloc.close();
    });

    test('emits error state when add fails', () async {
      when(
        () => mockAdd(any()),
      ).thenAnswer((_) async => throw Exception('add failed'));

      stubGet([]);
      final bloc = makeBloc();
      await pumpEventQueue();

      final states = await collectStates(bloc, () async {
        bloc.add(TransactionAdded(tTransaction));
        await pumpEventQueue();
      });

      expect(states.any((s) => s.error != null), isTrue);

      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────────────────
  // TransactionUpdated
  // ─────────────────────────────────────────────────────────────

  group('TransactionUpdated', () {
    setUp(() {
      when(() => mockUpdate(any())).thenAnswer((_) async {});
    });

    test(
      'calls updateTransaction use case and emits transactionMutated = true',
      () async {
        final bloc = makeBloc();
        await pumpEventQueue();

        stubGet([tTransaction]);

        final states = await collectStates(bloc, () async {
          bloc.add(TransactionUpdated(tTransaction));
          await pumpEventQueue();
        });

        verify(() => mockUpdate(tTransaction)).called(1);
        expect(states.any((s) => s.transactionMutated), isTrue);

        await bloc.close();
      },
    );

    test('emits error state when update fails', () async {
      when(
        () => mockUpdate(any()),
      ).thenAnswer((_) async => throw Exception('update failed'));

      stubGet([]);
      final bloc = makeBloc();
      await pumpEventQueue();

      final states = await collectStates(bloc, () async {
        bloc.add(TransactionUpdated(tTransaction));
        await pumpEventQueue();
      });

      expect(states.any((s) => s.error != null), isTrue);

      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────────────────
  // TransactionDeleted
  // ─────────────────────────────────────────────────────────────

  group('TransactionDeleted', () {
    setUp(() {
      when(() => mockDelete(any())).thenAnswer((_) async {});
    });

    test(
      'calls deleteTransaction use case and emits transactionMutated = true',
      () async {
        final bloc = makeBloc();
        await pumpEventQueue();

        stubGet([]);

        final states = await collectStates(bloc, () async {
          bloc.add(TransactionDeleted(tTransaction));
          await pumpEventQueue();
        });

        verify(() => mockDelete(tTransaction)).called(1);
        expect(states.any((s) => s.transactionMutated), isTrue);

        await bloc.close();
      },
    );

    test('emits error state when delete fails', () async {
      when(
        () => mockDelete(any()),
      ).thenAnswer((_) async => throw Exception('delete failed'));

      stubGet([]);
      final bloc = makeBloc();
      await pumpEventQueue();

      final states = await collectStates(bloc, () async {
        bloc.add(TransactionDeleted(tTransaction));
        await pumpEventQueue();
      });

      expect(states.any((s) => s.error != null), isTrue);

      await bloc.close();
    });
  });
}
