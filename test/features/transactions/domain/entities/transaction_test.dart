import 'package:flutter_test/flutter_test.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/features/transactions/domain/entities/transaction.dart';

void main() {
  final baseDate = DateTime(2026, 1, 15);

  final tTransaction = Transaction(
    id: 1,
    amount: 250,
    date: baseDate,
    type: TransactionType.expense,
    categoryId: 3,
    note: 'Grocery run',
  );

  group('Transaction equality', () {
    test('two instances with identical props are equal', () {
      final other = Transaction(
        id: 1,
        amount: 250,
        date: baseDate,
        type: TransactionType.expense,
        categoryId: 3,
        note: 'Grocery run',
      );
      expect(tTransaction, equals(other));
    });

    test('instances differ when id differs', () {
      expect(tTransaction, isNot(equals(tTransaction.copyWith(id: 2))));
    });

    test('instances differ when amount differs', () {
      expect(tTransaction, isNot(equals(tTransaction.copyWith(amount: 999))));
    });

    test('instances differ when type differs', () {
      expect(
        tTransaction,
        isNot(equals(tTransaction.copyWith(type: TransactionType.income))),
      );
    });

    test('instances differ when note differs', () {
      expect(
        tTransaction,
        isNot(equals(tTransaction.copyWith(note: 'Different note'))),
      );
    });

    test('hashCode is consistent for equal instances', () {
      final other = Transaction(
        id: 1,
        amount: 250,
        date: baseDate,
        type: TransactionType.expense,
        categoryId: 3,
        note: 'Grocery run',
      );
      expect(tTransaction.hashCode, equals(other.hashCode));
    });
  });

  group('Transaction.copyWith', () {
    test('returns an equal instance when no overrides are provided', () {
      expect(tTransaction.copyWith(), equals(tTransaction));
    });

    test('overrides only the supplied fields', () {
      final updated = tTransaction.copyWith(amount: 500, note: 'Updated');

      expect(updated.amount, 500);
      expect(updated.note, 'Updated');
      // unchanged fields stay the same
      expect(updated.id, tTransaction.id);
      expect(updated.date, tTransaction.date);
      expect(updated.type, tTransaction.type);
      expect(updated.categoryId, tTransaction.categoryId);
    });

    test('preserves nullable fields as null when not overridden', () {
      final noNote = Transaction(
        id: 2,
        amount: 100,
        date: baseDate,
        type: TransactionType.income,
      );

      final copy = noNote.copyWith(amount: 200);

      expect(copy.note, isNull);
      expect(copy.category, isNull);
      expect(copy.categoryId, isNull);
    });
  });

  group('Transaction optional fields', () {
    test('id defaults to null when not provided', () {
      final tx = Transaction(
        amount: 50,
        date: baseDate,
        type: TransactionType.income,
      );
      expect(tx.id, isNull);
    });

    test('note defaults to null when not provided', () {
      final tx = Transaction(
        amount: 50,
        date: baseDate,
        type: TransactionType.income,
      );
      expect(tx.note, isNull);
    });

    test('category defaults to null when not provided', () {
      expect(tTransaction.category, isNull);
    });

    test('categoryId defaults to null when not provided', () {
      final tx = Transaction(
        amount: 50,
        date: baseDate,
        type: TransactionType.income,
      );
      expect(tx.categoryId, isNull);
    });
  });
}
