import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/features/transactions/domain/entities/transaction.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';
import 'package:munshi/features/transactions/presentation/widgets/transaction_tile.dart';

// ── helpers ───────────────────────────────────────────────────

/// Wraps [widget] in the minimum scaffold required for Material widgets and
/// the [Slidable] package's group-tag mechanism.
Widget wrap(Widget widget) {
  return MaterialApp(
    home: Scaffold(
      body: SlidableAutoCloseBehavior(
        child: ListView(children: [widget]),
      ),
    ),
  );
}

// Shared fixtures.
final _tDate = DateTime(2026, 5, 1, 14, 30);

final _tCategory = TransactionCategory(
  id: 1,
  name: 'Food & Dining',
  icon: Icons.restaurant,
  color: Colors.green,
  type: TransactionType.expense,
  isDefault: true,
  createdAt: DateTime(2026),
);

final _tExpense = Transaction(
  id: 1,
  amount: 250,
  categoryId: 1,
  date: _tDate,
  note: 'Lunch',
  type: TransactionType.expense,
  category: _tCategory,
);

final _tIncome = Transaction(
  id: 2,
  amount: 5000,
  date: _tDate,
  note: 'Salary',
  type: TransactionType.income,
);

// ─────────────────────────────────────────────────────────────
// TransactionTile
// ─────────────────────────────────────────────────────────────

void main() {
  group('TransactionTile', () {
    // ── title text ─────────────────────────────────────────

    group('title display', () {
      testWidgets('shows note when available', (tester) async {
        await tester.pumpWidget(
          wrap(
            TransactionTile(
              transaction: _tExpense,
              onTap: () {},
            ),
          ),
        );

        expect(find.text('Lunch'), findsOneWidget);
      });

      testWidgets('falls back to category name when note is null', (
        tester,
      ) async {
        final t = Transaction(
          id: 3,
          amount: 100,
          categoryId: 1,
          date: _tDate,
          type: TransactionType.expense,
          category: _tCategory,
        );

        await tester.pumpWidget(
          wrap(TransactionTile(transaction: t, onTap: () {})),
        );

        expect(find.text('Food & Dining'), findsOneWidget);
      });

      testWidgets(
        'falls back to "Uncategorized" when note and category are null',
        (tester) async {
          final t = Transaction(
            id: 4,
            amount: 50,
            date: _tDate,
            type: TransactionType.expense,
          );

          await tester.pumpWidget(
            wrap(TransactionTile(transaction: t, onTap: () {})),
          );

          expect(find.text('Uncategorized'), findsOneWidget);
        },
      );
    });

    // ── amount display ─────────────────────────────────────

    group('amount display', () {
      testWidgets('expense amount contains minus sign', (tester) async {
        await tester.pumpWidget(
          wrap(TransactionTile(transaction: _tExpense, onTap: () {})),
        );

        final amountWidget = tester.widget<Text>(
          find.descendant(
            of: find.byType(ListTile),
            matching: find.textContaining('250'),
          ),
        );
        expect(amountWidget.data, contains('-'));
      });

      testWidgets('income amount does not contain minus sign', (tester) async {
        await tester.pumpWidget(
          wrap(TransactionTile(transaction: _tIncome, onTap: () {})),
        );

        final amountWidget = tester.widget<Text>(
          find.descendant(
            of: find.byType(ListTile),
            matching: find.textContaining('5,000'),
          ),
        );
        expect(amountWidget.data, isNot(contains('-')));
      });
    });

    // ── category icon ──────────────────────────────────────

    group('category icon', () {
      testWidgets('uses category icon when category is present', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrap(TransactionTile(transaction: _tExpense, onTap: () {})),
        );

        expect(
          find.byWidgetPredicate(
            (w) => w is Icon && w.icon == Icons.restaurant,
          ),
          findsOneWidget,
        );
      });

      testWidgets('uses fallback Icons.category when no category', (
        tester,
      ) async {
        final t = Transaction(
          id: 5,
          amount: 10,
          date: _tDate,
          note: 'misc',
          type: TransactionType.expense,
        );

        await tester.pumpWidget(
          wrap(TransactionTile(transaction: t, onTap: () {})),
        );

        expect(
          find.byWidgetPredicate(
            (w) => w is Icon && w.icon == Icons.category,
          ),
          findsOneWidget,
        );
      });
    });

    // ── callbacks ──────────────────────────────────────────

    group('callbacks', () {
      testWidgets('onTap is called when the tile is tapped', (tester) async {
        var tapped = false;

        await tester.pumpWidget(
          wrap(
            TransactionTile(
              transaction: _tExpense,
              onTap: () => tapped = true,
            ),
          ),
        );

        await tester.tap(find.byType(ListTile));
        expect(tapped, isTrue);
      });

      testWidgets('onCategoryTap is called when leading icon is tapped', (
        tester,
      ) async {
        var categoryTapped = false;

        await tester.pumpWidget(
          wrap(
            TransactionTile(
              transaction: _tExpense,
              onTap: () {},
              onCategoryTap: () => categoryTapped = true,
            ),
          ),
        );

        // The leading InkWell has a unique borderRadius of 12. Directly
        // invoke its onTap to avoid gesture-arena conflicts with Slidable.
        final leadingInkWell = tester.widget<InkWell>(
          find.byWidgetPredicate(
            (w) => w is InkWell && w.borderRadius == BorderRadius.circular(12),
          ),
        );
        leadingInkWell.onTap!();
        expect(categoryTapped, isTrue);
      });
    });

    // ── date subtitle ──────────────────────────────────────

    testWidgets('subtitle shows formatted date and time', (tester) async {
      await tester.pumpWidget(
        wrap(TransactionTile(transaction: _tExpense, onTap: () {})),
      );

      // "1 May • 2:30 pm" — exact locale output, but must contain the day.
      expect(find.textContaining('1 May'), findsOneWidget);
    });
  });
}
