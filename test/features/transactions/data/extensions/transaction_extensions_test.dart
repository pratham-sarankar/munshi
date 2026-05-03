import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/features/transactions/data/extensions/transaction_extensions.dart';
import 'package:munshi/features/transactions/domain/entities/transaction.dart';

void main() {
  final tDate = DateTime(2026, 5, 1, 10, 30);

  // ─────────────────────────────────────────────────────────────
  // TransactionRowExtension.toEntity
  // ─────────────────────────────────────────────────────────────

  group('TransactionRowExtension.toEntity', () {
    final tRow = TransactionRow(
      id: 42,
      amount: 250,
      categoryId: 3,
      date: tDate,
      note: 'Lunch',
      type: TransactionType.expense,
    );

    test('maps all fields correctly', () {
      final entity = tRow.toEntity();

      expect(entity.id, 42);
      expect(entity.amount, 250.0);
      expect(entity.categoryId, 3);
      expect(entity.date, tDate);
      expect(entity.note, 'Lunch');
      expect(entity.type, TransactionType.expense);
      expect(entity.category, isNull);
    });

    test('propagates nullable note as null', () {
      final rowWithoutNote = TransactionRow(
        id: 1,
        amount: 100,
        date: tDate,
        type: TransactionType.income,
      );

      expect(rowWithoutNote.toEntity().note, isNull);
    });

    test('propagates nullable categoryId as null', () {
      final rowWithoutCategory = TransactionRow(
        id: 1,
        amount: 100,
        date: tDate,
        type: TransactionType.income,
      );

      expect(rowWithoutCategory.toEntity().categoryId, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // TransactionExtension.toRow
  // ─────────────────────────────────────────────────────────────

  group('TransactionExtension.toRow', () {
    test('omits id when transaction id is null (new transaction)', () {
      final t = Transaction(
        amount: 150,
        categoryId: 5,
        date: tDate,
        note: 'Coffee',
        type: TransactionType.expense,
      );

      final companion = t.toRow() as TransactionsCompanion;

      expect(companion.id, const Value<int>.absent());
      expect(companion.amount.value, 150.0);
      expect(companion.categoryId.value, 5);
      expect(companion.date.value, tDate);
      expect(companion.note.value, 'Coffee');
      expect(companion.type.value, TransactionType.expense);
    });

    test(
      'includes id when transaction id is non-null (existing transaction)',
      () {
        final t = Transaction(
          id: 7,
          amount: 500,
          categoryId: 2,
          date: tDate,
          type: TransactionType.income,
        );

        final companion = t.toRow() as TransactionsCompanion;

        expect(companion.id, const Value(7));
      },
    );

    test('preserves null note as Value(null)', () {
      final t = Transaction(
        id: 1,
        amount: 100,
        date: tDate,
        type: TransactionType.income,
      );

      final companion = t.toRow() as TransactionsCompanion;

      expect(companion.note.value, isNull);
    });
  });
}
