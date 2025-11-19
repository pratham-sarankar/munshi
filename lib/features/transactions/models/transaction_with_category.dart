import 'package:flutter/material.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/transactions/models/transaction_type.dart';

/// A transaction with its optional category information.
///
/// The category can be null if the transaction has no associated category
/// or if the category was deleted. This allows transactions to exist
/// independently of categories.
class TransactionWithCategory {

  const TransactionWithCategory({required this.transaction, this.category});
  final Transaction transaction;
  final TransactionCategory? category;

  int get id => transaction.id;
  double get amount => transaction.amount;
  int? get categoryId => transaction.categoryId;
  DateTime get date => transaction.date;
  String? get note => transaction.note;
  TransactionType get type => transaction.type;

  // Category properties for convenience - return defaults if category is null
  String get categoryName => category?.name ?? 'Uncategorized';
  IconData get categoryIcon => category?.icon ?? Icons.help_outline;
  Color get categoryColor => category?.color ?? Colors.grey;
  TransactionType? get categoryType => category?.type;
  bool get isCategoryDefault => category?.isDefault ?? false;

  // Helper to check if category exists
  bool get hasCategory => category != null;
}
