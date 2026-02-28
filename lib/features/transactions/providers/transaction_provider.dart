import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/database/daos/transaction_dao.dart';
import 'package:munshi/features/transactions/models/grouped_transactions.dart';
import 'package:munshi/features/transactions/models/transaction_filter.dart';
import 'package:munshi/features/transactions/models/transaction_with_category.dart';

class TransactionProvider extends ChangeNotifier {
  TransactionProvider(
    this._transactionsDao, {
    VoidCallback? onTransactionChanged,
  }) : _onTransactionChanged = onTransactionChanged {
    loadNextPage();
  }

  static const int pageSize = 20;

  final TransactionsDao _transactionsDao;
  VoidCallback? _onTransactionChanged;
  TransactionFilter _currentFilter = TransactionFilter.empty();

  // Pagination state
  List<TransactionWithCategory> _transactions = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;
  int _offset = 0;
  // Token used to cancel superseded page loads after a refresh
  int _loadToken = 0;
  Object? _loadError;

  /// Set the callback to be called when transactions change
  set onTransactionChanged(VoidCallback? callback) {
    _onTransactionChanged = callback;
  }

  /// Get the current filter
  TransactionFilter get currentFilter => _currentFilter;

  /// Whether more pages are available
  bool get hasMore => _hasMore;

  /// Whether a page load is in progress
  bool get isLoadingMore => _isLoadingMore;

  /// The last error that occurred during a page load, or null if none.
  Object? get loadError => _loadError;

  /// Transactions grouped by date from the currently loaded pages
  List<GroupedTransactions> get groupedTransactions {
    if (_transactions.isEmpty) return [];

    final groupedMap = <String, List<TransactionWithCategory>>{};
    for (final transaction in _transactions) {
      final d = transaction.date;
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      groupedMap.putIfAbsent(key, () => []).add(transaction);
    }

    final sortedKeys = groupedMap.keys.toList()..sort((a, b) => b.compareTo(a));
    return sortedKeys.map((key) {
      return GroupedTransactions(
        date: DateTime.parse(key),
        transactions: groupedMap[key]!,
      );
    }).toList();
  }

  /// Apply a new filter and reload from the first page
  void applyFilter(TransactionFilter filter) {
    _currentFilter = filter;
    refresh();
  }

  /// Clear all filters and reload from the first page
  void clearFilters() {
    _currentFilter = TransactionFilter.empty();
    refresh();
  }

  /// Reset pagination state and reload the first page.
  ///
  /// Any in-progress page loads are invalidated via [_loadToken].
  Future<void> refresh() async {
    _loadToken++;
    _offset = 0;
    _transactions = [];
    _hasMore = true;
    _isLoadingMore = false;
    _loadError = null;
    await loadNextPage();
  }

  /// Load the next page of transactions (no-op if already loading or no more).
  Future<void> loadNextPage() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    _loadError = null;
    notifyListeners();

    final token = _loadToken;
    try {
      final categoryIds = _currentFilter.categories?.map((c) => c.id).toSet();

      final result = await _transactionsDao.getTransactionsPaged(
        limit: pageSize,
        offset: _offset,
        startDate: _currentFilter.effectiveStartDate,
        endDate: _currentFilter.effectiveEndDate,
        types: _currentFilter.types,
        minAmount: _currentFilter.minAmount,
        maxAmount: _currentFilter.maxAmount,
        categoryIds: categoryIds,
      );

      // Discard results if a refresh() was called while this load was in flight
      if (token != _loadToken) return;

      _transactions.addAll(result);
      _hasMore = result.length == pageSize;
      _offset += result.length;
    } on Exception catch (e) {
      if (token != _loadToken) return;
      _loadError = e;
      debugPrint('TransactionProvider: failed to load page: $e');
    } finally {
      if (token == _loadToken) {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> addTransaction(Insertable<Transaction> transaction) async {
    await _transactionsDao.insertTransaction(transaction);
    _onTransactionChanged?.call();
    await refresh();
  }

  Future<void> updateTransaction(Insertable<Transaction> transaction) async {
    await _transactionsDao.updateTransaction(transaction);
    _onTransactionChanged?.call();
    await refresh();
  }

  Future<void> deleteTransaction(TransactionWithCategory transaction) async {
    await _transactionsDao.deleteTransaction(transaction.transaction);
    _onTransactionChanged?.call();
    await refresh();
  }
}
