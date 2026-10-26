import '../data/models/budget_model.dart';
import '../data/models/notification_model.dart';
import '../data/models/savings_goal_model.dart';
import '../data/models/transaction_model.dart';

/// NotificationService creates notification items for various events.
/// Generates budget warnings, goal reminders, summaries, and transaction reminders.
class NotificationService {
  /// Create a budget warning notification when spending exceeds thresholds.
  NotificationItem createBudgetWarning(
    Budget budget,
    double spent,
    String userId,
  ) {
    final percentage = budget.limit > 0 ? (spent / budget.limit) * 100 : 0;
    final isOverBudget = percentage >= 100;
    
    return NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: 'budget_warning',
      title: isOverBudget ? 'Budget Exceeded!' : 'Budget Alert',
      message: isOverBudget
          ? 'You have exceeded your budget for ${budget.categoryId} by ${(percentage - 100).toStringAsFixed(0)}%'
          : 'You have used ${percentage.toStringAsFixed(0)}% of your budget for ${budget.categoryId}',
      isRead: false,
      createdAt: DateTime.now(),
    );
  }

  /// Create a savings goal reminder notification.
  NotificationItem createGoalReminder(
    SavingsGoal goal,
    int daysUntilTarget,
    String userId,
  ) {
    final remaining = goal.targetAmount - goal.currentAmount;
    final isUrgent = daysUntilTarget <= 30;
    
    return NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: 'goal_reminder',
      title: isUrgent ? 'Goal Deadline Approaching!' : 'Savings Goal Update',
      message: 'Your goal "${goal.name}" has $daysUntilTarget days remaining. '
          'You need to save ${remaining.toStringAsFixed(0)} more to reach your target.',
      isRead: false,
      createdAt: DateTime.now(),
    );
  }

  /// Create a weekly summary notification.
  NotificationItem createWeeklySummary(
    List<Transaction> transactions,
    DateTime weekStart,
    DateTime weekEnd,
    String userId,
  ) {
    final weekTransactions = transactions.where((t) =>
        !t.date.isBefore(weekStart) && !t.date.isAfter(weekEnd)).toList();
    
    final totalIncome = weekTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final totalExpenses = weekTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final balance = totalIncome - totalExpenses;
    
    return NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: 'weekly_summary',
      title: 'Your Weekly Summary',
      message: 'This week you earned ${totalIncome.toStringAsFixed(0)} UGX '
          'and spent ${totalExpenses.toStringAsFixed(0)} UGX. '
          'Balance: ${balance.toStringAsFixed(0)} UGX',
      isRead: false,
      createdAt: DateTime.now(),
    );
  }

  /// Create a transaction reminder notification.
  NotificationItem createTransactionReminder(String userId) {
    return NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: 'transaction_reminder',
      title: 'Record Your Expenses',
      message: 'Don\'t forget to log your transactions today to keep your budget on track!',
      isRead: false,
      createdAt: DateTime.now(),
    );
  }

  /// Create a goal achievement notification.
  NotificationItem createGoalAchievement(
    SavingsGoal goal,
    String userId,
  ) {
    return NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: 'goal_achievement',
      title: 'Goal Achieved! 🎉',
      message: 'Congratulations! You have reached your savings goal "${goal.name}" '
          'of ${goal.targetAmount.toStringAsFixed(0)} UGX!',
      isRead: false,
      createdAt: DateTime.now(),
    );
  }
}
