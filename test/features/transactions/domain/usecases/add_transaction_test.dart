import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/features/transactions/domain/entities/transaction.dart';
import 'package:munshi/features/transactions/domain/usecases/add_transaction.dart';
import 'package:munshi/features/transactions/domain/value_objects/transaction_filter.dart';
import 'helpers/mock_transaction_repository.dart';

void main() {
  late MockTransactionRepository mockRepository;
  late AddTransaction useCase;

  final tTransaction = Transaction(
    id: 1,
    amount: 150,
    date: DateTime(2026, 5),
    type: TransactionType.expense,
    note: 'Test expense',
  );

  setUpAll(() {
    registerFallbackValue(tTransaction);
    registerFallbackValue(TransactionFilter.empty());
  });

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = AddTransaction(mockRepository);
  });

  test(
    'delegates to repository.addTransaction with the correct transaction',
    () async {
      when(() => mockRepository.addTransaction(any())).thenAnswer((_) async {});

      await useCase(tTransaction);

      verify(() => mockRepository.addTransaction(tTransaction)).called(1);
    },
  );

  test('completes successfully when repository succeeds', () async {
    when(() => mockRepository.addTransaction(any())).thenAnswer((_) async {});

    await expectLater(useCase(tTransaction), completes);
  });

  test('does not call any other repository method', () async {
    when(() => mockRepository.addTransaction(any())).thenAnswer((_) async {});

    await useCase(tTransaction);

    verifyNever(() => mockRepository.updateTransaction(any()));
    verifyNever(() => mockRepository.deleteTransaction(any()));
    verifyNever(
      () => mockRepository.getTransactionsPage(
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
        filter: any(named: 'filter'),
      ),
    );
  });

  test('propagates exceptions thrown by the repository', () async {
    when(
      () => mockRepository.addTransaction(any()),
    ).thenAnswer((_) async => throw Exception('DB error'));

    await expectLater(useCase(tTransaction), throwsException);
  });
}
