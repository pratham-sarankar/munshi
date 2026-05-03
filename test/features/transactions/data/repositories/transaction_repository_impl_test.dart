import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:munshi/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:munshi/features/transactions/domain/entities/transaction.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';
import 'package:munshi/features/transactions/domain/value_objects/transaction_filter.dart';

class MockTransactionLocalDataSource extends Mock
    implements TransactionLocalDataSource {}

void main() {
  late MockTransactionLocalDataSource mockDataSource;
  late TransactionRepositoryImpl repository;

  final tDate = DateTime(2026, 5, 1, 12);

  final tTransaction = Transaction(
    id: 1,
    amount: 250,
    categoryId: 3,
    date: tDate,
    note: 'Lunch',
    type: TransactionType.expense,
  );

  final tCategory = TransactionCategory(
    id: 3,
    name: 'Food',
    icon: const IconData(0xe25a, fontFamily: 'MaterialIcons'),
    color: const Color(0xFF4CAF50),
    type: TransactionType.expense,
    isDefault: true,
    createdAt: DateTime(2026),
  );

  setUpAll(() {
    // Register fallback values for argument matchers.
    registerFallbackValue(TransactionFilter.empty());
    registerFallbackValue(const TransactionsCompanion());
  });

  setUp(() {
    mockDataSource = MockTransactionLocalDataSource();
    repository = TransactionRepositoryImpl(mockDataSource);
  });

  // ─────────────────────────────────────────────────────────────
  // getTransactionsPage
  // ─────────────────────────────────────────────────────────────

  group('getTransactionsPage', () {
    setUp(() {
      when(
        () => mockDataSource.getTransactionsPaged(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          types: any(named: 'types'),
          minAmount: any(named: 'minAmount'),
          maxAmount: any(named: 'maxAmount'),
          categoryIds: any(named: 'categoryIds'),
        ),
      ).thenAnswer((_) async => [tTransaction]);
    });

    test(
      'delegates to getTransactionsPaged with correct limit and offset',
      () async {
        await repository.getTransactionsPage(
          limit: 20,
          offset: 40,
          filter: TransactionFilter.empty(),
        );

        verify(
          () => mockDataSource.getTransactionsPaged(
            limit: 20,
            offset: 40,
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            types: any(named: 'types'),
            minAmount: any(named: 'minAmount'),
            maxAmount: any(named: 'maxAmount'),
            categoryIds: any(named: 'categoryIds'),
          ),
        ).called(1);
      },
    );

    test('passes null categoryIds when filter has no categories', () async {
      await repository.getTransactionsPage(
        limit: 10,
        offset: 0,
        filter: TransactionFilter.empty(),
      );

      verify(
        () => mockDataSource.getTransactionsPaged(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          types: any(named: 'types'),
          minAmount: any(named: 'minAmount'),
          maxAmount: any(named: 'maxAmount'),
        ),
      ).called(1);
    });

    test('maps filter categories to a Set of IDs', () async {
      final filter = TransactionFilter(categories: {tCategory});

      await repository.getTransactionsPage(
        limit: 10,
        offset: 0,
        filter: filter,
      );

      verify(
        () => mockDataSource.getTransactionsPaged(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          categoryIds: {tCategory.id},
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          types: any(named: 'types'),
          minAmount: any(named: 'minAmount'),
          maxAmount: any(named: 'maxAmount'),
        ),
      ).called(1);
    });

    test(
      'passes effectiveStartDate and effectiveEndDate from datePeriod',
      () async {
        final filter = TransactionFilter.fromTimeframe('This Month');
        final expectedStart = filter.effectiveStartDate;
        final expectedEnd = filter.effectiveEndDate;

        await repository.getTransactionsPage(
          limit: 10,
          offset: 0,
          filter: filter,
        );

        verify(
          () => mockDataSource.getTransactionsPaged(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            startDate: expectedStart,
            endDate: expectedEnd,
            types: any(named: 'types'),
            minAmount: any(named: 'minAmount'),
            maxAmount: any(named: 'maxAmount'),
            categoryIds: any(named: 'categoryIds'),
          ),
        ).called(1);
      },
    );

    test('passes amount bounds from filter', () async {
      const filter = TransactionFilter(minAmount: 100, maxAmount: 500);

      await repository.getTransactionsPage(
        limit: 10,
        offset: 0,
        filter: filter,
      );

      verify(
        () => mockDataSource.getTransactionsPaged(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          minAmount: 100,
          maxAmount: 500,
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          types: any(named: 'types'),
          categoryIds: any(named: 'categoryIds'),
        ),
      ).called(1);
    });

    test('returns the list produced by the datasource', () async {
      final result = await repository.getTransactionsPage(
        limit: 10,
        offset: 0,
        filter: TransactionFilter.empty(),
      );

      expect(result, [tTransaction]);
    });

    test('propagates exceptions from the datasource', () async {
      when(
        () => mockDataSource.getTransactionsPaged(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          types: any(named: 'types'),
          minAmount: any(named: 'minAmount'),
          maxAmount: any(named: 'maxAmount'),
          categoryIds: any(named: 'categoryIds'),
        ),
      ).thenAnswer((_) async => throw Exception('DB error'));

      expect(
        () => repository.getTransactionsPage(
          limit: 10,
          offset: 0,
          filter: TransactionFilter.empty(),
        ),
        throwsException,
      );
    });
  });

  // ─────────────────────────────────────────────────────────────
  // addTransaction
  // ─────────────────────────────────────────────────────────────

  group('addTransaction', () {
    setUp(() {
      when(
        () => mockDataSource.insertTransaction(any()),
      ).thenAnswer((_) async => 1);
    });

    test('delegates to insertTransaction', () async {
      await repository.addTransaction(tTransaction);

      verify(() => mockDataSource.insertTransaction(any())).called(1);
    });

    test('propagates exceptions from the datasource', () async {
      when(
        () => mockDataSource.insertTransaction(any()),
      ).thenAnswer((_) async => throw Exception('insert failed'));

      await expectLater(
        () => repository.addTransaction(tTransaction),
        throwsException,
      );
    });
  });

  // ─────────────────────────────────────────────────────────────
  // updateTransaction
  // ─────────────────────────────────────────────────────────────

  group('updateTransaction', () {
    setUp(() {
      when(
        () => mockDataSource.updateTransaction(any()),
      ).thenAnswer((_) async => true);
    });

    test('delegates to updateTransaction', () async {
      await repository.updateTransaction(tTransaction);

      verify(() => mockDataSource.updateTransaction(any())).called(1);
    });

    test('propagates exceptions from the datasource', () async {
      when(
        () => mockDataSource.updateTransaction(any()),
      ).thenAnswer((_) async => throw Exception('update failed'));

      await expectLater(
        () => repository.updateTransaction(tTransaction),
        throwsException,
      );
    });
  });

  // ─────────────────────────────────────────────────────────────
  // deleteTransaction
  // ─────────────────────────────────────────────────────────────

  group('deleteTransaction', () {
    setUp(() {
      when(
        () => mockDataSource.deleteTransaction(any()),
      ).thenAnswer((_) async => 1);
    });

    test('delegates to deleteTransaction', () async {
      await repository.deleteTransaction(tTransaction);

      verify(() => mockDataSource.deleteTransaction(any())).called(1);
    });

    test('propagates exceptions from the datasource', () async {
      when(
        () => mockDataSource.deleteTransaction(any()),
      ).thenAnswer((_) async => throw Exception('delete failed'));

      await expectLater(
        () => repository.deleteTransaction(tTransaction),
        throwsException,
      );
    });
  });
}
