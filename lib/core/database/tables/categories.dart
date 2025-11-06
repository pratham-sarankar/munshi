import 'package:drift/drift.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get iconCodePoint => integer()();
  TextColumn get iconFontFamily => text().nullable()();
  TextColumn get iconFontPackage => text().nullable()();
  IntColumn get colorValue => integer()();
  TextColumn get type => text()(); // 'expense' or 'income'
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
