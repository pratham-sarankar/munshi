import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:munshi/features/transactions/models/transaction_category.dart';

class TransactionCategoryConverter
    extends TypeConverter<TransactionCategory, String> {
  const TransactionCategoryConverter();

  @override
  TransactionCategory fromSql(String jsonString) {
    return TransactionCategory.fromJson(json.decode(jsonString));
  }

  @override
  String toSql(TransactionCategory value) => json.encode(value.toJson());
}
