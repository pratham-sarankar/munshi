import 'package:munshi/core/models/date_period.dart';
import 'package:munshi/core/database/daos/transaction_dao.dart';
import 'package:munshi/features/transactions/models/transaction_category.dart';

class PeriodSummaryData {
  final double totalSpent;
  final double totalIncome;
  final double balance;
  final double avgDaily;
  final int transactionCount;
  final double biggestSpend;
  final DatePeriod period;

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
}

class DashboardDataService {
  final TransactionsDao _transactionsDao;

  DashboardDataService(this._transactionsDao);

  /// Alternative method using SQL-based calculation for better performance
  Future<PeriodSummaryData> getPeriodSummarySql(DatePeriod period) async {
    // Use the SQL-based DAO method for maximum efficiency
    return await _transactionsDao.getPeriodSummarySql(period);
  }

  /// Get spending breakdown by category for the period
  Future<Map<TransactionCategory, double>> getSpendingByCategory(
    DatePeriod period,
  ) async {
    return await _transactionsDao.getSpendingByCategory(period);
  }

  // Future<List<Transaction>> getTransactionsForPeriod(DatePeriod period) async {
  //   return await _transactionsDao.getTransactions(period: period
}
