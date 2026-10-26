import '../data/models/transaction_model.dart';

/// FinanceService provides core financial calculation methods.
/// Processes transaction data to compute income, expenses, and balances.
class FinanceService {
  /// Calculate total income from transactions within a date range.
  /// Returns 0.0 if no income transactions are found.
  double calculateTotalIncome(
    List<Transaction> transactions, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final filtered = _filterByDateRange(transactions, startDate, endDate);
    return filtered
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate total expenses from transactions within a date range.
  /// Returns 0.0 if no expense transactions are found.
  double calculateTotalExpenses(
    List<Transaction> transactions, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final filtered = _filterByDateRange(transactions, startDate, endDate);
    return filtered
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate balance (income - expenses) from all transactions.
  /// Positive balance indicates surplus, negative indicates deficit.
  double calculateBalance(List<Transaction> transactions) {
    final income = calculateTotalIncome(transactions);
    final expenses = calculateTotalExpenses(transactions);
    return income - expenses;
  }

  /// Get all transactions for a specific category.
  List<Transaction> getTransactionsByCategory(
    List<Transaction> transactions,
    String categoryId,
  ) {
    return transactions.where((t) => t.category == categoryId).toList();
  }

  /// Get all transactions within a specific date range.
  List<Transaction> getTransactionsByDateRange(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _filterByDateRange(transactions, startDate, endDate);
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
