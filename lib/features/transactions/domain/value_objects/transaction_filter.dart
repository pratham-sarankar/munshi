import 'package:flutter/widgets.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/core/models/date_period.dart';
import 'package:munshi/features/transactions/domain/entities/transaction.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';

/// An immutable value object that encapsulates all criteria used to filter
/// a list of [Transaction]s.
///
/// A filter is considered *active* when at least one field is set. Each
/// distinct filtering dimension — amount range, transaction types, categories,
/// and date — counts as **one** unit in [activeFilterCount], regardless of
/// how many fields within that dimension are populated.
///
/// Prefer the named factory constructors over the default constructor for
/// common scenarios:
///
/// ```dart
/// // No filtering.
/// final empty = TransactionFilter.empty();
///
/// // Filter to a calendar month.
/// final monthly = TransactionFilter.withDatePeriod(
///   DatePeriod.monthly(DateTime.now()),
/// );
///
/// // Filter by a user-selected timeframe label.
/// final today = TransactionFilter.fromTimeframe('Today');
/// ```
///
/// [TransactionFilter] is immutable. Use [copyWith] to derive a modified copy,
/// or [clearAll] to reset to an empty filter.
@immutable
class TransactionFilter {
  /// Creates a [TransactionFilter] with optional filtering criteria.
  ///
  /// All parameters default to `null`, which means no filtering is applied for
  /// that dimension. Pass `const TransactionFilter()` or prefer the
  /// [TransactionFilter.empty] factory for clarity.
  const TransactionFilter({
    this.minAmount,
    this.maxAmount,
    this.types,
    this.categories,
    this.datePeriod,
    this.customStartDate,
    this.customEndDate,
  });

  /// Creates an empty filter with no active criteria.
  ///
  /// Equivalent to `const TransactionFilter()`. Use this factory to make
  /// intent explicit at call sites.
  factory TransactionFilter.empty() {
    return const TransactionFilter();
  }

  /// Creates a filter restricted to the given [datePeriod].
  ///
  /// All other filter dimensions remain unset. The [effectiveStartDate] and
  /// [effectiveEndDate] getters will delegate to [datePeriod]'s boundaries.
  factory TransactionFilter.withDatePeriod(DatePeriod datePeriod) {
    return TransactionFilter(datePeriod: datePeriod);
  }

  /// Creates a filter with an explicit date range instead of a [DatePeriod].
  ///
  /// Either bound may be `null` to represent an open-ended range:
  /// - Only [startDate] → "from this date onwards".
  /// - Only [endDate] → "up to and including this date".
  /// - Neither → equivalent to [TransactionFilter.empty] for the date dimension.
  ///
  /// When [datePeriod] is also set on the same filter (e.g. via [copyWith]),
  /// [datePeriod] takes precedence in [effectiveStartDate] and
  /// [effectiveEndDate].
  factory TransactionFilter.withCustomDateRange({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TransactionFilter(
      customStartDate: startDate,
      customEndDate: endDate,
    );
  }

  /// Creates a filter from a human-readable [timeframe] label.
  ///
  /// Recognised values and their corresponding [DatePeriod]:
  ///
  /// | [timeframe]  | Period                       |
  /// |--------------|------------------------------|
  /// | `'Today'`    | [DatePeriod.daily] (today)   |
  /// | `'This Week'`| [DatePeriod.weekly] (current)|
  /// | `'This Month'`| [DatePeriod.monthly] (current)|
  /// | `'Last Month'`| [DatePeriod.monthly] (previous)|
  /// | `'This Year'`| [DatePeriod.yearly] (current)|
  ///
  /// Any other value returns [TransactionFilter.empty].
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

  /// Lower bound for the transaction amount (inclusive), or `null` for no
  /// lower bound.
  final double? minAmount;

  /// Upper bound for the transaction amount (inclusive), or `null` for no
  /// upper bound.
  final double? maxAmount;

  /// The set of [TransactionType]s to include, or `null` to include all types.
  ///
  /// An *empty* set is treated the same as `null` — no type filtering is
  /// applied.
  final Set<TransactionType>? types;

  /// The set of [TransactionCategory]s to include, or `null` to include all
  /// categories.
  ///
  /// An *empty* set is treated the same as `null` — no category filtering is
  /// applied.
  final Set<TransactionCategory>? categories;

  /// A pre-defined calendar period used to bound the query by date.
  ///
  /// When set, [effectiveStartDate] and [effectiveEndDate] delegate to this
  /// period's boundaries, taking precedence over [customStartDate] and
  /// [customEndDate].
  final DatePeriod? datePeriod;

  /// The start of a custom date range, or `null` for no lower date bound.
  ///
  /// Ignored when [datePeriod] is set — use [effectiveStartDate] to read the
  /// resolved boundary.
  final DateTime? customStartDate;

  /// The end of a custom date range, or `null` for no upper date bound.
  ///
  /// Ignored when [datePeriod] is set — use [effectiveEndDate] to read the
  /// resolved boundary.
  final DateTime? customEndDate;

  /// The resolved start date for the query.
  ///
  /// Returns [DatePeriod.startDate] when [datePeriod] is set; otherwise falls
  /// back to [customStartDate]. Returns `null` when no date dimension is
  /// active.
  DateTime? get effectiveStartDate {
    if (datePeriod != null) return datePeriod!.startDate;
    return customStartDate;
  }

  /// The resolved end date for the query.
  ///
  /// Returns [DatePeriod.endDate] when [datePeriod] is set; otherwise falls
  /// back to [customEndDate]. Returns `null` when no date dimension is active.
  DateTime? get effectiveEndDate {
    if (datePeriod != null) return datePeriod!.endDate;
    return customEndDate;
  }

  /// Whether any filter criterion is currently active.
  ///
  /// Returns `true` if at least one field is set to a non-null, non-empty
  /// value.
  bool get hasActiveFilters {
    return minAmount != null ||
        maxAmount != null ||
        (types != null && types!.isNotEmpty) ||
        (categories != null && categories!.isNotEmpty) ||
        datePeriod != null ||
        customStartDate != null ||
        customEndDate != null;
  }

  /// The number of active filter *dimensions*.
  ///
  /// Each dimension counts at most once:
  /// - Amount range (`minAmount` and/or `maxAmount`) → **1**
  /// - Transaction types → **1**
  /// - Categories → **1**
  /// - Date (`datePeriod`, `customStartDate`, or `customEndDate`) → **1**
  ///
  /// Maximum value is **4**.
  int get activeFilterCount {
    var count = 0;
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

  /// Whether an amount range filter (`minAmount` or `maxAmount`) is active.
  bool get hasAmountFilter => minAmount != null || maxAmount != null;

  /// Whether a transaction-type filter is active (i.e. [types] is non-null and
  /// non-empty).
  bool get hasTypeFilter => types != null && types!.isNotEmpty;

  /// Whether a category filter is active (i.e. [categories] is non-null and
  /// non-empty).
  bool get hasCategoryFilter => categories != null && categories!.isNotEmpty;

  /// Whether a date filter is active via [datePeriod], [customStartDate], or
  /// [customEndDate].
  bool get hasDateFilter =>
      datePeriod != null || customStartDate != null || customEndDate != null;

  /// Returns a copy of this filter with the specified fields replaced.
  ///
  /// To **clear** a nullable field back to `null`, pass the corresponding
  /// `clear*` flag as `true`. The clear flag takes precedence over any
  /// replacement value supplied for the same field:
  ///
  /// ```dart
  /// // Sets minAmount to null even though 999 is also passed.
  /// filter.copyWith(minAmount: 999, clearMinAmount: true);
  /// ```
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

  /// Returns an empty [TransactionFilter], discarding all active criteria.
  ///
  /// Equivalent to `TransactionFilter.empty()`.
  TransactionFilter clearAll() {
    return TransactionFilter.empty();
  }

  /// A [DatePeriod] covering today.
  static DatePeriod get todayPeriod => DatePeriod.daily(DateTime.now());

  /// A [DatePeriod] covering the current calendar week.
  static DatePeriod get thisWeekPeriod => DatePeriod.weekly(DateTime.now());

  /// A [DatePeriod] covering the current calendar month.
  static DatePeriod get thisMonthPeriod => DatePeriod.monthly(DateTime.now());

  /// A [DatePeriod] covering the previous calendar month.
  static DatePeriod get lastMonthPeriod =>
      DatePeriod.monthly(DateTime.now()).previous();

  /// A [DatePeriod] covering the current calendar year.
  static DatePeriod get thisYearPeriod => DatePeriod.yearly(DateTime.now());

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

  /// Returns `true` when both sets contain exactly the same elements,
  /// regardless of insertion order. Two `null` values are also considered
  /// equal.
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
