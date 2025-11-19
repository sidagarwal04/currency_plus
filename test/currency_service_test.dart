import 'package:flutter_test/flutter_test.dart';
import 'package:currency_plus/services/currency_service.dart';

void main() {
  late CurrencyService currencyService;

  setUp(() {
    currencyService = CurrencyService();
  });

  group('CurrencyService Tests', () {
    test('Convert USD to EUR', () {
      final result = currencyService.convert(
        amount: 100,
        fromCurrency: 'USD',
        toCurrency: 'EUR',
      );

      expect(result, isNotNull);
      expect(result, closeTo(92, 0.1)); // 100 USD ≈ 92 EUR
    });

    test('Convert EUR to USD', () {
      final result = currencyService.convert(
        amount: 92,
        fromCurrency: 'EUR',
        toCurrency: 'USD',
      );

      expect(result, isNotNull);
      expect(result, closeTo(100, 0.1)); // 92 EUR ≈ 100 USD
    });

    test('Convert same currency should return same amount', () {
      final result = currencyService.convert(
        amount: 100,
        fromCurrency: 'USD',
        toCurrency: 'USD',
      );

      expect(result, 100);
    });

    test('Convert unsupported currency should return null', () {
      final result = currencyService.convert(
        amount: 100,
        fromCurrency: 'USD',
        toCurrency: 'XYZ',
      );

      expect(result, isNull);
    });

    test('Get exchange rate USD to EUR', () {
      final rate = currencyService.getExchangeRate(
        fromCurrency: 'USD',
        toCurrency: 'EUR',
      );

      expect(rate, isNotNull);
      expect(rate, 0.92);
    });

    test('Check if currency is supported', () {
      expect(currencyService.isCurrencySupported('USD'), isTrue);
      expect(currencyService.isCurrencySupported('EUR'), isTrue);
      expect(currencyService.isCurrencySupported('XYZ'), isFalse);
    });

    test('Get list of supported currencies', () {
      final currencies = currencyService.getSupportedCurrencies();

      expect(currencies, isNotEmpty);
      expect(currencies, contains('USD'));
      expect(currencies, contains('EUR'));
      expect(currencies.length, 10);
    });

    test('Convert zero amount', () {
      final result = currencyService.convert(
        amount: 0,
        fromCurrency: 'USD',
        toCurrency: 'EUR',
      );

      expect(result, 0);
    });

    test('Convert large amount', () {
      final result = currencyService.convert(
        amount: 1000000,
        fromCurrency: 'USD',
        toCurrency: 'JPY',
      );

      expect(result, isNotNull);
      expect(result, closeTo(149500000, 1000)); // 1M USD ≈ 149.5M JPY
    });

    test('Convert INR to JPY (non-USD base)', () {
      final result = currencyService.convert(
        amount: 1000,
        fromCurrency: 'INR',
        toCurrency: 'JPY',
      );

      expect(result, isNotNull);
      // 1000 INR → USD → JPY
      // 1000 / 83.12 * 149.50 ≈ 1798.65
      expect(result, closeTo(1798.65, 10));
    });
  });
}
