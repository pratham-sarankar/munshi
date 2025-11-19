import 'package:intl/intl.dart';
import 'package:munshi/core/service_locator.dart';
import 'package:munshi/providers/currency_provider.dart';

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
  /// Helper method to format a number with optional grouping using intl package
  String _formatAmount({
    required int decimalPlaces,
    required bool useGrouping,
  }) {
    if (useGrouping) {
      try {
        final currencyProvider = locator<CurrencyProvider>();
        final selectedCurrency = currencyProvider.selectedCurrency;

        // Create NumberFormat with the currency's locale and decimal places
        final formatter = NumberFormat.decimalPatternDigits(
          locale: selectedCurrency.locale,
          decimalDigits: decimalPlaces,
        );

        return formatter.format(this);
      } catch (e) {
        // Fallback to Indian locale formatting if provider is not available
        final formatter = NumberFormat.decimalPatternDigits(
          locale: 'hi_IN',
          decimalDigits: decimalPlaces,
        );
        return formatter.format(this);
      }
    } else {
      return toStringAsFixed(decimalPlaces);
    }
  }

  /// Formats the double as currency with the selected currency symbol
  /// Example: 1000.0.toCurrency() => "₹1,000"
  String toCurrency({int decimalPlaces = 0, bool useGrouping = true}) {
    try {
      final currencyProvider = locator<CurrencyProvider>();
      final symbol = currencyProvider.selectedCurrency.symbol;
      final formattedAmount = _formatAmount(
        decimalPlaces: decimalPlaces,
        useGrouping: useGrouping,
      );
      return '$symbol$formattedAmount';
    } catch (e) {
      // Fallback formatting with INR symbol
      final formattedAmount = _formatAmount(
        decimalPlaces: decimalPlaces,
        useGrouping: useGrouping,
      );
      return '₹$formattedAmount';
    }
  }

  /// Formats the double as currency with spacing
  /// Example: 1000.0.toCurrencySpaced() => "₹ 1,000"
  String toCurrencySpaced({int decimalPlaces = 0, bool useGrouping = true}) {
    try {
      final currencyProvider = locator<CurrencyProvider>();
      final symbol = currencyProvider.selectedCurrency.symbol;
      final formattedAmount = _formatAmount(
        decimalPlaces: decimalPlaces,
        useGrouping: useGrouping,
      );
      return '$symbol $formattedAmount';
    } catch (e) {
      // Fallback formatting with INR symbol
      final formattedAmount = _formatAmount(
        decimalPlaces: decimalPlaces,
        useGrouping: useGrouping,
      );
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
    return toDouble().toCurrency(useGrouping: useGrouping);
  }

  /// Formats the int as currency with spacing
  /// Example: 1000.toCurrencySpaced() => "₹ 1,000"
  String toCurrencySpaced({bool useGrouping = true}) {
    return toDouble().toCurrencySpaced(
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
