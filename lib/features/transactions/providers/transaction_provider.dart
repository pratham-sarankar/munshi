import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:munshi/core/database/tables/transactions.dart';
import '../../../core/database/daos/transaction_dao.dart';
import '../../../core/database/app_database.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionsDao _transactionsDao;

  TransactionProvider(this._transactionsDao);

  Stream<List<Transaction>> get watchTransactions =>
      _transactionsDao.watchAllTransactions();

  Future<void> addTransaction(Insertable<Transaction> transaction) async {
    await _transactionsDao.insertTransaction(transaction);
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    await _transactionsDao.deleteTransaction(transaction);
  }
}
