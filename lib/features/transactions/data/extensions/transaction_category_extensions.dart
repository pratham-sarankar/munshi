import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';

extension TransactionCategoryRowExtensions on TransactionCategoryRow {
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

extension TransactionCategoryExtension on TransactionCategory {
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
