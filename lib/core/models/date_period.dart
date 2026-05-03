import 'package:intl/intl.dart';
import 'package:munshi/core/models/period_type.dart';

/// Represents a calendar period (day, week, month, or year) with a start/end date range.
class DatePeriod {
  /// Creates a [DatePeriod] with explicit [type], [startDate], [endDate] and [displayName].
  const DatePeriod({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.displayName,
  });

  /// Creates a [DatePeriod] from a [PeriodType] and a reference [date].
  factory DatePeriod.fromPeriodType(PeriodType type, DateTime date) {
    switch (type) {
      case PeriodType.daily:
        return DatePeriod.daily(date);
      case PeriodType.weekly:
        return DatePeriod.weekly(date);
      case PeriodType.monthly:
        return DatePeriod.monthly(date);
      case PeriodType.yearly:
        return DatePeriod.yearly(date);
    }
  }

  // Factory constructors for different period types
  /// Creates a monthly [DatePeriod] covering the entire month that contains [date].
  factory DatePeriod.monthly(DateTime date) {
    final startDate = DateTime(date.year, date.month);
    final endDate = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
    final displayName = _getMonthName(date);

    return DatePeriod(
      type: PeriodType.monthly,
      startDate: startDate,
      endDate: endDate,
      displayName: displayName,
    );
  }

  /// Creates a weekly [DatePeriod] (Mon–Sun) for the week that contains [date].
  factory DatePeriod.weekly(DateTime date) {
    // Get Monday of the week containing the date
    final startDate = date.subtract(Duration(days: date.weekday - 1));
    final normalizedStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final endDate = normalizedStart.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    final displayName =
        '${_formatDate(normalizedStart)} - ${_formatDate(endDate)}';

    return DatePeriod(
      type: PeriodType.weekly,
      startDate: normalizedStart,
      endDate: endDate,
      displayName: displayName,
    );
  }

  /// Creates a daily [DatePeriod] covering the single calendar day of [date].
  factory DatePeriod.daily(DateTime date) {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final displayName = _getDailyDisplayName(date);

    return DatePeriod(
      type: PeriodType.daily,
      startDate: startDate,
      endDate: endDate,
      displayName: displayName,
    );
  }

  /// Creates a yearly [DatePeriod] covering the full year of [date].
  factory DatePeriod.yearly(DateTime date) {
    final startDate = DateTime(date.year);
    final endDate = DateTime(date.year, 12, 31, 23, 59, 59);
    final displayName = date.year.toString();

    return DatePeriod(
      type: PeriodType.yearly,
      startDate: startDate,
      endDate: endDate,
      displayName: displayName,
    );
  }

  /// The granularity of this period (daily, weekly, monthly, yearly).
  final PeriodType type;

  /// The inclusive start of the period.
  final DateTime startDate;

  /// The inclusive end of the period.
  final DateTime endDate;

  /// Human-readable label for this period (e.g. `'May 2026'`).
  final String displayName;

  // Navigation methods
  /// Returns the period immediately following this one.
  DatePeriod next() {
    switch (type) {
      case PeriodType.monthly:
        final nextMonth = DateTime(startDate.year, startDate.month + 1);
        return DatePeriod.monthly(nextMonth);
      case PeriodType.weekly:
        final nextWeek = startDate.add(const Duration(days: 7));
        return DatePeriod.weekly(nextWeek);
      case PeriodType.daily:
        final nextDay = startDate.add(const Duration(days: 1));
        return DatePeriod.daily(nextDay);
      case PeriodType.yearly:
        final nextYear = DateTime(startDate.year + 1);
        return DatePeriod.yearly(nextYear);
    }
  }

  /// Returns the period immediately preceding this one.
  DatePeriod previous() {
    switch (type) {
      case PeriodType.monthly:
        final prevMonth = DateTime(startDate.year, startDate.month - 1);
        return DatePeriod.monthly(prevMonth);
      case PeriodType.weekly:
        final prevWeek = startDate.subtract(const Duration(days: 7));
        return DatePeriod.weekly(prevWeek);
      case PeriodType.daily:
        final prevDay = startDate.subtract(const Duration(days: 1));
        return DatePeriod.daily(prevDay);
      case PeriodType.yearly:
        final prevYear = DateTime(startDate.year - 1);
        return DatePeriod.yearly(prevYear);
    }
  }

  // Check if a date falls within this period
  /// Returns `true` if [date] falls within this period (inclusive).
  bool contains(DateTime date) {
    return date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
        date.isBefore(endDate.add(const Duration(seconds: 1)));
  }

  static String _getMonthName(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  static String _getDailyDisplayName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Today';
    } else if (targetDate == yesterday) {
      return 'Yesterday';
    } else {
      return _formatDate(date);
    }
  }

  static String _formatDate(DateTime date) {
    return DateFormat('d MMM').format(date);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DatePeriod &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => type.hashCode ^ startDate.hashCode ^ endDate.hashCode;

  @override
  String toString() {
    return 'DatePeriod(type: $type, displayName: $displayName, start: $startDate, end: $endDate)';
  }
}
