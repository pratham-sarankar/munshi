import 'package:mocktail/mocktail.dart';
import 'package:munshi/features/transactions/domain/repositories/transaction_repository.dart';

/// A [MockTransactionRepository] that can be used in tests.
///
/// Register fallback values before using matchers that require them:
/// ```dart
/// setUpAll(() {
///   registerFallbackValue(/* Transaction instance */);
///   registerFallbackValue(TransactionFilter.empty());
/// });
/// ```
class MockTransactionRepository extends Mock implements TransactionRepository {}
