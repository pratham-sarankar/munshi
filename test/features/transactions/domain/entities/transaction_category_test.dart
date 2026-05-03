import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';

void main() {
  const tIcon = IconData(0xe25a, fontFamily: 'MaterialIcons');
  const tColor = Color(0xFF4CAF50);
  final baseDate = DateTime(2026);

  final tCategory = TransactionCategory(
    id: 1,
    name: 'Food',
    icon: tIcon,
    color: tColor,
    type: TransactionType.expense,
    isDefault: true,
    createdAt: baseDate,
  );

  group('TransactionCategory equality', () {
    test('two instances with identical props are equal', () {
      final other = TransactionCategory(
        id: 1,
        name: 'Food',
        icon: tIcon,
        color: tColor,
        type: TransactionType.expense,
        isDefault: true,
        createdAt: baseDate,
      );
      expect(tCategory, equals(other));
    });

    test('instances differ when id differs', () {
      expect(tCategory, isNot(equals(tCategory.copyWith(id: 99))));
    });

    test('instances differ when name differs', () {
      expect(tCategory, isNot(equals(tCategory.copyWith(name: 'Transport'))));
    });

    test('instances differ when type differs', () {
      expect(
        tCategory,
        isNot(equals(tCategory.copyWith(type: TransactionType.income))),
      );
    });

    test('instances differ when isDefault differs', () {
      expect(
        tCategory,
        isNot(equals(tCategory.copyWith(isDefault: false))),
      );
    });

    test('instances differ when color differs', () {
      expect(
        tCategory,
        isNot(equals(tCategory.copyWith(color: const Color(0xFFFF0000)))),
      );
    });

    test('instances differ when createdAt differs', () {
      expect(
        tCategory,
        isNot(equals(tCategory.copyWith(createdAt: DateTime(2025, 6, 1)))),
      );
    });

    test('hashCode is consistent for equal instances', () {
      final other = TransactionCategory(
        id: 1,
        name: 'Food',
        icon: tIcon,
        color: tColor,
        type: TransactionType.expense,
        isDefault: true,
        createdAt: baseDate,
      );
      expect(tCategory.hashCode, equals(other.hashCode));
    });
  });

  group('TransactionCategory.copyWith', () {
    test('returns an equal instance when no overrides are provided', () {
      expect(tCategory.copyWith(), equals(tCategory));
    });

    test('overrides only the supplied fields', () {
      final updated = tCategory.copyWith(name: 'Travel', isDefault: false);

      expect(updated.name, 'Travel');
      expect(updated.isDefault, false);
      // unchanged fields stay the same
      expect(updated.id, tCategory.id);
      expect(updated.icon, tCategory.icon);
      expect(updated.color, tCategory.color);
      expect(updated.type, tCategory.type);
      expect(updated.createdAt, tCategory.createdAt);
    });

    test('can update a single field independently', () {
      final updated = tCategory.copyWith(id: 42);
      expect(updated.id, 42);
      expect(updated.name, tCategory.name);
    });
  });
}
