import 'package:flutter_test/flutter_test.dart';
import 'package:currency_plus/services/hybrid_currency_service.dart';

void main() {
  late HybridCurrencyService hybridService;

  setUp(() {
    hybridService = HybridCurrencyService();
  });

  group('HybridCurrencyService Tests', () {
    test('Initial state is API mode', () {
      expect(hybridService.isUsingApi, isTrue);
    });

    test('Can toggle to offline mode', () {
      hybridService.setUseApi(false);
      expect(hybridService.isUsingApi, isFalse);
    });

    test('Can toggle back to API mode', () {
      hybridService.setUseApi(false);
      hybridService.setUseApi(true);
      expect(hybridService.isUsingApi, isTrue);
    });

    test('Get supported currencies returns list', () {
      final currencies = hybridService.getSupportedCurrencies();
      expect(currencies, isNotEmpty);
      expect(currencies, contains('USD'));
      expect(currencies, contains('EUR'));
    });

    test('Convert in offline mode', () async {
      hybridService.setUseApi(false);
      
      final result = await hybridService.convert(
        amount: 100,
        fromCurrency: 'USD',
        toCurrency: 'EUR',
      );

      expect(result, isNotNull);
      expect(result, greaterThan(0));
    });

    test('Get exchange rate in offline mode', () async {
      hybridService.setUseApi(false);
      
      final rate = await hybridService.getExchangeRate(
        fromCurrency: 'USD',
        toCurrency: 'EUR',
      );

      expect(rate, isNotNull);
      expect(rate, greaterThan(0));
    });

    test('Clear cache works', () {
      hybridService.clearCache();
      expect(hybridService.hasCachedRates, isFalse);
    });

    test('Last error is null initially', () {
      expect(hybridService.lastError, isNull);
    });

    test('Is not loading initially', () {
      expect(hybridService.isLoading, isFalse);
    });

    test('Convert same currency returns same amount', () async {
      hybridService.setUseApi(false);
      
      final result = await hybridService.convert(
        amount: 100,
        fromCurrency: 'USD',
        toCurrency: 'USD',
      );

      expect(result, 100);
    });

    test('Convert zero amount returns zero', () async {
      hybridService.setUseApi(false);
      
      final result = await hybridService.convert(
        amount: 0,
        fromCurrency: 'USD',
        toCurrency: 'EUR',
      );

      expect(result, 0);
    });

    // API mode tests (require network)
    /*
    test('Convert in API mode with fallback', () async {
      hybridService.setUseApi(true);
      
      final result = await hybridService.convert(
        amount: 100,
        fromCurrency: 'USD',
        toCurrency: 'EUR',
      );

      // Should return result from either API or offline fallback
      expect(result, isNotNull);
      expect(result, greaterThan(0));
    });

    test('Refresh rates in API mode', () async {
      await hybridService.refreshRates();
      // Should complete without error
    }, skip: 'Requires API key and network');
    */
  });
}
