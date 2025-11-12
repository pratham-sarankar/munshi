import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:munshi/core/database/app_database.dart';

class TransactionCategoryConverter
    extends TypeConverter<TransactionCategory, String> {
  const TransactionCategoryConverter();

  @override
  TransactionCategory fromSql(String jsonString) {
    return TransactionCategory.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  @override
  String toSql(TransactionCategory value) {
    return value.toJsonString();
  }
}
