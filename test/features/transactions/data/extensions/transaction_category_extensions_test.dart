import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/features/transactions/data/extensions/transaction_category_extensions.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';

void main() {
  final tCreatedAt = DateTime(2026);
  const tIcon = IconData(0xe25a, fontFamily: 'MaterialIcons');
  const tColor = Color(0xFF4CAF50);

  // ─────────────────────────────────────────────────────────────
  // TransactionCategoryRowExtensions.toEntity
  // ─────────────────────────────────────────────────────────────

  group('TransactionCategoryRowExtensions.toEntity', () {
    final tRow = TransactionCategoryRow(
      id: 1,
      name: 'Food & Dining',
      icon: tIcon,
      color: tColor,
      type: TransactionType.expense,
      isDefault: true,
      createdAt: tCreatedAt,
    );

    test('maps all fields correctly', () {
      final entity = tRow.toEntity();

      expect(entity.id, 1);
      expect(entity.name, 'Food & Dining');
      expect(entity.icon, tIcon);
      expect(entity.color, tColor);
      expect(entity.type, TransactionType.expense);
      expect(entity.isDefault, isTrue);
      expect(entity.createdAt, tCreatedAt);
    });

    test('reflects non-default category correctly', () {
      final row = TransactionCategoryRow(
        id: 10,
        name: 'Shopping',
        icon: tIcon,
        color: tColor,
        type: TransactionType.expense,
        isDefault: false,
        createdAt: tCreatedAt,
      );

      expect(row.toEntity().isDefault, isFalse);
    });

    test('reflects income type correctly', () {
      final row = TransactionCategoryRow(
        id: 5,
        name: 'Salary',
        icon: tIcon,
        color: tColor,
        type: TransactionType.income,
        isDefault: false,
        createdAt: tCreatedAt,
      );

      expect(row.toEntity().type, TransactionType.income);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // TransactionCategoryExtension.toRow
  // ─────────────────────────────────────────────────────────────

  group('TransactionCategoryExtension.toRow', () {
    final tEntity = TransactionCategory(
      id: 3,
      name: 'Transport',
      icon: tIcon,
      color: tColor,
      type: TransactionType.expense,
      isDefault: false,
      createdAt: tCreatedAt,
    );

    test('maps all fields correctly', () {
      final row = tEntity.toRow();

      expect(row.id, 3);
      expect(row.name, 'Transport');
      expect(row.icon, tIcon);
      expect(row.color, tColor);
      expect(row.type, TransactionType.expense);
      expect(row.isDefault, isFalse);
      expect(row.createdAt, tCreatedAt);
    });

    test('round-trip: toRow().toEntity() produces an equal entity', () {
      final roundTripped = tEntity.toRow().toEntity();
      expect(roundTripped, equals(tEntity));
    });
  });
}
