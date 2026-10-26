import '../data/models/budget_model.dart';
import '../data/models/transaction_model.dart';

/// BudgetService handles budget tracking and status calculations.
/// Implements a three-tier status system: green (<70%), yellow (70-99%), red (>=100%).
class BudgetService {
  /// Calculate total amount spent for a given budget by summing matching transactions.
  /// Only counts expense transactions within the budget's date range and category.
  double calculateSpentForBudget(
    List<Transaction> transactions,
    Budget budget,
  ) {
    return transactions.where((t) {
      return t.type == TransactionType.expense &&
          t.category == budget.categoryId &&
          !t.date.isBefore(budget.startDate) &&
          !t.date.isAfter(budget.endDate);
    }).fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate remaining budget amount.
  /// Returns negative value if over budget.
  double calculateRemaining(double limit, double spent) {
    return limit - spent;
  }

  /// Get budget status based on spending percentage.
  /// Returns 'green' if <70%, 'yellow' if 70-99%, 'red' if >=100%.
  String getBudgetStatus(double spent, double limit) {
    if (limit == 0) return 'green';
    
    final percentage = (spent / limit) * 100;
    
    if (percentage >= 100) {
      return 'red';
    } else if (percentage >= 70) {
      return 'yellow';
    } else {
      return 'green';
    }
  }

  /// Check all budgets and return list of warnings for over-budget or near-limit categories.
  /// Returns a list of warning messages describing budget status.
  List<String> checkBudgetWarnings(
    List<Budget> budgets,
    List<Transaction> transactions,
  ) {
    final warnings = <String>[];

    for (final budget in budgets) {
      final spent = calculateSpentForBudget(transactions, budget);
      final status = getBudgetStatus(spent, budget.limit);
      final percentage = budget.limit > 0 ? (spent / budget.limit) * 100 : 0;

      if (status == 'red') {
        warnings.add(
          'Budget exceeded for ${budget.categoryId}: ${percentage.toStringAsFixed(0)}% spent',
        );
      } else if (status == 'yellow') {
        warnings.add(
          'Budget warning for ${budget.categoryId}: ${percentage.toStringAsFixed(0)}% spent',
        );
      }
    }

    return warnings;
  }

  /// Get the spending percentage for a budget.
  double getSpendingPercentage(double spent, double limit) {
    if (limit == 0) return 0.0;
    return (spent / limit) * 100;
  }
}
