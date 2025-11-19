import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/features/dashboard/providers/dashboard_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

// Enum to define different stat types
enum DashboardStatType { transactions, biggestSpend }

class DashboardStatsWidget extends StatefulWidget {
  const DashboardStatsWidget({
    required this.statType, super.key,
    this.animationDelay = const Duration(),
  });

  final DashboardStatType statType;
  final Duration animationDelay;

  @override
  State<DashboardStatsWidget> createState() => _DashboardStatsWidgetState();
}

class _DashboardStatsWidgetState extends State<DashboardStatsWidget>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _entryController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _entryScaleAnimation;
  late Animation<Offset> _entrySlideAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.98).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: const Cubic(0.25, 0.46, 0.45, 0.94), // iOS easeOutQuad
      ),
    );

    _elevationAnimation = Tween<double>(begin: 0.05, end: 0.12).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );

    _entryScaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Cubic(0.23, 1, 0.32, 1), // iOS easeOutQuint
      ),
    );

    _entrySlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Cubic(0.23, 1, 0.32, 1),
          ),
        );

    // Start entry animation after delay
    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _entryController.forward();
      }
    });
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        final colorScheme = Theme.of(context).colorScheme;

        // Get stat-specific data
        final statData = _getStatData(dashboardProvider);

        if (dashboardProvider.isLoading || !dashboardProvider.hasData) {
          return _buildLoadingWidget(colorScheme);
        }

        return SlideTransition(
          position: _entrySlideAnimation,
          child: ScaleTransition(
            scale: _entryScaleAnimation,
            child: FadeTransition(
              opacity: _entryController,
              child: GestureDetector(
                onTapDown: (_) => _hoverController.forward(),
                onTapUp: (_) => _hoverController.reverse(),
                onTapCancel: () => _hoverController.reverse(),
                child: AnimatedBuilder(
                  animation: _hoverController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withValues(
                                alpha: _elevationAnimation.value,
                              ),
                              blurRadius: 10 + (_elevationAnimation.value * 40),
                              offset: Offset(
                                0,
                                4 + (_elevationAnimation.value * 8),
                              ),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon section with enhanced styling
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: statData.accentColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: statData.accentColor.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: Icon(
                                    statData.icon,
                                    color: statData.accentColor,
                                    size: 20,
                                  ),
                                ),
                                // Subtle indicator dot
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statData.accentColor.withValues(
                                      alpha: 0.4,
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Value with improved typography
                            Text(
                              statData.value,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.onSurface,
                                    height: 1,
                                    letterSpacing: -0.3,
                                  ),
                            ),

                            const SizedBox(height: 4),

                            // Title with enhanced styling
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    statData.title,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.7),
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.1,
                                          fontSize: 14,
                                        ),
                                  ),
                                ),
                                Icon(
                                  Icons.trending_up_rounded,
                                  size: 14,
                                  color: statData.accentColor.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to get stat-specific data
  _StatData _getStatData(DashboardProvider provider) {
    switch (widget.statType) {
      case DashboardStatType.transactions:
        return _StatData(
          title: 'Transactions',
          value: provider.formattedTransactionCount,
          icon: Iconsax.receipt_search_outline,
          accentColor: Colors.blue,
        );
      case DashboardStatType.biggestSpend:
        return _StatData(
          title: 'Biggest Spend',
          value: provider.formattedBiggestSpend,
          icon: Iconsax.card_pos_outline,
          accentColor: Colors.orange,
        );
    }
  }

  Widget _buildLoadingWidget(ColorScheme colorScheme) {
    return SlideTransition(
      position: _entrySlideAnimation,
      child: ScaleTransition(
        scale: _entryScaleAnimation,
        child: FadeTransition(
          opacity: _entryController,
          child: Container(
            padding: const EdgeInsets.all(16),
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
                  // Icon section shimmer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Value shimmer
                  Container(
                    width: double.infinity,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Title shimmer
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
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
}

// Helper class to hold stat data
class _StatData {

  _StatData({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
}
