import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/features/auth/services/auth_service.dart';
import 'package:munshi/features/dashboard/providers/dashboard_provider.dart';
import 'package:munshi/features/dashboard/widgets/dashboard_categories_widget.dart';
import 'package:munshi/features/dashboard/widgets/dashboard_stats_widget.dart';
import 'package:munshi/features/dashboard/widgets/dashboard_summary_card.dart';
import 'package:munshi/features/dashboard/widgets/greeting_text.dart';
import 'package:munshi/features/dashboard/widgets/period_selector_bottom_sheet.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                const GreetingText(),
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
                    GestureDetector(
                      onTap: () => PeriodSelectorBottomSheet.show(
                        context,
                        dashboardProvider.currentPeriodType,
                        (newType) =>
                            dashboardProvider.changePeriodType(newType),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          dashboardProvider.selectedPeriod.displayName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
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
              Consumer<AuthService>(
                builder: (context, value, child) {
                  return CircleAvatar(
                    child: value.currentUser == null
                        ? Image.asset('assets/images/profile.png')
                        : ClipOval(
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/images/profile.png',
                              image: value.currentUser!.picture,
                              imageErrorBuilder: (context, error, stackTrace) {
                                log('Failed to load profile image: $error');
                                return const Icon(Iconsax.user_bold, size: 20);
                              },
                            ),
                          ),
                  );
                },
              ),
            ],
            actionsPadding: const EdgeInsets.only(right: 15),
          ),
          body: RefreshIndicator(
            onRefresh: () => dashboardProvider.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
