import 'package:flutter_test/flutter_test.dart';
import 'package:login_app/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formatCurrency returns correct format for USD', () {
      final result = CurrencyFormatter.formatCurrency(1234.56, 'USD');
      expect(result, '\$1,234.56');
    });

    test('formatCurrency returns correct format for UGX', () {
      final result = CurrencyFormatter.formatCurrency(50000, 'UGX');
      expect(result, 'USh50,000.00');
    });

    test('formatCurrency handles negative amounts', () {
      final result = CurrencyFormatter.formatCurrency(-1234.56, 'USD');
      expect(result, '-\$1,234.56');
    });

    test('formatCompact returns K for thousands', () {
      final result = CurrencyFormatter.formatCompact(1234.56, 'USD');
      expect(result, '\$1.2K');
    });

    test('formatCompact returns M for millions', () {
      final result = CurrencyFormatter.formatCompact(1500000, 'USD');
      expect(result, '\$1.5M');
    });

    test('formatCompact returns B for billions', () {
      final result = CurrencyFormatter.formatCompact(2500000000, 'USD');
      expect(result, '\$2.5B');
    });

    test('getCurrencySymbol returns correct symbol', () {
      expect(CurrencyFormatter.getCurrencySymbol('USD'), '\$');
      expect(CurrencyFormatter.getCurrencySymbol('EUR'), '€');
      expect(CurrencyFormatter.getCurrencySymbol('GBP'), '£');
      expect(CurrencyFormatter.getCurrencySymbol('UGX'), 'USh');
    });

    test('getCurrencyName returns correct name', () {
      expect(CurrencyFormatter.getCurrencyName('USD'), 'US Dollar');
      expect(CurrencyFormatter.getCurrencyName('UGX'), 'Ugandan Shilling');
    });

    test('parseCurrency extracts number from currency string', () {
      expect(CurrencyFormatter.parseCurrency('\$1,234.56'), 1234.56);
      expect(CurrencyFormatter.parseCurrency('USh50,000.00'), 50000.00);
      expect(CurrencyFormatter.parseCurrency('€-100.50'), -100.50);
    });

    test('formatAmount formats without currency symbol', () {
      final result = CurrencyFormatter.formatAmount(1234.56);
      expect(result, '1,234.56');
    });

    test('isValidAmount validates positive amounts', () {
      expect(CurrencyFormatter.isValidAmount('1234.56'), true);
      expect(CurrencyFormatter.isValidAmount('\$1,234.56'), true);
      expect(CurrencyFormatter.isValidAmount('-100'), false);
      expect(CurrencyFormatter.isValidAmount('abc'), false);
      expect(CurrencyFormatter.isValidAmount(''), false);
    });

    test('convertCurrency returns same amount for same currency', () {
      final result = CurrencyFormatter.convertCurrency(
        amount: 100,
        fromCurrency: 'USD',
        toCurrency: 'USD',
      );
      expect(result, 100);
    });

    test('convertCurrency uses exchange rates when provided', () {
      final exchangeRates = {
        'USD': 1.0,
        'EUR': 0.85,
      };
      final result = CurrencyFormatter.convertCurrency(
        amount: 100,
        fromCurrency: 'USD',
        toCurrency: 'EUR',
        exchangeRates: exchangeRates,
      );
      expect(result, 85.0);
    });
  });
}
