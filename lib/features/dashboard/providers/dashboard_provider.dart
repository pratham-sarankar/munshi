import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:munshi/core/models/date_period.dart';
import 'package:munshi/core/models/period_type.dart';
import 'package:munshi/providers/period_provider.dart';
import 'package:munshi/features/dashboard/services/dashboard_data_service.dart';
import 'package:munshi/features/transactions/models/transaction_category.dart';
import 'package:munshi/features/dashboard/models/category_spending_data.dart';
import 'package:munshi/core/extensions/currency_extensions.dart';

class DashboardProvider extends ChangeNotifier {
  // Private fields
  late DatePeriod _selectedPeriod;
  PeriodSummaryData? _summaryData;
  Map<TransactionCategory, CategorySpendingData>? _categorySpending;
  bool _isLoading = false;
  String? _error;
  final DashboardDataService _dashboardDataService;
  final PeriodProvider _periodProvider;

  // Constructor
  DashboardProvider(this._dashboardDataService, this._periodProvider) {
    // Initialize with user's preferred default period
    _selectedPeriod = DatePeriod.fromPeriodType(
      _periodProvider.defaultPeriod,
      DateTime.now(),
    );
    _loadDashboardData();
  }

  // Getters
  DatePeriod get selectedPeriod => _selectedPeriod;
  PeriodType get currentPeriodType => _selectedPeriod.type;
  PeriodSummaryData? get summaryData => _summaryData;
  Map<TransactionCategory, CategorySpendingData>? get categorySpending =>
      _categorySpending;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Convenience getters for UI
  bool get hasData => _summaryData != null;
  bool get hasCategoryData =>
      _categorySpending != null && _categorySpending!.isNotEmpty;
  double get totalSpent => _summaryData?.totalSpent ?? 0;
  double get totalIncome => _summaryData?.totalIncome ?? 0;
  double get balance => _summaryData?.balance ?? 0;
  double get avgDaily => _summaryData?.avgDaily ?? 0;
  int get transactionCount => _summaryData?.transactionCount ?? 0;
  double get biggestSpend => _summaryData?.biggestSpend ?? 0;

  // Methods
  Future<void> _loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Add 300ms delay for smoother UX
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      // Load both summary data and category spending in parallel
      final results = await Future.wait([
        _dashboardDataService.getPeriodSummarySql(_selectedPeriod),
        _dashboardDataService.getSpendingByCategoryWithCount(_selectedPeriod),
      ]);

      _summaryData = results[0] as PeriodSummaryData;
      _categorySpending =
          results[1] as Map<TransactionCategory, CategorySpendingData>;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _summaryData = PeriodSummaryData.empty(_selectedPeriod);
      _categorySpending = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Changes the selected period by the given direction
  /// [direction] > 0 moves to next period, < 0 moves to previous period
  Future<void> changePeriod(int direction) async {
    final newPeriod = direction > 0
        ? _selectedPeriod.next()
        : _selectedPeriod.previous();

    await setPeriod(newPeriod);

    // Provide haptic feedback
    HapticFeedback.selectionClick();
  }

  /// Sets the period to a specific DatePeriod
  Future<void> setPeriod(DatePeriod period) async {
    if (_selectedPeriod == period) return;

    _selectedPeriod = period;
    notifyListeners(); // Notify immediately for UI responsiveness

    await _loadDashboardData();
  }

  /// Changes the period type (daily, weekly, monthly) and resets to current period
  Future<void> changePeriodType(PeriodType newType) async {
    if (_selectedPeriod.type == newType) return;

    final now = DateTime.now();
    DatePeriod newPeriod;

    switch (newType) {
      case PeriodType.daily:
        newPeriod = DatePeriod.daily(now);
        break;
      case PeriodType.weekly:
        newPeriod = DatePeriod.weekly(now);
        break;
      case PeriodType.monthly:
        newPeriod = DatePeriod.monthly(now);
        break;
      case PeriodType.yearly:
        newPeriod = DatePeriod.yearly(now);
        break;
    }

    await setPeriod(newPeriod);

    // Provide haptic feedback
    HapticFeedback.selectionClick();
  }

  /// Manually refresh the dashboard data
  Future<void> refresh() async {
    await _loadDashboardData();
  }

  /// Format currency amount using the extension
  String formatCurrency(double amount) {
    return amount.toCurrency();
  }

  /// Get spending amount for a specific category
  double getCategorySpending(TransactionCategory category) {
    return _categorySpending?[category]?.totalAmount ?? 0.0;
  }

  /// Get transaction count for a specific category
  int getCategoryTransactionCount(TransactionCategory category) {
    return _categorySpending?[category]?.transactionCount ?? 0;
  }

  /// Get CategorySpendingData for a specific category
  CategorySpendingData? getCategorySpendingData(TransactionCategory category) {
    return _categorySpending?[category];
  }

  /// Get formatted values for UI display
  String get formattedTotalSpent => formatCurrency(totalSpent);
  String get formattedTotalIncome => formatCurrency(totalIncome);
  String get formattedBalance => formatCurrency(balance);
  String get formattedAvgDaily => formatCurrency(avgDaily);
  String get formattedBiggestSpend => formatCurrency(biggestSpend);
  String get formattedTransactionCount => transactionCount.toString();

  /// Get formatted category spending
  String getFormattedCategorySpending(TransactionCategory category) {
    return formatCurrency(getCategorySpending(category));
  }
}
