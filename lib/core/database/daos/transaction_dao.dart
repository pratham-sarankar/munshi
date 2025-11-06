import 'package:drift/drift.dart';
import 'package:munshi/core/database/converters/transaction_category_converter.dart';
import 'package:munshi/core/models/date_period.dart';
import 'package:munshi/features/dashboard/models/category_spending_data.dart';
import 'package:munshi/features/dashboard/services/dashboard_data_service.dart';
import 'package:munshi/features/transactions/models/grouped_transactions.dart';
import 'package:munshi/features/transactions/models/transaction_category.dart';
import 'package:munshi/features/transactions/models/transaction_type.dart';
import '../app_database.dart';
import '../converters/transaction_type_converter.dart';
import '../tables/transactions.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Future<List<Transaction>> getAllTransactions() => select(transactions).get();

  Stream<List<Transaction>> watchAllTransactions() {
    final query = select(transactions)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.watch();
  }

  Future<int> insertTransaction(Insertable<Transaction> transaction) =>
      into(transactions).insert(transaction);

  Future<bool> updateTransaction(Insertable<Transaction> transaction) =>
      update(transactions).replace(transaction);

  Future<int> deleteTransaction(Insertable<Transaction> transaction) =>
      delete(transactions).delete(transaction);

  Future<List<Transaction>> getTransactionsByType(TransactionType type) {
    return (select(transactions)..where(
          (tbl) =>
              tbl.type.equals(const TransactionTypeConverter().toSql(type)),
        ))
        .get();
  }

  /// Get transactions grouped by date using a single query and grouping in Dart
  Future<List<GroupedTransactions>> getTransactionsGroupedByDate({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = select(transactions)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);

    if (startDate != null && endDate != null) {
      query.where((t) => t.date.isBetweenValues(startDate, endDate));
    } else if (startDate != null) {
      query.where((t) => t.date.isBiggerOrEqualValue(startDate));
    } else if (endDate != null) {
      query.where((t) => t.date.isSmallerOrEqualValue(endDate));
    }

    final allTransactions = await query.get();

    // Group transactions by date (truncated to day)
    final Map<DateTime, List<Transaction>> groupedMap = {};
    for (final tx in allTransactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      groupedMap.putIfAbsent(date, () => []).add(tx);
    }

    // Convert to list of GroupedTransactions, ordered by date descending
    final groupedTransactions =
        groupedMap.entries
            .map(
              (entry) => GroupedTransactions(
                date: entry.key,
                transactions: entry.value
                  ..sort((a, b) => b.date.compareTo(a.date)),
              ),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return groupedTransactions;
  }

  /// Watch transactions grouped by date with real-time updates
  Stream<List<GroupedTransactions>> watchTransactionsGroupedByDate({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    // For simplicity, we'll use the existing watchAllTransactions and group in Dart
    // A more advanced implementation could use custom SQL with triggers
    return watchAllTransactions().asyncMap((transactions) async {
      if (transactions.isEmpty) return <GroupedTransactions>[];

      // Filter transactions by date range if provided
      var filteredTransactions = transactions;
      if (startDate != null) {
        filteredTransactions = filteredTransactions
            .where(
              (t) =>
                  t.date.isAtSameMomentAs(startDate) ||
                  t.date.isAfter(startDate),
            )
            .toList();
      }
      if (endDate != null) {
        final endOfDay = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
          999,
        );
        filteredTransactions = filteredTransactions
            .where((t) => !t.date.isAfter(endOfDay))
            .toList();
      }

      // Group by date
      final Map<String, List<Transaction>> groupedMap = {};
      for (final transaction in filteredTransactions) {
        final dateKey = DateTime(
          transaction.date.year,
          transaction.date.month,
          transaction.date.day,
        );
        final dateString =
            '${dateKey.year}-${dateKey.month.toString().padLeft(2, '0')}-${dateKey.day.toString().padLeft(2, '0')}';
        groupedMap.putIfAbsent(dateString, () => []).add(transaction);
      }

      // Convert to GroupedTransactions and sort by date descending
      final List<GroupedTransactions> result = [];
      final sortedDates = groupedMap.keys.toList()
        ..sort((a, b) => b.compareTo(a));

      for (final dateString in sortedDates) {
        final date = DateTime.parse(dateString);
        final transactionsForDate = groupedMap[dateString]!;
        // Sort transactions within the day by time descending
        transactionsForDate.sort((a, b) => b.date.compareTo(a.date));
        result.add(
          GroupedTransactions(date: date, transactions: transactionsForDate),
        );
      }

      return result;
    });
  }

  /// Alternative: More efficient SQL-based calculation (requires custom SQL)
  Future<PeriodSummaryData> getPeriodSummarySql(DatePeriod period) async {
    final startDate = period.startDate;
    final endDate = period.endDate;

    // Custom SQL query to calculate all summary data in one go
    final result = await customSelect(
      '''
      SELECT 
        COUNT(*) as transaction_count,
        COALESCE(SUM(CASE WHEN type = ? THEN amount ELSE 0 END), 0) as total_income,
        COALESCE(SUM(CASE WHEN type = ? THEN amount ELSE 0 END), 0) as total_expense,
        COALESCE(MAX(CASE WHEN type = ? THEN amount ELSE 0 END), 0) as biggest_spend
      FROM transactions 
      WHERE date BETWEEN ? AND ?
      ''',
      variables: [
        Variable.withString(
          const TransactionTypeConverter().toSql(TransactionType.income),
        ),
        Variable.withString(
          const TransactionTypeConverter().toSql(TransactionType.expense),
        ),
        Variable.withString(
          const TransactionTypeConverter().toSql(TransactionType.expense),
        ),
        Variable.withDateTime(startDate),
        Variable.withDateTime(endDate),
      ],
    ).getSingle();

    final transactionCount = result.read<int>('transaction_count');
    final totalIncome = result.read<double>('total_income');
    final totalExpense = result.read<double>('total_expense');
    final biggestSpend = result.read<double>('biggest_spend');

    if (transactionCount == 0) {
      return PeriodSummaryData.empty(period);
    }

    final balance = totalIncome - totalExpense;
    
    // Calculate days only up to today for average calculation
    // to avoid including future dates in the denominator
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final effectiveEndDate = period.endDate.isAfter(today) ? today : period.endDate;
    final periodDays = effectiveEndDate.difference(period.startDate).inDays + 1;
    final avgDaily = periodDays > 0 ? totalExpense / periodDays : 0;

    return PeriodSummaryData(
      totalSpent: totalExpense,
      totalIncome: totalIncome,
      balance: balance,
      avgDaily: avgDaily,
      transactionCount: transactionCount,
      biggestSpend: biggestSpend,
      period: period,
    );
  }

  /// Get spending breakdown by category with both amount and transaction count
  Future<Map<TransactionCategory, CategorySpendingData>>
  getSpendingByCategoryWithCount(DatePeriod period) async {
    final result = await customSelect(
      '''
      SELECT category, SUM(amount) as total_amount, COUNT(*) as transaction_count
      FROM transactions 
      WHERE date BETWEEN ? AND ? AND type = ?
      GROUP BY category
      ''',
      variables: [
        Variable.withDateTime(period.startDate),
        Variable.withDateTime(period.endDate),
        Variable.withString(
          const TransactionTypeConverter().toSql(TransactionType.expense),
        ),
      ],
    ).get();

    final Map<TransactionCategory, CategorySpendingData> categorySpending = {};
    for (final row in result) {
      final categoryString = row.read<String>('category');
      final amount = row.read<double>('total_amount');
      final count = row.read<int>('transaction_count');
      final category = const TransactionCategoryConverter().fromSql(
        categoryString,
      );
      categorySpending[category] = CategorySpendingData(
        category: category,
        totalAmount: amount,
        transactionCount: count,
      );
    }

    return categorySpending;
  }
}
