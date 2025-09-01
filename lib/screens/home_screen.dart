import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:munshi/screens/transactions_screen.dart';
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
  final double _totalSpent = 12430;
  final double _percentageChange = 12;
  final int _transactionCount = 45;
  final double _biggestSpendAmount = 3200;

  // Sample transaction data - replace with your actual data
  final List<Transaction> _recentTransactions = [
    Transaction(
      id: '1',
      merchant: 'Starbucks Coffee',
      category: 'Food',
      amount: 12.50,
      date: 'Today',
      time: '2:30 PM',
      icon: Icons.local_cafe,
      color: Colors.brown,
      description: 'Venti Caramel Macchiato',
      paymentMethod: 'Credit Card',
      status: 'Completed',
    ),
    Transaction(
      id: '2',
      merchant: 'Amazon',
      category: 'Shopping',
      amount: 89.99,
      date: 'Yesterday',
      time: '10:15 AM',
      icon: Icons.shopping_bag,
      color: Colors.orange,
      description: 'Wireless Headphones',
      paymentMethod: 'Debit Card',
      status: 'Completed',
    ),
    Transaction(
      id: '3',
      merchant: 'Uber',
      category: 'Transport',
      amount: 25.30,
      date: 'Yesterday',
      time: '8:45 PM',
      icon: Icons.local_taxi,
      color: Colors.black,
      description: 'Trip to Downtown',
      paymentMethod: 'Credit Card',
      status: 'Completed',
    ),
    Transaction(
      id: '4',
      merchant: 'Netflix',
      category: 'Entertainment',
      amount: 15.99,
      date: 'Dec 28',
      time: '12:00 AM',
      icon: Icons.movie,
      color: Colors.red,
      description: 'Monthly Subscription',
      paymentMethod: 'Credit Card',
      status: 'Completed',
    ),
    Transaction(
      id: '5',
      merchant: 'Electricity Bill',
      category: 'Bills',
      amount: 120.00,
      date: 'Dec 27',
      time: '3:20 PM',
      icon: Icons.bolt,
      color: Colors.yellow.shade700,
      description: 'Monthly Electricity',
      paymentMethod: 'Bank Transfer',
      status: 'Completed',
    ),
    Transaction(
      id: '6',
      merchant: 'Pharmacy Plus',
      category: 'Health',
      amount: 45.60,
      date: 'Dec 26',
      time: '11:30 AM',
      icon: Icons.local_pharmacy,
      color: Colors.green,
      description: 'Prescription Medicine',
      paymentMethod: 'Cash',
      status: 'Completed',
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
  } // Removed extra closing brace

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
                    Icons.chevron_left,
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
                    Icons.chevron_right,
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
              child: Icon(Icons.person, size: 20, color: colorScheme.onPrimary),
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
                child: _buildSummaryCard(colorScheme),
              ),
              const SizedBox(height: 16),

              // Quick Stats Row
              _buildQuickStatsRow(colorScheme),
              const SizedBox(height: 28),

              // Recent Transactions
              _buildRecentTransactions(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: colorScheme.surface.withValues(alpha: 0.05),
            blurRadius: 1,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Spent',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Active',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            _formatCurrency(_totalSpent),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _percentageChange > 0
                  ? Colors.red.shade50
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _percentageChange > 0
                    ? Colors.red.withValues(alpha: 0.2)
                    : Colors.green.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _percentageChange > 0 ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _percentageChange > 0
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '${_percentageChange.abs()}% from last month',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _percentageChange > 0
                        ? Colors.red.shade700
                        : Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            colorScheme,
            'Transactions',
            _transactionCount.toString(),
            Icons.receipt_long,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            colorScheme,
            'Biggest Spend',
            _formatCurrency(_biggestSpendAmount),
            Icons.credit_card,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ColorScheme colorScheme,
    String title,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
              iconAlignment: IconAlignment.start,
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
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentTransactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final transaction = _recentTransactions[index];
            return SlideTransition(
              position: _transactionAnimations[index],
              child: FadeTransition(
                opacity: _transactionAnimationController,
                child: TransactionTile(transaction: transaction, onTap: () {}),
              ),
            );
          },
        ),
      ],
    );
  }
}
