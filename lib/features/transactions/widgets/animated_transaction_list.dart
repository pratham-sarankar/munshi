import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/transactions/widgets/transaction_tile.dart';

class AnimatedTransactionList extends StatefulWidget {
  const AnimatedTransactionList({
    super.key,
    required this.transactions,
    required this.onTap,
    this.controller,
  });
  final List<Transaction> transactions;
  final Function(Transaction) onTap;
  final ScrollController? controller;
  @override
  State<AnimatedTransactionList> createState() =>
      _AnimatedTransactionListState();
}

class _AnimatedTransactionListState extends State<AnimatedTransactionList>
    with SingleTickerProviderStateMixin {
  late Animation<double> _fadeAnimation;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: widget.transactions.isEmpty
                ? _buildEmptyState(colorScheme)
                : SlidableAutoCloseBehavior(
                    child: ListView.separated(
                      controller: widget.controller,
                      shrinkWrap: false,
                      itemCount: widget.transactions.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, thickness: 1),
                      itemBuilder: (context, index) {
                        final transaction = widget.transactions[index];
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(50 * (1 - value), 0),
                              child: Opacity(
                                opacity: value,
                                child: TransactionTile(
                                  transaction: transaction,
                                  onTap: () {
                                    widget.onTap(widget.transactions[index]);
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No transactions found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
