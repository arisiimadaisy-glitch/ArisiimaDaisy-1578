import '../data/models/savings_goal_model.dart';

/// SavingsService handles savings goal calculations and progress tracking.
/// Provides methods for computing progress percentages, time remaining, and monthly targets.
class SavingsService {
  /// Calculate progress percentage for a savings goal.
  /// Returns value between 0-100, capped at 100 if current exceeds target.
  double calculateProgress(SavingsGoal goal) {
    if (goal.targetAmount == 0) return 0.0;
    
    final progress = (goal.currentAmount / goal.targetAmount) * 100;
    return progress > 100 ? 100.0 : progress;
  }

  /// Calculate number of days remaining until target date.
  /// Returns negative value if target date has passed.
  int calculateDaysRemaining(SavingsGoal goal) {
    final now = DateTime.now();
    final difference = goal.targetDate.difference(now);
    return difference.inDays;
  }

  /// Calculate monthly savings target needed to reach goal by target date.
  /// Returns 0 if goal is already achieved or target date has passed.
  double calculateMonthlyTarget(SavingsGoal goal) {
    final remaining = goal.targetAmount - goal.currentAmount;
    
    if (remaining <= 0) return 0.0;
    
    final daysRemaining = calculateDaysRemaining(goal);
    
    if (daysRemaining <= 0) return 0.0;
    
    // Calculate months remaining (approximate)
    final monthsRemaining = daysRemaining / 30.0;
    
    if (monthsRemaining <= 0) return remaining;
    
    return remaining / monthsRemaining;
  }

  /// Calculate amount remaining to reach goal.
  double calculateAmountRemaining(SavingsGoal goal) {
    final remaining = goal.targetAmount - goal.currentAmount;
    return remaining > 0 ? remaining : 0.0;
  }

  /// Check if goal is achieved.
  bool isGoalAchieved(SavingsGoal goal) {
    return goal.currentAmount >= goal.targetAmount;
  }

  /// Check if goal target date has passed.
  bool isTargetDatePassed(SavingsGoal goal) {
    return DateTime.now().isAfter(goal.targetDate);
  }

  /// Get status message for a savings goal.
  String getGoalStatus(SavingsGoal goal) {
    if (isGoalAchieved(goal)) {
      return 'Goal achieved!';
    } else if (isTargetDatePassed(goal)) {
      return 'Target date passed';
    } else {
      final daysLeft = calculateDaysRemaining(goal);
      if (daysLeft < 30) {
        return '$daysLeft days remaining';
      } else {
        final monthsLeft = (daysLeft / 30).round();
        return '$monthsLeft months remaining';
      }
    }
  }
}
