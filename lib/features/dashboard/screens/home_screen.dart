import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/core/service_locator.dart';
import 'package:munshi/features/dashboard/widgets/dashboard_stats_widget.dart';
import 'package:munshi/features/dashboard/widgets/dashboard_summary_card.dart';
import 'package:munshi/features/transactions/models/transaction.dart';
import 'package:munshi/features/transactions/services/transaction_service.dart';
import 'package:munshi/widgets/transaction_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  DateTime _currentMonth = DateTime.now();
  late AnimationController _summaryCardAnimationController;
  late Animation<double> _summaryCardAnimation;
  late AnimationController _transactionAnimationController;
  late List<Animation<Offset>> _transactionAnimations;
  
  /// Transaction service for database operations
  late final TransactionService _transactionService;

  // User data - in real app this would come from auth/storage
  final String _userName = "Alex Johnson";

  // Sample data for stats (these would be calculated from database in real implementation)
  final int _transactionCount = 45;
  final double _biggestSpendAmount = 3200;

  @override
  void initState() {
    super.initState();
    
    // Get the transaction service from dependency injection
    _transactionService = locator<TransactionService>();
    
    _summaryCardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _summaryCardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _summaryCardAnimationController,
        curve: Curves.easeOutExpo,
      ),
    );

    // Transaction animations - initialize with empty list, will be rebuilt when data loads
    _transactionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _transactionAnimations = [];

    // Start animations
    _summaryCardAnimationController.forward();
  }

  /// Creates transaction animations based on the number of transactions
  void _initializeTransactionAnimations(int transactionCount) {
    _transactionAnimations = List.generate(
      transactionCount,
      (index) =>
          Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _transactionAnimationController,
              curve: Interval(
                index * 0.1,
                0.5 + (index * 0.1),
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
    );

    _summaryCardAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _transactionAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _summaryCardAnimationController.dispose();
    _transactionAnimationController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  String _formatCurrency(double amount) {
    // Added missing method signature
    return "₹${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}";
  }

  String _getMonthName(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${months[date.month - 1]} ${date.year}";
  }

  void _changeMonth(int direction) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + direction,
      );
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()}, ${_userName.split(' ').first}! 👋',
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
          // Month Selector
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
                  onPressed: () => _changeMonth(-1),
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                ),
                Text(
                  _getMonthName(_currentMonth),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
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
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Hero Summary Card
              ScaleTransition(
                scale: _summaryCardAnimation,
                child: DashboardSummaryCard(),
              ),
              const SizedBox(height: 15),

              // Quick Stats Row
              _buildQuickStatsRow(colorScheme),
              const SizedBox(height: 18),

              // Recent Transactions
              _buildRecentTransactions(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsRow(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: DashboardStatsWidget(
            'Transactions',
            _transactionCount.toString(),
            Iconsax.receipt_search_outline,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: DashboardStatsWidget(
            'Biggest Spend',
            _formatCurrency(_biggestSpendAmount),
            Iconsax.card_pos_outline,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // Navigate to transactions screen
                // This would be implemented with proper navigation
              },
              icon: Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: colorScheme.primary,
              ),
              iconAlignment: IconAlignment.end,
              label: Text(
                'View All',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        /// StreamBuilder to display recent transactions from database
        /// 
        /// Watches the last 10 transactions and automatically updates
        /// the UI when transactions are added, updated, or deleted.
        StreamBuilder<List<Transaction>>(
          stream: _transactionService.watchRecentTransactions(limit: 10),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show loading shimmer while data is being fetched
              return _buildTransactionLoadingShimmer();
            }

            if (snapshot.hasError) {
              // Show error message if data fetching fails
              return _buildTransactionError(snapshot.error.toString());
            }

            final recentTransactions = snapshot.data ?? [];

            if (recentTransactions.isEmpty) {
              // Show empty state when no transactions exist
              return _buildEmptyTransactions(colorScheme);
            }

            // Initialize animations based on transaction count
            if (_transactionAnimations.length != recentTransactions.length) {
              _initializeTransactionAnimations(recentTransactions.length);
              _transactionAnimationController.forward();
            }

            return ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentTransactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final transaction = recentTransactions[index];
                
                // Ensure we have enough animation objects
                if (index >= _transactionAnimations.length) {
                  return _buildTransactionItem(transaction, colorScheme, index);
                }
                
                return SlideTransition(
                  position: _transactionAnimations[index],
                  child: FadeTransition(
                    opacity: _transactionAnimationController,
                    child: _buildTransactionItem(transaction, colorScheme, index),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  /// Builds a loading shimmer effect for transactions
  Widget _buildTransactionLoadingShimmer() {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5, // Show 5 shimmer items
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 120,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 60,
                height: 14,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        );
      },
    );
  }

  /// Builds an error widget for when transaction loading fails
  Widget _buildTransactionError(String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load transactions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds an empty state widget when no transactions exist
  Widget _buildEmptyTransactions(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding transactions to see them here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    Transaction transaction,
    ColorScheme colorScheme,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: TransactionTile(onTap: () {}, transaction: transaction),
        );
      },
    );
  }
}
