import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exchange_rate_response.dart';
import '../config/api_config.dart';

/// API-based currency conversion service
/// Phase 2: Uses real-time exchange rates from ExchangeRate-API
class ApiCurrencyService {
  // Using ExchangeRate-API free tier
  // Base URL for the API
  static String get _baseUrl => ApiConfig.exchangeRateApiUrl;
  
  // API Key - Free tier (1,500 requests/month)
  // For production, store this securely (e.g., environment variables)
  static String get _apiKey => ApiConfig.exchangeRateApiKey;
  
  // Cache for exchange rates
  ExchangeRateResponse? _cachedRates;
  DateTime? _lastFetchTime;
  
  // Cache duration (1 hour)
  static const Duration _cacheDuration = Duration(hours: 1);

  /// Fetch latest exchange rates from API
  /// Returns cached data if available and not expired
  Future<ExchangeRateResponse?> fetchExchangeRates({
    String baseCurrency = 'USD',
    bool forceRefresh = false,
  }) async {
    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && _isCacheValid() && _cachedRates?.baseCode == baseCurrency) {
      return _cachedRates;
    }

    try {
      final url = Uri.parse('$_baseUrl/$_apiKey/latest/$baseCurrency');
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _cachedRates = ExchangeRateResponse.fromJson(data);
        _lastFetchTime = DateTime.now();
        return _cachedRates;
      } else {
        throw Exception('Failed to load exchange rates: ${response.statusCode}');
      }
    } catch (e) {
      // Return cached data as fallback if available
      if (_cachedRates != null) {
        return _cachedRates;
      }
      rethrow;
    }
  }

  /// Convert amount from one currency to another using API rates
  Future<double?> convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final rates = await fetchExchangeRates(baseCurrency: fromCurrency);
      
      if (rates == null || !rates.isSuccess) {
        return null;
      }

      final toRate = rates.conversionRates[toCurrency];
      if (toRate == null) {
        return null;
      }

      return amount * toRate;
    } catch (e) {
      return null;
    }
  }

  /// Get the exchange rate between two currencies
  Future<double?> getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final rates = await fetchExchangeRates(baseCurrency: fromCurrency);
      
      if (rates == null || !rates.isSuccess) {
        return null;
      }

      return rates.conversionRates[toCurrency];
    } catch (e) {
      return null;
    }
  }

  /// Get list of supported currencies from cached rates
  List<String> getSupportedCurrencies() {
    if (_cachedRates == null) {
      return [];
    }
    return _cachedRates!.conversionRates.keys.toList();
  }

  /// Check if cache is still valid
  bool _isCacheValid() {
    if (_lastFetchTime == null) return false;
    final difference = DateTime.now().difference(_lastFetchTime!);
    return difference < _cacheDuration;
  }

  /// Get last update time
  DateTime? get lastUpdateTime => _cachedRates?.lastUpdateTime;

  /// Get next update time
  DateTime? get nextUpdateTime => _cachedRates?.nextUpdateTime;

  /// Check if rates are cached
  bool get hasCachedRates => _cachedRates != null;

  /// Clear the cache
  void clearCache() {
    _cachedRates = null;
    _lastFetchTime = null;
  }

  /// Get cache age
  Duration? get cacheAge {
    if (_lastFetchTime == null) return null;
    return DateTime.now().difference(_lastFetchTime!);
  }
}
