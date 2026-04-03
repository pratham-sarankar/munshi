import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/features/categories/providers/category_provider.dart';
import 'package:munshi/features/transactions/bloc/transaction_bloc.dart';
import 'package:munshi/features/transactions/bloc/transaction_event.dart';
import 'package:munshi/features/transactions/bloc/transaction_state.dart';
import 'package:munshi/features/transactions/models/transaction_filter.dart';
import 'package:munshi/features/transactions/models/transaction_with_category.dart';
import 'package:munshi/features/transactions/screens/transaction_form_screen.dart';
import 'package:munshi/features/transactions/widgets/category_selection_bottom_sheet.dart';
import 'package:munshi/features/transactions/widgets/grouped_transaction_list.dart';
import 'package:munshi/features/transactions/widgets/transaction_details_screen.dart';
import 'package:munshi/features/transactions/widgets/transaction_filter_bottom_sheet.dart';
import 'package:munshi/providers/currency_provider.dart';
import 'package:provider/provider.dart';

/// Screen that displays the paginated, filterable transaction history.
///
/// Uses [TransactionBloc] for all state management and dispatches events for
/// user interactions such as filtering, editing, and deleting transactions.
class TransactionsScreen extends StatefulWidget {
  /// Creates a [TransactionsScreen].
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    // Trigger load when within 200px of the bottom
    if (position.pixels >= position.maxScrollExtent - 200) {
      final bloc = context.read<TransactionBloc>();
      final state = bloc.state;
      if (!state.isLoadingMore && state.hasMore) {
        bloc.add(const TransactionNextPageRequested());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Watch CurrencyProvider to rebuild entire screen when currency changes.
    // This is necessary because currency formatting occurs throughout the widget tree
    // in transaction tiles, filter displays, and detail modals.
    context.watch<CurrencyProvider>();
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final groupedTransactions = state.groupedTransactions;
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
                        _showFilterBottomSheet(context, state),
                    icon: const Icon(Iconsax.filter_outline),
                    tooltip: 'Filter transactions',
                  ),
                  if (state.currentFilter.hasActiveFilters)
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
                          '${state.currentFilter.activeFilterCount}',
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
              if (state.currentFilter.hasActiveFilters)
                Container(
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
                          _getActiveFiltersText(state.currentFilter),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context
                            .read<TransactionBloc>()
                            .add(const TransactionFilterCleared()),
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
                ),

              // Transaction List
              Expanded(
                child: GroupedTransactionList(
                  controller: _scrollController,
                  onTap: (transaction) {
                    _showTransactionDetails(transaction, colorScheme);
                  },
                  onDelete: (transaction) async {
                    context
                        .read<TransactionBloc>()
                        .add(TransactionDeleted(transaction));
                  },
                  onEdit: (transaction) async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => TransactionFormScreen(
                          transaction: transaction,
                          onSubmit: (updated) => context
                              .read<TransactionBloc>()
                              .add(TransactionUpdated(updated)),
                        ),
                      ),
                    );
                  },
                  onCategoryTap: (transaction) {
                    _showCategorySelectionSheet(transaction);
                  },
                  groupedTransactions: groupedTransactions,
                  isLoadingMore: state.isLoadingMore,
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
    TransactionState state,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionFilterBottomSheet(
        initialFilter: state.currentFilter,
        onApplyFilter: (filter) {
          context
              .read<TransactionBloc>()
              .add(TransactionFilterApplied(filter));
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
        onCategorySelected: (selectedCategory) {
          // Update the transaction with the new category
          final updatedTransaction = transaction.transaction.copyWith(
            categoryId: drift.Value(selectedCategory.id),
          );

          context
              .read<TransactionBloc>()
              .add(TransactionUpdated(updatedTransaction));

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

