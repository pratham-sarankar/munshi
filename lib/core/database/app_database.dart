import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:munshi/core/database/converters/transaction_type_converter.dart';
import 'package:munshi/core/database/converters/transaction_category_converter.dart';
import 'package:munshi/features/transactions/models/transaction_category.dart';
import 'package:munshi/features/transactions/models/transaction_type.dart';
import 'package:path_provider/path_provider.dart';
import './tables/transactions.dart';
import './daos/transaction_dao.dart';
part 'app_database.g.dart';

@DriftDatabase(tables: [Transactions], daos: [TransactionsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'munshi_database',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
