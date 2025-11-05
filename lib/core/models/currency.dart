class Currency {
  final String code;
  final String symbol;
  final String name;
  final String flag;
  final String locale;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
    required this.locale,
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
    return {
      'code': code,
      'symbol': symbol,
      'name': name,
      'flag': flag,
      'locale': locale,
    };
  }

  factory Currency.fromMap(Map<String, dynamic> map) {
    return Currency(
      code: map['code'] ?? '',
      symbol: map['symbol'] ?? '',
      name: map['name'] ?? '',
      flag: map['flag'] ?? '',
      locale: map['locale'] ?? 'en_US',
    );
  }

  @override
  String toString() {
    return 'Currency{code: $code, symbol: $symbol, name: $name, flag: $flag, locale: $locale}';
  }
}

/// List of supported currencies
class SupportedCurrencies {
  static const List<Currency> currencies = [
    // Major currencies
    Currency(
      code: 'USD',
      symbol: '\$',
      name: 'US Dollar',
      flag: '🇺🇸',
      locale: 'en_US',
    ),
    Currency(
      code: 'EUR',
      symbol: '€',
      name: 'Euro',
      flag: '🇪🇺',
      locale: 'de_DE',
    ),
    Currency(
      code: 'GBP',
      symbol: '£',
      name: 'British Pound',
      flag: '🇬🇧',
      locale: 'en_GB',
    ),
    Currency(
      code: 'INR',
      symbol: '₹',
      name: 'Indian Rupee',
      flag: '🇮🇳',
      locale: 'hi_IN',
    ),
    Currency(
      code: 'JPY',
      symbol: '¥',
      name: 'Japanese Yen',
      flag: '🇯🇵',
      locale: 'ja_JP',
    ),
    Currency(
      code: 'CNY',
      symbol: '¥',
      name: 'Chinese Yuan',
      flag: '🇨🇳',
      locale: 'zh_CN',
    ),
    Currency(
      code: 'AUD',
      symbol: 'A\$',
      name: 'Australian Dollar',
      flag: '🇦🇺',
      locale: 'en_AU',
    ),
    Currency(
      code: 'CAD',
      symbol: 'C\$',
      name: 'Canadian Dollar',
      flag: '🇨🇦',
      locale: 'en_CA',
    ),
    Currency(
      code: 'CHF',
      symbol: 'Fr',
      name: 'Swiss Franc',
      flag: '🇨🇭',
      locale: 'de_CH',
    ),
    Currency(
      code: 'SGD',
      symbol: 'S\$',
      name: 'Singapore Dollar',
      flag: '🇸🇬',
      locale: 'en_SG',
    ),
    Currency(
      code: 'HKD',
      symbol: 'HK\$',
      name: 'Hong Kong Dollar',
      flag: '🇭🇰',
      locale: 'zh_HK',
    ),
    Currency(
      code: 'NZD',
      symbol: 'NZ\$',
      name: 'New Zealand Dollar',
      flag: '🇳🇿',
      locale: 'en_NZ',
    ),
    Currency(
      code: 'SEK',
      symbol: 'kr',
      name: 'Swedish Krona',
      flag: '🇸🇪',
      locale: 'sv_SE',
    ),
    Currency(
      code: 'NOK',
      symbol: 'kr',
      name: 'Norwegian Krone',
      flag: '🇳🇴',
      locale: 'nb_NO',
    ),
    Currency(
      code: 'DKK',
      symbol: 'kr',
      name: 'Danish Krone',
      flag: '🇩🇰',
      locale: 'da_DK',
    ),
    Currency(
      code: 'PLN',
      symbol: 'zł',
      name: 'Polish Złoty',
      flag: '🇵🇱',
      locale: 'pl_PL',
    ),
    Currency(
      code: 'CZK',
      symbol: 'Kč',
      name: 'Czech Koruna',
      flag: '🇨🇿',
      locale: 'cs_CZ',
    ),
    Currency(
      code: 'HUF',
      symbol: 'Ft',
      name: 'Hungarian Forint',
      flag: '🇭🇺',
      locale: 'hu_HU',
    ),
    Currency(
      code: 'RON',
      symbol: 'lei',
      name: 'Romanian Leu',
      flag: '🇷🇴',
      locale: 'ro_RO',
    ),
    Currency(
      code: 'BGN',
      symbol: 'лв',
      name: 'Bulgarian Lev',
      flag: '🇧🇬',
      locale: 'bg_BG',
    ),
    Currency(
      code: 'HRK',
      symbol: 'kn',
      name: 'Croatian Kuna',
      flag: '🇭🇷',
      locale: 'hr_HR',
    ),
    Currency(
      code: 'RUB',
      symbol: '₽',
      name: 'Russian Ruble',
      flag: '🇷🇺',
      locale: 'ru_RU',
    ),
    Currency(
      code: 'TRY',
      symbol: '₺',
      name: 'Turkish Lira',
      flag: '🇹🇷',
      locale: 'tr_TR',
    ),
    Currency(
      code: 'ZAR',
      symbol: 'R',
      name: 'South African Rand',
      flag: '🇿🇦',
      locale: 'af_ZA',
    ),
    Currency(
      code: 'BRL',
      symbol: 'R\$',
      name: 'Brazilian Real',
      flag: '🇧🇷',
      locale: 'pt_BR',
    ),
    Currency(
      code: 'MXN',
      symbol: '\$',
      name: 'Mexican Peso',
      flag: '🇲🇽',
      locale: 'es_MX',
    ),
    Currency(
      code: 'ARS',
      symbol: '\$',
      name: 'Argentine Peso',
      flag: '🇦🇷',
      locale: 'es_AR',
    ),
    Currency(
      code: 'CLP',
      symbol: '\$',
      name: 'Chilean Peso',
      flag: '🇨🇱',
      locale: 'es_CL',
    ),
    Currency(
      code: 'COP',
      symbol: '\$',
      name: 'Colombian Peso',
      flag: '🇨🇴',
      locale: 'es_CO',
    ),
    Currency(
      code: 'PEN',
      symbol: 'S/',
      name: 'Peruvian Sol',
      flag: '🇵🇪',
      locale: 'es_PE',
    ),
    Currency(
      code: 'KRW',
      symbol: '₩',
      name: 'South Korean Won',
      flag: '🇰🇷',
      locale: 'ko_KR',
    ),
    Currency(
      code: 'THB',
      symbol: '฿',
      name: 'Thai Baht',
      flag: '🇹🇭',
      locale: 'th_TH',
    ),
    Currency(
      code: 'MYR',
      symbol: 'RM',
      name: 'Malaysian Ringgit',
      flag: '🇲🇾',
      locale: 'ms_MY',
    ),
    Currency(
      code: 'IDR',
      symbol: 'Rp',
      name: 'Indonesian Rupiah',
      flag: '🇮🇩',
      locale: 'id_ID',
    ),
    Currency(
      code: 'PHP',
      symbol: '₱',
      name: 'Philippine Peso',
      flag: '🇵🇭',
      locale: 'fil_PH',
    ),
    Currency(
      code: 'VND',
      symbol: '₫',
      name: 'Vietnamese Dong',
      flag: '🇻🇳',
      locale: 'vi_VN',
    ),
    Currency(
      code: 'PKR',
      symbol: '₨',
      name: 'Pakistani Rupee',
      flag: '🇵🇰',
      locale: 'ur_PK',
    ),
    Currency(
      code: 'BDT',
      symbol: '৳',
      name: 'Bangladeshi Taka',
      flag: '🇧🇩',
      locale: 'bn_BD',
    ),
    Currency(
      code: 'LKR',
      symbol: '₨',
      name: 'Sri Lankan Rupee',
      flag: '🇱🇰',
      locale: 'si_LK',
    ),
    Currency(
      code: 'NPR',
      symbol: '₨',
      name: 'Nepalese Rupee',
      flag: '🇳🇵',
      locale: 'ne_NP',
    ),
    Currency(
      code: 'AED',
      symbol: 'د.إ',
      name: 'UAE Dirham',
      flag: '🇦🇪',
      locale: 'ar_AE',
    ),
    Currency(
      code: 'SAR',
      symbol: '﷼',
      name: 'Saudi Riyal',
      flag: '🇸🇦',
      locale: 'ar_SA',
    ),
    Currency(
      code: 'QAR',
      symbol: '﷼',
      name: 'Qatari Riyal',
      flag: '🇶🇦',
      locale: 'ar_QA',
    ),
    Currency(
      code: 'KWD',
      symbol: 'د.ك',
      name: 'Kuwaiti Dinar',
      flag: '🇰🇼',
      locale: 'ar_KW',
    ),
    Currency(
      code: 'BHD',
      symbol: '.د.ب',
      name: 'Bahraini Dinar',
      flag: '🇧🇭',
      locale: 'ar_BH',
    ),
    Currency(
      code: 'OMR',
      symbol: '﷼',
      name: 'Omani Rial',
      flag: '🇴🇲',
      locale: 'ar_OM',
    ),
    Currency(
      code: 'ILS',
      symbol: '₪',
      name: 'Israeli Shekel',
      flag: '🇮🇱',
      locale: 'he_IL',
    ),
    Currency(
      code: 'EGP',
      symbol: '£',
      name: 'Egyptian Pound',
      flag: '🇪🇬',
      locale: 'ar_EG',
    ),
    Currency(
      code: 'NGN',
      symbol: '₦',
      name: 'Nigerian Naira',
      flag: '🇳🇬',
      locale: 'en_NG',
    ),
    Currency(
      code: 'KES',
      symbol: 'KSh',
      name: 'Kenyan Shilling',
      flag: '🇰🇪',
      locale: 'sw_KE',
    ),
    Currency(
      code: 'GHS',
      symbol: '₵',
      name: 'Ghanaian Cedi',
      flag: '🇬🇭',
      locale: 'en_GH',
    ),
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
