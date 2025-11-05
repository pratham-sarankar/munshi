import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../../../core/database/daos/transaction_dao.dart';
import '../../../core/database/app_database.dart';
import '../models/grouped_transactions.dart';
import '../models/transaction_filter.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionsDao _transactionsDao;
  TransactionFilter _currentFilter = TransactionFilter.empty();

  TransactionProvider(this._transactionsDao);

  /// Get the current filter
  TransactionFilter get currentFilter => _currentFilter;

  /// Apply a new filter
  void applyFilter(TransactionFilter filter) {
    _currentFilter = filter;
    if (kDebugMode) {
      print(
        'Applied filter with categories: ${filter.categories?.map((c) => c.name).join(', ') ?? 'none'}',
      );
    }
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _currentFilter = TransactionFilter.empty();
    notifyListeners();
  }

  Stream<List<Transaction>> get watchTransactions =>
      _transactionsDao.watchAllTransactions();

  Stream<List<GroupedTransactions>> get watchGroupedTransactions {
    if (!_currentFilter.hasActiveFilters) {
      return _transactionsDao.watchTransactionsGroupedByDate();
    }

    return _transactionsDao
        .watchTransactionsGroupedByDate(
          startDate: _currentFilter.effectiveStartDate,
          endDate: _currentFilter.effectiveEndDate,
        )
        .map(
          (groupedTransactions) =>
              _applyFiltersToGroupedTransactions(groupedTransactions),
        );
  }

  /// Apply filters to grouped transactions
  List<GroupedTransactions> _applyFiltersToGroupedTransactions(
    List<GroupedTransactions> groupedTransactions,
  ) {
    if (!_currentFilter.hasActiveFilters) {
      return groupedTransactions;
    }

    final filteredGroups = <GroupedTransactions>[];

    for (final group in groupedTransactions) {
      final filteredTransactions = group.transactions.where((transaction) {
        // Amount filter
        if (_currentFilter.minAmount != null &&
            transaction.amount < _currentFilter.minAmount!) {
          return false;
        }
        if (_currentFilter.maxAmount != null &&
            transaction.amount > _currentFilter.maxAmount!) {
          return false;
        }

        // Type filter
        if (_currentFilter.types != null &&
            _currentFilter.types!.isNotEmpty &&
            !_currentFilter.types!.contains(transaction.type)) {
          return false;
        }

        // Category filter
        if (_currentFilter.categories != null &&
            _currentFilter.categories!.isNotEmpty &&
            !_currentFilter.categories!.contains(transaction.category)) {
          if (kDebugMode) {
            print('Filtering out transaction: ${transaction.category.name}');
            print(
              'Filter categories: ${_currentFilter.categories!.map((c) => c.name).join(', ')}',
            );
          }
          return false;
        }

        return true;
      }).toList();

      if (filteredTransactions.isNotEmpty) {
        filteredGroups.add(
          GroupedTransactions(
            date: group.date,
            transactions: filteredTransactions,
          ),
        );
      }
    }

    return filteredGroups;
  }

  Stream<List<GroupedTransactions>> watchGroupedTransactionsInRange({
    DateTime? startDate,
    DateTime? endDate,
  }) => _transactionsDao.watchTransactionsGroupedByDate(
    startDate: startDate,
    endDate: endDate,
  );

  Future<List<GroupedTransactions>> getGroupedTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) => _transactionsDao.getTransactionsGroupedByDate(
    startDate: startDate,
    endDate: endDate,
  );

  Future<void> addTransaction(Insertable<Transaction> transaction) async {
    await _transactionsDao.insertTransaction(transaction);
  }

  Future<void> updateTransaction(Insertable<Transaction> transaction) async {
    await _transactionsDao.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    await _transactionsDao.deleteTransaction(transaction);
  }
}
