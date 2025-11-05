import 'package:munshi/providers/currency_provider.dart';
import 'package:munshi/core/service_locator.dart';

/// Extension on String to add currency formatting functionality
extension CurrencyStringExtension on String {
  /// Adds the selected currency symbol at the beginning of the string
  /// Example: "100".withCurrency() => "₹100"
  String withCurrency() {
    try {
      final currencyProvider = locator<CurrencyProvider>();
      final symbol = currencyProvider.selectedCurrency.symbol;
      return '$symbol$this';
    } catch (e) {
      // Fallback to INR symbol if provider is not available
      return '₹$this';
    }
  }

  /// Adds the selected currency symbol with proper spacing for formatted amounts
  /// Example: "1,000".withCurrencySpaced() => "₹ 1,000"
  String withCurrencySpaced() {
    try {
      final currencyProvider = locator<CurrencyProvider>();
      final symbol = currencyProvider.selectedCurrency.symbol;
      return '$symbol $this';
    } catch (e) {
      // Fallback to INR symbol if provider is not available
      return '₹ $this';
    }
  }
}

/// Extension on double to add currency formatting functionality
extension CurrencyDoubleExtension on double {
  /// Formats the double as currency with the selected currency symbol
  /// Example: 1000.0.toCurrency() => "₹1,000"
  String toCurrency({int decimalPlaces = 0, bool useGrouping = true}) {
    try {
      final currencyProvider = locator<CurrencyProvider>();
      final symbol = currencyProvider.selectedCurrency.symbol;

      String formattedAmount;
      if (useGrouping) {
        // Format with comma separators using Western grouping (groups of 3)
        formattedAmount = toStringAsFixed(decimalPlaces).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},',
        );
      } else {
        formattedAmount = toStringAsFixed(decimalPlaces);
      }

      return '$symbol$formattedAmount';
    } catch (e) {
      // Fallback formatting with INR symbol using Western grouping
      String formattedAmount;
      if (useGrouping) {
        formattedAmount = toStringAsFixed(decimalPlaces).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},',
        );
      } else {
        formattedAmount = toStringAsFixed(decimalPlaces);
      }
      return '₹$formattedAmount';
    }
  }

  /// Formats the double as currency with spacing
  /// Example: 1000.0.toCurrencySpaced() => "₹ 1,000"
  String toCurrencySpaced({int decimalPlaces = 0, bool useGrouping = true}) {
    try {
      final currencyProvider = locator<CurrencyProvider>();
      final symbol = currencyProvider.selectedCurrency.symbol;

      String formattedAmount;
      if (useGrouping) {
        // Format with comma separators using Western grouping (groups of 3)
        formattedAmount = toStringAsFixed(decimalPlaces).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},',
        );
      } else {
        formattedAmount = toStringAsFixed(decimalPlaces);
      }

      return '$symbol $formattedAmount';
    } catch (e) {
      // Fallback formatting with INR symbol using Western grouping
      String formattedAmount;
      if (useGrouping) {
        formattedAmount = toStringAsFixed(decimalPlaces).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},',
        );
      } else {
        formattedAmount = toStringAsFixed(decimalPlaces);
      }
      return '₹ $formattedAmount';
    }
  }

  /// Formats the double as currency for transactions (with + or - prefix)
  /// Example: 1000.0.toTransactionCurrency(isExpense: true) => "- ₹1,000"
  String toTransactionCurrency({
    required bool isExpense,
    int decimalPlaces = 2,
    bool useGrouping = true,
  }) {
    final prefix = isExpense ? '- ' : '+ ';
    final currencyFormatted = toCurrency(
      decimalPlaces: decimalPlaces,
      useGrouping: useGrouping,
    );
    return '$prefix$currencyFormatted';
  }
}

/// Extension on int to add currency formatting functionality
extension CurrencyIntExtension on int {
  /// Formats the int as currency with the selected currency symbol
  /// Example: 1000.toCurrency() => "₹1,000"
  String toCurrency({bool useGrouping = true}) {
    return toDouble().toCurrency(decimalPlaces: 0, useGrouping: useGrouping);
  }

  /// Formats the int as currency with spacing
  /// Example: 1000.toCurrencySpaced() => "₹ 1,000"
  String toCurrencySpaced({bool useGrouping = true}) {
    return toDouble().toCurrencySpaced(
      decimalPlaces: 0,
      useGrouping: useGrouping,
    );
  }

  /// Formats the int as currency for transactions (with + or - prefix)
  /// Example: 1000.toTransactionCurrency(isExpense: true) => "- ₹1,000"
  String toTransactionCurrency({
    required bool isExpense,
    bool useGrouping = true,
  }) {
    return toDouble().toTransactionCurrency(
      isExpense: isExpense,
      decimalPlaces: 0,
      useGrouping: useGrouping,
    );
  }
}
