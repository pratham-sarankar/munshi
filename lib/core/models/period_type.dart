enum PeriodType { daily, weekly, monthly, yearly }

extension PeriodTypeExtension on PeriodType {
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
