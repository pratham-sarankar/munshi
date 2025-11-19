import 'package:munshi/features/transactions/models/transaction_with_category.dart';

class GroupedTransactions {

  const GroupedTransactions({required this.date, required this.transactions});
  final DateTime date;
  final List<TransactionWithCategory> transactions;

  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
