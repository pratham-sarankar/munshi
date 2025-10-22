import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:munshi/core/models/date_period.dart';
import 'package:munshi/features/dashboard/services/dashboard_data_service.dart';

class DashboardProvider extends ChangeNotifier {
  // Private fields
  late DatePeriod _selectedPeriod;
  PeriodSummaryData? _summaryData;
  bool _isLoading = false;
  String? _error;

  // Constructor
  DashboardProvider() {
    // Initialize with current month
    _selectedPeriod = DatePeriod.monthly(DateTime.now());
    _loadDashboardData();
  }

  // Getters
  DatePeriod get selectedPeriod => _selectedPeriod;
  PeriodSummaryData? get summaryData => _summaryData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Convenience getters for UI
  bool get hasData => _summaryData != null;
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

    try {
      await Future.delayed(
        const Duration(milliseconds: 2000),
      ); // Simulate delay
      final data = await DashboardDataService.getPeriodSummary(_selectedPeriod);
      _summaryData = data;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _summaryData = PeriodSummaryData.empty(_selectedPeriod);
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

  /// Manually refresh the dashboard data
  Future<void> refresh() async {
    await _loadDashboardData();
  }

  /// Helper method to get greeting based on current time
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  /// Format currency amount to Indian Rupee format
  String formatCurrency(double amount) {
    return "₹${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}";
  }

  /// Get formatted values for UI display
  String get formattedTotalSpent => formatCurrency(totalSpent);
  String get formattedTotalIncome => formatCurrency(totalIncome);
  String get formattedBalance => formatCurrency(balance);
  String get formattedAvgDaily => formatCurrency(avgDaily);
  String get formattedBiggestSpend => formatCurrency(biggestSpend);
  String get formattedTransactionCount => transactionCount.toString();
}
