import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/features/transactions/domain/entities/daily_transactions.dart';
import 'package:munshi/features/transactions/domain/entities/transaction.dart';
import 'package:munshi/features/transactions/presentation/widgets/grouped_transaction_list.dart';
import 'package:munshi/features/transactions/presentation/widgets/transaction_tile.dart';

// ── helpers ───────────────────────────────────────────────────

Widget wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

final _tDate = DateTime(2026, 5, 1, 10);
final DateTime _yesterday = DateTime.now().subtract(const Duration(days: 1));
final _today = DateTime.now();

Transaction makeTransaction({
  required int id,
  required DateTime date,
  double amount = 100.0,
  String? note,
  TransactionType type = TransactionType.expense,
}) {
  return Transaction(
    id: id,
    amount: amount,
    date: date,
    note: note,
    type: type,
  );
}

// ─────────────────────────────────────────────────────────────
// GroupedTransactionList
// ─────────────────────────────────────────────────────────────

void main() {
  group('GroupedTransactionList', () {
    // ── empty state ────────────────────────────────────────

    group('empty state', () {
      testWidgets('shows "No transactions found" when list is empty', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrap(
            GroupedTransactionList(
              groupedTransactions: const [],
              onTap: (_) {},
            ),
          ),
        );
        // Let entry animations complete.
        await tester.pumpAndSettle();

        expect(find.text('No transactions found'), findsOneWidget);
      });

      testWidgets('shows hint text in empty state', (tester) async {
        await tester.pumpWidget(
          wrap(
            GroupedTransactionList(
              groupedTransactions: const [],
              onTap: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Try adjusting your filters or search terms'),
          findsOneWidget,
        );
      });

      testWidgets('does not show empty state while isLoadingMore is true', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrap(
            GroupedTransactionList(
              groupedTransactions: const [],
              onTap: (_) {},
              isLoadingMore: true,
            ),
          ),
        );
        // pump() with a duration instead of pumpAndSettle() — the
        // CircularProgressIndicator has an infinite animation that never settles.
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('No transactions found'), findsNothing);
      });
    });

    // ── loading indicator ──────────────────────────────────

    group('loading indicator', () {
      testWidgets(
        'shows CircularProgressIndicator when isLoadingMore is true',
        (tester) async {
          final group = DailyTransactions(
            date: _tDate,
            transactions: [makeTransaction(id: 1, date: _tDate)],
          );

          await tester.pumpWidget(
            wrap(
              GroupedTransactionList(
                groupedTransactions: [group],
                onTap: (_) {},
                isLoadingMore: true,
              ),
            ),
          );
          await tester.pump(); // start animations

          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        },
      );

      testWidgets('hides loading indicator when isLoadingMore is false', (
        tester,
      ) async {
        final group = DailyTransactions(
          date: _tDate,
          transactions: [makeTransaction(id: 1, date: _tDate)],
        );

        await tester.pumpWidget(
          wrap(
            GroupedTransactionList(
              groupedTransactions: [group],
              onTap: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    // ── transaction tiles ──────────────────────────────────

    group('transaction tiles', () {
      testWidgets('renders one TransactionTile per transaction', (
        tester,
      ) async {
        final group = DailyTransactions(
          date: _tDate,
          transactions: [
            makeTransaction(id: 1, date: _tDate, note: 'Lunch'),
            makeTransaction(id: 2, date: _tDate, note: 'Coffee'),
          ],
        );

        await tester.pumpWidget(
          wrap(
            GroupedTransactionList(
              groupedTransactions: [group],
              onTap: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TransactionTile), findsNWidgets(2));
        expect(find.text('Lunch'), findsOneWidget);
        expect(find.text('Coffee'), findsOneWidget);
      });

      testWidgets('renders tiles across multiple date groups', (tester) async {
        final groups = [
          DailyTransactions(
            date: _tDate,
            transactions: [makeTransaction(id: 1, date: _tDate, note: 'Older')],
          ),
          DailyTransactions(
            date: _today,
            transactions: [makeTransaction(id: 2, date: _today, note: 'Newer')],
          ),
        ];

        await tester.pumpWidget(
          wrap(
            GroupedTransactionList(
              groupedTransactions: groups,
              onTap: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TransactionTile), findsNWidgets(2));
      });
    });

    // ── date headers ───────────────────────────────────────

    group('date headers', () {
      testWidgets('shows "Today" header for today\'s transactions', (
        tester,
      ) async {
        final group = DailyTransactions(
          date: _today,
          transactions: [makeTransaction(id: 1, date: _today)],
        );

        await tester.pumpWidget(
          wrap(
            GroupedTransactionList(
              groupedTransactions: [group],
              onTap: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Today'), findsOneWidget);
      });

      testWidgets('shows "Yesterday" header for yesterday\'s transactions', (
        tester,
      ) async {
        final group = DailyTransactions(
          date: _yesterday,
          transactions: [makeTransaction(id: 1, date: _yesterday)],
        );

        await tester.pumpWidget(
          wrap(
            GroupedTransactionList(
              groupedTransactions: [group],
              onTap: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Yesterday'), findsOneWidget);
      });

      testWidgets('shows formatted date header for older transactions', (
        tester,
      ) async {
        // Use a fixed old date that is never "today" or "yesterday".
        final oldDate = DateTime(2026, 1, 15);
        final group = DailyTransactions(
          date: oldDate,
          transactions: [makeTransaction(id: 1, date: oldDate)],
        );

        await tester.pumpWidget(
          wrap(
            GroupedTransactionList(
              groupedTransactions: [group],
              onTap: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // "Thursday, Jan 15, 2026" — just assert the year appears.
        expect(find.textContaining('2026'), findsOneWidget);
      });
    });

    // ── onTap callback ─────────────────────────────────────

    group('onTap callback', () {
      testWidgets('calls onTap with the tapped transaction', (tester) async {
        Transaction? tapped;
        final tx = makeTransaction(id: 1, date: _tDate, note: 'Groceries');
        final group = DailyTransactions(date: _tDate, transactions: [tx]);

        await tester.pumpWidget(
          wrap(
            GroupedTransactionList(
              groupedTransactions: [group],
              onTap: (t) => tapped = t,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ListTile));
        expect(tapped, equals(tx));
      });
    });

    // ── Slidable wiring ────────────────────────────────────

    testWidgets('each tile is wrapped in a Slidable', (tester) async {
      final group = DailyTransactions(
        date: _tDate,
        transactions: [makeTransaction(id: 1, date: _tDate)],
      );

      await tester.pumpWidget(
        wrap(
          GroupedTransactionList(
            groupedTransactions: [group],
            onTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Slidable), findsOneWidget);
    });
  });
}
