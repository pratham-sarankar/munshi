import 'package:drift/drift.dart';
import 'package:munshi/core/database/converters/color_converter.dart';
import 'package:munshi/core/database/converters/icon_data_converter.dart';
import 'package:munshi/core/database/converters/transaction_type_converter.dart';

class TransactionCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text().map(const IconDataConverter())();
  IntColumn get color => integer().map(const ColorConverter())();
  TextColumn get type => text().map(const TransactionTypeConverter())();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
