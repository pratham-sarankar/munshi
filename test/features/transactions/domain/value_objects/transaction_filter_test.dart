import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/core/models/date_period.dart';
import 'package:munshi/core/models/period_type.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';
import 'package:munshi/features/transactions/domain/value_objects/transaction_filter.dart';

// A fixed category used across tests.
final _tCategory = TransactionCategory(
  id: 1,
  name: 'Food',
  icon: const IconData(0xe25a, fontFamily: 'MaterialIcons'),
  color: const Color(0xFF4CAF50),
  type: TransactionType.expense,
  isDefault: true,
  createdAt: DateTime(2026),
);

void main() {
  // ─────────────────────────────────────────────────────────────
  // Factories
  // ─────────────────────────────────────────────────────────────

  group('TransactionFilter.empty', () {
    test('all fields are null', () {
      const f = TransactionFilter();
      expect(f.minAmount, isNull);
      expect(f.maxAmount, isNull);
      expect(f.types, isNull);
      expect(f.categories, isNull);
      expect(f.datePeriod, isNull);
      expect(f.customStartDate, isNull);
      expect(f.customEndDate, isNull);
    });

    test('factory produces an equal value to default constructor', () {
      expect(TransactionFilter.empty(), equals(const TransactionFilter()));
    });
  });

  group('TransactionFilter.withDatePeriod', () {
    test('sets datePeriod and leaves all other fields null', () {
      final period = DatePeriod.monthly(DateTime(2026, 5));
      final f = TransactionFilter.withDatePeriod(period);

      expect(f.datePeriod, equals(period));
      expect(f.minAmount, isNull);
      expect(f.maxAmount, isNull);
      expect(f.types, isNull);
      expect(f.categories, isNull);
      expect(f.customStartDate, isNull);
      expect(f.customEndDate, isNull);
    });
  });

  group('TransactionFilter.withCustomDateRange', () {
    test('sets both customStartDate and customEndDate', () {
      final start = DateTime(2026);
      final end = DateTime(2026, 1, 31);
      final f = TransactionFilter.withCustomDateRange(
        startDate: start,
        endDate: end,
      );

      expect(f.customStartDate, equals(start));
      expect(f.customEndDate, equals(end));
      expect(f.datePeriod, isNull);
    });

    test('accepts only startDate (open-ended upper bound)', () {
      final start = DateTime(2026);
      final f = TransactionFilter.withCustomDateRange(startDate: start);

      expect(f.customStartDate, equals(start));
      expect(f.customEndDate, isNull);
    });

    test('accepts only endDate (open-ended lower bound)', () {
      final end = DateTime(2026, 12, 31);
      final f = TransactionFilter.withCustomDateRange(endDate: end);

      expect(f.customEndDate, equals(end));
      expect(f.customStartDate, isNull);
    });
  });

  group('TransactionFilter.fromTimeframe', () {
    test('"Today" produces a daily DatePeriod', () {
      final f = TransactionFilter.fromTimeframe('Today');
      expect(f.datePeriod, isNotNull);
      expect(f.datePeriod!.type, PeriodType.daily);
    });

    test('"This Week" produces a weekly DatePeriod', () {
      final f = TransactionFilter.fromTimeframe('This Week');
      expect(f.datePeriod!.type, PeriodType.weekly);
    });

    test('"This Month" produces a monthly DatePeriod', () {
      final f = TransactionFilter.fromTimeframe('This Month');
      expect(f.datePeriod!.type, PeriodType.monthly);
    });

    test(
      '"Last Month" produces a monthly DatePeriod for the previous month',
      () {
        final f = TransactionFilter.fromTimeframe('Last Month');
        final now = DateTime.now();
        // The period's end date must be before the current month's start.
        expect(
          f.datePeriod!.endDate.isBefore(DateTime(now.year, now.month)),
          isTrue,
        );
      },
    );

    test('"This Year" produces a yearly DatePeriod', () {
      final f = TransactionFilter.fromTimeframe('This Year');
      expect(f.datePeriod!.type, PeriodType.yearly);
    });

    test('unknown string falls back to empty filter', () {
      expect(
        TransactionFilter.fromTimeframe('Unknown'),
        equals(TransactionFilter.empty()),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────
  // effectiveStartDate / effectiveEndDate
  // ─────────────────────────────────────────────────────────────

  group('effectiveStartDate / effectiveEndDate', () {
    test('datePeriod takes precedence over custom dates', () {
      final period = DatePeriod.monthly(DateTime(2026, 3));
      final f = TransactionFilter(
        datePeriod: period,
        customStartDate: DateTime(2000),
        customEndDate: DateTime(2000, 12, 31),
      );

      expect(f.effectiveStartDate, equals(period.startDate));
      expect(f.effectiveEndDate, equals(period.endDate));
    });

    test('falls back to customStartDate when no datePeriod', () {
      final start = DateTime(2026);
      final end = DateTime(2026, 6, 30);
      final f = TransactionFilter.withCustomDateRange(
        startDate: start,
        endDate: end,
      );

      expect(f.effectiveStartDate, equals(start));
      expect(f.effectiveEndDate, equals(end));
    });

    test('returns null for both when filter is empty', () {
      expect(TransactionFilter.empty().effectiveStartDate, isNull);
      expect(TransactionFilter.empty().effectiveEndDate, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // hasActiveFilters
  // ─────────────────────────────────────────────────────────────

  group('hasActiveFilters', () {
    test('is false for empty filter', () {
      expect(TransactionFilter.empty().hasActiveFilters, isFalse);
    });

    test('is true when only minAmount is set', () {
      expect(const TransactionFilter(minAmount: 10).hasActiveFilters, isTrue);
    });

    test('is true when only maxAmount is set', () {
      expect(const TransactionFilter(maxAmount: 500).hasActiveFilters, isTrue);
    });

    test('is true when types is non-empty', () {
      expect(
        const TransactionFilter(
          types: {TransactionType.expense},
        ).hasActiveFilters,
        isTrue,
      );
    });

    test('is false when types is an empty set', () {
      // An empty set is not considered active.
      expect(
        const TransactionFilter(types: {}).hasActiveFilters,
        isFalse,
      );
    });

    test('is true when categories is non-empty', () {
      expect(
        TransactionFilter(categories: {_tCategory}).hasActiveFilters,
        isTrue,
      );
    });

    test('is true when datePeriod is set', () {
      final f = TransactionFilter.fromTimeframe('Today');
      expect(f.hasActiveFilters, isTrue);
    });

    test('is true when only customStartDate is set', () {
      final f = TransactionFilter(customStartDate: DateTime(2026));
      expect(f.hasActiveFilters, isTrue);
    });

    test('is true when only customEndDate is set', () {
      final f = TransactionFilter(customEndDate: DateTime(2026, 12, 31));
      expect(f.hasActiveFilters, isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // activeFilterCount
  // ─────────────────────────────────────────────────────────────

  group('activeFilterCount', () {
    test('is 0 for empty filter', () {
      expect(TransactionFilter.empty().activeFilterCount, 0);
    });

    test('minAmount and maxAmount together count as 1', () {
      const f = TransactionFilter(minAmount: 10, maxAmount: 500);
      expect(f.activeFilterCount, 1);
    });

    test('minAmount alone counts as 1', () {
      expect(const TransactionFilter(minAmount: 10).activeFilterCount, 1);
    });

    test('types counts as 1', () {
      expect(
        const TransactionFilter(
          types: {TransactionType.income},
        ).activeFilterCount,
        1,
      );
    });

    test('categories counts as 1', () {
      expect(
        TransactionFilter(categories: {_tCategory}).activeFilterCount,
        1,
      );
    });

    test('datePeriod counts as 1 date dimension', () {
      final f = TransactionFilter.fromTimeframe('This Month');
      expect(f.activeFilterCount, 1);
    });

    test('customStartDate and customEndDate together count as 1', () {
      final f = TransactionFilter.withCustomDateRange(
        startDate: DateTime(2026),
        endDate: DateTime(2026, 1, 31),
      );
      expect(f.activeFilterCount, 1);
    });

    test('all dimensions active count correctly', () {
      // amount(1) + types(1) + categories(1) + date(1) = 4
      final f = TransactionFilter(
        minAmount: 10,
        maxAmount: 1000,
        types: const {TransactionType.expense},
        categories: {_tCategory},
        datePeriod: DatePeriod.monthly(DateTime(2026, 5)),
      );
      expect(f.activeFilterCount, 4);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Individual predicate flags
  // ─────────────────────────────────────────────────────────────

  group('filter predicate flags', () {
    test('hasAmountFilter is true when minAmount is set', () {
      expect(const TransactionFilter(minAmount: 50).hasAmountFilter, isTrue);
    });

    test('hasAmountFilter is true when maxAmount is set', () {
      expect(const TransactionFilter(maxAmount: 500).hasAmountFilter, isTrue);
    });

    test('hasAmountFilter is false for empty filter', () {
      expect(TransactionFilter.empty().hasAmountFilter, isFalse);
    });

    test('hasTypeFilter is true when types is non-empty', () {
      expect(
        const TransactionFilter(
          types: {TransactionType.income},
        ).hasTypeFilter,
        isTrue,
      );
    });

    test('hasTypeFilter is false when types is empty set', () {
      expect(const TransactionFilter(types: {}).hasTypeFilter, isFalse);
    });

    test('hasTypeFilter is false when types is null', () {
      expect(TransactionFilter.empty().hasTypeFilter, isFalse);
    });

    test('hasCategoryFilter is true when categories is non-empty', () {
      expect(
        TransactionFilter(categories: {_tCategory}).hasCategoryFilter,
        isTrue,
      );
    });

    test('hasCategoryFilter is false when categories is null', () {
      expect(TransactionFilter.empty().hasCategoryFilter, isFalse);
    });

    test('hasDateFilter is true when datePeriod is set', () {
      final f = TransactionFilter.fromTimeframe('Today');
      expect(f.hasDateFilter, isTrue);
    });

    test('hasDateFilter is true when customStartDate is set', () {
      final f = TransactionFilter(customStartDate: DateTime(2026));
      expect(f.hasDateFilter, isTrue);
    });

    test('hasDateFilter is true when customEndDate is set', () {
      final f = TransactionFilter(customEndDate: DateTime(2026, 12, 31));
      expect(f.hasDateFilter, isTrue);
    });

    test('hasDateFilter is false for empty filter', () {
      expect(TransactionFilter.empty().hasDateFilter, isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // copyWith
  // ─────────────────────────────────────────────────────────────

  group('copyWith', () {
    const base = TransactionFilter(
      minAmount: 10,
      maxAmount: 500,
      types: {TransactionType.expense},
    );

    test('no overrides returns an equal instance', () {
      expect(base.copyWith(), equals(base));
    });

    test('overrides only the supplied field', () {
      final updated = base.copyWith(minAmount: 99);
      expect(updated.minAmount, 99);
      expect(updated.maxAmount, base.maxAmount);
      expect(updated.types, base.types);
    });

    test('clearMinAmount flag sets minAmount to null', () {
      final cleared = base.copyWith(clearMinAmount: true);
      expect(cleared.minAmount, isNull);
      expect(cleared.maxAmount, base.maxAmount); // unchanged
    });

    test('clearMaxAmount flag sets maxAmount to null', () {
      final cleared = base.copyWith(clearMaxAmount: true);
      expect(cleared.maxAmount, isNull);
      expect(cleared.minAmount, base.minAmount); // unchanged
    });

    test('clearTypes flag sets types to null', () {
      final cleared = base.copyWith(clearTypes: true);
      expect(cleared.types, isNull);
    });

    test('clearCategories flag sets categories to null', () {
      final f = TransactionFilter(categories: {_tCategory});
      final cleared = f.copyWith(clearCategories: true);
      expect(cleared.categories, isNull);
    });

    test('clearDatePeriod flag sets datePeriod to null', () {
      final f = TransactionFilter.fromTimeframe('This Month');
      final cleared = f.copyWith(clearDatePeriod: true);
      expect(cleared.datePeriod, isNull);
    });

    test('clear flag takes precedence over a supplied replacement value', () {
      // Even if minAmount: 999 is passed, clearMinAmount wins.
      final cleared = base.copyWith(minAmount: 999, clearMinAmount: true);
      expect(cleared.minAmount, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // clearAll
  // ─────────────────────────────────────────────────────────────

  group('clearAll', () {
    test('returns an empty filter regardless of how many fields were set', () {
      final f = TransactionFilter(
        minAmount: 10,
        maxAmount: 500,
        types: const {TransactionType.income},
        categories: {_tCategory},
        datePeriod: DatePeriod.monthly(DateTime(2026, 5)),
      );
      expect(f.clearAll(), equals(TransactionFilter.empty()));
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Equality & hashCode
  // ─────────────────────────────────────────────────────────────

  group('equality', () {
    test('two empty filters are equal', () {
      expect(TransactionFilter.empty(), equals(TransactionFilter.empty()));
    });

    test('same amount bounds are equal', () {
      const a = TransactionFilter(minAmount: 100, maxAmount: 500);
      const b = TransactionFilter(minAmount: 100, maxAmount: 500);
      expect(a, equals(b));
    });

    test('different minAmount are not equal', () {
      const a = TransactionFilter(minAmount: 100);
      const b = TransactionFilter(minAmount: 200);
      expect(a, isNot(equals(b)));
    });

    test('same type sets are equal regardless of insertion order', () {
      const a = TransactionFilter(
        types: {TransactionType.income, TransactionType.expense},
      );
      const b = TransactionFilter(
        types: {TransactionType.expense, TransactionType.income},
      );
      // TransactionFilter uses _setEquals which is order-independent.
      expect(a, equals(b));
    });

    test('different type sets are not equal', () {
      const a = TransactionFilter(types: {TransactionType.income});
      const b = TransactionFilter(
        types: {TransactionType.income, TransactionType.expense},
      );
      expect(a, isNot(equals(b)));
    });

    test('same category sets are equal', () {
      final a = TransactionFilter(categories: {_tCategory});
      final b = TransactionFilter(categories: {_tCategory});
      expect(a, equals(b));
    });

    test('different custom date ranges are not equal', () {
      final a = TransactionFilter(customStartDate: DateTime(2026));
      final b = TransactionFilter(customStartDate: DateTime(2026, 6));
      expect(a, isNot(equals(b)));
    });

    test('equal instances share the same hashCode', () {
      const a = TransactionFilter(minAmount: 50, maxAmount: 200);
      const b = TransactionFilter(minAmount: 50, maxAmount: 200);
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
