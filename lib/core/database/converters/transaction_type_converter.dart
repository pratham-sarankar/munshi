import 'package:drift/drift.dart';
import 'package:munshi/core/enums/transaction_type.dart';

class TransactionTypeConverter extends TypeConverter<TransactionType, String> {
  const TransactionTypeConverter();

  @override
  TransactionType fromSql(String fromDb) {
    return TransactionType.values.firstWhere(
      (e) => e.toString().split('.').last == fromDb,
    );
  }

  @override
  String toSql(TransactionType value) {
    return value.toString().split('.').last;
  }
}
