import '../data/models/transaction_model.dart';

/// AnalyticsService provides data analysis and trend calculations.
/// Generates spending breakdowns, trends, and period comparisons.
class AnalyticsService {
  /// Get spending breakdown by category for a date range.
  /// Returns a map of category IDs to total amounts spent.
  Map<String, double> getSpendingByCategory(
    List<Transaction> transactions, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final filtered = _filterByDateRange(transactions, startDate, endDate);
    final expenseTransactions = filtered.where((t) => t.type == TransactionType.expense);
    
    final categoryTotals = <String, double>{};
    
    for (final transaction in expenseTransactions) {
      categoryTotals[transaction.category] = 
          (categoryTotals[transaction.category] ?? 0.0) + transaction.amount;
    }
    
    return categoryTotals;
  }

  /// Get monthly spending trend for the specified number of months.
  /// Returns list of total expenses for each month, ordered from oldest to most recent.
  List<double> getMonthlyTrend(List<Transaction> transactions, int months) {
    final now = DateTime.now();
    final trend = <double>[];
    
    for (int i = months - 1; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 0, 23, 59, 59);
      
      final monthTotal = transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              !t.date.isBefore(monthStart) &&
              !t.date.isAfter(monthEnd))
          .fold(0.0, (sum, t) => sum + t.amount);
      
      trend.add(monthTotal);
    }
    
    return trend;
  }

  /// Get weekly spending trend for the specified number of weeks.
  /// Returns list of total expenses for each week, ordered from oldest to most recent.
  List<double> getWeeklyTrend(List<Transaction> transactions, int weeks) {
    final now = DateTime.now();
    final trend = <double>[];
    
    for (int i = weeks - 1; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
      final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
      
      final weekTotal = transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              !t.date.isBefore(weekStart) &&
              !t.date.isAfter(weekEnd))
          .fold(0.0, (sum, t) => sum + t.amount);
      
      trend.add(weekTotal);
    }
    
    return trend;
  }

  /// Compare current period spending with previous period.
  /// Returns percentage difference (positive means spending increased, negative means decreased).
  double compareWithPreviousPeriod(
    List<Transaction> transactions,
    DateTime currentStart,
    DateTime currentEnd,
  ) {
    final currentPeriod = _filterByDateRange(transactions, currentStart, currentEnd);
    final currentTotal = currentPeriod
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final periodLength = currentEnd.difference(currentStart);
    final previousStart = currentStart.subtract(periodLength);
    final previousEnd = currentStart.subtract(const Duration(seconds: 1));
    
    final previousPeriod = _filterByDateRange(transactions, previousStart, previousEnd);
    final previousTotal = previousPeriod
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    if (previousTotal == 0) {
      return currentTotal > 0 ? 100.0 : 0.0;
    }
    
    return ((currentTotal - previousTotal) / previousTotal) * 100;
  }

  /// Get top spending categories for a date range.
  /// Returns list of category IDs sorted by spending amount (highest first).
  List<MapEntry<String, double>> getTopSpendingCategories(
    List<Transaction> transactions, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 5,
  }) {
    final categoryTotals = getSpendingByCategory(
      transactions,
      startDate: startDate,
      endDate: endDate,
    );
    
    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(limit).toList();
  }

  /// Internal helper to filter transactions by date range.
  List<Transaction> _filterByDateRange(
    List<Transaction> transactions,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null && endDate == null) {
      return transactions;
    }

    return transactions.where((t) {
      if (startDate != null && t.date.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && t.date.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();
  }
}
