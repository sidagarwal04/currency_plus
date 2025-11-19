import 'currency_service.dart';
import 'api_currency_service.dart';

/// Hybrid service that uses API when available, falls back to offline rates
/// Provides best of both worlds: real-time rates with offline functionality
class HybridCurrencyService {
  final ApiCurrencyService _apiService = ApiCurrencyService();
  final CurrencyService _offlineService = CurrencyService();

  bool _useApi = true;
  bool _isLoading = false;
  String? _lastError;

  /// Convert amount using API or fallback to offline
  Future<double?> convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (!_useApi) {
      return _offlineService.convert(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
    }

    _isLoading = true;
    _lastError = null;

    try {
      final result = await _apiService.convert(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
      _isLoading = false;
      
      if (result != null) {
        return result;
      }

      // Fallback to offline if API returns null
      return _offlineService.convert(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
    } catch (e) {
      _isLoading = false;
      _lastError = e.toString();
      
      // Fallback to offline on error
      return _offlineService.convert(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
    }
  }

  /// Get exchange rate using API or fallback to offline
  Future<double?> getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (!_useApi) {
      return _offlineService.getExchangeRate(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
    }

    try {
      final result = await _apiService.getExchangeRate(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
      
      if (result != null) {
        return result;
      }

      // Fallback to offline if API returns null
      return _offlineService.getExchangeRate(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
    } catch (e) {
      _lastError = e.toString();
      
      // Fallback to offline on error
      return _offlineService.getExchangeRate(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
    }
  }

  /// Toggle between API and offline mode
  void setUseApi(bool useApi) {
    _useApi = useApi;
  }

  /// Check if using API mode
  bool get isUsingApi => _useApi;

  /// Check if currently loading from API
  bool get isLoading => _isLoading;

  /// Get last error message
  String? get lastError => _lastError;

  /// Check if has cached rates from API
  bool get hasCachedRates => _apiService.hasCachedRates;

  /// Get last update time from API
  DateTime? get lastUpdateTime => _apiService.lastUpdateTime;

  /// Get cache age
  Duration? get cacheAge => _apiService.cacheAge;

  /// Force refresh from API
  Future<void> refreshRates({String baseCurrency = 'USD'}) async {
    try {
      await _apiService.fetchExchangeRates(
        baseCurrency: baseCurrency,
        forceRefresh: true,
      );
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    }
  }

  /// Clear API cache
  void clearCache() {
    _apiService.clearCache();
  }

  /// Get supported currencies (offline list)
  List<String> getSupportedCurrencies() {
    return _offlineService.getSupportedCurrencies();
  }
}
