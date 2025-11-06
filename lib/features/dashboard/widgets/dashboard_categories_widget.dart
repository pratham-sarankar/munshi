import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/features/dashboard/providers/dashboard_provider.dart';
import 'package:munshi/features/dashboard/widgets/category_tile.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class DashboardCategoriesWidget extends StatefulWidget {
  const DashboardCategoriesWidget({super.key});

  @override
  State<DashboardCategoriesWidget> createState() =>
      _DashboardCategoriesWidgetState();
}

class _DashboardCategoriesWidgetState extends State<DashboardCategoriesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        final colorScheme = Theme.of(context).colorScheme;

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              if (dashboardProvider.isLoading)
                _buildLoadingCategories(colorScheme)
              else if (dashboardProvider.hasCategoryData)
                _buildCategoriesList(dashboardProvider)
              else
                _buildEmptyCategoriesState(colorScheme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesList(DashboardProvider dashboardProvider) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 5),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dashboardProvider.categorySpending!.keys.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final category = dashboardProvider.categorySpending!.keys.elementAt(
          index,
        );
        final spendingAmount = dashboardProvider.getCategorySpending(category);
        final transactionCount = dashboardProvider.getCategoryTransactionCount(
          category,
        );

        return CategoryTile(
          onTap: () {},
          category: category,
          spendingAmount: spendingAmount,
          transactionCount: transactionCount,
          animationDelay: Duration(milliseconds: 400 + (index * 120)),
        );
      },
    );
  }

  Widget _buildEmptyCategoriesState(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surface.withValues(alpha: 0.8),
              ],
            ),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon container with background (matching category tile style)
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Iconsax.graph_outline,
                      size: 36,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No spending data yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add some transactions to see your spending breakdown by category',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCategories(ColorScheme colorScheme) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 5),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6, // Show 6 shimmer items
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _buildShimmerCategoryTile(colorScheme, index);
      },
    );
  }

  Widget _buildShimmerCategoryTile(ColorScheme colorScheme, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surface.withValues(alpha: 0.8),
              ],
            ),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Shimmer.fromColors(
            baseColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            highlightColor: colorScheme.surface,
            child: Row(
              children: [
                // Icon container shimmer
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                // Category name and transaction count shimmer
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 18,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 120,
                        height: 14,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Trailing arrow shimmer
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
