import 'package:flutter/material.dart';
import 'package:munshi/core/models/currency.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the user's selected currency and persists it via [SharedPreferences].
class CurrencyProvider extends ChangeNotifier {
  /// Creates a CurrencyProvider and loads the currency synchronously from SharedPreferences.
  CurrencyProvider(this.prefs) {
    _loadCurrencyFromPrefs();
  }
  static const String _currencyCodeKey = 'selected_currency_code';

  Currency _selectedCurrency = SupportedCurrencies.defaultCurrency;

  /// The currently selected currency.
  Currency get selectedCurrency => _selectedCurrency;

  /// The [SharedPreferences] instance used to persist the selected currency.
  final SharedPreferences prefs;

  /// Changes the selected currency and persists the change.
  void setSelectedCurrency(Currency currency) {
    if (_selectedCurrency != currency) {
      _selectedCurrency = currency;
      _saveCurrencyToPrefs();
      notifyListeners();
    }
  }

  /// Changes the selected currency by its ISO [currencyCode].
  void setSelectedCurrencyByCode(String currencyCode) {
    final currency = SupportedCurrencies.getCurrencyByCode(currencyCode);
    if (currency != null) {
      setSelectedCurrency(currency);
    }
  }

  void _loadCurrencyFromPrefs() {
    final currencyCode = prefs.getString(_currencyCodeKey);
    if (currencyCode != null) {
      final currency = SupportedCurrencies.getCurrencyByCode(currencyCode);
      if (currency != null) {
        _selectedCurrency = currency;
        notifyListeners();
      }
    }
  }

  Future<void> _saveCurrencyToPrefs() async {
    await prefs.setString(_currencyCodeKey, _selectedCurrency.code);
  }
}
