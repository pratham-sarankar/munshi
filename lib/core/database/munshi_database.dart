import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'munshi_database.g.dart';

/// Transactions table definition for the MunshiDB database.
/// 
/// This table stores all user transactions with their details including:
/// - id: Primary key for unique identification
/// - merchant: Name of the merchant/store/service
/// - amount: Transaction amount (positive for income, negative for expense)
/// - date: Date when the transaction occurred
/// - time: Time when the transaction occurred
/// - description: Optional description or notes about the transaction
/// - category: Category of the transaction (Food, Shopping, etc.)
/// - isIncome: Boolean flag to distinguish between income and expense
/// - createdAt: Timestamp when the record was created
/// - updatedAt: Timestamp when the record was last updated
@DataClassName('TransactionData')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get merchant => text().withLength(min: 1, max: 100)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get time => text()();
  TextColumn get description => text().withLength(max: 500).nullable()();
  TextColumn get category => text().withLength(min: 1, max: 50)();
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// MunshiDB - The main database class for the Munshi personal finance app.
/// 
/// This database handles all local data storage for the application, including
/// transaction records. It uses Drift for type-safe database operations and
/// SQLite as the underlying database engine.
/// 
/// The database is automatically created when first accessed and includes
/// proper migration support for future schema changes.
@DriftDatabase(tables: [Transactions])
class MunshiDatabase extends _$MunshiDatabase {
  /// Creates a new instance of MunshiDatabase.
  /// 
  /// The database file is stored in the application's documents directory
  /// and is named 'munshi_db.sqlite'.
  MunshiDatabase() : super(_openConnection());

  /// Database schema version.
  /// 
  /// Increment this when making schema changes to trigger migrations.
  @override
  int get schemaVersion => 1;

  /// Migration strategy for database schema changes.
  /// 
  /// This method handles migrating the database when the schema version
  /// is updated. Currently set to onCreate only since this is the initial version.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
      );

  /// Get all transactions ordered by date (newest first).
  /// 
  /// Returns a stream that automatically updates when transactions change.
  Stream<List<TransactionData>> watchAllTransactions() {
    return select(transactions)
      ..orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.time, mode: OrderingMode.desc),
      ])
      ..watch();
  }

  /// Get the most recent transactions (limited by count).
  /// 
  /// [limit] specifies the maximum number of transactions to return.
  /// Returns a stream that automatically updates when transactions change.
  Stream<List<TransactionData>> watchRecentTransactions({int limit = 10}) {
    return (select(transactions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.time, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .watch();
  }

  /// Get transactions filtered by category.
  /// 
  /// [category] the category to filter by.
  /// Returns a stream of transactions matching the specified category.
  Stream<List<TransactionData>> watchTransactionsByCategory(String category) {
    return (select(transactions)
          ..where((t) => t.category.equals(category))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.time, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Get transactions within a date range.
  /// 
  /// [startDate] the start date (inclusive).
  /// [endDate] the end date (inclusive).
  /// Returns a stream of transactions within the specified date range.
  Stream<List<TransactionData>> watchTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return (select(transactions)
          ..where((t) => t.date.isBetweenValues(startDate, endDate))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.time, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Insert a new transaction into the database.
  /// 
  /// [transaction] the transaction data to insert.
  /// Returns the ID of the newly inserted transaction.
  Future<int> insertTransaction(TransactionsCompanion transaction) {
    return into(transactions).insert(transaction);
  }

  /// Update an existing transaction.
  /// 
  /// [transaction] the transaction data with updates.
  /// Returns true if the transaction was updated successfully.
  Future<bool> updateTransaction(TransactionData transaction) {
    return update(transactions).replace(transaction);
  }

  /// Delete a transaction by ID.
  /// 
  /// [id] the ID of the transaction to delete.
  /// Returns the number of rows affected (should be 1 if successful).
  Future<int> deleteTransaction(int id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  /// Get a single transaction by ID.
  /// 
  /// [id] the ID of the transaction to retrieve.
  /// Returns the transaction data or null if not found.
  Future<TransactionData?> getTransactionById(int id) {
    return (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Calculate total income within a date range.
  /// 
  /// [startDate] the start date (inclusive).
  /// [endDate] the end date (inclusive).
  /// Returns the total income amount.
  Future<double> getTotalIncome(DateTime startDate, DateTime endDate) async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.isIncome.equals(true) &
              transactions.date.isBetweenValues(startDate, endDate));
    
    final result = await query.getSingleOrNull();
    return result?.read(transactions.amount.sum()) ?? 0.0;
  }

  /// Calculate total expenses within a date range.
  /// 
  /// [startDate] the start date (inclusive).
  /// [endDate] the end date (inclusive).
  /// Returns the total expense amount (as a positive number).
  Future<double> getTotalExpenses(DateTime startDate, DateTime endDate) async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.isIncome.equals(false) &
              transactions.date.isBetweenValues(startDate, endDate));
    
    final result = await query.getSingleOrNull();
    return (result?.read(transactions.amount.sum()) ?? 0.0).abs();
  }

  /// Get transaction count by category within a date range.
  /// 
  /// [startDate] the start date (inclusive).
  /// [endDate] the end date (inclusive).
  /// Returns a map of category to transaction count.
  Future<Map<String, int>> getTransactionCountByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.category, transactions.id.count()])
      ..where(transactions.date.isBetweenValues(startDate, endDate))
      ..groupBy([transactions.category]);

    final results = await query.get();
    final Map<String, int> categoryCount = {};
    
    for (final result in results) {
      final category = result.read(transactions.category);
      final count = result.read(transactions.id.count());
      if (category != null && count != null) {
        categoryCount[category] = count;
      }
    }
    
    return categoryCount;
  }
}

/// Opens a connection to the SQLite database.
/// 
/// This function handles the platform-specific database connection setup,
/// ensuring SQLite3 is properly initialized on mobile platforms.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Ensure sqlite3 is loaded on mobile platforms
    if (Platform.isAndroid || Platform.isIOS) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Get the application documents directory
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'munshi_db.sqlite'));

    // Create a native database connection
    return NativeDatabase.createInBackground(file);
  });
}