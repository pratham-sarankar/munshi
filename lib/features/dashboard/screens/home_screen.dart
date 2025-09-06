import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/features/dashboard/widgets/dashboard_stats_widget.dart';
import 'package:munshi/features/dashboard/widgets/dashboard_summary_card.dart';
import 'package:munshi/features/transactions/models/transaction.dart';
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

  // User data - in real app this would come from auth/storage
  final String _userName = "Alex Johnson";

  // Sample data

  final int _transactionCount = 45;
  final double _biggestSpendAmount = 3200;

  final List<Transaction> _recentTransactions = [
    Transaction(
      merchant: "Zomato",
      amount: 250,
      date: "Today",
      time: "2:30 PM",
      icon: IonIcons.restaurant,
      color: const Color(0xFFE23744),
      category: "Food & Dining",
    ),
    Transaction(
      merchant: "Amazon",
      amount: 1200,
      date: "Yesterday",
      time: "11:45 AM",
      icon: IonIcons.bag_handle,
      color: const Color(0xFFFF9900),
      category: "Shopping",
    ),
    Transaction(
      merchant: "Electricity Bill",
      amount: 1800,
      date: "Aug 25",
      time: "9:15 AM",
      icon: IonIcons.flash,
      color: const Color(0xFF4CAF50),
      category: "Utilities",
    ),
    Transaction(
      merchant: "Uber",
      amount: 400,
      date: "Aug 25",
      time: "7:30 PM",
      icon: IonIcons.car,
      color: const Color(0xFF000000),
      category: "Transportation",
    ),
    Transaction(
      merchant: "Burger King",
      amount: 600,
      date: "Aug 24",
      time: "1:20 PM",
      icon: IonIcons.fast_food,
      color: const Color(0xFFD62300),
      category: "Food & Dining",
    ),
  ];

  @override
  void initState() {
    super.initState();
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

    // Transaction animations
    _transactionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _transactionAnimations = List.generate(
      _recentTransactions.length,
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
              onPressed: () {},
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
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentTransactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final transaction = _recentTransactions[index];
            return SlideTransition(
              position: _transactionAnimations[index],
              child: FadeTransition(
                opacity: _transactionAnimationController,
                child: _buildTransactionItem(transaction, colorScheme, index),
              ),
            );
          },
        ),
      ],
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
