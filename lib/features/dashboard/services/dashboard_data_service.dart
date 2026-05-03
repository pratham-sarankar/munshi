import 'package:munshi/core/models/date_period.dart';
import 'package:munshi/features/dashboard/models/category_spending_data.dart';
import 'package:munshi/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';

/// Aggregated financial summary for a single [DatePeriod].
class PeriodSummaryData {
  /// Creates a [PeriodSummaryData] with the given values.
  const PeriodSummaryData({
    required this.totalSpent,
    required this.totalIncome,
    required this.balance,
    required this.avgDaily,
    required this.transactionCount,
    required this.biggestSpend,
    required this.period,
  });

  /// Creates an empty [PeriodSummaryData] with all values set to zero.
  factory PeriodSummaryData.empty(DatePeriod period) {
    return PeriodSummaryData(
      totalSpent: 0,
      totalIncome: 0,
      balance: 0,
      avgDaily: 0,
      transactionCount: 0,
      biggestSpend: 0,
      period: period,
    );
  }

  /// Total expense amount for the period.
  final double totalSpent;

  /// Total income amount for the period.
  final double totalIncome;

  /// Net balance (income minus expenses) for the period.
  final double balance;

  /// Average daily spending for the period.
  final double avgDaily;

  /// Number of transactions within the period.
  final int transactionCount;

  /// Largest single expense within the period.
  final double biggestSpend;

  /// The date period these figures belong to.
  final DatePeriod period;
}

/// Service that fetches aggregated dashboard data from the local database.
class DashboardDataService {
  /// Creates a [DashboardDataService] backed by [dataSource].
  DashboardDataService(this._dataSource);
  final TransactionLocalDataSource _dataSource;

  /// Alternative method using SQL-based calculation for better performance
  Future<PeriodSummaryData> getPeriodSummarySql(DatePeriod period) async {
    // Use the SQL-based DAO method for maximum efficiency
    return _dataSource.getPeriodSummarySql(period);
  }

  /// Get spending breakdown by category with transaction count for the period
  Future<Map<TransactionCategory?, CategorySpendingData>>
  getSpendingByCategoryWithCount(DatePeriod period) async {
    return _dataSource.getSpendingByCategoryWithCount(period);
  }

  // Future<List<Transaction>> getTransactionsForPeriod(DatePeriod period) async {
  //   return await _transactionsDao.getTransactions(period: period
}
