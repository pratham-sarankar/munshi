import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/features/transactions/data/datasources/transaction_local_datasource.dart';

void main() {
  late AppDatabase db;
  late TransactionLocalDataSource dataSource;

  // ── helpers ──────────────────────────────────────────────────

  /// Insert a bare transaction row and return its auto-generated id.
  Future<int> insertTx({
    required double amount,
    required TransactionType type,
    required DateTime date,
    String? note,
    int? categoryId,
  }) {
    return dataSource.insertTransaction(
      TransactionsCompanion.insert(
        amount: amount,
        type: type,
        date: date,
        note: Value(note),
        categoryId: Value(categoryId),
      ),
    );
  }

  /// Insert a bare category row and return its auto-generated id.
  Future<int> insertCategory({
    String name = 'Test Category',
    TransactionType type = TransactionType.expense,
  }) {
    return db
        .into(db.transactionCategories)
        .insert(
          TransactionCategoriesCompanion.insert(
            name: name,
            icon: const IconData(0xe25a, fontFamily: 'MaterialIcons'),
            color: const Color(0xFF4CAF50),
            type: type,
          ),
        );
  }

  // ── setup / teardown ─────────────────────────────────────────

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = db.transactionLocalDataSource;
  });

  tearDown(() => db.close());

  // ─────────────────────────────────────────────────────────────
  // insertTransaction
  // ─────────────────────────────────────────────────────────────

  group('insertTransaction', () {
    test('returns a positive auto-increment id', () async {
      final id = await insertTx(
        amount: 100,
        type: TransactionType.expense,
        date: DateTime(2026, 5),
      );
      expect(id, greaterThan(0));
    });

    test('two inserts produce distinct ids', () async {
      final id1 = await insertTx(
        amount: 10,
        type: TransactionType.expense,
        date: DateTime(2026, 5),
      );
      final id2 = await insertTx(
        amount: 20,
        type: TransactionType.income,
        date: DateTime(2026, 5, 2),
      );
      expect(id1, isNot(equals(id2)));
    });
  });

  // ─────────────────────────────────────────────────────────────
  // getTransactionsPaged – no filters
  // ─────────────────────────────────────────────────────────────

  group('getTransactionsPaged – no filters', () {
    test('returns all inserted transactions', () async {
      await insertTx(
        amount: 10,
        type: TransactionType.expense,
        date: DateTime(2026, 5),
      );
      await insertTx(
        amount: 20,
        type: TransactionType.income,
        date: DateTime(2026, 5, 2),
      );

      final results = await dataSource.getTransactionsPaged(
        limit: 10,
        offset: 0,
      );

      expect(results, hasLength(2));
    });

    test('returns an empty list when no transactions exist', () async {
      final results = await dataSource.getTransactionsPaged(
        limit: 10,
        offset: 0,
      );
      expect(results, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Ordering
  // ─────────────────────────────────────────────────────────────

  group('ordering', () {
    test('results are ordered newest date first', () async {
      await insertTx(
        amount: 1,
        type: TransactionType.expense,
        date: DateTime(2026),
      );
      await insertTx(
        amount: 2,
        type: TransactionType.expense,
        date: DateTime(2026, 3),
      );
      await insertTx(
        amount: 3,
        type: TransactionType.expense,
        date: DateTime(2026, 2),
      );

      final results = await dataSource.getTransactionsPaged(
        limit: 10,
        offset: 0,
      );

      expect(results[0].date, DateTime(2026, 3));
      expect(results[1].date, DateTime(2026, 2));
      expect(results[2].date, DateTime(2026));
    });

    test('same-date rows are ordered by id descending', () async {
      final sameDate = DateTime(2026, 5);
      final id1 = await insertTx(
        amount: 10,
        type: TransactionType.expense,
        date: sameDate,
      );
      final id2 = await insertTx(
        amount: 20,
        type: TransactionType.expense,
        date: sameDate,
      );

      final results = await dataSource.getTransactionsPaged(
        limit: 10,
        offset: 0,
      );

      // Higher id (inserted later) should appear first.
      expect(results[0].id, id2);
      expect(results[1].id, id1);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Pagination
  // ─────────────────────────────────────────────────────────────

  group('pagination', () {
    setUp(() async {
      for (var i = 1; i <= 5; i++) {
        await insertTx(
          amount: i * 10.0,
          type: TransactionType.expense,
          date: DateTime(2026, 5, i),
        );
      }
    });

    test('limit restricts the number of results', () async {
      final results = await dataSource.getTransactionsPaged(
        limit: 3,
        offset: 0,
      );
      expect(results, hasLength(3));
    });

    test('offset skips the correct number of results', () async {
      final first = await dataSource.getTransactionsPaged(
        limit: 5,
        offset: 0,
      );
      final paged = await dataSource.getTransactionsPaged(
        limit: 5,
        offset: 2,
      );

      expect(paged.length, 3);
      expect(paged[0].id, first[2].id);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Date filtering
  // ─────────────────────────────────────────────────────────────

  group('date filtering', () {
    setUp(() async {
      await insertTx(
        amount: 1,
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15),
      );
      await insertTx(
        amount: 2,
        type: TransactionType.expense,
        date: DateTime(2026, 3, 15),
      );
      await insertTx(
        amount: 3,
        type: TransactionType.expense,
        date: DateTime(2026, 5, 15),
      );
    });

    test('startDate filters out older transactions', () async {
      final results = await dataSource.getTransactionsPaged(
        limit: 10,
        offset: 0,
        startDate: DateTime(2026, 3),
      );

      expect(results, hasLength(2));
      expect(
        results.every((t) => !t.date.isBefore(DateTime(2026, 3))),
        isTrue,
      );
    });

    test('endDate filters out newer transactions', () async {
      final results = await dataSource.getTransactionsPaged(
        limit: 10,
        offset: 0,
        endDate: DateTime(2026, 3, 31),
      );

      expect(results, hasLength(2));
      expect(
        results.every(
          (t) => !t.date.isAfter(DateTime(2026, 3, 31, 23, 59, 59, 999)),
        ),
        isTrue,
      );
    });

    test('startDate and endDate together restrict to the range', () async {
      final results = await dataSource.getTransactionsPaged(
        limit: 10,
        offset: 0,
        startDate: DateTime(2026, 2),
        endDate: DateTime(2026, 4, 30),
      );

      expect(results, hasLength(1));
      expect(results[0].amount, 2.0);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Type filtering
  // ─────────────────────────────────────────────────────────────

  group('type filtering', () {
    setUp(() async {
      await insertTx(
        amount: 500,
        type: TransactionType.income,
        date: DateTime(2026, 5),
      );
      await insertTx(
        amount: 100,
        type: TransactionType.expense,
        date: DateTime(2026, 5, 2),
      );
    });

    test('filters to expense only', () async {
      final results = await dataSource.getTransactionsPaged(
        limit: 10,
        offset: 0,
        types: {TransactionType.expense},
      );

      expect(results, hasLength(1));
      expect(results[0].type, TransactionType.expense);
    });

    test('filters to income only', () async {
      final results = await dataSource.getTransactionsPaged(
        limit: 10,
        offset: 0,
        types: {TransactionType.income},
      );

      expect(results, hasLength(1));
      expect(results[0].type, TransactionType.income);
    });

    test('both types returns all rows', () async {
      final results = await dataSource.getTransactionsPaged(
        limit: 10,
        offset: 0,
        types: {TransactionType.income, TransactionType.expense},
      );

      expect(results, hasLength(2));
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Amount filtering
  // ─────────────────────────────────────────────────────────────

  group('amount filtering', () {
    setUp(() async {
      for (final amount in [50.0, 200.0, 500.0]) {
        await insertTx(
          amount: amount,
          type: TransactionType.expense,
          date: DateTime(2026, 5),
        );
      }
    });

    test('minAmount filters out lower amounts', () async {
      final results = await dataSource.getTransactionsPaged(
        limit: 10,
        offset: 0,
        minAmount: 200,
      );

      expect(results, hasLength(2));
      expect(results.every((t) => t.amount >= 200.0), isTrue);
    });

    test('maxAmount filters out higher amounts', () async {
      final results = await dataSource.getTransactionsPaged(
        limit: 10,
        offset: 0,
        maxAmount: 200,
      );

      expect(results, hasLength(2));
      expect(results.every((t) => t.amount <= 200.0), isTrue);
    });

    test('minAmount and maxAmount together restrict to the range', () async {
      final results = await dataSource.getTransactionsPaged(
        limit: 10,
        offset: 0,
        minAmount: 100,
        maxAmount: 300,
      );

      expect(results, hasLength(1));
      expect(results[0].amount, 200.0);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Category ID filtering
  // ─────────────────────────────────────────────────────────────

  group('category filtering', () {
    late int catA;
    late int catB;

    setUp(() async {
      catA = await insertCategory(name: 'Food');
      catB = await insertCategory(name: 'Transport');

      await insertTx(
        amount: 10,
        type: TransactionType.expense,
        date: DateTime(2026, 5),
        categoryId: catA,
      );
      await insertTx(
        amount: 20,
        type: TransactionType.expense,
        date: DateTime(2026, 5, 2),
        categoryId: catB,
      );
      // Uncategorised
      await insertTx(
        amount: 30,
        type: TransactionType.expense,
        date: DateTime(2026, 5, 3),
      );
    });

    test('filters to a single category', () async {
      final results = await dataSource.getTransactionsPaged(
        limit: 10,
        offset: 0,
        categoryIds: {catA},
      );

      expect(results, hasLength(1));
      expect(results[0].categoryId, catA);
    });

    test('filters to multiple categories', () async {
      final results = await dataSource.getTransactionsPaged(
        limit: 10,
        offset: 0,
        categoryIds: {catA, catB},
      );

      expect(results, hasLength(2));
    });
  });

  // ─────────────────────────────────────────────────────────────
  // updateTransaction
  // ─────────────────────────────────────────────────────────────

  group('updateTransaction', () {
    test('updates the amount of an existing row', () async {
      final id = await insertTx(
        amount: 100,
        type: TransactionType.expense,
        date: DateTime(2026, 5),
        note: 'original',
      );

      final updated = await dataSource.updateTransaction(
        TransactionsCompanion(
          id: Value(id),
          amount: const Value(999),
          type: const Value(TransactionType.income),
          date: Value(DateTime(2026, 5)),
          note: const Value('updated'),
        ),
      );

      expect(updated, isTrue);

      final results = await dataSource.getTransactionsPaged(
        limit: 10,
        offset: 0,
      );
      expect(results.first.amount, 999.0);
      expect(results.first.note, 'updated');
    });
  });

  // ─────────────────────────────────────────────────────────────
  // deleteTransaction
  // ─────────────────────────────────────────────────────────────

  group('deleteTransaction', () {
    test('removes the row and returns 1', () async {
      final id = await insertTx(
        amount: 50,
        type: TransactionType.expense,
        date: DateTime(2026, 5),
      );

      final deleted = await dataSource.deleteTransaction(
        TransactionsCompanion(id: Value(id)),
      );

      expect(deleted, 1);

      final results = await dataSource.getTransactionsPaged(
        limit: 10,
        offset: 0,
      );
      expect(results, isEmpty);
    });

    test('returns 0 when no matching row exists', () async {
      final deleted = await dataSource.deleteTransaction(
        const TransactionsCompanion(id: Value(9999)),
      );
      expect(deleted, 0);
    });
  });
}
