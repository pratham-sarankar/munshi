// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_local_datasource.dart';

// ignore_for_file: type=lint
mixin _$TransactionLocalDataSourceMixin on DatabaseAccessor<AppDatabase> {
  $TransactionCategoriesTable get transactionCategories =>
      attachedDatabase.transactionCategories;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  TransactionLocalDataSourceManager get managers =>
      TransactionLocalDataSourceManager(this);
}

class TransactionLocalDataSourceManager {
  final _$TransactionLocalDataSourceMixin _db;
  TransactionLocalDataSourceManager(this._db);
  $$TransactionCategoriesTableTableManager get transactionCategories =>
      $$TransactionCategoriesTableTableManager(
        _db.attachedDatabase,
        _db.transactionCategories,
      );
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
}
