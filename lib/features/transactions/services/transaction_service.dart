import 'package:munshi/core/database/munshi_database.dart';
import 'package:munshi/features/transactions/models/transaction.dart';
import 'package:drift/drift.dart';

/// Service class for managing transaction operations.
/// 
/// This service provides a high-level interface for transaction-related
/// operations, abstracting away the database implementation details
/// and providing convenient methods for the UI layer.
class TransactionService {
  final MunshiDatabase _database;

  /// Creates a new TransactionService instance.
  /// 
  /// [database] The Drift database instance to use for operations.
  TransactionService(this._database);

  /// Gets all transactions as a stream for real-time updates.
  /// 
  /// Returns a stream that emits the complete list of transactions
  /// whenever any transaction is added, updated, or deleted.
  /// Transactions are ordered by date (newest first).
  Stream<List<Transaction>> watchAllTransactions() {
    return _database
        .watchAllTransactions()
        .map((dataList) => Transaction.fromDataList(dataList));
  }

  /// Gets recent transactions as a stream for real-time updates.
  /// 
  /// [limit] Maximum number of recent transactions to return (default: 10).
  /// Returns a stream that emits the most recent transactions
  /// whenever any transaction is added, updated, or deleted.
  Stream<List<Transaction>> watchRecentTransactions({int limit = 10}) {
    return _database
        .watchRecentTransactions(limit: limit)
        .map((dataList) => Transaction.fromDataList(dataList));
  }

  /// Gets transactions filtered by category as a stream.
  /// 
  /// [category] The category to filter by.
  /// Returns a stream that emits transactions matching the specified category.
  Stream<List<Transaction>> watchTransactionsByCategory(String category) {
    return _database
        .watchTransactionsByCategory(category)
        .map((dataList) => Transaction.fromDataList(dataList));
  }

  /// Gets transactions within a date range as a stream.
  /// 
  /// [startDate] The start date (inclusive).
  /// [endDate] The end date (inclusive).
  /// Returns a stream that emits transactions within the specified date range.
  Stream<List<Transaction>> watchTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _database
        .watchTransactionsByDateRange(startDate, endDate)
        .map((dataList) => Transaction.fromDataList(dataList));
  }

  /// Adds a new transaction to the database.
  /// 
  /// [merchant] The name of the merchant/store/service.
  /// [amount] The transaction amount (positive for income, negative for expense).
  /// [date] The date when the transaction occurred.
  /// [time] The time when the transaction occurred.
  /// [category] The category of the transaction.
  /// [isIncome] Whether this is an income transaction.
  /// [description] Optional description or notes about the transaction.
  /// 
  /// Returns the ID of the newly created transaction.
  Future<int> addTransaction({
    required String merchant,
    required double amount,
    required DateTime date,
    required String time,
    required String category,
    required bool isIncome,
    String? description,
  }) {
    final companion = TransactionsCompanion.insert(
      merchant: merchant,
      amount: amount,
      date: date,
      time: time,
      category: category,
      isIncome: isIncome,
      description: description != null ? Value(description) : const Value.absent(),
    );

    return _database.insertTransaction(companion);
  }

  /// Updates an existing transaction.
  /// 
  /// [transaction] The transaction to update with new values.
  /// Returns true if the transaction was updated successfully.
  Future<bool> updateTransaction(Transaction transaction) {
    return _database.updateTransaction(transaction.data);
  }

  /// Deletes a transaction by ID.
  /// 
  /// [id] The ID of the transaction to delete.
  /// Returns true if the transaction was deleted successfully.
  Future<bool> deleteTransaction(int id) async {
    final rowsAffected = await _database.deleteTransaction(id);
    return rowsAffected > 0;
  }

  /// Gets a single transaction by ID.
  /// 
  /// [id] The ID of the transaction to retrieve.
  /// Returns the transaction or null if not found.
  Future<Transaction?> getTransactionById(int id) async {
    final data = await _database.getTransactionById(id);
    return data != null ? Transaction.fromData(data) : null;
  }

  /// Calculates the total income within a date range.
  /// 
  /// [startDate] The start date (inclusive).
  /// [endDate] The end date (inclusive).
  /// Returns the total income amount.
  Future<double> getTotalIncome(DateTime startDate, DateTime endDate) {
    return _database.getTotalIncome(startDate, endDate);
  }

  /// Calculates the total expenses within a date range.
  /// 
  /// [startDate] The start date (inclusive).
  /// [endDate] The end date (inclusive).
  /// Returns the total expense amount (as a positive number).
  Future<double> getTotalExpenses(DateTime startDate, DateTime endDate) {
    return _database.getTotalExpenses(startDate, endDate);
  }

  /// Gets the net balance (income - expenses) within a date range.
  /// 
  /// [startDate] The start date (inclusive).
  /// [endDate] The end date (inclusive).
  /// Returns the net balance (positive means surplus, negative means deficit).
  Future<double> getNetBalance(DateTime startDate, DateTime endDate) async {
    final income = await getTotalIncome(startDate, endDate);
    final expenses = await getTotalExpenses(startDate, endDate);
    return income - expenses;
  }

  /// Gets transaction count by category within a date range.
  /// 
  /// [startDate] The start date (inclusive).
  /// [endDate] The end date (inclusive).
  /// Returns a map of category to transaction count.
  Future<Map<String, int>> getTransactionCountByCategory(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _database.getTransactionCountByCategory(startDate, endDate);
  }

  /// Gets spending breakdown by category within a date range.
  /// 
  /// [startDate] The start date (inclusive).
  /// [endDate] The end date (inclusive).
  /// Returns a map of category to total amount spent.
  Future<Map<String, double>> getSpendingByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final transactions = await _database
        .watchTransactionsByDateRange(startDate, endDate)
        .first;

    final Map<String, double> spendingByCategory = {};

    for (final transaction in transactions) {
      if (!transaction.isIncome) {
        final category = transaction.category;
        final amount = transaction.amount.abs();
        spendingByCategory[category] = (spendingByCategory[category] ?? 0) + amount;
      }
    }

    return spendingByCategory;
  }

  /// Gets income breakdown by category within a date range.
  /// 
  /// [startDate] The start date (inclusive).
  /// [endDate] The end date (inclusive).
  /// Returns a map of category to total income amount.
  Future<Map<String, double>> getIncomeByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final transactions = await _database
        .watchTransactionsByDateRange(startDate, endDate)
        .first;

    final Map<String, double> incomeByCategory = {};

    for (final transaction in transactions) {
      if (transaction.isIncome) {
        final category = transaction.category;
        final amount = transaction.amount;
        incomeByCategory[category] = (incomeByCategory[category] ?? 0) + amount;
      }
    }

    return incomeByCategory;
  }

  /// Searches transactions by merchant name or description.
  /// 
  /// [query] The search query string.
  /// [startDate] Optional start date filter.
  /// [endDate] Optional end date filter.
  /// Returns a list of transactions matching the search criteria.
  Future<List<Transaction>> searchTransactions(
    String query, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Get all transactions in the date range (or all if no date filter)
    Stream<List<TransactionData>> transactionStream;

    if (startDate != null && endDate != null) {
      transactionStream = _database.watchTransactionsByDateRange(startDate, endDate);
    } else {
      transactionStream = _database.watchAllTransactions();
    }

    final transactions = await transactionStream.first;

    // Filter by search query
    final filteredTransactions = transactions.where((transaction) {
      final lowerQuery = query.toLowerCase();
      final merchantMatch = transaction.merchant.toLowerCase().contains(lowerQuery);
      final descriptionMatch = transaction.description?.toLowerCase().contains(lowerQuery) ?? false;
      return merchantMatch || descriptionMatch;
    }).toList();

    return Transaction.fromDataList(filteredTransactions);
  }

  /// Gets daily spending totals within a date range.
  /// 
  /// [startDate] The start date (inclusive).
  /// [endDate] The end date (inclusive).
  /// Returns a map of date to total spending amount.
  Future<Map<DateTime, double>> getDailySpending(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final transactions = await _database
        .watchTransactionsByDateRange(startDate, endDate)
        .first;

    final Map<DateTime, double> dailySpending = {};

    for (final transaction in transactions) {
      if (!transaction.isIncome) {
        final date = DateTime(
          transaction.date.year,
          transaction.date.month,
          transaction.date.day,
        );
        final amount = transaction.amount.abs();
        dailySpending[date] = (dailySpending[date] ?? 0) + amount;
      }
    }

    return dailySpending;
  }

  /// Gets monthly spending totals for a given year.
  /// 
  /// [year] The year to get monthly spending for.
  /// Returns a map of month to total spending amount.
  Future<Map<int, double>> getMonthlySpending(int year) async {
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31, 23, 59, 59);

    final transactions = await _database
        .watchTransactionsByDateRange(startDate, endDate)
        .first;

    final Map<int, double> monthlySpending = {};

    for (final transaction in transactions) {
      if (!transaction.isIncome) {
        final month = transaction.date.month;
        final amount = transaction.amount.abs();
        monthlySpending[month] = (monthlySpending[month] ?? 0) + amount;
      }
    }

    return monthlySpending;
  }

  /// Closes the database connection.
  /// 
  /// This should be called when the service is no longer needed
  /// to properly close the database connection.
  Future<void> close() {
    return _database.close();
  }
}