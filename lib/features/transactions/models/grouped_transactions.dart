import 'package:munshi/features/transactions/models/transaction_with_category.dart';

class GroupedTransactions {
  final DateTime date;
  final List<TransactionWithCategory> transactions;

  const GroupedTransactions({required this.date, required this.transactions});

  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
