import 'package:get_it/get_it.dart';
import 'package:munshi/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt locator = GetIt.instance;

/// Sets up dependency injection for the app using get_it.
///
/// Registers SharedPreferences as a singleton, then ThemeProvider with the prefs instance.
/// This allows ThemeProvider to synchronously access SharedPreferences.
Future<void> setupLocator() async {
  final prefs = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(prefs);
  locator.registerLazySingleton<ThemeProvider>(() => ThemeProvider(prefs));
}
