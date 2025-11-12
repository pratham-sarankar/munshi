import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:munshi/features/transactions/models/grouped_transactions.dart';
import 'package:munshi/features/transactions/models/transaction_with_category.dart';
import 'package:munshi/features/transactions/widgets/transaction_tile.dart';

class GroupedTransactionList extends StatefulWidget {
  const GroupedTransactionList({
    required this.groupedTransactions,
    required this.onTap,
    super.key,
    this.onDelete,
    this.onEdit,
    this.onCategoryTap,
    this.controller,
  });
  // Indent for dividers to align with ListTile title text
  // Accounts for leading widget (56dp) + horizontal padding (16dp)
  static const double _kDividerIndent = 72;

  final List<GroupedTransactions> groupedTransactions;
  final void Function(TransactionWithCategory) onTap;
  final Future<void> Function(TransactionWithCategory transaction)? onDelete;
  final Future<void> Function(TransactionWithCategory transaction)? onEdit;
  final void Function(TransactionWithCategory)? onCategoryTap;
  final ScrollController? controller;

  @override
  State<GroupedTransactionList> createState() => _GroupedTransactionListState();
}

class _GroupedTransactionListState extends State<GroupedTransactionList>
    with SingleTickerProviderStateMixin {
  late Animation<double> _fadeAnimation;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.7, curve: Curves.easeOut),
      ),
    );
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: widget.groupedTransactions.isEmpty
                ? _buildEmptyState(colorScheme)
                : SlidableAutoCloseBehavior(
                    child: ListView(
                      controller: widget.controller,
                      children: _buildGroupedTransactionWidgets(),
                    ),
                  ),
          ),
        );
      },
    );
  }

  List<Widget> _buildGroupedTransactionWidgets() {
    final widgets = <Widget>[];
    var globalIndex = 0;

    for (final (groupIndex, group) in widget.groupedTransactions.indexed) {
      // Add date divider
      widgets.add(_buildDateDivider(group.date, globalIndex));
      globalIndex++;

      // Add transactions for this date
      for (
        var transactionIndex = 0;
        transactionIndex < group.transactions.length;
        transactionIndex++
      ) {
        final transaction = group.transactions[transactionIndex];
        widgets.add(_buildAnimatedTransactionTile(transaction, globalIndex));
        globalIndex++;

        // Add separator if not the last transaction of the date
        if (transactionIndex < group.transactions.length - 1) {
          widgets.add(
            const Divider(
              height: 1,
              thickness: 1,
              indent: GroupedTransactionList._kDividerIndent,
            ),
          );
        }
      }

      // Add spacing between date groups (except for the last group)
      if (groupIndex < widget.groupedTransactions.length - 1) {
        widgets.add(const SizedBox(height: 16));
      }
    }

    return widgets;
  }

  Widget _buildDateDivider(DateTime date, int index) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    String displayText;
    if (transactionDate == today) {
      displayText = 'Today';
    } else if (transactionDate == yesterday) {
      displayText = 'Yesterday';
    } else {
      displayText = DateFormat('EEEE, MMM d, yyyy').format(date);
    }

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 80)),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final slideValue = Curves.easeOutCubic.transform(value);
        final fadeValue = Curves.easeOut.transform(value);

        return Transform.translate(
          offset: Offset(0, 30 * (1 - slideValue)),
          child: Opacity(
            opacity: fadeValue,
            child: Container(
              padding: const EdgeInsets.only(
                right: 16,
                left: 16,
                top: 10,
                bottom: 2,
              ),
              child: Row(
                children: [
                  Text(
                    displayText,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTransactionTile(
    TransactionWithCategory transaction,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(transaction.id),
      duration: Duration(milliseconds: 600 + (index * 80)),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final slideValue = Curves.easeOutCubic.transform(value);
        final fadeValue = Curves.easeOut.transform(value);
        final scaleValue = 0.95 + (0.05 * Curves.easeOutBack.transform(value));

        return Transform.scale(
          scale: scaleValue,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - slideValue)),
            child: Opacity(
              opacity: fadeValue,
              child: TransactionTile(
                transaction: transaction,
                onTap: () {
                  widget.onTap(transaction);
                },
                onDelete: widget.onDelete,
                onEdit: widget.onEdit,
                onCategoryTap: widget.onCategoryTap != null
                    ? () => widget.onCategoryTap!(transaction)
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No transactions found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
