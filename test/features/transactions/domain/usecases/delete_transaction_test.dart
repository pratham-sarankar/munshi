import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/features/transactions/domain/entities/transaction.dart';
import 'package:munshi/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:munshi/features/transactions/domain/value_objects/transaction_filter.dart';
import 'helpers/mock_transaction_repository.dart';

void main() {
  late MockTransactionRepository mockRepository;
  late DeleteTransaction useCase;

  final tTransaction = Transaction(
    id: 7,
    amount: 80,
    date: DateTime(2026, 3, 10),
    type: TransactionType.expense,
  );

  setUpAll(() {
    registerFallbackValue(tTransaction);
    registerFallbackValue(TransactionFilter.empty());
  });

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = DeleteTransaction(mockRepository);
  });

  test(
    'delegates to repository.deleteTransaction with the correct transaction',
    () async {
      when(
        () => mockRepository.deleteTransaction(any()),
      ).thenAnswer((_) async {});

      await useCase(tTransaction);

      verify(() => mockRepository.deleteTransaction(tTransaction)).called(1);
    },
  );

  test('completes successfully when repository succeeds', () async {
    when(
      () => mockRepository.deleteTransaction(any()),
    ).thenAnswer((_) async {});

    await expectLater(useCase(tTransaction), completes);
  });

  test('does not call any other repository method', () async {
    when(
      () => mockRepository.deleteTransaction(any()),
    ).thenAnswer((_) async {});

    await useCase(tTransaction);

    verifyNever(() => mockRepository.addTransaction(any()));
    verifyNever(() => mockRepository.updateTransaction(any()));
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
      () => mockRepository.deleteTransaction(any()),
    ).thenAnswer((_) async => throw Exception('Delete failed'));

    await expectLater(useCase(tTransaction), throwsException);
  });
}
