import 'package:flutter/material.dart';
import 'package:munshi/core/database/munshi_database.dart';
import 'package:icons_plus/icons_plus.dart';

/// Transaction model for UI display purposes.
/// 
/// This class extends the database TransactionData with additional UI-specific
/// properties like icon and color for better visual representation in the app.
/// It serves as a bridge between the database layer and the presentation layer.
class Transaction {
  /// The database transaction data
  final TransactionData data;
  
  /// Icon to display for this transaction category
  final IconData icon;
  
  /// Color theme for this transaction category
  final Color color;

  /// Creates a new Transaction instance.
  /// 
  /// [data] The database transaction data
  /// [icon] Icon to display for this transaction
  /// [color] Color theme for this transaction
  Transaction({
    required this.data,
    required this.icon,
    required this.color,
  });

  /// Convenience getters to access database fields
  
  int get id => data.id;
  String get merchant => data.merchant;
  double get amount => data.amount;
  DateTime get date => data.date;
  String get time => data.time;
  String? get description => data.description;
  String get category => data.category;
  bool get isIncome => data.isIncome;
  DateTime get createdAt => data.createdAt;
  DateTime get updatedAt => data.updatedAt;

  /// Creates a Transaction from database data with appropriate icon and color.
  /// 
  /// This factory method maps transaction categories to their corresponding
  /// icons and colors for consistent visual representation across the app.
  factory Transaction.fromData(TransactionData data) {
    return Transaction(
      data: data,
      icon: _getIconForCategory(data.category),
      color: _getColorForCategory(data.category),
    );
  }

  /// Creates a list of Transactions from database data.
  /// 
  /// Convenience method to convert a list of TransactionData to Transaction objects.
  static List<Transaction> fromDataList(List<TransactionData> dataList) {
    return dataList.map((data) => Transaction.fromData(data)).toList();
  }

  /// Gets the appropriate icon for a transaction category.
  /// 
  /// Maps category names to their corresponding Material Design icons
  /// for consistent visual representation.
  static IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'food & dining':
      case 'dining':
        return IonIcons.restaurant;
      case 'shopping':
      case 'retail':
        return IonIcons.bag_handle;
      case 'transport':
      case 'transportation':
      case 'travel':
        return IonIcons.car;
      case 'entertainment':
      case 'movies':
      case 'games':
        return IonIcons.game_controller;
      case 'bills':
      case 'utilities':
      case 'electricity':
      case 'water':
        return IonIcons.receipt;
      case 'health':
      case 'medical':
      case 'healthcare':
        return IonIcons.medical;
      case 'education':
      case 'learning':
        return IonIcons.school;
      case 'fuel':
      case 'gas':
      case 'petrol':
        return IonIcons.car_sport;
      case 'income':
      case 'salary':
      case 'wages':
        return IonIcons.cash;
      case 'investment':
      case 'stocks':
        return IonIcons.trending_up;
      case 'gift':
      case 'gifts':
        return IonIcons.gift;
      case 'insurance':
        return IonIcons.shield_checkmark;
      default:
        return IonIcons.card; // Default icon for unknown categories
    }
  }

  /// Gets the appropriate color for a transaction category.
  /// 
  /// Maps category names to their corresponding theme colors
  /// for consistent visual representation.
  static Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'food & dining':
      case 'dining':
        return const Color(0xFFE23744); // Red
      case 'shopping':
      case 'retail':
        return const Color(0xFFFF9900); // Orange
      case 'transport':
      case 'transportation':
      case 'travel':
        return const Color(0xFF2196F3); // Blue
      case 'entertainment':
      case 'movies':
      case 'games':
        return const Color(0xFF9C27B0); // Purple
      case 'bills':
      case 'utilities':
      case 'electricity':
      case 'water':
        return const Color(0xFF607D8B); // Blue Grey
      case 'health':
      case 'medical':
      case 'healthcare':
        return const Color(0xFF4CAF50); // Green
      case 'education':
      case 'learning':
        return const Color(0xFF3F51B5); // Indigo
      case 'fuel':
      case 'gas':
      case 'petrol':
        return const Color(0xFF795548); // Brown
      case 'income':
      case 'salary':
      case 'wages':
        return const Color(0xFF4CAF50); // Green
      case 'investment':
      case 'stocks':
        return const Color(0xFF00BCD4); // Cyan
      case 'gift':
      case 'gifts':
        return const Color(0xFFE91E63); // Pink
      case 'insurance':
        return const Color(0xFF009688); // Teal
      default:
        return const Color(0xFF757575); // Grey for unknown categories
    }
  }

  /// Converts this Transaction to a TransactionsCompanion for database insertion.
  /// 
  /// This method is useful when creating new transactions or updating existing ones.
  /// The companion object is used by Drift for type-safe database operations.
  TransactionsCompanion toCompanion() {
    return TransactionsCompanion.insert(
      merchant: merchant,
      amount: amount,
      date: date,
      time: time,
      description: description != null ? Value(description!) : const Value.absent(),
      category: category,
      isIncome: isIncome,
    );
  }

  /// Creates a copy of this Transaction with updated fields.
  /// 
  /// Useful for updating transactions while preserving unchanged fields.
  Transaction copyWith({
    TransactionData? data,
    IconData? icon,
    Color? color,
  }) {
    return Transaction(
      data: data ?? this.data,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  /// Returns a string representation of this transaction.
  /// 
  /// Useful for debugging and logging purposes.
  @override
  String toString() {
    return 'Transaction{id: $id, merchant: $merchant, amount: $amount, category: $category, date: $date}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          data.id == other.data.id;

  @override
  int get hashCode => data.id.hashCode;
}

/// Predefined transaction categories with their display names.
/// 
/// This class provides a centralized list of transaction categories
/// that can be used throughout the app for consistency.
class TransactionCategories {
  static const List<String> expenseCategories = [
    'Food & Dining',
    'Shopping',
    'Transportation',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Fuel',
    'Insurance',
    'Gifts',
    'Other',
  ];

  static const List<String> incomeCategories = [
    'Salary',
    'Business',
    'Investment',
    'Freelance',
    'Rental',
    'Interest',
    'Dividend',
    'Gift',
    'Bonus',
    'Other',
  ];

  /// Gets all categories (income + expense).
  static List<String> get allCategories => [
        ...incomeCategories,
        ...expenseCategories,
      ];

  /// Checks if a category is an income category.
  static bool isIncomeCategory(String category) {
    return incomeCategories.contains(category);
  }

  /// Checks if a category is an expense category.
  static bool isExpenseCategory(String category) {
    return expenseCategories.contains(category);
  }
}
