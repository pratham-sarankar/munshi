import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/features/dashboard/providers/dashboard_provider.dart';
import 'package:munshi/features/dashboard/widgets/dashboard_categories_widget.dart';
import 'package:munshi/features/dashboard/widgets/dashboard_stats_widget.dart';
import 'package:munshi/features/dashboard/widgets/dashboard_summary_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final String _userName = "Alex Johnson";

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        final colorScheme = Theme.of(context).colorScheme;
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${dashboardProvider.getGreeting()}, ${_userName.split(' ').first}! 👋',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => dashboardProvider.changePeriod(-1),
                      icon: Icon(
                        Icons.chevron_left_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                    ),
                    Text(
                      dashboardProvider.selectedPeriod.displayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    IconButton(
                      onPressed: () => dashboardProvider.changePeriod(1),
                      icon: Icon(
                        Icons.chevron_right_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),

              // Profile Avatar
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    Iconsax.user_outline,
                    size: 18,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => dashboardProvider.refresh(),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  DashboardSummaryCard(),
                  const SizedBox(height: 15),

                  // Quick Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: DashboardStatsWidget(
                          statType: DashboardStatType.transactions,
                          animationDelay: const Duration(milliseconds: 200),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: DashboardStatsWidget(
                          statType: DashboardStatType.biggestSpend,
                          animationDelay: const Duration(milliseconds: 350),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Recent Transactions
                  DashboardCategoriesWidget(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
