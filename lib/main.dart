import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:munshi/core/theme.dart';
import 'package:munshi/screens/main_screen.dart';
import 'package:munshi/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:munshi/core/service_locator.dart';

/// Main entry point for the Munshi app.
///
/// This function ensures Flutter bindings are initialized, preserves the native splash screen,
/// sets up dependency injection using get_it, initializes the ThemeProvider asynchronously,
/// and then removes the splash screen before running the app.
///
/// The ThemeProvider is injected using get_it and provided to the widget tree via Provider.
/// This guarantees the theme is loaded from persistent storage before the UI is shown, preventing flicker.
void main() async {
  // Ensure Flutter engine and widget binding is initialized before any async or plugin code.
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Preserve the native splash screen until initialization is complete.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Register all app-wide singletons/services using get_it, including SharedPreferences and ThemeProvider.
  // This ensures SharedPreferences is ready before ThemeProvider is created, allowing synchronous theme loading.
  await setupLocator();

  // Remove the splash screen after all dependencies are initialized.
  FlutterNativeSplash.remove();

  // Inject ThemeProvider into the widget tree using Provider, then launch the app.
  runApp(
    ChangeNotifierProvider.value(
      value: locator<ThemeProvider>(),
      child: const Munshi(),
    ),
  );
}

/// Root widget for the Munshi app.
///
/// Sets up Material Design 3 theming using Google Fonts and provides theme switching
/// based on the ThemeProvider's state. The MainScreen is the home widget.
class Munshi extends StatelessWidget {
  const Munshi({super.key});

  @override
  Widget build(BuildContext context) {
    // Create the MaterialTheme using the Manrope font for all text styles.
    final theme = MaterialTheme(
      GoogleFonts.manropeTextTheme(Typography.material2021().englishLike),
    );

    // Listen to ThemeProvider for theme changes and rebuild MaterialApp accordingly.
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Munshi',
          debugShowCheckedModeBanner: false,
          theme: theme.light(),
          darkTheme: theme.dark(),
          highContrastTheme: theme.lightHighContrast(),
          highContrastDarkTheme: theme.darkHighContrast(),
          themeMode: themeProvider
              .themeMode, // Uses the current theme mode from provider
          home: MainScreen(), // Main navigation and dashboard
        );
      },
    );
  }
}
