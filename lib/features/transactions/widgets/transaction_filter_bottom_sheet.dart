import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/categories/providers/category_provider.dart';
import 'package:provider/provider.dart';
import '../../../providers/currency_provider.dart';
import '../models/transaction_filter.dart';
import '../models/transaction_type.dart';

class TransactionFilterBottomSheet extends StatefulWidget {
  final TransactionFilter initialFilter;
  final Function(TransactionFilter) onApplyFilter;

  const TransactionFilterBottomSheet({
    super.key,
    required this.initialFilter,
    required this.onApplyFilter,
  });

  @override
  State<TransactionFilterBottomSheet> createState() =>
      _TransactionFilterBottomSheetState();
}

class _TransactionFilterBottomSheetState
    extends State<TransactionFilterBottomSheet>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TransactionFilter _workingFilter;
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  final List<String> _timeframeOptions = [
    'Today',
    'This Week',
    'This Month',
    'Last Month',
    'This Year',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _workingFilter = widget.initialFilter;

    // Initialize amount controllers
    if (_workingFilter.minAmount != null) {
      _minAmountController.text = _workingFilter.minAmount!.toStringAsFixed(2);
    }
    if (_workingFilter.maxAmount != null) {
      _maxAmountController.text = _workingFilter.maxAmount!.toStringAsFixed(2);
    }

    // Add listeners to update UI when text changes
    _minAmountController.addListener(() {
      setState(() {});
    });
    _maxAmountController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Row(
              children: [
                Text(
                  'Filter & Sort',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (_workingFilter.hasActiveFilters)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _workingFilter = TransactionFilter.empty();
                        _minAmountController.clear();
                        _maxAmountController.clear();
                      });
                    },
                    child: const Text('Clear All'),
                  ),
              ],
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Date'),
              Tab(text: 'Amount'),
              Tab(text: 'Type'),
              Tab(text: 'Category'),
            ],
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDateFilterTab(colorScheme),
                _buildAmountFilterTab(colorScheme),
                _buildTypeFilterTab(colorScheme),
                _buildCategoryFilterTab(colorScheme),
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      // Parse amount filters
                      final minAmount = double.tryParse(
                        _minAmountController.text,
                      );
                      final maxAmount = double.tryParse(
                        _maxAmountController.text,
                      );

                      final finalFilter = _workingFilter.copyWith(
                        minAmount: minAmount,
                        maxAmount: maxAmount,
                        clearMinAmount: _minAmountController.text.isEmpty,
                        clearMaxAmount: _maxAmountController.text.isEmpty,
                      );

                      widget.onApplyFilter(finalFilter);
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Periods',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _timeframeOptions.map((timeframe) {
              final isSelected =
                  _workingFilter.datePeriod?.displayName ==
                  TransactionFilter.fromTimeframe(
                    timeframe,
                  ).datePeriod?.displayName;
              return FilterChip(
                label: Text(timeframe),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _workingFilter = TransactionFilter.fromTimeframe(
                        timeframe,
                      );
                    } else {
                      _workingFilter = _workingFilter.copyWith(
                        clearDatePeriod: true,
                      );
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Custom Range',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final startDate = await showDatePicker(
                      context: context,
                      initialDate:
                          _workingFilter.customStartDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (startDate != null) {
                      setState(() {
                        _workingFilter = _workingFilter.copyWith(
                          customStartDate: startDate,
                          clearDatePeriod: true, // Clear predefined period
                        );
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _workingFilter.customStartDate != null
                        ? DateFormat(
                            'd MMM y',
                          ).format(_workingFilter.customStartDate!)
                        : 'Start Date',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final endDate = await showDatePicker(
                      context: context,
                      initialDate:
                          _workingFilter.customEndDate ?? DateTime.now(),
                      firstDate:
                          _workingFilter.customStartDate ?? DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (endDate != null) {
                      setState(() {
                        _workingFilter = _workingFilter.copyWith(
                          customEndDate: endDate,
                          clearDatePeriod: true, // Clear predefined period
                        );
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _workingFilter.customEndDate != null
                        ? DateFormat(
                            'd MMM y',
                          ).format(_workingFilter.customEndDate!)
                        : 'End Date',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_workingFilter.customStartDate != null ||
              _workingFilter.customEndDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _workingFilter = _workingFilter.copyWith(
                      clearCustomStartDate: true,
                      clearCustomEndDate: true,
                    );
                  });
                },
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear Custom Range'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAmountFilterTab(ColorScheme colorScheme) {
    final currencySymbol = context
        .watch<CurrencyProvider>()
        .selectedCurrency
        .symbol;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount Range',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _minAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: 'Minimum Amount',
              prefixIcon: const Icon(Iconsax.wallet_1_outline),
              prefixText: '$currencySymbol ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _minAmountController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _minAmountController.clear();
                      },
                      icon: const Icon(Icons.clear, size: 20),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _maxAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: 'Maximum Amount',
              prefixIcon: const Icon(Iconsax.wallet_1_outline),
              prefixText: '$currencySymbol ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _maxAmountController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _maxAmountController.clear();
                      },
                      icon: const Icon(Icons.clear, size: 20),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilterTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Type',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TransactionType.values.map((type) {
              final isSelected = _workingFilter.types?.contains(type) ?? false;
              return FilterChip(
                label: Text(type.name.toUpperCase()),
                selected: isSelected,
                avatar: Icon(
                  type == TransactionType.income
                      ? Iconsax.arrow_down_outline
                      : Iconsax.arrow_up_outline,
                  size: 16,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : (type == TransactionType.income
                            ? Colors.green
                            : Colors.red),
                ),
                onSelected: (selected) {
                  setState(() {
                    final currentTypes =
                        _workingFilter.types?.toSet() ?? <TransactionType>{};
                    if (selected) {
                      currentTypes.add(type);
                    } else {
                      currentTypes.remove(type);
                    }
                    _workingFilter = _workingFilter.copyWith(
                      types: currentTypes.isEmpty ? null : currentTypes,
                      clearTypes: currentTypes.isEmpty,
                    );
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterTab(ColorScheme colorScheme) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categories',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Expense Categories
              Text(
                'Expense Categories',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categoryProvider.expenseCategories.map((category) {
                  final isSelected =
                      _workingFilter.categories?.contains(category) ?? false;
                  return FilterChip(
                    label: Text(category.name),
                    selected: isSelected,
                    avatar: Icon(
                      category.icon,
                      size: 16,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : category.color,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        final currentCategories =
                            _workingFilter.categories?.toSet() ??
                            <TransactionCategory>{};
                        if (selected) {
                          currentCategories.add(category);
                        } else {
                          currentCategories.remove(category);
                        }
                        _workingFilter = _workingFilter.copyWith(
                          categories: currentCategories.isEmpty
                              ? null
                              : currentCategories,
                          clearCategories: currentCategories.isEmpty,
                        );
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Income Categories
              Text(
                'Income Categories',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categoryProvider.incomeCategories.map((category) {
                  final isSelected =
                      _workingFilter.categories?.contains(category) ?? false;
                  return FilterChip(
                    label: Text(category.name),
                    selected: isSelected,
                    avatar: Icon(
                      category.icon,
                      size: 16,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : category.color,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        final currentCategories =
                            _workingFilter.categories?.toSet() ??
                            <TransactionCategory>{};
                        if (selected) {
                          currentCategories.add(category);
                        } else {
                          currentCategories.remove(category);
                        }
                        _workingFilter = _workingFilter.copyWith(
                          categories: currentCategories.isEmpty
                              ? null
                              : currentCategories,
                          clearCategories: currentCategories.isEmpty,
                        );
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
