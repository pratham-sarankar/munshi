import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/categories/providers/category_provider.dart';
import 'package:munshi/features/categories/widgets/add_edit_category_dialog.dart';
import 'package:munshi/features/categories/widgets/category_list_tile.dart';
import 'package:munshi/features/transactions/models/transaction_type.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showAddCategoryDialog(TransactionType type) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddEditCategoryDialog(type: type),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category added successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showEditCategoryDialog(
    TransactionCategory category,
    TransactionType type,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AddEditCategoryDialog(type: type, category: category),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteCategory(int categoryId, String categoryName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "$categoryName"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<CategoryProvider>().deleteCategory(categoryId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category deleted successfully'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting category: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Iconsax.minus_cirlce_outline), text: 'Expense'),
            Tab(icon: Icon(Iconsax.add_circle_outline), text: 'Income'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_category_fab',
        onPressed: () {
          final type = _tabController.index == 0
              ? TransactionType.expense
              : TransactionType.income;
          _showAddCategoryDialog(type);
        },
        icon: const Icon(Iconsax.add_outline),
        label: const Text('Add Category'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Expense categories
          _CategoryList(
            type: TransactionType.expense,
            onEdit: (category) =>
                _showEditCategoryDialog(category, TransactionType.expense),
            onDelete: (category) => _deleteCategory(category.id, category.name),
          ),
          // Income categories
          _CategoryList(
            type: TransactionType.income,
            onEdit: (category) =>
                _showEditCategoryDialog(category, TransactionType.income),
            onDelete: (category) => _deleteCategory(category.id, category.name),
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.type,
    required this.onEdit,
    required this.onDelete,
  });

  final TransactionType type;
  final Function(dynamic category) onEdit;
  final Function(dynamic category) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = type == TransactionType.expense
            ? provider.expenseCategories
            : provider.incomeCategories;

        if (categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.category_outline,
                  size: 64,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No categories yet',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the button below to add your first category',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryListTile(
              category: category,
              onTap: () => onEdit(category),
              onDelete: () => onDelete(category),
            );
          },
        );
      },
    );
  }
}
