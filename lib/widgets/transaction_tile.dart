import 'package:flutter/material.dart';
import 'package:munshi/features/transactions/models/transaction.dart';
import 'package:intl/intl.dart';

/// A reusable widget for displaying transaction information in a tile format.
/// 
/// This widget displays transaction details including merchant name, category,
/// date, time, and amount with proper formatting and visual styling.
/// It adapts to both income and expense transactions with appropriate colors.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.onTap,
    required this.transaction,
  });

  /// Callback function to be called when the tile is tapped
  final VoidCallback onTap;
  
  /// The transaction data to display
  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth * 0.05,
              vertical: constraints.maxWidth * 0.02,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // Transaction icon with category-based styling
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: transaction.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    transaction.icon,
                    color: transaction.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Transaction details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Merchant name
                      Text(
                        transaction.merchant,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      
                      // Category
                      Text(
                        transaction.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      
                      // Date and time
                      Text(
                        '${_formatDate(transaction.date)} • ${transaction.time}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Transaction amount with income/expense styling
                Text(
                  _formatCurrency(transaction.amount, transaction.isIncome),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: transaction.isIncome 
                        ? Colors.green.shade600 
                        : Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Formats the transaction amount with proper currency symbol and sign
  /// 
  /// [amount] The transaction amount
  /// [isIncome] Whether this is an income transaction
  /// Returns formatted currency string with appropriate sign
  String _formatCurrency(double amount, bool isIncome) {
    final absAmount = amount.abs();
    final formattedAmount = "₹${absAmount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match match) => '${match[1]},'
    )}";
    
    return isIncome ? '+$formattedAmount' : '-$formattedAmount';
  }

  /// Formats the transaction date to a human-readable format
  /// 
  /// [date] The transaction date
  /// Returns formatted date string (e.g., "Today", "Yesterday", "Dec 25")
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else if (date.year == now.year) {
      // Same year, show month and day
      return DateFormat('MMM d').format(date);
    } else {
      // Different year, show month, day, and year
      return DateFormat('MMM d, y').format(date);
    }
  }
}
