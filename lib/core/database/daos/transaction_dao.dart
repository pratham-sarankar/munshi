import 'package:drift/drift.dart';
import 'package:munshi/core/models/date_period.dart';
import 'package:munshi/features/dashboard/models/category_spending_data.dart';
import 'package:munshi/features/dashboard/services/dashboard_data_service.dart';
import 'package:munshi/features/transactions/models/grouped_transactions.dart';
import 'package:munshi/features/transactions/models/transaction_type.dart';
import 'package:munshi/features/transactions/models/transaction_with_category.dart';
import '../app_database.dart';
import '../converters/transaction_type_converter.dart';
import '../tables/transactions.dart';
import '../tables/transaction_categories.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions, TransactionCategories])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Future<List<Transaction>> getAllTransactions() => select(transactions).get();

  Stream<List<TransactionWithCategory>> watchAllTransactions() {
    final query = select(transactions).join([
      leftOuterJoin(
        transactionCategories,
        transactions.categoryId.equalsExp(transactionCategories.id),
      ),
    ])..orderBy([OrderingTerm.desc(transactions.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final transaction = row.readTable(transactions);
        final category = row.readTableOrNull(transactionCategories);
        return TransactionWithCategory(
          transaction: transaction,
          category: category,
        );
      }).toList();
    });
  }

  Future<int> insertTransaction(Insertable<Transaction> transaction) =>
      into(transactions).insert(transaction);

  Future<bool> updateTransaction(Insertable<Transaction> transaction) =>
      update(transactions).replace(transaction);

  Future<int> deleteTransaction(Insertable<Transaction> transaction) =>
      delete(transactions).delete(transaction);

  /// Get all transactions with their category information
  Future<List<TransactionWithCategory>>
  getAllTransactionsWithCategories() async {
    final query = select(transactions).join([
      leftOuterJoin(
        transactionCategories,
        transactions.categoryId.equalsExp(transactionCategories.id),
      ),
    ])..orderBy([OrderingTerm.desc(transactions.date)]);

    final result = await query.get();
    return result.map((row) {
      final transaction = row.readTable(transactions);
      final category = row.readTableOrNull(transactionCategories);
      return TransactionWithCategory(
        transaction: transaction,
        category: category,
      );
    }).toList();
  }

  Future<List<Transaction>> getTransactionsByType(TransactionType type) {
    return (select(transactions)..where(
          (tbl) =>
              tbl.type.equals(const TransactionTypeConverter().toSql(type)),
        ))
        .get();
  }

  /// Get transactions with categories by type
  Future<List<TransactionWithCategory>> getTransactionsWithCategoriesByType(
    TransactionType type,
  ) async {
    final query =
        select(transactions).join([
            leftOuterJoin(
              transactionCategories,
              transactions.categoryId.equalsExp(transactionCategories.id),
            ),
          ])
          ..where(
            transactions.type.equals(
              const TransactionTypeConverter().toSql(type),
            ),
          )
          ..orderBy([OrderingTerm.desc(transactions.date)]);

    final result = await query.get();
    return result.map((row) {
      final transaction = row.readTable(transactions);
      final category = row.readTableOrNull(transactionCategories);
      return TransactionWithCategory(
        transaction: transaction,
        category: category,
      );
    }).toList();
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
      final Map<String, List<TransactionWithCategory>> groupedMap = {};
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
    final effectiveEndDate = period.endDate.isAfter(today)
        ? today
        : period.endDate;

    // Handle edge case where period starts in the future
    // In this case, use period start date as effective end date
    final effectiveEnd = effectiveEndDate.isBefore(period.startDate)
        ? period.startDate
        : effectiveEndDate;

    // Calculate period days with inclusive counting
    // (inDays returns full 24-hour periods, so we add 1 for inclusive count)
    final periodDays = effectiveEnd.difference(period.startDate).inDays + 1;
    final double avgDaily = periodDays > 0 ? totalExpense / periodDays : 0;

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
  Future<Map<TransactionCategory?, CategorySpendingData>>
  getSpendingByCategoryWithCount(DatePeriod period) async {
    // Use efficient SQL GROUP BY to calculate aggregations in the database
    final aggregationResult = await customSelect(
      '''
      SELECT 
        category_id,
        SUM(amount) as total_amount,
        COUNT(*) as transaction_count
      FROM transactions 
      WHERE date BETWEEN ? AND ? AND type = ?
      GROUP BY category_id
      ''',
      variables: [
        Variable.withDateTime(period.startDate),
        Variable.withDateTime(period.endDate),
        Variable.withString(
          const TransactionTypeConverter().toSql(TransactionType.expense),
        ),
      ],
    ).get();

    // If no transactions found, return empty map
    if (aggregationResult.isEmpty) {
      return <TransactionCategory?, CategorySpendingData>{};
    }

    // Get all category IDs from the aggregation result (excluding nulls)
    final categoryIds = aggregationResult
        .map((row) => row.readNullable<int>('category_id'))
        .where((id) => id != null)
        .cast<int>()
        .toList();

    // Fetch category details for the relevant categories only
    final categories = categoryIds.isNotEmpty
        ? await (select(
            transactionCategories,
          )..where((tbl) => tbl.id.isIn(categoryIds))).get()
        : <TransactionCategory>[];

    // Create a map of category ID to category for efficient lookup
    final categoryMap = {for (final cat in categories) cat.id: cat};

    // Build the final result map
    final Map<TransactionCategory?, CategorySpendingData> categorySpending = {};

    for (final row in aggregationResult) {
      final categoryId = row.readNullable<int>('category_id');
      final totalAmount = row.read<double>('total_amount');
      final transactionCount = row.read<int>('transaction_count');

      final category = categoryId != null ? categoryMap[categoryId] : null;

      categorySpending[category] = CategorySpendingData(
        category: category,
        totalAmount: totalAmount,
        transactionCount: transactionCount,
      );
    }

    return categorySpending;
  }
}
