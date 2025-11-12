import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/transactions/models/transaction_type.dart';

class CategorySelectionBottomSheet extends StatefulWidget {
  const CategorySelectionBottomSheet({
    required this.categories, required this.currentCategoryId, required this.transactionType, required this.onCategorySelected, super.key,
  });

  final List<TransactionCategory> categories;
  final int? currentCategoryId;
  final TransactionType transactionType;
  final Function(TransactionCategory) onCategorySelected;

  @override
  State<CategorySelectionBottomSheet> createState() =>
      _CategorySelectionBottomSheetState();
}

class _CategorySelectionBottomSheetState
    extends State<CategorySelectionBottomSheet> {
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.currentCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              children: [
                Icon(
                  Iconsax.category_outline,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select Category',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Iconsax.close_circle_outline),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Categories List
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: widget.categories.length,
              itemBuilder: (context, index) {
                final category = widget.categories[index];
                final isSelected = _selectedCategoryId == category.id;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Material(
                    color: isSelected
                        ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                        : colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = category.id;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            // Category Icon
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: category.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: category.color.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Icon(
                                category.icon,
                                color: category.color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Category Name
                            Expanded(
                              child: Text(
                                category.name,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: colorScheme.onSurface,
                                    ),
                              ),
                            ),
                            // Selection Indicator
                            if (isSelected)
                              Icon(
                                Iconsax.tick_circle_bold,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
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
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _selectedCategoryId == null
                        ? null
                        : () {
                            final selectedCategory = widget.categories
                                .firstWhere((c) => c.id == _selectedCategoryId);
                            widget.onCategorySelected(selectedCategory);
                            Navigator.pop(context);
                          },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Save Category'),
                  ),
                ),
              ],
            ),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
