import 'package:munshi/core/models/date_period.dart';
import 'package:munshi/features/dashboard/models/category_spending_data.dart';
import 'package:munshi/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';

class PeriodSummaryData {
  const PeriodSummaryData({
    required this.totalSpent,
    required this.totalIncome,
    required this.balance,
    required this.avgDaily,
    required this.transactionCount,
    required this.biggestSpend,
    required this.period,
  });

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
  final double totalSpent;
  final double totalIncome;
  final double balance;
  final double avgDaily;
  final int transactionCount;
  final double biggestSpend;
  final DatePeriod period;
}

class DashboardDataService {
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
