import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:munshi/core/extensions/currency_extensions.dart';
import 'package:munshi/features/transactions/models/transaction_type.dart';
import 'package:munshi/features/transactions/models/transaction_with_category.dart';

class TransactionTile extends StatefulWidget {
  const TransactionTile({
    required this.onTap, required this.transaction, super.key,
    this.onDelete,
    this.onEdit,
    this.onCategoryTap,
  });
  final VoidCallback onTap;
  final TransactionWithCategory transaction;
  final Future<void> Function(TransactionWithCategory transaction)? onDelete;
  final Future<void> Function(TransactionWithCategory transaction)? onEdit;
  final VoidCallback? onCategoryTap;

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile>
    with SingleTickerProviderStateMixin {
  late final SlidableController controller;

  @override
  void initState() {
    super.initState();
    controller = SlidableController(this);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Slidable(
      controller: controller,
      key: ValueKey(widget.transaction.id),
      groupTag: 'transactions',
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        dismissible: DismissiblePane(
          confirmDismiss: _showDeleteConfirmationDialog,
          closeOnCancel: true,
          onDismissed: _deleteTransaction,
        ),
        children: [
          SlidableAction(
            onPressed: (context) => _editTransaction(),
            backgroundColor: colorScheme.inverseSurface,
            foregroundColor: colorScheme.onInverseSurface,
            icon: Iconsax.edit_outline,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) async {
              final confirm = await _showDeleteConfirmationDialog();
              if (confirm) {
                _deleteTransaction();
              }
            },
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
            icon: Iconsax.trash_outline,
            label: 'Delete',
          ),
        ],
      ),

      child: ListTile(
        dense: false,
        enableFeedback: true,
        onTap: widget.onTap,
        leading: InkWell(
          onTap: widget.onCategoryTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.transaction.categoryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.transaction.categoryIcon,
              color: widget.transaction.categoryColor,
              size: 22,
            ),
          ),
        ),
        title: Text(widget.transaction.categoryName),
        subtitle: Text(
          DateFormat('d MMM • h:mm a').format(widget.transaction.date),
        ),
        trailing: Text(
          widget.transaction.amount.toTransactionCurrency(
            isExpense: widget.transaction.type == TransactionType.expense,
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: widget.transaction.type == TransactionType.expense
                ? colorScheme.error
                : colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Future<void> _deleteTransaction() async {
    if (widget.onDelete != null) {
      await widget.onDelete!(widget.transaction);
    }
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
    }
  }

  void _editTransaction() {
    if (widget.onEdit != null) {
      widget.onEdit!(widget.transaction);
    }
    // If onEdit is null, do nothing - as the developer intended
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // cancel
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true), // confirm
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
