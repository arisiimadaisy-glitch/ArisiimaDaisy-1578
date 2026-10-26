import 'package:flutter/material.dart';

/// Application-wide constants for the Uganda expense tracker app
class AppConstants {
  AppConstants._();

  // Uganda color palette
  static const Color ugandaGreen = Color(0xFF11BD2E);
  static const Color ugandaYellow = Color(0xFFFCDC04);
  static const Color ugandaRed = Color(0xFFD90000);
  static const Color ugandaBlack = Color(0xFF000000);

  // Default currency
  static const String defaultCurrencyCode = 'UGX';
  static final Currency defaultCurrency = currencies.firstWhere(
    (c) => c.code == defaultCurrencyCode,
    orElse: () => currencies.first,
  );

  // World currencies list (major currencies including UGX)
  static final List<Currency> currencies = [
    Currency(code: 'UGX', name: 'Ugandan Shilling', symbol: 'USh'),
    Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
    Currency(code: 'EUR', name: 'Euro', symbol: '€'),
    Currency(code: 'GBP', name: 'British Pound', symbol: '£'),
    Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
    Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
    Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
    Currency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$'),
    Currency(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$'),
    Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF'),
    Currency(code: 'SEK', name: 'Swedish Krona', symbol: 'kr'),
    Currency(code: 'NZD', name: 'New Zealand Dollar', symbol: 'NZ\$'),
    Currency(code: 'ZAR', name: 'South African Rand', symbol: 'R'),
    Currency(code: 'KES', name: 'Kenyan Shilling', symbol: 'KSh'),
    Currency(code: 'TZS', name: 'Tanzanian Shilling', symbol: 'TSh'),
    Currency(code: 'RWF', name: 'Rwandan Franc', symbol: 'FRw'),
    Currency(code: 'NGN', name: 'Nigerian Naira', symbol: '₦'),
    Currency(code: 'GHS', name: 'Ghanaian Cedi', symbol: 'GH₵'),
    Currency(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ'),
    Currency(code: 'SAR', name: 'Saudi Riyal', symbol: '﷼'),
    Currency(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$'),
    Currency(code: 'MXN', name: 'Mexican Peso', symbol: 'Mex\$'),
    Currency(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$'),
    Currency(code: 'HKD', name: 'Hong Kong Dollar', symbol: 'HK\$'),
    Currency(code: 'KRW', name: 'South Korean Won', symbol: '₩'),
  ];

  // Default expense categories
  static const List<ExpenseCategory> defaultCategories = [
    ExpenseCategory(name: 'Food & Dining', icon: Icons.restaurant_outlined),
    ExpenseCategory(name: 'Transport', icon: Icons.directions_car_outlined),
    ExpenseCategory(name: 'Shopping', icon: Icons.shopping_bag_outlined),
    ExpenseCategory(name: 'Entertainment', icon: Icons.movie_outlined),
    ExpenseCategory(
      name: 'Bills & Utilities',
      icon: Icons.receipt_long_outlined,
    ),
    ExpenseCategory(name: 'Healthcare', icon: Icons.local_hospital_outlined),
    ExpenseCategory(name: 'Education', icon: Icons.school_outlined),
    ExpenseCategory(name: 'Groceries', icon: Icons.shopping_cart_outlined),
    ExpenseCategory(name: 'Travel', icon: Icons.flight_outlined),
    ExpenseCategory(name: 'Personal Care', icon: Icons.face_outlined),
    ExpenseCategory(name: 'Housing', icon: Icons.home_outlined),
    ExpenseCategory(name: 'Insurance', icon: Icons.security_outlined),
    ExpenseCategory(name: 'Investments', icon: Icons.trending_up_outlined),
    ExpenseCategory(
      name: 'Gifts & Donations',
      icon: Icons.card_giftcard_outlined,
    ),
    ExpenseCategory(name: 'Other', icon: Icons.more_horiz_outlined),
  ];

  // App metadata
  static const String appName = 'PesaTracker';
  static const String appVersion = '1.0.0';
}

/// Currency model
class Currency {
  final String code;
  final String name;
  final String symbol;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  @override
  String toString() => '$name ($code)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/// Expense category model
class ExpenseCategory {
  final String name;
  final IconData icon;

  const ExpenseCategory({required this.name, required this.icon});

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategory &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}
