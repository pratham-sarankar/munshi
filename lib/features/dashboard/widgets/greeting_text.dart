import 'package:flutter/material.dart';

class GreetingText extends StatelessWidget {
  const GreetingText({super.key});

  String _getTimeBasedGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning! 👋';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon! 👋';
    } else {
      return 'Good Evening! 👋';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      _getTimeBasedGreeting(),
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }
}
