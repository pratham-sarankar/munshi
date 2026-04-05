import 'package:munshi/features/transactions/domain/entities/transaction.dart';

class GroupedTransactions {
  const GroupedTransactions({required this.date, required this.transactions});
  final DateTime date;
  final List<Transaction> transactions;
}
