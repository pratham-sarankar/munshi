import 'package:get_it/get_it.dart';
import 'package:munshi/providers/theme_provider.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<ThemeProvider>(() => ThemeProvider());
}
