class Currency {
  final String code;
  final String symbol;
  final String name;
  final String flag;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  String get displayName => '$flag $symbol ($code)';

  Map<String, dynamic> toMap() {
    return {'code': code, 'symbol': symbol, 'name': name, 'flag': flag};
  }

  factory Currency.fromMap(Map<String, dynamic> map) {
    return Currency(
      code: map['code'] ?? '',
      symbol: map['symbol'] ?? '',
      name: map['name'] ?? '',
      flag: map['flag'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Currency{code: $code, symbol: $symbol, name: $name, flag: $flag}';
  }
}

/// List of supported currencies
class SupportedCurrencies {
  static const List<Currency> currencies = [
    // Major currencies
    Currency(code: 'USD', symbol: '\$', name: 'US Dollar', flag: '🇺🇸'),
    Currency(code: 'EUR', symbol: '€', name: 'Euro', flag: '🇪🇺'),
    Currency(code: 'GBP', symbol: '£', name: 'British Pound', flag: '🇬🇧'),
    Currency(code: 'INR', symbol: '₹', name: 'Indian Rupee', flag: '🇮🇳'),
    Currency(code: 'JPY', symbol: '¥', name: 'Japanese Yen', flag: '🇯🇵'),
    Currency(code: 'CNY', symbol: '¥', name: 'Chinese Yuan', flag: '🇨🇳'),
    Currency(
      code: 'AUD',
      symbol: 'A\$',
      name: 'Australian Dollar',
      flag: '🇦🇺',
    ),
    Currency(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar', flag: '🇨🇦'),
    Currency(code: 'CHF', symbol: 'Fr', name: 'Swiss Franc', flag: '🇨🇭'),
    Currency(
      code: 'SGD',
      symbol: 'S\$',
      name: 'Singapore Dollar',
      flag: '🇸🇬',
    ),
    Currency(
      code: 'HKD',
      symbol: 'HK\$',
      name: 'Hong Kong Dollar',
      flag: '🇭🇰',
    ),
    Currency(
      code: 'NZD',
      symbol: 'NZ\$',
      name: 'New Zealand Dollar',
      flag: '🇳🇿',
    ),
    Currency(code: 'SEK', symbol: 'kr', name: 'Swedish Krona', flag: '🇸🇪'),
    Currency(code: 'NOK', symbol: 'kr', name: 'Norwegian Krone', flag: '🇳🇴'),
    Currency(code: 'DKK', symbol: 'kr', name: 'Danish Krone', flag: '🇩🇰'),
    Currency(code: 'PLN', symbol: 'zł', name: 'Polish Złoty', flag: '🇵🇱'),
    Currency(code: 'CZK', symbol: 'Kč', name: 'Czech Koruna', flag: '🇨🇿'),
    Currency(code: 'HUF', symbol: 'Ft', name: 'Hungarian Forint', flag: '🇭🇺'),
    Currency(code: 'RON', symbol: 'lei', name: 'Romanian Leu', flag: '🇷🇴'),
    Currency(code: 'BGN', symbol: 'лв', name: 'Bulgarian Lev', flag: '🇧🇬'),
    Currency(code: 'HRK', symbol: 'kn', name: 'Croatian Kuna', flag: '🇭🇷'),
    Currency(code: 'RUB', symbol: '₽', name: 'Russian Ruble', flag: '🇷🇺'),
    Currency(code: 'TRY', symbol: '₺', name: 'Turkish Lira', flag: '🇹🇷'),
    Currency(
      code: 'ZAR',
      symbol: 'R',
      name: 'South African Rand',
      flag: '🇿🇦',
    ),
    Currency(code: 'BRL', symbol: 'R\$', name: 'Brazilian Real', flag: '🇧🇷'),
    Currency(code: 'MXN', symbol: '\$', name: 'Mexican Peso', flag: '🇲🇽'),
    Currency(code: 'ARS', symbol: '\$', name: 'Argentine Peso', flag: '🇦🇷'),
    Currency(code: 'CLP', symbol: '\$', name: 'Chilean Peso', flag: '🇨🇱'),
    Currency(code: 'COP', symbol: '\$', name: 'Colombian Peso', flag: '🇨🇴'),
    Currency(code: 'PEN', symbol: 'S/', name: 'Peruvian Sol', flag: '🇵🇪'),
    Currency(code: 'KRW', symbol: '₩', name: 'South Korean Won', flag: '🇰🇷'),
    Currency(code: 'THB', symbol: '฿', name: 'Thai Baht', flag: '🇹🇭'),
    Currency(
      code: 'MYR',
      symbol: 'RM',
      name: 'Malaysian Ringgit',
      flag: '🇲🇾',
    ),
    Currency(
      code: 'IDR',
      symbol: 'Rp',
      name: 'Indonesian Rupiah',
      flag: '🇮🇩',
    ),
    Currency(code: 'PHP', symbol: '₱', name: 'Philippine Peso', flag: '🇵🇭'),
    Currency(code: 'VND', symbol: '₫', name: 'Vietnamese Dong', flag: '🇻🇳'),
    Currency(code: 'PKR', symbol: '₨', name: 'Pakistani Rupee', flag: '🇵🇰'),
    Currency(code: 'BDT', symbol: '৳', name: 'Bangladeshi Taka', flag: '🇧🇩'),
    Currency(code: 'LKR', symbol: '₨', name: 'Sri Lankan Rupee', flag: '🇱🇰'),
    Currency(code: 'NPR', symbol: '₨', name: 'Nepalese Rupee', flag: '🇳🇵'),
    Currency(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham', flag: '🇦🇪'),
    Currency(code: 'SAR', symbol: '﷼', name: 'Saudi Riyal', flag: '🇸🇦'),
    Currency(code: 'QAR', symbol: '﷼', name: 'Qatari Riyal', flag: '🇶🇦'),
    Currency(code: 'KWD', symbol: 'د.ك', name: 'Kuwaiti Dinar', flag: '🇰🇼'),
    Currency(code: 'BHD', symbol: '.د.ب', name: 'Bahraini Dinar', flag: '🇧🇭'),
    Currency(code: 'OMR', symbol: '﷼', name: 'Omani Rial', flag: '🇴🇲'),
    Currency(code: 'ILS', symbol: '₪', name: 'Israeli Shekel', flag: '🇮🇱'),
    Currency(code: 'EGP', symbol: '£', name: 'Egyptian Pound', flag: '🇪🇬'),
    Currency(code: 'NGN', symbol: '₦', name: 'Nigerian Naira', flag: '🇳🇬'),
    Currency(code: 'KES', symbol: 'KSh', name: 'Kenyan Shilling', flag: '🇰🇪'),
    Currency(code: 'GHS', symbol: '₵', name: 'Ghanaian Cedi', flag: '🇬🇭'),
  ];

  /// Get currency by code
  static Currency? getCurrencyByCode(String code) {
    try {
      return currencies.firstWhere(
        (currency) => currency.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get default currency (INR)
  static Currency get defaultCurrency {
    return getCurrencyByCode('INR') ?? currencies.first;
  }

  /// Search currencies by name, code, or symbol
  static List<Currency> searchCurrencies(String query) {
    if (query.isEmpty) return currencies;

    final lowercaseQuery = query.toLowerCase();
    return currencies.where((currency) {
      return currency.name.toLowerCase().contains(lowercaseQuery) ||
          currency.code.toLowerCase().contains(lowercaseQuery) ||
          currency.symbol.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
