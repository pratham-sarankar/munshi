import 'package:munshi/features/transactions/domain/entities/transaction_with_category.dart';

class GroupedTransactions {
  const GroupedTransactions({required this.date, required this.transactions});
  final DateTime date;
  final List<TransactionWithCategory> transactions;
}
