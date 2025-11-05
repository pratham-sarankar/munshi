import 'package:flutter/material.dart';
import 'package:munshi/core/models/date_period.dart';

class PeriodSelectorBottomSheet extends StatelessWidget {
  final PeriodType currentPeriodType;
  final ValueChanged<PeriodType> onPeriodTypeChanged;

  const PeriodSelectorBottomSheet({
    super.key,
    required this.currentPeriodType,
    required this.onPeriodTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Select Report Period',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how you want to view your financial data',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Period options
          _buildPeriodOption(
            context,
            PeriodType.daily,
            Icons.today_rounded,
            'Daily',
            'View daily spending and income',
            currentPeriodType == PeriodType.daily,
          ),
          const SizedBox(height: 12),
          _buildPeriodOption(
            context,
            PeriodType.weekly,
            Icons.view_week_rounded,
            'Weekly',
            'View weekly spending patterns',
            currentPeriodType == PeriodType.weekly,
          ),
          const SizedBox(height: 12),
          _buildPeriodOption(
            context,
            PeriodType.monthly,
            Icons.calendar_month_rounded,
            'Monthly',
            'View monthly financial overview',
            currentPeriodType == PeriodType.monthly,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPeriodOption(
    BuildContext context,
    PeriodType periodType,
    IconData icon,
    String title,
    String subtitle,
    bool isSelected,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onPeriodTypeChanged(periodType);
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.08)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              // Icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.2)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: colorScheme.onPrimary,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> show(
    BuildContext context,
    PeriodType currentPeriodType,
    ValueChanged<PeriodType> onPeriodTypeChanged,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PeriodSelectorBottomSheet(
        currentPeriodType: currentPeriodType,
        onPeriodTypeChanged: onPeriodTypeChanged,
      ),
    );
  }
}
