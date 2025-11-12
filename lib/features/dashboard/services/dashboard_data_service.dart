import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/database/daos/transaction_dao.dart';
import 'package:munshi/core/models/date_period.dart';
import 'package:munshi/features/dashboard/models/category_spending_data.dart';

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

  DashboardDataService(this._transactionsDao);
  final TransactionsDao _transactionsDao;

  /// Alternative method using SQL-based calculation for better performance
  Future<PeriodSummaryData> getPeriodSummarySql(DatePeriod period) async {
    // Use the SQL-based DAO method for maximum efficiency
    return _transactionsDao.getPeriodSummarySql(period);
  }

  /// Get spending breakdown by category with transaction count for the period
  Future<Map<TransactionCategory?, CategorySpendingData>>
  getSpendingByCategoryWithCount(DatePeriod period) async {
    return _transactionsDao.getSpendingByCategoryWithCount(period);
  }

  // Future<List<Transaction>> getTransactionsForPeriod(DatePeriod period) async {
  //   return await _transactionsDao.getTransactions(period: period
}
