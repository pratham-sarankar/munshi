import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:munshi/core/extensions/currency_extensions.dart';
import 'package:munshi/core/models/date_period.dart';
import 'package:munshi/core/models/period_type.dart';
import 'package:munshi/features/dashboard/models/category_spending_data.dart';
import 'package:munshi/features/dashboard/services/dashboard_data_service.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';
import 'package:munshi/providers/currency_provider.dart';
import 'package:munshi/providers/period_provider.dart';

/// Provides aggregated financial data for the dashboard screen.
///
/// Listens to [CurrencyProvider] and refreshes formatted values whenever
/// the selected currency changes.
class DashboardProvider extends ChangeNotifier {
  // Constructor
  /// Creates a [DashboardProvider] and loads dashboard data for the current period.
  DashboardProvider(
    this._dashboardDataService,
    this._periodProvider,
    this._currencyProvider,
  ) {
    // Initialize with user's preferred default period
    _selectedPeriod = DatePeriod.fromPeriodType(
      _periodProvider.defaultPeriod,
      DateTime.now(),
    );
    _loadDashboardData();

    // Listen to currency changes and notify listeners to update UI
    // This ensures all formatted currency values update when currency changes
    _currencyProvider.addListener(_onCurrencyChanged);
  }
  // Private fields
  late DatePeriod _selectedPeriod;
  PeriodSummaryData? _summaryData;
  Map<TransactionCategory?, CategorySpendingData>? _categorySpending;
  bool _isLoading = false;
  String? _error;
  final DashboardDataService _dashboardDataService;
  final PeriodProvider _periodProvider;
  final CurrencyProvider _currencyProvider;

  void _onCurrencyChanged() {
    // Notify listeners so widgets can rebuild with new currency formatting
    notifyListeners();
  }

  @override
  void dispose() {
    _currencyProvider.removeListener(_onCurrencyChanged);
    super.dispose();
  }

  // Getters
  /// The currently selected date period.
  DatePeriod get selectedPeriod => _selectedPeriod;

  /// The type of the currently selected period.
  PeriodType get currentPeriodType => _selectedPeriod.type;

  /// Summary data for the selected period, or `null` while loading.
  PeriodSummaryData? get summaryData => _summaryData;

  /// Category spending breakdown, or `null` while loading.
  Map<TransactionCategory?, CategorySpendingData>? get categorySpending =>
      _categorySpending;

  /// Whether data is currently being fetched.
  bool get isLoading => _isLoading;

  /// Error message from the last failed load, or `null` if successful.
  String? get error => _error;

  // Convenience getters for UI
  /// `true` if summary data has been loaded at least once.
  bool get hasData => _summaryData != null;

  /// `true` if category spending data is available and non-empty.
  bool get hasCategoryData =>
      _categorySpending != null && _categorySpending!.isNotEmpty;

  /// Total amount spent in the selected period.
  double get totalSpent => _summaryData?.totalSpent ?? 0;

  /// Total income received in the selected period.
  double get totalIncome => _summaryData?.totalIncome ?? 0;

  /// Net balance (income minus expenses) for the selected period.
  double get balance => _summaryData?.balance ?? 0;

  /// Average daily spending for the selected period.
  double get avgDaily => _summaryData?.avgDaily ?? 0;

  /// Number of transactions in the selected period.
  int get transactionCount => _summaryData?.transactionCount ?? 0;

  /// The single largest expense in the selected period.
  double get biggestSpend => _summaryData?.biggestSpend ?? 0;

  /// Check if the selected period is the current period (today/this week/this month/this year)
  bool get isCurrentPeriod {
    final now = DateTime.now();
    final currentPeriod = DatePeriod.fromPeriodType(_selectedPeriod.type, now);
    return _selectedPeriod == currentPeriod;
  }

  // Methods
  Future<void> _loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Add 300ms delay for smoother UX
    await Future<void>.delayed(const Duration(milliseconds: 300));

    try {
      // Load both summary data and category spending in parallel
      final results = await Future.wait([
        _dashboardDataService.getPeriodSummarySql(_selectedPeriod),
        _dashboardDataService.getSpendingByCategoryWithCount(_selectedPeriod),
      ]);

      _summaryData = results[0] as PeriodSummaryData;
      _categorySpending =
          results[1] as Map<TransactionCategory?, CategorySpendingData>;
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
      case PeriodType.weekly:
        newPeriod = DatePeriod.weekly(now);
      case PeriodType.monthly:
        newPeriod = DatePeriod.monthly(now);
      case PeriodType.yearly:
        newPeriod = DatePeriod.yearly(now);
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
  double getCategorySpending(TransactionCategory? category) {
    return _categorySpending?[category]?.totalAmount ?? 0.0;
  }

  /// Get transaction count for a specific category
  int getCategoryTransactionCount(TransactionCategory? category) {
    return _categorySpending?[category]?.transactionCount ?? 0;
  }

  /// Get CategorySpendingData for a specific category
  CategorySpendingData? getCategorySpendingData(TransactionCategory? category) {
    return _categorySpending?[category];
  }

  /// Get formatted values for UI display
  /// Formatted [totalSpent] as a currency string.
  String get formattedTotalSpent => formatCurrency(totalSpent);

  /// Formatted [totalIncome] as a currency string.
  String get formattedTotalIncome => formatCurrency(totalIncome);

  /// Formatted [balance] as a currency string.
  String get formattedBalance => formatCurrency(balance);

  /// Formatted average daily spending as a currency string.
  String get formattedAvgDaily => formatCurrency(avgDaily);

  /// Formatted [biggestSpend] as a currency string.
  String get formattedBiggestSpend => formatCurrency(biggestSpend);

  /// Formatted transaction count as a string.
  String get formattedTransactionCount => transactionCount.toString();

  /// Get formatted category spending
  String getFormattedCategorySpending(TransactionCategory? category) {
    return formatCurrency(getCategorySpending(category));
  }
}
