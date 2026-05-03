import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';

/// Model to hold both spending amount and transaction count for a category
class CategorySpendingData {
  /// Creates a [CategorySpendingData] with the given values.
  const CategorySpendingData({
    required this.category,
    required this.totalAmount,
    required this.transactionCount,
  });

  /// Create an empty category spending data
  factory CategorySpendingData.empty(TransactionCategory? category) {
    return CategorySpendingData(
      category: category,
      totalAmount: 0,
      transactionCount: 0,
    );
  }

  /// The category these figures belong to, or `null` for uncategorised.
  final TransactionCategory? category;

  /// Total money spent in this category during the selected period.
  final double totalAmount;

  /// Number of transactions in this category during the selected period.
  final int transactionCount;

  /// Check if this category has any spending
  bool get hasSpending => totalAmount > 0 || transactionCount > 0;

  /// Average amount per transaction
  double get averagePerTransaction =>
      transactionCount > 0 ? totalAmount / transactionCount : 0.0;

  @override
  bool operator ==(Object other) {
    return other is CategorySpendingData &&
        other.category == category &&
        other.totalAmount == totalAmount &&
        other.transactionCount == transactionCount;
  }

  @override
  int get hashCode => Object.hash(category, totalAmount, transactionCount);

  @override
  String toString() {
    return 'CategorySpendingData(category: ${category?.name ?? 'Uncategorized'}, '
        'totalAmount: $totalAmount, transactionCount: $transactionCount)';
  }
}
