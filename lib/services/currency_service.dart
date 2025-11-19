/// Currency conversion service
/// MVP Phase: Uses hardcoded exchange rates (base: USD)
class CurrencyService {
  // Hardcoded exchange rates for MVP (base currency: USD)
  // In production, these would come from an API
  static final Map<String, double> _exchangeRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'JPY': 149.50,
    'AUD': 1.54,
    'CAD': 1.38,
    'CHF': 0.88,
    'CNY': 7.24,
    'INR': 83.12,
    'MXN': 17.15,
  };

  /// Convert amount from one currency to another
  /// Returns null if conversion fails
  double? convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    try {
      final fromRate = _exchangeRates[fromCurrency];
      final toRate = _exchangeRates[toCurrency];

      if (fromRate == null || toRate == null) {
        return null;
      }

      // Convert to USD first, then to target currency
      final amountInUSD = amount / fromRate;
      final convertedAmount = amountInUSD * toRate;

      return convertedAmount;
    } catch (e) {
      return null;
    }
  }

  /// Get the exchange rate between two currencies
  double? getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) {
    try {
      final fromRate = _exchangeRates[fromCurrency];
      final toRate = _exchangeRates[toCurrency];

      if (fromRate == null || toRate == null) {
        return null;
      }

      return toRate / fromRate;
    } catch (e) {
      return null;
    }
  }

  /// Check if currency is supported
  bool isCurrencySupported(String currencyCode) {
    return _exchangeRates.containsKey(currencyCode);
  }

  /// Get list of supported currencies
  List<String> getSupportedCurrencies() {
    return _exchangeRates.keys.toList();
  }
}
