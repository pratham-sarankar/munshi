import 'package:drift/drift.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/database/converters/transaction_type_converter.dart';
import 'package:munshi/core/database/tables/transaction_categories.dart';
import 'package:munshi/core/database/tables/transactions.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/core/models/date_period.dart';
import 'package:munshi/features/dashboard/models/category_spending_data.dart';
import 'package:munshi/features/dashboard/services/dashboard_data_service.dart';
import 'package:munshi/features/transactions/data/extensions/transaction_category_extensions.dart';
import 'package:munshi/features/transactions/data/extensions/transaction_extensions.dart';
import 'package:munshi/features/transactions/domain/entities/transaction.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';

part 'transaction_local_datasource.g.dart';

/// Local data source for transaction operations using Drift database.
///
/// Provides methods for querying, inserting, updating, and deleting
/// transactions from the local SQLite database. Includes filtering,
/// pagination, and aggregation operations for financial analytics.
@DriftAccessor(tables: [Transactions, TransactionCategories])
class TransactionLocalDataSource extends DatabaseAccessor<AppDatabase>
    with _$TransactionLocalDataSourceMixin {
  /// Creates a new instance of [TransactionLocalDataSource].
  TransactionLocalDataSource(super.attachedDatabase);

  /// Retrieves paginated transactions with optional filtering and date
  /// range constraints.
  ///
  /// Parameters:
  ///   - [limit]: Maximum number of transactions to return
  ///   - [offset]: Number of transactions to skip for pagination
  ///   - [startDate]: Optional start date filter (inclusive)
  ///   - [endDate]: Optional end date filter (inclusive)
  ///   - [types]: Optional set of transaction types to filter by
  ///   - [minAmount]: Optional minimum transaction amount filter
  ///   - [maxAmount]: Optional maximum transaction amount filter
  ///   - [categoryIds]: Optional set of category IDs to filter by
  ///
  /// Returns a list of transactions matching the specified criteria,
  /// ordered by date (newest first) and then by ID (newest first).
  Future<List<Transaction>> getTransactionsPaged({
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
      final t = row.readTable(transactions);
      final c = row.readTableOrNull(transactionCategories);
      return t.toEntity(category: c?.toEntity());
    }).toList();
  }

  /// Inserts a new transaction into the database.
  ///
  /// Parameters:
  ///   - [transaction]: The transaction row to insert
  ///
  /// Returns the ID of the inserted transaction.
  Future<int> insertTransaction(Insertable<TransactionRow> transaction) =>
      into(transactions).insert(transaction);

  /// Updates an existing transaction in the database.
  ///
  /// Parameters:
  ///   - [transaction]: The transaction row with updated values
  ///
  /// Returns true if the update was successful.
  Future<bool> updateTransaction(Insertable<TransactionRow> transaction) =>
      update(transactions).replace(transaction);

  /// Deletes a transaction from the database.
  ///
  /// Parameters:
  ///   - [transaction]: The transaction row to delete
  ///
  /// Returns the number of rows deleted.
  Future<int> deleteTransaction(Insertable<TransactionRow> transaction) =>
      delete(transactions).delete(transaction);

  /// Retrieves summary data for a specific time period.
  ///
  /// Calculates aggregate metrics including transaction count, total income,
  /// total expenses, biggest single spending, and average daily spending
  /// for the given period.
  ///
  /// Parameters:
  ///   - [period]: The date period for which to calculate summary data
  ///
  /// Returns a [PeriodSummaryData] object with aggregated financial metrics
  /// for the specified period.
  Future<PeriodSummaryData> getPeriodSummarySql(DatePeriod period) async {
    final startDate = period.startDate;
    final endDate = period.endDate;

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

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final effectiveEndDate = period.endDate.isAfter(today)
        ? today
        : period.endDate;

    final effectiveEnd = effectiveEndDate.isBefore(period.startDate)
        ? period.startDate
        : effectiveEndDate;

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

  /// Retrieves spending data grouped by transaction category for a given period.
  ///
  /// Calculates total amount spent and transaction count for each expense category
  /// within the specified date range using efficient SQL GROUP BY aggregation.
  ///
  /// Parameters:
  ///   - [period]: The date period for which to calculate spending by category
  ///
  /// Returns a map of transaction categories to their spending data, including
  /// total amount and transaction count. Null key represents uncategorized
  /// transactions.
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
        : <TransactionCategoryRow>[];

    // Create a map of category ID to category for efficient lookup
    final categoryMap = {for (final cat in categories) cat.id: cat};

    // Build the final result map
    final categorySpending = <TransactionCategory?, CategorySpendingData>{};

    for (final row in aggregationResult) {
      final categoryId = row.readNullable<int>('category_id');
      final totalAmount = row.read<double>('total_amount');
      final transactionCount = row.read<int>('transaction_count');

      final category = categoryId != null ? categoryMap[categoryId] : null;

      categorySpending[category?.toEntity()] = CategorySpendingData(
        category: category?.toEntity(),
        totalAmount: totalAmount,
        transactionCount: transactionCount,
      );
    }

    return categorySpending;
  }
}
