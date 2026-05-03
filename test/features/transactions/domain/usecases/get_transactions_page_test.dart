import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/features/transactions/domain/entities/transaction.dart';
import 'package:munshi/features/transactions/domain/usecases/get_transactions_page.dart';
import 'package:munshi/features/transactions/domain/value_objects/transaction_filter.dart';
import 'helpers/mock_transaction_repository.dart';

void main() {
  late MockTransactionRepository mockRepository;
  late GetTransactionsPage useCase;

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
    mockRepository = MockTransactionRepository();
    useCase = GetTransactionsPage(mockRepository);
  });

  // Convenience stub helper.
  void stubPage(List<Transaction> results) {
    when(
      () => mockRepository.getTransactionsPage(
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
        filter: any(named: 'filter'),
      ),
    ).thenAnswer((_) async => results);
  }

  test('delegates to repository with the correct parameters', () async {
    final filter = TransactionFilter.empty();
    stubPage([tTransaction]);

    await useCase(limit: 20, offset: 0, filter: filter);

    verify(
      () => mockRepository.getTransactionsPage(
        limit: 20,
        offset: 0,
        filter: filter,
      ),
    ).called(1);
  });

  test('returns the list provided by the repository', () async {
    stubPage([tTransaction]);

    final result = await useCase(
      limit: 20,
      offset: 0,
      filter: TransactionFilter.empty(),
    );

    expect(result, equals([tTransaction]));
  });

  test('returns empty list when repository has no results', () async {
    stubPage([]);

    final result = await useCase(
      limit: 20,
      offset: 0,
      filter: TransactionFilter.empty(),
    );

    expect(result, isEmpty);
  });

  test('forwards offset for second page', () async {
    stubPage([]);

    await useCase(limit: 20, offset: 20, filter: TransactionFilter.empty());

    verify(
      () => mockRepository.getTransactionsPage(
        limit: 20,
        offset: 20,
        filter: any(named: 'filter'),
      ),
    ).called(1);
  });

  test('passes the filter through unchanged', () async {
    const filter = TransactionFilter(
      minAmount: 50,
      types: {TransactionType.expense},
    );
    stubPage([]);

    await useCase(limit: 10, offset: 0, filter: filter);

    verify(
      () => mockRepository.getTransactionsPage(
        limit: 10,
        offset: 0,
        filter: filter,
      ),
    ).called(1);
  });

  test('does not call any other repository method', () async {
    stubPage([]);

    await useCase(limit: 20, offset: 0, filter: TransactionFilter.empty());

    verifyNever(() => mockRepository.addTransaction(any()));
    verifyNever(() => mockRepository.updateTransaction(any()));
    verifyNever(() => mockRepository.deleteTransaction(any()));
  });

  test('propagates exceptions thrown by the repository', () async {
    when(
      () => mockRepository.getTransactionsPage(
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
        filter: any(named: 'filter'),
      ),
    ).thenAnswer((_) async => throw Exception('Query failed'));

    await expectLater(
      useCase(limit: 20, offset: 0, filter: TransactionFilter.empty()),
      throwsException,
    );
  });
}
