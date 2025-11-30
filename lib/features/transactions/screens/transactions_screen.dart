import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/features/categories/providers/category_provider.dart';
import 'package:munshi/features/transactions/models/grouped_transactions.dart';
import 'package:munshi/features/transactions/models/transaction_filter.dart';
import 'package:munshi/features/transactions/models/transaction_with_category.dart';
import 'package:munshi/features/transactions/providers/transaction_provider.dart';
import 'package:munshi/features/transactions/screens/transaction_form_screen.dart';
import 'package:munshi/features/transactions/widgets/category_selection_bottom_sheet.dart';
import 'package:munshi/features/transactions/widgets/grouped_transaction_list.dart';
import 'package:munshi/features/transactions/widgets/transaction_details_screen.dart';
import 'package:munshi/features/transactions/widgets/transaction_filter_bottom_sheet.dart';
import 'package:munshi/providers/currency_provider.dart';
import 'package:provider/provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final transactionProvider = Provider.of<TransactionProvider>(context);
    // Watch CurrencyProvider to rebuild entire screen when currency changes.
    // This is necessary because currency formatting occurs throughout the widget tree
    // in transaction tiles, filter displays, and detail modals.
    context.watch<CurrencyProvider>();
    return StreamBuilder<List<GroupedTransactions>>(
      stream: transactionProvider.watchGroupedTransactions,
      builder: (context, snapshot) {
        final groupedTransactions = snapshot.data ?? [];
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            title: Text(
              'Transactions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            centerTitle: false,
            actions: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () =>
                        _showFilterBottomSheet(context, transactionProvider),
                    icon: const Icon(Iconsax.filter_outline),
                    tooltip: 'Filter transactions',
                  ),
                  if (transactionProvider.currentFilter.hasActiveFilters)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${transactionProvider.currentFilter.activeFilterCount}',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Active Filters Indicator
              Consumer<TransactionProvider>(
                builder: (context, provider, child) {
                  if (!provider.currentFilter.hasActiveFilters) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.filter_tick_outline,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getActiveFiltersText(provider.currentFilter),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => provider.clearFilters(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Transaction List
              Expanded(
                child: GroupedTransactionList(
                  onTap: (transaction) {
                    _showTransactionDetails(transaction, colorScheme);
                  },
                  onDelete: (transaction) async {
                    await transactionProvider.deleteTransaction(transaction);
                  },
                  onEdit: (transaction) async {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => TransactionFormScreen(
                          transaction: transaction,
                          onSubmit: transactionProvider.updateTransaction,
                        ),
                      ),
                    );
                  },
                  onCategoryTap: (transaction) {
                    _showCategorySelectionSheet(
                      transaction,
                      transactionProvider,
                    );
                  },
                  groupedTransactions: groupedTransactions,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showTransactionDetails(
    TransactionWithCategory transaction,
    ColorScheme colorScheme,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailsScreen(transaction: transaction),
    );
  }

  Future<void> _showFilterBottomSheet(
    BuildContext context,
    TransactionProvider provider,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionFilterBottomSheet(
        initialFilter: provider.currentFilter,
        onApplyFilter: (filter) {
          provider.applyFilter(filter);
        },
      ),
    );
  }

  String _getActiveFiltersText(TransactionFilter filter) {
    final activeFilters = <String>[];

    if (filter.hasAmountFilter) {
      if (filter.minAmount != null && filter.maxAmount != null) {
        activeFilters.add(
          'Amount: ₹${filter.minAmount!.toStringAsFixed(0)} - ₹${filter.maxAmount!.toStringAsFixed(0)}',
        );
      } else if (filter.minAmount != null) {
        activeFilters.add('Min: ₹${filter.minAmount!.toStringAsFixed(0)}');
      } else if (filter.maxAmount != null) {
        activeFilters.add('Max: ₹${filter.maxAmount!.toStringAsFixed(0)}');
      }
    }

    if (filter.hasTypeFilter) {
      final types = filter.types!.map((t) => t.name.toUpperCase()).join(', ');
      activeFilters.add('Type: $types');
    }

    if (filter.hasCategoryFilter) {
      final count = filter.categories!.length;
      activeFilters.add('$count ${count == 1 ? 'Category' : 'Categories'}');
    }

    if (filter.hasDateFilter) {
      if (filter.datePeriod != null) {
        activeFilters.add('Period: ${filter.datePeriod!.displayName}');
      } else if (filter.customStartDate != null ||
          filter.customEndDate != null) {
        activeFilters.add('Custom Date Range');
      }
    }

    return activeFilters.join(' • ');
  }

  Future<void> _showCategorySelectionSheet(
    TransactionWithCategory transaction,
    TransactionProvider transactionProvider,
  ) async {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    // Get categories based on transaction type
    final categories = transaction.type.name == 'expense'
        ? categoryProvider.expenseCategories
        : categoryProvider.incomeCategories;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategorySelectionBottomSheet(
        categories: categories,
        currentCategoryId: transaction.categoryId,
        transactionType: transaction.type,
        onCategorySelected: (selectedCategory) async {
          // Update the transaction with the new category
          final updatedTransaction = transaction.transaction.copyWith(
            categoryId: drift.Value(selectedCategory.id),
          );

          await transactionProvider.updateTransaction(updatedTransaction);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Category changed to ${selectedCategory.name}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }
}
