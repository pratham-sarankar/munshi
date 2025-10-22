import 'dart:math';

import 'package:flutter/material.dart';
import 'package:munshi/features/transactions/models/transaction_category.dart';

class CategoryTile extends StatefulWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.onTap,
    this.animationDelay = const Duration(milliseconds: 0),
    this.index = 0,
  });

  final TransactionCategory category;
  final VoidCallback onTap;
  final Duration animationDelay;
  final int index;

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 100)),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Cubic(0.165, 0.84, 0.44, 1.0), // iOS easeOutQuart
          ),
        );

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    // Start animations after delay
    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _entryController.forward();
        _scaleController.forward();
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final random = Random();
    final transaction = random.nextInt(150) + 50; // Random between 50 and 200

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(16),
              shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(16),
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
                  child: Row(
                    children: [
                      // Icon container with background
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: widget.category.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.category.color.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          widget.category.icon,
                          color: widget.category.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Category name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.category.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$transaction Transactions',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Trailing arrow with background
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
