import 'package:flutter_test/flutter_test.dart';
import 'package:currency_plus/services/api_currency_service.dart';

void main() {
  late ApiCurrencyService apiService;

  setUp(() {
    apiService = ApiCurrencyService();
  });

  group('ApiCurrencyService Tests', () {
    test('Cache validity check', () {
      expect(apiService.hasCachedRates, isFalse);
    });

    test('Supported currencies returns empty without cache', () {
      final currencies = apiService.getSupportedCurrencies();
      expect(currencies, isEmpty);
    });

    test('Cache age is null when no cache', () {
      expect(apiService.cacheAge, isNull);
    });

    test('Last update time is null when no cache', () {
      expect(apiService.lastUpdateTime, isNull);
    });

    test('Next update time is null when no cache', () {
      expect(apiService.nextUpdateTime, isNull);
    });

    test('Clear cache works', () {
      apiService.clearCache();
      expect(apiService.hasCachedRates, isFalse);
    });

    // Note: These tests require actual API key and network connection
    // For CI/CD, mock the HTTP responses or use demo mode

    /*
    test('Fetch exchange rates from API', () async {
      final rates = await apiService.fetchExchangeRates();
      
      if (rates != null) {
        expect(rates.isSuccess, isTrue);
        expect(rates.baseCode, 'USD');
        expect(rates.conversionRates, isNotEmpty);
      }
    }, skip: 'Requires API key and network');

    test('Convert currency via API', () async {
      final result = await apiService.convert(
        amount: 100,
        fromCurrency: 'USD',
        toCurrency: 'EUR',
      );
      
      if (result != null) {
        expect(result, greaterThan(0));
      }
    }, skip: 'Requires API key and network');

    test('Get exchange rate via API', () async {
      final rate = await apiService.getExchangeRate(
        fromCurrency: 'USD',
        toCurrency: 'EUR',
      );
      
      if (rate != null) {
        expect(rate, greaterThan(0));
      }
    }, skip: 'Requires API key and network');
    */
  });
}
