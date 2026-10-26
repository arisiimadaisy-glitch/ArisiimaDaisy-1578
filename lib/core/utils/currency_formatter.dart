import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Helper functions for currency formatting and conversion
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Format an amount with the specified currency code
  /// Example: formatCurrency(1234.56, 'USD') returns "$1,234.56"
  static String formatCurrency(double amount, String currencyCode) {
    final currency = AppConstants.currencies.firstWhere(
      (c) => c.code == currencyCode,
      orElse: () => AppConstants.defaultCurrency,
    );

    // Format with thousand separators and 2 decimal places
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final formattedAmount = formatter.format(amount.abs());

    // Add currency symbol
    final prefix = amount < 0 ? '-' : '';
    return '$prefix${currency.symbol}$formattedAmount';
  }

  /// Format an amount with compact notation (e.g., 1.2K, 1.5M)
  /// Example: formatCompact(1234.56, 'USD') returns "$1.2K"
  static String formatCompact(double amount, String currencyCode) {
    final currency = AppConstants.currencies.firstWhere(
      (c) => c.code == currencyCode,
      orElse: () => AppConstants.defaultCurrency,
    );

    final absAmount = amount.abs();
    final prefix = amount < 0 ? '-' : '';

    String formattedNumber;
    if (absAmount >= 1000000000) {
      formattedNumber = '${(absAmount / 1000000000).toStringAsFixed(1)}B';
    } else if (absAmount >= 1000000) {
      formattedNumber = '${(absAmount / 1000000).toStringAsFixed(1)}M';
    } else if (absAmount >= 1000) {
      formattedNumber = '${(absAmount / 1000).toStringAsFixed(1)}K';
    } else {
      formattedNumber = absAmount.toStringAsFixed(2);
    }

    return '$prefix${currency.symbol}$formattedNumber';
  }

  /// Get the currency symbol for a currency code
  /// Example: getCurrencySymbol('USD') returns "$"
  static String getCurrencySymbol(String currencyCode) {
    final currency = AppConstants.currencies.firstWhere(
      (c) => c.code == currencyCode,
      orElse: () => AppConstants.defaultCurrency,
    );
    return currency.symbol;
  }

  /// Get the currency name for a currency code
  /// Example: getCurrencyName('USD') returns "US Dollar"
  static String getCurrencyName(String currencyCode) {
    final currency = AppConstants.currencies.firstWhere(
      (c) => c.code == currencyCode,
      orElse: () => AppConstants.defaultCurrency,
    );
    return currency.name;
  }

  /// Parse a currency string to a double
  /// Example: parseCurrency("$1,234.56") returns 1234.56
  static double? parseCurrency(String currencyString) {
    // Remove all non-numeric characters except decimal point and minus sign
    final cleanString = currencyString.replaceAll(RegExp(r'[^\d.-]'), '');
    return double.tryParse(cleanString);
  }

  /// Convert currency from one code to another
  /// Note: This is a stub implementation that returns the same amount.
  /// Real conversion requires an external API (e.g., exchangerate-api.com)
  ///  Implement real currency conversion with API
  static double convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    Map<String, double>? exchangeRates,
  }) {
    // If same currency, no conversion needed
    if (fromCurrency == toCurrency) {
      return amount;
    }

    // If exchange rates are provided, use them
    if (exchangeRates != null) {
      final fromRate = exchangeRates[fromCurrency];
      final toRate = exchangeRates[toCurrency];

      if (fromRate != null && toRate != null) {
        // Convert to base currency (usually USD) then to target currency
        final baseAmount = amount / fromRate;
        return baseAmount * toRate;
      }
    }

    // Stub: return same amount (needs real API integration)
    return amount;
  }

  /// Format amount without currency symbol
  /// Example: formatAmount(1234.56) returns "1,234.56"
  static String formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(amount);
  }

  /// Validate if a string is a valid currency amount
  static bool isValidAmount(String value) {
    if (value.isEmpty) return false;
    final parsed = parseCurrency(value);
    return parsed != null && parsed >= 0;
  }
}
