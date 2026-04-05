import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:munshi/core/enums/transaction_type.dart';

part 'transaction_category.freezed.dart';

/// Represents a transaction category.
///
/// Contains category metadata like name, icon, color, and type.
@freezed
abstract class TransactionCategory with _$TransactionCategory {
  /// Creates a new [TransactionCategory] instance.
  const factory TransactionCategory({
    required int id,
    required String name,
    required IconData icon,
    required Color color,
    required TransactionType type,
    required bool isDefault,
    required DateTime createdAt,
  }) = _TransactionCategory;
}
