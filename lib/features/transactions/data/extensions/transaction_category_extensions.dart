import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';

/// Extension to convert a [TransactionCategoryRow] (Drift row) to a domain entity.
extension TransactionCategoryRowExtensions on TransactionCategoryRow {
  /// Converts this database row to a [TransactionCategory] entity.
  TransactionCategory toEntity() {
    return TransactionCategory(
      id: id,
      name: name,
      icon: icon,
      color: color,
      type: type,
      isDefault: isDefault,
      createdAt: createdAt,
    );
  }
}

/// Extension to convert a [TransactionCategory] domain entity to a database row.
extension TransactionCategoryExtension on TransactionCategory {
  /// Converts this entity to a [TransactionCategoryRow] for persistence.
  TransactionCategoryRow toRow() {
    return TransactionCategoryRow(
      id: id,
      name: name,
      icon: icon,
      color: color,
      type: type,
      isDefault: isDefault,
      createdAt: createdAt,
    );
  }
}
