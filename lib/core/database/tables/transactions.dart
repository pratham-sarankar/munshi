import 'package:drift/drift.dart';
import 'package:munshi/core/database/converters/transaction_category_converter.dart';
import '../converters/transaction_type_converter.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get category => text().map(const TransactionCategoryConverter())();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get type => text().map(const TransactionTypeConverter())();
}
