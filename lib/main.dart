import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:munshi/core/theme.dart';
import 'package:munshi/screens/main_screen.dart';
import 'package:munshi/providers/theme_provider.dart';
import 'package:munshi/features/transactions/services/transaction_service.dart';
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

  // Initialize sample data for testing (only in debug mode)
  if (kDebugMode) {
    await _initializeSampleData();
  }

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

/// Initializes sample transaction data for testing purposes.
/// 
/// This function adds sample transactions to the database to demonstrate
/// the app functionality. It only runs in debug mode and checks if
/// data already exists to avoid duplicates.
Future<void> _initializeSampleData() async {
  try {
    final transactionService = locator<TransactionService>();
    
    // Check if data already exists by getting all transactions
    final existingTransactions = await transactionService.watchAllTransactions().first;
    
    // Only add sample data if the database is empty
    if (existingTransactions.isEmpty) {
      final now = DateTime.now();
      
      // Add sample expense transactions
      await transactionService.addTransaction(
        merchant: 'Zomato',
        amount: 250.0,
        date: now.subtract(const Duration(hours: 2)),
        time: '2:30 PM',
        category: 'Food & Dining',
        isIncome: false,
        description: 'Lunch order from office',
      );
      
      await transactionService.addTransaction(
        merchant: 'Amazon',
        amount: 1200.0,
        date: now.subtract(const Duration(days: 1)),
        time: '11:45 AM',
        category: 'Shopping',
        isIncome: false,
        description: 'Electronics purchase',
      );
      
      await transactionService.addTransaction(
        merchant: 'Uber',
        amount: 400.0,
        date: now.subtract(const Duration(days: 1)),
        time: '7:30 PM',
        category: 'Transportation',
        isIncome: false,
        description: 'Ride to airport',
      );
      
      await transactionService.addTransaction(
        merchant: 'Electricity Bill',
        amount: 1800.0,
        date: now.subtract(const Duration(days: 2)),
        time: '9:15 AM',
        category: 'Bills & Utilities',
        isIncome: false,
        description: 'Monthly electricity bill',
      );
      
      await transactionService.addTransaction(
        merchant: 'Burger King',
        amount: 600.0,
        date: now.subtract(const Duration(days: 3)),
        time: '1:20 PM',
        category: 'Food & Dining',
        isIncome: false,
        description: 'Family dinner',
      );
      
      // Add sample income transactions
      await transactionService.addTransaction(
        merchant: 'TechCorp Inc.',
        amount: 85000.0,
        date: now.subtract(const Duration(days: 5)),
        time: '10:00 AM',
        category: 'Salary',
        isIncome: true,
        description: 'Monthly salary credit',
      );
      
      await transactionService.addTransaction(
        merchant: 'Freelance Client',
        amount: 15000.0,
        date: now.subtract(const Duration(days: 7)),
        time: '3:45 PM',
        category: 'Freelance',
        isIncome: true,
        description: 'Website development project',
      );
      
      await transactionService.addTransaction(
        merchant: 'Investment Returns',
        amount: 2500.0,
        date: now.subtract(const Duration(days: 10)),
        time: '12:00 PM',
        category: 'Investment',
        isIncome: true,
        description: 'Mutual fund dividend',
      );
      
      if (kDebugMode) {
        print('Sample transaction data initialized successfully');
      }
    } else {
      if (kDebugMode) {
        print('Transaction data already exists, skipping sample data initialization');
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error initializing sample data: $error');
    }
  }
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
