import 'package:drift/drift.dart';
import 'package:munshi/core/database/converters/transaction_category_converter.dart';
import 'package:munshi/core/models/date_period.dart';
import 'package:munshi/features/dashboard/services/dashboard_data_service.dart';
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

  Future<List<Transaction>> getTransactions({
    DatePeriod? period,
    TransactionType? type,
    TransactionCategory? category,
  }) {
    final query = select(transactions);
    if (period != null) {
      query.where(
        (table) => table.date.isBetweenValues(period.startDate, period.endDate),
      );
    }
    if (type != null) {
      query.where(
        (table) =>
            table.type.equals(const TransactionTypeConverter().toSql(type)),
      );
    }
    if (category != null) {
      query.where(
        (table) => table.category.equals(
          const TransactionCategoryConverter().toSql(category),
        ),
      );
    }
    return query.get();
  }

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

  /// Efficiently calculates period summary data in a single database operation
  Future<PeriodSummaryData> getPeriodSummary(DatePeriod period) async {
    // Get all transactions for the period
    final transactionsInPeriod = await getTransactions(period: period);

    if (transactionsInPeriod.isEmpty) {
      return PeriodSummaryData.empty(period);
    }

    double totalIncome = 0;
    double totalExpense = 0;
    double biggestSpend = 0;

    for (final transaction in transactionsInPeriod) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
        if (transaction.amount > biggestSpend) {
          biggestSpend = transaction.amount;
        }
      }
    }

    final balance = totalIncome - totalExpense;
    final periodDays = period.endDate.difference(period.startDate).inDays + 1;
    final avgDaily = totalExpense / periodDays;

    return PeriodSummaryData(
      totalSpent: totalExpense,
      totalIncome: totalIncome,
      balance: balance,
      avgDaily: avgDaily,
      transactionCount: transactionsInPeriod.length,
      biggestSpend: biggestSpend,
      period: period,
    );
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
    final periodDays = period.endDate.difference(period.startDate).inDays + 1;
    final avgDaily = totalExpense / periodDays;

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

  /// Get spending breakdown by category for a given period
  Future<Map<TransactionCategory, double>> getSpendingByCategory(
    DatePeriod period,
  ) async {
    final result = await customSelect(
      '''
      SELECT category, SUM(amount) as total_amount
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

    final Map<TransactionCategory, double> categorySpending = {};
    for (final row in result) {
      final categoryString = row.read<String>('category');
      final amount = row.read<double>('total_amount');
      final category = const TransactionCategoryConverter().fromSql(
        categoryString,
      );
      categorySpending[category] = amount;
    }

    return categorySpending;
  }
}
