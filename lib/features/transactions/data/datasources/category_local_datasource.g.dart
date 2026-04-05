// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_local_datasource.dart';

// ignore_for_file: type=lint
mixin _$CategoryLocalDataSourceMixin on DatabaseAccessor<AppDatabase> {
  $TransactionCategoriesTable get transactionCategories =>
      attachedDatabase.transactionCategories;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  CategoryLocalDataSourceManager get managers =>
      CategoryLocalDataSourceManager(this);
}

class CategoryLocalDataSourceManager {
  final _$CategoryLocalDataSourceMixin _db;
  CategoryLocalDataSourceManager(this._db);
  $$TransactionCategoriesTableTableManager get transactionCategories =>
      $$TransactionCategoriesTableTableManager(
        _db.attachedDatabase,
        _db.transactionCategories,
      );
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
}
