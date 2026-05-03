/// The time granularity used for grouping transactions on the dashboard.
enum PeriodType {
  /// One calendar day.
  daily,

  /// One calendar week (Monday–Sunday).
  weekly,

  /// One calendar month.
  monthly,

  /// One calendar year.
  yearly,
}

/// Extension helpers for [PeriodType].
extension PeriodTypeExtension on PeriodType {
  /// Returns a human-readable label for this period type.
  String get displayName {
    switch (this) {
      case PeriodType.daily:
        return 'Daily';
      case PeriodType.weekly:
        return 'Weekly';
      case PeriodType.monthly:
        return 'Monthly';
      case PeriodType.yearly:
        return 'Yearly';
    }
  }
}
