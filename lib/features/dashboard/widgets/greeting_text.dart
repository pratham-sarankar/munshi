import 'package:flutter/material.dart';
import 'package:munshi/features/auth/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class GreetingText extends StatelessWidget {
  const GreetingText({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;
        if (user == null) {
          return Shimmer.fromColors(
            baseColor: colorScheme.surfaceContainerHighest,
            highlightColor: colorScheme.surfaceContainerHigh,
            child: Container(
              width: 120,
              height: 14,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }
        final name = user.givenName;
        return Text(
          'Hello! $name 👋',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        );
      },
    );
  }
}
