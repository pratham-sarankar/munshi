import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/database/daos/transaction_dao.dart';
import '../../../core/database/app_database.dart';
import '../models/grouped_transactions.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionsDao _transactionsDao;

  TransactionProvider(this._transactionsDao);

  Stream<List<Transaction>> get watchTransactions =>
      _transactionsDao.watchAllTransactions();

  Stream<List<GroupedTransactions>> get watchGroupedTransactions =>
      _transactionsDao.watchTransactionsGroupedByDate();

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
