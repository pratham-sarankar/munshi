import 'package:drift/drift.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/database/converters/transaction_type_converter.dart';
import 'package:munshi/core/database/tables/transaction_categories.dart';
import 'package:munshi/core/database/tables/transactions.dart';
import 'package:munshi/core/models/date_period.dart';
import 'package:munshi/features/dashboard/models/category_spending_data.dart';
import 'package:munshi/features/dashboard/services/dashboard_data_service.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_type.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_with_category.dart';

part 'transaction_dao.g.dart';

/// Data access object for managing transaction queries and operations.
///
/// Provides methods for querying, inserting, updating, and deleting transactions
/// from the database with support for filtering, pagination, and aggregations.
@DriftAccessor(tables: [Transactions, TransactionCategories])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  /// Creates a new instance of [TransactionsDao].
  TransactionsDao(super.attachedDatabase);

  /// Get a page of transactions with all filtering done in SQL.
  ///
  /// All filters are applied in SQL — nothing is processed on the Dart side.
  /// Use [limit] and [offset] to paginate through results.
  Future<List<TransactionWithCategory>> getTransactionsPaged({
    required int limit,
    required int offset,
    DateTime? startDate,
    DateTime? endDate,
    Set<TransactionType>? types,
    double? minAmount,
    double? maxAmount,
    Set<int>? categoryIds,
  }) async {
    final query = select(transactions).join([
      leftOuterJoin(
        transactionCategories,
        transactions.categoryId.equalsExp(transactionCategories.id),
      ),
    ]);

    final conditions = <Expression<bool>>[];

    if (startDate != null) {
      conditions.add(transactions.date.isBiggerOrEqualValue(startDate));
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
      conditions.add(transactions.date.isSmallerOrEqualValue(endOfDay));
    }
    if (types != null && types.isNotEmpty) {
      final typeValues = types
          .map(const TransactionTypeConverter().toSql)
          .toList();
      conditions.add(transactions.type.isIn(typeValues));
    }
    if (minAmount != null) {
      conditions.add(transactions.amount.isBiggerOrEqualValue(minAmount));
    }
    if (maxAmount != null) {
      conditions.add(transactions.amount.isSmallerOrEqualValue(maxAmount));
    }
    if (categoryIds != null && categoryIds.isNotEmpty) {
      conditions.add(transactions.categoryId.isIn(categoryIds.toList()));
    }

    if (conditions.isNotEmpty) {
      query.where(conditions.reduce((a, b) => a & b));
    }

    query
      ..orderBy([
        OrderingTerm.desc(transactions.date),
        OrderingTerm.desc(transactions.id),
      ])
      ..limit(limit, offset: offset);

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

  /// Insert a new transaction into the database.
  Future<int> insertTransaction(Insertable<Transaction> transaction) =>
      into(transactions).insert(transaction);

  /// Update an existing transaction in the database.
  Future<bool> updateTransaction(Insertable<Transaction> transaction) =>
      update(transactions).replace(transaction);

  /// Delete a transaction from the database.
  Future<int> deleteTransaction(Insertable<Transaction> transaction) =>
      delete(transactions).delete(transaction);

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
    final avgDaily = periodDays > 0 ? totalExpense / periodDays : 0.0;

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
    final categorySpending = <TransactionCategory?, CategorySpendingData>{};

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
