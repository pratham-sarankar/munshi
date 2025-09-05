import 'package:flutter/material.dart';

class DashboardStatsWidget extends StatelessWidget {
  const DashboardStatsWidget(
    this.title,
    this.value,
    this.icon,
    this.accentColor, {
    super.key,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        return AspectRatio(
          aspectRatio: 1.4,
          child: Container(
            padding: EdgeInsets.all(constraints.maxWidth * 0.1),
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
              children: [
                Container(
                  padding: EdgeInsets.all(constraints.maxWidth * 0.05),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                SizedBox(height: 4),
                Expanded(
                  flex: 20,
                  child: FittedBox(
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: FittedBox(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
