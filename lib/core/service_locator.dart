import 'package:get_it/get_it.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/database/daos/transaction_dao.dart'
    show TransactionsDao;
import 'package:munshi/features/auth/services/auth_service.dart';
import 'package:munshi/features/dashboard/services/dashboard_data_service.dart';
import 'package:munshi/providers/theme_provider.dart';
import 'package:munshi/providers/currency_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt locator = GetIt.instance;

/// Sets up the service locator by registering necessary singletons and lazy singletons.
///
/// This function performs the following:
/// - Retrieves an instance of [SharedPreferences] and registers it as a singleton.
/// - Registers [ThemeProvider] as a lazy singleton, initialized with the shared preferences.
/// - Registers [CurrencyProvider] as a lazy singleton, initialized with the shared preferences.
/// - Registers [AppDatabase] as a lazy singleton for database access.
/// - Registers [TransactionsDao] as a lazy singleton, initialized with the [AppDatabase] instance.
/// - Registers [DashboardDataService] as a lazy singleton, initialized with the [TransactionsDao] instance.
/// - Registers [AuthService] as a lazy singleton for authentication operations.
///
/// Call this function during app initialization to ensure all dependencies are available via the locator.
Future<void> setupLocator() async {
  final prefs = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(prefs);
  locator.registerLazySingleton<ThemeProvider>(() => ThemeProvider(prefs));
  locator.registerLazySingleton<CurrencyProvider>(
    () => CurrencyProvider(prefs),
  );

  locator.registerLazySingleton<AppDatabase>(() => AppDatabase());
  locator.registerLazySingleton<TransactionsDao>(
    () => TransactionsDao(locator<AppDatabase>()),
  );
  locator.registerLazySingleton<DashboardDataService>(
    () => DashboardDataService(locator<TransactionsDao>()),
  );

  // Register AuthService as a lazy singleton
  final authService = AuthService();
  await authService.init();
  locator.registerLazySingleton<AuthService>(() => authService);
}
