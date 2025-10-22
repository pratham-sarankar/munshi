enum PeriodType { daily, weekly, monthly }

class DatePeriod {
  final PeriodType type;
  final DateTime startDate;
  final DateTime endDate;
  final String displayName;

  const DatePeriod({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.displayName,
  });

  // Factory constructors for different period types
  factory DatePeriod.monthly(DateTime date) {
    final startDate = DateTime(date.year, date.month, 1);
    final endDate = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
    final displayName = _getMonthName(date);

    return DatePeriod(
      type: PeriodType.monthly,
      startDate: startDate,
      endDate: endDate,
      displayName: displayName,
    );
  }

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

    final displayName = 'Week of ${_formatDate(normalizedStart)}';

    return DatePeriod(
      type: PeriodType.weekly,
      startDate: normalizedStart,
      endDate: endDate,
      displayName: displayName,
    );
  }

  factory DatePeriod.daily(DateTime date) {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final displayName = _formatDate(date);

    return DatePeriod(
      type: PeriodType.daily,
      startDate: startDate,
      endDate: endDate,
      displayName: displayName,
    );
  }

  // Navigation methods
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
    }
  }

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
    }
  }

  // Check if a date falls within this period
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
    return "${months[date.month - 1]} ${date.year}";
  }

  static String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
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
