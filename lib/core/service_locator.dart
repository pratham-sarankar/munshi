import 'package:get_it/get_it.dart';
import 'package:munshi/providers/theme_provider.dart';
import 'package:munshi/core/database/munshi_database.dart';
import 'package:munshi/features/transactions/services/transaction_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt locator = GetIt.instance;

/// Sets up dependency injection for the app using get_it.
///
/// Registers all app-wide singletons and services including:
/// - SharedPreferences for persistent storage
/// - ThemeProvider for theme management
/// - MunshiDatabase for local data storage
/// - TransactionService for transaction operations
/// 
/// This ensures all dependencies are properly initialized before the app starts
/// and provides a centralized way to access them throughout the application.
Future<void> setupLocator() async {
  // Register SharedPreferences as a singleton
  // This must be done first as other services depend on it
  final prefs = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(prefs);

  // Register the MunshiDatabase as a singleton
  // This provides the core data storage layer for the application
  final database = MunshiDatabase();
  locator.registerSingleton<MunshiDatabase>(database);

  // Register the TransactionService as a singleton
  // This provides high-level transaction management operations
  locator.registerSingleton<TransactionService>(
    TransactionService(database),
  );

  // Register ThemeProvider with SharedPreferences dependency
  // This allows synchronous access to theme preferences
  locator.registerLazySingleton<ThemeProvider>(
    () => ThemeProvider(prefs),
  );
}
