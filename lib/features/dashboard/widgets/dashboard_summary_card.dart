import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/core/models/period_type.dart';
import 'package:munshi/features/dashboard/providers/dashboard_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class DashboardSummaryCard extends StatefulWidget {
  const DashboardSummaryCard({super.key});

  @override
  State<DashboardSummaryCard> createState() => _DashboardSummaryCardState();
}

class _DashboardSummaryCardState extends State<DashboardSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _summaryCardAnimationController;
  late Animation<double> _summaryCardAnimation;
  late Animation<Offset> _summaryCardSlideAnimation;

  @override
  void initState() {
    // Summary card animations with iOS-style spring curves
    _summaryCardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _summaryCardAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _summaryCardAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _summaryCardSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _summaryCardAnimationController,
            curve: const Cubic(0.175, 0.885, 0.32, 1.0), // iOS easeOutQuart
          ),
        );
    _summaryCardAnimationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _summaryCardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        final colorScheme = Theme.of(context).colorScheme;

        if (dashboardProvider.isLoading || !dashboardProvider.hasData) {
          return _buildLoadingCard(colorScheme);
        }

        return SlideTransition(
          position: _summaryCardSlideAnimation,
          child: ScaleTransition(
            scale: _summaryCardAnimation,
            child: FadeTransition(
              opacity: _summaryCardAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with month badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Iconsax.wallet_3_outline,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _getPeriodTitle(
                                dashboardProvider.selectedPeriod.type,
                              ),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            dashboardProvider.selectedPeriod.displayName,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Main spending amount
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dashboardProvider.formattedTotalSpent,
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      height: 0.9,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getPeriodDescription(
                                  dashboardProvider.selectedPeriod.type,
                                ),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Stats row - matching DashboardStatsWidget style
                    Row(
                      children: [
                        // Income
                        Expanded(
                          child: _buildStatItem(
                            context,
                            icon: Iconsax.money_recive_outline,
                            iconColor: Colors.green,
                            label: 'Income',
                            value: dashboardProvider.formattedTotalIncome,
                            valueColor: colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Balance
                        Expanded(
                          child: _buildStatItem(
                            context,
                            icon: dashboardProvider.balance >= 0
                                ? Iconsax.arrow_up_3_outline
                                : Iconsax.arrow_down_outline,
                            iconColor: dashboardProvider.balance >= 0
                                ? Colors.blue
                                : Colors.orange,
                            label: 'Balance',
                            value: dashboardProvider.formatCurrency(
                              dashboardProvider.balance.abs(),
                            ),
                            valueColor: colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Daily Average
                        Expanded(
                          child: _buildStatItem(
                            context,
                            icon: Iconsax.calendar_outline,
                            iconColor: Colors.purple,
                            label: 'Daily Avg',
                            value: dashboardProvider.formattedAvgDaily,
                            valueColor: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodTitle(PeriodType type) {
    switch (type) {
      case PeriodType.daily:
        return 'Daily Overview';
      case PeriodType.weekly:
        return 'Weekly Overview';
      case PeriodType.monthly:
        return 'Monthly Overview';
      case PeriodType.yearly:
        return 'Yearly Overview';
    }
  }

  String _getPeriodDescription(PeriodType type) {
    switch (type) {
      case PeriodType.daily:
        return 'Total spent today';
      case PeriodType.weekly:
        return 'Total spent this week';
      case PeriodType.monthly:
        return 'Total spent this month';
      case PeriodType.yearly:
        return 'Total spent this year';
    }
  }

  Widget _buildLoadingCard(ColorScheme colorScheme) {
    return SlideTransition(
      position: _summaryCardSlideAnimation,
      child: ScaleTransition(
        scale: _summaryCardAnimation,
        child: FadeTransition(
          opacity: _summaryCardAnimation,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Shimmer.fromColors(
              baseColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              highlightColor: colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header shimmer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 120,
                            height: 20,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 80,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Main amount shimmer
                  Container(
                    width: 200,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 140,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stats row shimmer
                  Row(
                    children: [
                      Expanded(child: _buildShimmerStatItem(colorScheme)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildShimmerStatItem(colorScheme)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildShimmerStatItem(colorScheme)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerStatItem(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 50,
            height: 14,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 12,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}
