class Currency {
  final String code;
  final String name;
  final String symbol;
  final String flag;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
  });

  @override
  String toString() => '$flag $code';
}

// Popular currencies - expanded list
class CurrencyData {
  static const List<Currency> currencies = [
    Currency(code: 'USD', name: 'US Dollar', symbol: '\$', flag: '🇺🇸'),
    Currency(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺'),
    Currency(code: 'GBP', name: 'British Pound', symbol: '£', flag: '🇬🇧'),
    Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥', flag: '🇯🇵'),
    Currency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$', flag: '🇦🇺'),
    Currency(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$', flag: '🇨🇦'),
    Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'Fr', flag: '🇨🇭'),
    Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', flag: '🇨🇳'),
    Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹', flag: '🇮🇳'),
    Currency(code: 'MXN', name: 'Mexican Peso', symbol: '\$', flag: '🇲🇽'),
    Currency(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$', flag: '🇸🇬'),
    Currency(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ', flag: '🇦🇪'),
    Currency(code: 'THB', name: 'Thai Baht', symbol: '฿', flag: '🇹🇭'),
    Currency(code: 'NZD', name: 'New Zealand Dollar', symbol: 'NZ\$', flag: '🇳🇿'),
    Currency(code: 'KRW', name: 'South Korean Won', symbol: '₩', flag: '🇰🇷'),
    Currency(code: 'HKD', name: 'Hong Kong Dollar', symbol: 'HK\$', flag: '🇭🇰'),
    Currency(code: 'SEK', name: 'Swedish Krona', symbol: 'kr', flag: '🇸🇪'),
    Currency(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr', flag: '🇳🇴'),
    Currency(code: 'DKK', name: 'Danish Krone', symbol: 'kr', flag: '🇩🇰'),
    Currency(code: 'ZAR', name: 'South African Rand', symbol: 'R', flag: '🇿🇦'),
    Currency(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$', flag: '🇧🇷'),
    Currency(code: 'RUB', name: 'Russian Ruble', symbol: '₽', flag: '🇷🇺'),
    Currency(code: 'TRY', name: 'Turkish Lira', symbol: '₺', flag: '🇹🇷'),
    Currency(code: 'SAR', name: 'Saudi Riyal', symbol: '﷼', flag: '🇸🇦'),
    Currency(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM', flag: '🇲🇾'),
    Currency(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp', flag: '🇮🇩'),
    Currency(code: 'PHP', name: 'Philippine Peso', symbol: '₱', flag: '🇵🇭'),
    Currency(code: 'PLN', name: 'Polish Zloty', symbol: 'zł', flag: '🇵🇱'),
    Currency(code: 'ILS', name: 'Israeli Shekel', symbol: '₪', flag: '🇮🇱'),
    Currency(code: 'CZK', name: 'Czech Koruna', symbol: 'Kč', flag: '🇨🇿'),
  ];

  static Currency? findByCode(String code) {
    try {
      return currencies.firstWhere((c) => c.code == code);
    } catch (e) {
      return null;
    }
  }
}
