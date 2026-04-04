import 'package:get_it/get_it.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/database/daos/transaction_dao.dart'
    show TransactionsDao;
import 'package:munshi/features/dashboard/services/dashboard_data_service.dart';
import 'package:munshi/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:munshi/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:munshi/features/transactions/domain/usecases/add_transaction.dart';
import 'package:munshi/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:munshi/features/transactions/domain/usecases/get_transactions_page.dart';
import 'package:munshi/features/transactions/domain/usecases/update_transaction.dart';
import 'package:munshi/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:munshi/providers/currency_provider.dart';
import 'package:munshi/providers/period_provider.dart';
import 'package:munshi/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The global [GetIt] service-locator instance.
final GetIt locator = GetIt.instance;

/// Sets up the service locator by registering necessary singletons and lazy singletons.
///
/// This function performs the following:
/// - Retrieves an instance of [SharedPreferences] and registers it as a singleton.
/// - Registers [ThemeProvider] as a lazy singleton, initialized with the shared preferences.
/// - Registers [CurrencyProvider] as a lazy singleton, initialized with the shared preferences.
/// - Registers [PeriodProvider] as a lazy singleton, initialized with the shared preferences.
/// - Registers [AppDatabase] as a lazy singleton for database access.
/// - Registers [TransactionsDao] as a lazy singleton, initialized with the [AppDatabase] instance.
/// - Registers [DashboardDataService] as a lazy singleton, initialized with the [TransactionsDao] instance.
/// - Registers [TransactionRepository] (backed by [TransactionRepositoryImpl]) as a lazy singleton.
/// - Registers the four transaction use cases as lazy singletons.
/// - Registers [TransactionBloc] as a factory so each call produces a fresh instance.
///
/// Call this function during app initialization to ensure all dependencies are available via the locator.
Future<void> setupLocator() async {
  final prefs = await SharedPreferences.getInstance();
  locator
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<ThemeProvider>(() => ThemeProvider(prefs))
    ..registerLazySingleton<CurrencyProvider>(
      () => CurrencyProvider(prefs),
    )
    ..registerLazySingleton<PeriodProvider>(() => PeriodProvider(prefs))
    ..registerLazySingleton<AppDatabase>(AppDatabase.new)
    ..registerLazySingleton<TransactionsDao>(
      () => TransactionsDao(locator<AppDatabase>()),
    )
    ..registerLazySingleton<DashboardDataService>(
      () => DashboardDataService(locator<TransactionsDao>()),
    )
    // Clean-architecture transaction wiring
    ..registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(locator<TransactionsDao>()),
    )
    ..registerLazySingleton<GetTransactionsPage>(
      () => GetTransactionsPage(locator<TransactionRepository>()),
    )
    ..registerLazySingleton<AddTransaction>(
      () => AddTransaction(locator<TransactionRepository>()),
    )
    ..registerLazySingleton<UpdateTransaction>(
      () => UpdateTransaction(locator<TransactionRepository>()),
    )
    ..registerLazySingleton<DeleteTransaction>(
      () => DeleteTransaction(locator<TransactionRepository>()),
    )
    ..registerFactory<TransactionBloc>(
      () => TransactionBloc(
        getTransactionsPage: locator<GetTransactionsPage>(),
        addTransaction: locator<AddTransaction>(),
        updateTransaction: locator<UpdateTransaction>(),
        deleteTransaction: locator<DeleteTransaction>(),
      ),
    );
}
