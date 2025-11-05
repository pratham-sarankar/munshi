import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:munshi/core/models/currency.dart';

class CurrencyProvider extends ChangeNotifier {
  static const String _currencyCodeKey = 'selected_currency_code';

  Currency _selectedCurrency = SupportedCurrencies.defaultCurrency;

  Currency get selectedCurrency => _selectedCurrency;

  final SharedPreferences prefs;

  /// Creates a CurrencyProvider and loads the currency synchronously from SharedPreferences.
  CurrencyProvider(this.prefs) {
    _loadCurrencyFromPrefs();
  }

  void setSelectedCurrency(Currency currency) {
    if (_selectedCurrency != currency) {
      _selectedCurrency = currency;
      _saveCurrencyToPrefs();
      notifyListeners();
    }
  }

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

  void _saveCurrencyToPrefs() {
    prefs.setString(_currencyCodeKey, _selectedCurrency.code);
  }
}
