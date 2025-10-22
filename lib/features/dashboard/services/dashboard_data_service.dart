import 'package:munshi/core/models/date_period.dart';

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
  // In the future, this will connect to your database/API
  // For now, it returns mock data based on the period

  static Future<PeriodSummaryData> getPeriodSummary(DatePeriod period) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data - replace with real database queries
    switch (period.type) {
      case PeriodType.daily:
        return PeriodSummaryData(
          totalSpent: 450,
          totalIncome: 0, // Usually no daily income tracking
          balance: -450,
          avgDaily: 450, // Same as daily spend
          transactionCount: 3,
          biggestSpend: 200,
          period: period,
        );

      case PeriodType.weekly:
        return PeriodSummaryData(
          totalSpent: 2800,
          totalIncome: 1200, // Maybe some side income
          balance: -1600,
          avgDaily: 400, // 2800 / 7 days
          transactionCount: 15,
          biggestSpend: 800,
          period: period,
        );

      case PeriodType.monthly:
        return PeriodSummaryData(
          totalSpent: 12430,
          totalIncome: 45800,
          balance: 33370,
          avgDaily: 401, // 12430 / ~31 days
          transactionCount: 45,
          biggestSpend: 3200,
          period: period,
        );
    }
  }

  // Future methods for real data integration:

  // static Future<List<Transaction>> getTransactionsForPeriod(DatePeriod period) async {
  //   // Query transactions where date is between period.startDate and period.endDate
  // }

  // static Future<List<Category>> getSpendingByCategory(DatePeriod period) async {
  //   // Get spending breakdown by category for the period
  // }

  // static Future<Map<String, double>> getComparisonWithPreviousPeriod(DatePeriod period) async {
  //   // Compare current period with previous period
  // }
}
