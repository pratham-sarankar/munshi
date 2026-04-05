import 'package:drift/drift.dart';
import 'package:munshi/core/database/converters/color_converter.dart';
import 'package:munshi/core/database/converters/icon_data_converter.dart';
import 'package:munshi/core/database/converters/transaction_type_converter.dart';

/// Database table for storing transaction categories.
///
/// Contains category information including name, icon, color, transaction type,
/// and default status tracking.
@DataClassName('TransactionCategoryRow')
class TransactionCategories extends Table {
  /// Unique identifier for the category.
  IntColumn get id => integer().autoIncrement()();

  /// Name of the category.
  TextColumn get name => text()();

  /// Icon data associated with the category.
  TextColumn get icon => text().map(const IconDataConverter())();

  /// Color value for the category.
  IntColumn get color => integer().map(const ColorConverter())();

  /// Transaction type (income or expense).
  TextColumn get type => text().map(const TransactionTypeConverter())();

  /// Whether this is a default system category.
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// Timestamp when the category was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
