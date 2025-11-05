import '../../../core/database/app_database.dart';

class GroupedTransactions {
  final DateTime date;
  final List<Transaction> transactions;

  const GroupedTransactions({required this.date, required this.transactions});

  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
