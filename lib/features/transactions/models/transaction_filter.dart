import 'package:munshi/core/models/date_period.dart';
import 'package:munshi/features/transactions/models/transaction_category.dart';
import 'package:munshi/features/transactions/models/transaction_type.dart';

class TransactionFilter {
  final double? minAmount;
  final double? maxAmount;
  final Set<TransactionType>? types;
  final Set<TransactionCategory>? categories;
  final DatePeriod? datePeriod;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const TransactionFilter({
    this.minAmount,
    this.maxAmount,
    this.types,
    this.categories,
    this.datePeriod,
    this.customStartDate,
    this.customEndDate,
  });

  /// Create an empty filter (no filtering applied)
  factory TransactionFilter.empty() {
    return const TransactionFilter();
  }

  /// Create filter with predefined date period
  factory TransactionFilter.withDatePeriod(DatePeriod datePeriod) {
    return TransactionFilter(datePeriod: datePeriod);
  }

  /// Create filter with custom date range
  factory TransactionFilter.withCustomDateRange({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TransactionFilter(
      customStartDate: startDate,
      customEndDate: endDate,
    );
  }

  /// Get effective start date (from datePeriod or customStartDate)
  DateTime? get effectiveStartDate {
    if (datePeriod != null) return datePeriod!.startDate;
    return customStartDate;
  }

  /// Get effective end date (from datePeriod or customEndDate)
  DateTime? get effectiveEndDate {
    if (datePeriod != null) return datePeriod!.endDate;
    return customEndDate;
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return minAmount != null ||
        maxAmount != null ||
        (types != null && types!.isNotEmpty) ||
        (categories != null && categories!.isNotEmpty) ||
        datePeriod != null ||
        customStartDate != null ||
        customEndDate != null;
  }

  /// Get the number of active filters
  int get activeFilterCount {
    int count = 0;
    if (minAmount != null || maxAmount != null) count++;
    if (types != null && types!.isNotEmpty) count++;
    if (categories != null && categories!.isNotEmpty) count++;
    if (datePeriod != null ||
        customStartDate != null ||
        customEndDate != null) {
      count++;
    }
    return count;
  }

  /// Check if a specific filter type is active
  bool get hasAmountFilter => minAmount != null || maxAmount != null;
  bool get hasTypeFilter => types != null && types!.isNotEmpty;
  bool get hasCategoryFilter => categories != null && categories!.isNotEmpty;
  bool get hasDateFilter =>
      datePeriod != null || customStartDate != null || customEndDate != null;

  /// Copy with modifications
  TransactionFilter copyWith({
    double? minAmount,
    double? maxAmount,
    Set<TransactionType>? types,
    Set<TransactionCategory>? categories,
    DatePeriod? datePeriod,
    DateTime? customStartDate,
    DateTime? customEndDate,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
    bool clearTypes = false,
    bool clearCategories = false,
    bool clearDatePeriod = false,
    bool clearCustomStartDate = false,
    bool clearCustomEndDate = false,
  }) {
    return TransactionFilter(
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
      types: clearTypes ? null : (types ?? this.types),
      categories: clearCategories ? null : (categories ?? this.categories),
      datePeriod: clearDatePeriod ? null : (datePeriod ?? this.datePeriod),
      customStartDate: clearCustomStartDate
          ? null
          : (customStartDate ?? this.customStartDate),
      customEndDate: clearCustomEndDate
          ? null
          : (customEndDate ?? this.customEndDate),
    );
  }

  /// Clear all filters
  TransactionFilter clearAll() {
    return TransactionFilter.empty();
  }

  /// Predefined date periods using DatePeriod
  static DatePeriod get todayPeriod => DatePeriod.daily(DateTime.now());
  static DatePeriod get thisWeekPeriod => DatePeriod.weekly(DateTime.now());
  static DatePeriod get thisMonthPeriod => DatePeriod.monthly(DateTime.now());
  static DatePeriod get lastMonthPeriod =>
      DatePeriod.monthly(DateTime.now()).previous();
  static DatePeriod get thisYearPeriod => DatePeriod.yearly(DateTime.now());

  /// Create filter from predefined timeframe using DatePeriod
  factory TransactionFilter.fromTimeframe(String timeframe) {
    switch (timeframe) {
      case 'Today':
        return TransactionFilter.withDatePeriod(todayPeriod);
      case 'This Week':
        return TransactionFilter.withDatePeriod(thisWeekPeriod);
      case 'This Month':
        return TransactionFilter.withDatePeriod(thisMonthPeriod);
      case 'Last Month':
        return TransactionFilter.withDatePeriod(lastMonthPeriod);
      case 'This Year':
        return TransactionFilter.withDatePeriod(thisYearPeriod);
      default:
        return TransactionFilter.empty();
    }
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionFilter &&
        other.minAmount == minAmount &&
        other.maxAmount == maxAmount &&
        _setEquals(other.types, types) &&
        _setEquals(other.categories, categories) &&
        other.datePeriod == datePeriod &&
        other.customStartDate == customStartDate &&
        other.customEndDate == customEndDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      minAmount,
      maxAmount,
      types,
      categories,
      datePeriod,
      customStartDate,
      customEndDate,
    );
  }

  /// Helper method to compare sets
  bool _setEquals<T>(Set<T>? a, Set<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    return a.containsAll(b) && b.containsAll(a);
  }

  @override
  String toString() {
    return 'TransactionFilter('
        'minAmount: $minAmount, '
        'maxAmount: $maxAmount, '
        'types: $types, '
        'categories: $categories, '
        'datePeriod: $datePeriod, '
        'customStartDate: $customStartDate, '
        'customEndDate: $customEndDate'
        ')';
  }
}
