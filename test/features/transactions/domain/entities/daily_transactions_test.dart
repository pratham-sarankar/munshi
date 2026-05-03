import 'package:flutter_test/flutter_test.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/features/transactions/domain/entities/daily_transactions.dart';
import 'package:munshi/features/transactions/domain/entities/transaction.dart';

void main() {
  final date = DateTime(2026, 5);

  final tx1 = Transaction(
    id: 1,
    amount: 100,
    date: date,
    type: TransactionType.expense,
  );
  final tx2 = Transaction(
    id: 2,
    amount: 50,
    date: date,
    type: TransactionType.income,
  );

  group('DailyTransactions equality', () {
    test('two instances with same date and transactions are equal', () {
      final a = DailyTransactions(date: date, transactions: [tx1, tx2]);
      final b = DailyTransactions(date: date, transactions: [tx1, tx2]);
      expect(a, equals(b));
    });

    test('instances differ when date differs', () {
      final a = DailyTransactions(date: date, transactions: [tx1]);
      final b = DailyTransactions(
        date: DateTime(2026, 5, 2),
        transactions: [tx1],
      );
      expect(a, isNot(equals(b)));
    });

    test('instances differ when transaction list length differs', () {
      final a = DailyTransactions(date: date, transactions: [tx1]);
      final b = DailyTransactions(date: date, transactions: [tx1, tx2]);
      expect(a, isNot(equals(b)));
    });

    test('instances differ when transaction order differs', () {
      final a = DailyTransactions(date: date, transactions: [tx1, tx2]);
      final b = DailyTransactions(date: date, transactions: [tx2, tx1]);
      expect(a, isNot(equals(b)));
    });

    test('two instances with empty transaction lists are equal', () {
      final a = DailyTransactions(date: date, transactions: const []);
      final b = DailyTransactions(date: date, transactions: const []);
      expect(a, equals(b));
    });
  });

  group('DailyTransactions.toString', () {
    test('contains the class name', () {
      final dt = DailyTransactions(date: date, transactions: [tx1]);
      expect(dt.toString(), contains('DailyTransactions'));
    });

    test('contains the date', () {
      final dt = DailyTransactions(date: date, transactions: [tx1]);
      expect(dt.toString(), contains(date.toString()));
    });
  });

  group('DailyTransactions fields', () {
    test('exposes date correctly', () {
      final dt = DailyTransactions(date: date, transactions: const []);
      expect(dt.date, equals(date));
    });

    test('exposes transactions correctly', () {
      final dt = DailyTransactions(date: date, transactions: [tx1, tx2]);
      expect(dt.transactions, equals([tx1, tx2]));
    });
  });
}
