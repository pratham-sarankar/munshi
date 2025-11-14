import 'dart:async';

import 'package:flutter/material.dart';
import 'package:munshi/features/auth/services/auth_service.dart';
import 'package:munshi/features/auth/widgets/cached_profile_avatar.dart';
import 'package:munshi/features/dashboard/providers/dashboard_provider.dart';
import 'package:munshi/features/dashboard/widgets/dashboard_categories_widget.dart';
import 'package:munshi/features/dashboard/widgets/dashboard_stats_widget.dart';
import 'package:munshi/features/dashboard/widgets/dashboard_summary_card.dart';
import 'package:munshi/features/dashboard/widgets/greeting_text.dart';
import 'package:munshi/features/dashboard/widgets/period_selector_bottom_sheet.dart';
import 'package:munshi/features/transactions/providers/transaction_provider.dart';
import 'package:munshi/features/transactions/models/transaction_with_category.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TransactionProvider? _transactionProvider;
  DashboardProvider? _dashboardProvider;
  StreamSubscription<List<TransactionWithCategory>>? _txSubscription;
  int? _prevTransactionCount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
      _transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

      // Listen to the provider's transaction stream and refresh the dashboard
      // only when a new transaction is added (i.e., count increases).
      _txSubscription = _transactionProvider
          ?.watchTransactions
          .listen((txList) {
        if (!mounted) return;
        final newCount = txList.length;
        if (_prevTransactionCount == null) {
          _prevTransactionCount = newCount;
          return;
        }

        if (newCount > _prevTransactionCount!) {
          _dashboardProvider?.refresh();
        }

        _prevTransactionCount = newCount;
      });
    });
  }

  @override
  void dispose() {
    _txSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DashboardProvider, TransactionProvider>(
      builder: (context, dashboardProvider, transactionProvider, child) {
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
                      onPressed: dashboardProvider.isCurrentPeriod
                          ? null
                          : () => dashboardProvider.changePeriod(1),
                      icon: Icon(
                        Icons.chevron_right_rounded,
                        color: dashboardProvider.isCurrentPeriod
                            ? colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.3,
                              )
                            : colorScheme.onSurfaceVariant,
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
                  return CachedProfileAvatar(
                    imageUrl: value.currentUser?.picture,
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
                  const DashboardSummaryCard(),
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
                  const DashboardCategoriesWidget(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
