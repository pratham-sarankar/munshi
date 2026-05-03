import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/features/transactions/domain/entities/transaction.dart';
import 'package:munshi/features/transactions/domain/value_objects/transaction_filter.dart';
import '../usecases/helpers/mock_transaction_repository.dart';

void main() {
  late MockTransactionRepository repository;

  final tTransaction = Transaction(
    id: 1,
    amount: 100,
    date: DateTime(2026, 5),
    type: TransactionType.expense,
  );

  setUpAll(() {
    registerFallbackValue(tTransaction);
    registerFallbackValue(TransactionFilter.empty());
  });

  setUp(() {
    repository = MockTransactionRepository();
  });

  group('TransactionRepository contract', () {
    test('addTransaction completes without error', () async {
      when(() => repository.addTransaction(any())).thenAnswer((_) async {});

      await expectLater(repository.addTransaction(tTransaction), completes);
    });

    test('updateTransaction completes without error', () async {
      when(() => repository.updateTransaction(any())).thenAnswer((_) async {});

      await expectLater(repository.updateTransaction(tTransaction), completes);
    });

    test('deleteTransaction completes without error', () async {
      when(() => repository.deleteTransaction(any())).thenAnswer((_) async {});

      await expectLater(repository.deleteTransaction(tTransaction), completes);
    });

    test('getTransactionsPage returns a list of transactions', () async {
      final expected = [tTransaction];
      when(
        () => repository.getTransactionsPage(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          filter: any(named: 'filter'),
        ),
      ).thenAnswer((_) async => expected);

      final result = await repository.getTransactionsPage(
        limit: 20,
        offset: 0,
        filter: TransactionFilter.empty(),
      );

      expect(result, equals(expected));
    });

    test('getTransactionsPage returns empty list when no results', () async {
      when(
        () => repository.getTransactionsPage(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          filter: any(named: 'filter'),
        ),
      ).thenAnswer((_) async => []);

      final result = await repository.getTransactionsPage(
        limit: 20,
        offset: 0,
        filter: TransactionFilter.empty(),
      );

      expect(result, isEmpty);
    });
  });
}
