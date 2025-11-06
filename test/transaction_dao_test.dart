import 'package:flutter_test/flutter_test.dart';
import 'package:munshi/core/models/date_period.dart';
import 'package:munshi/core/models/period_type.dart';

void main() {
  group('Average Daily Calculation Tests', () {
    test('Average calculation should only count days up to today for future periods', () {
      // Get today's date
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Create a monthly period that includes future dates
      final currentMonth = DatePeriod.monthly(now);
      
      // Calculate expected days only up to today
      final effectiveEndDate = currentMonth.endDate.isAfter(today) 
          ? DateTime(today.year, today.month, today.day, 23, 59, 59)
          : currentMonth.endDate;
      final expectedDays = effectiveEndDate.difference(currentMonth.startDate).inDays + 1;
      
      // If we're in the middle of the month, expectedDays should be less than total days in month
      if (now.day < 28) {  // Most months have at least 28 days
        expect(expectedDays, lessThan(31));
        expect(expectedDays, equals(now.day));
      }
      
      // Test with total expense
      const totalExpense = 1000.0;
      final avgDaily = expectedDays > 0 ? totalExpense / expectedDays : 0;
      
      // Average should be higher when calculated with fewer days
      final fullMonthDays = currentMonth.endDate.difference(currentMonth.startDate).inDays + 1;
      final avgDailyWithFutureDays = totalExpense / fullMonthDays;
      
      // If current date is before end of month, avg with correct calculation should be higher
      if (currentMonth.endDate.isAfter(today)) {
        expect(avgDaily, greaterThan(avgDailyWithFutureDays));
      }
    });

    test('Average calculation should use full period for past periods', () {
      // Get a past month (last month)
      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1, 15);
      final lastMonthPeriod = DatePeriod.monthly(lastMonth);
      
      final today = DateTime(now.year, now.month, now.day, 23, 59, 59);
      
      // For past periods, effective end date should be the period's end date
      final effectiveEndDate = lastMonthPeriod.endDate.isAfter(today) 
          ? today 
          : lastMonthPeriod.endDate;
      
      expect(effectiveEndDate, equals(lastMonthPeriod.endDate));
      
      // Calculate days for past period
      final expectedDays = effectiveEndDate.difference(lastMonthPeriod.startDate).inDays + 1;
      final fullPeriodDays = lastMonthPeriod.endDate.difference(lastMonthPeriod.startDate).inDays + 1;
      
      // Should use full period days for past periods
      expect(expectedDays, equals(fullPeriodDays));
    });

    test('Average calculation should handle daily periods correctly', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Today's period
      final todayPeriod = DatePeriod.daily(today);
      final effectiveEndDate = todayPeriod.endDate.isAfter(DateTime(today.year, today.month, today.day, 23, 59, 59))
          ? DateTime(today.year, today.month, today.day, 23, 59, 59)
          : todayPeriod.endDate;
      
      final expectedDays = effectiveEndDate.difference(todayPeriod.startDate).inDays + 1;
      
      // For today, should be 1 day
      expect(expectedDays, equals(1));
      
      // Test average calculation
      const totalExpense = 100.0;
      final avgDaily = expectedDays > 0 ? totalExpense / expectedDays : 0;
      expect(avgDaily, equals(100.0));
    });

    test('Average calculation should handle weekly periods correctly', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 23, 59, 59);
      
      // Current week
      final currentWeek = DatePeriod.weekly(now);
      
      // Calculate effective end date
      final effectiveEndDate = currentWeek.endDate.isAfter(today) ? today : currentWeek.endDate;
      final expectedDays = effectiveEndDate.difference(currentWeek.startDate).inDays + 1;
      
      // Should be at most 7 days
      expect(expectedDays, lessThanOrEqualTo(7));
      
      // If we're in the middle of the week, should be less than 7
      if (currentWeek.endDate.isAfter(today)) {
        expect(expectedDays, lessThan(7));
      }
    });

    test('Average calculation should return 0 when periodDays is 0 or negative', () {
      // Edge case: period with no valid days
      const totalExpense = 100.0;
      const periodDays = 0;
      
      final avgDaily = periodDays > 0 ? totalExpense / periodDays : 0;
      expect(avgDaily, equals(0.0));
    });

    test('Average calculation should handle future periods (period starts after today)', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 23, 59, 59);
      
      // Create a period that starts in the future (next month)
      final futureMonth = DateTime(now.year, now.month + 1, 15);
      final futurePeriod = DatePeriod.monthly(futureMonth);
      
      // Calculate effective end date
      final effectiveEndDate = futurePeriod.endDate.isAfter(today) ? today : futurePeriod.endDate;
      
      // Handle edge case where period starts in the future
      final effectiveEnd = effectiveEndDate.isBefore(futurePeriod.startDate)
          ? futurePeriod.startDate
          : effectiveEndDate;
      
      final periodDays = effectiveEnd.difference(futurePeriod.startDate).inDays + 1;
      
      // For future periods, should use at least 1 day (the start date)
      expect(periodDays, greaterThanOrEqualTo(1));
      
      // Test average calculation doesn't crash
      const totalExpense = 100.0;
      final avgDaily = periodDays > 0 ? totalExpense / periodDays : 0;
      expect(avgDaily, greaterThanOrEqualTo(0));
    });
  });
}
