import 'package:drift/drift.dart';
import 'package:munshi/core/database/converters/transaction_type_converter.dart';
import 'package:munshi/core/database/tables/transaction_categories.dart';

/// Database table definition for storing financial transactions.
///
/// Contains transaction details including amount, category, date, note, and
/// type.
@DataClassName('TransactionRow')
class Transactions extends Table {
  /// Unique identifier for the transaction, auto-incremented.
  IntColumn get id => integer().autoIncrement()();

  /// Transaction amount in the base currency.
  RealColumn get amount => real()();

  /// Foreign key reference to the transaction category.
  IntColumn get categoryId => integer().nullable().references(
    TransactionCategories,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// Date and time when the transaction occurred.
  DateTimeColumn get date => dateTime()();

  /// Optional note or description for the transaction.
  TextColumn get note => text().nullable()();

  /// Type of transaction (income or expense).
  TextColumn get type => text().map(const TransactionTypeConverter())();
}
