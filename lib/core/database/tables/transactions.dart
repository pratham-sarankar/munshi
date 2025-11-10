import 'package:drift/drift.dart';
import '../converters/transaction_type_converter.dart';
import 'transaction_categories.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  IntColumn get categoryId => integer().nullable().references(
    TransactionCategories,
    #id,
    onDelete: KeyAction.setNull,
  )();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get type => text().map(const TransactionTypeConverter())();
}
