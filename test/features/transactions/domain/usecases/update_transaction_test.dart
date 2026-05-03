import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/features/transactions/domain/entities/transaction.dart';
import 'package:munshi/features/transactions/domain/usecases/update_transaction.dart';
import 'package:munshi/features/transactions/domain/value_objects/transaction_filter.dart';
import 'helpers/mock_transaction_repository.dart';

void main() {
  late MockTransactionRepository mockRepository;
  late UpdateTransaction useCase;

  final tTransaction = Transaction(
    id: 5,
    amount: 300,
    date: DateTime(2026, 4, 20),
    type: TransactionType.income,
    note: 'Salary',
  );

  setUpAll(() {
    registerFallbackValue(tTransaction);
    registerFallbackValue(TransactionFilter.empty());
  });

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = UpdateTransaction(mockRepository);
  });

  test(
    'delegates to repository.updateTransaction with the correct transaction',
    () async {
      when(
        () => mockRepository.updateTransaction(any()),
      ).thenAnswer((_) async {});

      await useCase(tTransaction);

      verify(() => mockRepository.updateTransaction(tTransaction)).called(1);
    },
  );

  test('completes successfully when repository succeeds', () async {
    when(
      () => mockRepository.updateTransaction(any()),
    ).thenAnswer((_) async {});

    await expectLater(useCase(tTransaction), completes);
  });

  test('does not call any other repository method', () async {
    when(
      () => mockRepository.updateTransaction(any()),
    ).thenAnswer((_) async {});

    await useCase(tTransaction);

    verifyNever(() => mockRepository.addTransaction(any()));
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
      () => mockRepository.updateTransaction(any()),
    ).thenAnswer((_) async => throw Exception('Update failed'));

    await expectLater(useCase(tTransaction), throwsException);
  });
}
