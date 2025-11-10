import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';
import 'transaction_type.dart';

/// A transaction with its associated category information
class TransactionWithCategory {
  final Transaction transaction;
  final TransactionCategory category;

  const TransactionWithCategory({
    required this.transaction,
    required this.category,
  });

  int get id => transaction.id;
  double get amount => transaction.amount;
  int get categoryId => transaction.categoryId;
  DateTime get date => transaction.date;
  String? get note => transaction.note;
  TransactionType get type => transaction.type;

  // Category properties for convenience
  String get categoryName => category.name;
  IconData get categoryIcon => category.icon;
  Color get categoryColor => category.color;
  TransactionType get categoryType => category.type;
  bool get isCategoryDefault => category.isDefault;
}
