import '../data/models/budget_model.dart';
import '../data/models/savings_goal_model.dart';
import '../data/models/transaction_model.dart';

/// AIService provides rule-based conversational AI for financial queries.
/// Implements pattern matching to answer questions about spending, budgets, savings, and affordability.
class AIService {
  /// Process a user message and return an appropriate response.
  /// Uses pattern matching to detect query intent and provides relevant financial insights.
  String processMessage(
    String query,
    List<Transaction> transactions,
    List<Budget> budgets,
    List<SavingsGoal> goals,
  ) {
    final lowerQuery = query.toLowerCase().trim();

    // Pattern 1: Spending queries - "how much", "spent", "spending"
    if (_matchesPattern(lowerQuery, [
      'how much',
      'spent',
      'spending',
      'total',
    ])) {
      return _handleSpendingQuery(lowerQuery, transactions);
    }

    // Pattern 2: Category breakdown - "where", "money go", "category"
    if (_matchesPattern(lowerQuery, [
      'where',
      'money go',
      'category',
      'categories',
      'breakdown',
    ])) {
      return _handleCategoryQuery(transactions);
    }

    // Pattern 3: Affordability checks - "afford", "can I buy", "should I"
    if (_matchesPattern(lowerQuery, [
      'afford',
      'can i buy',
      'should i buy',
      'can i spend',
    ])) {
      return _handleAffordabilityQuery(lowerQuery, transactions, budgets);
    }

    // Pattern 4: Savings advice - "save", "saving", "tips"
    if (_matchesPattern(lowerQuery, [
      'save',
      'saving',
      'savings',
      'tips',
      'advice',
    ])) {
      return _handleSavingsQuery(transactions, goals);
    }

    // Pattern 5: Budget status - "budget", "how much left"
    if (_matchesPattern(lowerQuery, [
      'budget',
      'how much left',
      'remaining',
      'left',
    ])) {
      return _handleBudgetQuery(budgets, transactions);
    }

    // Pattern 6: Income queries
    if (_matchesPattern(lowerQuery, ['income', 'earned', 'earning'])) {
      return _handleIncomeQuery(transactions);
    }

    // Pattern 7: Goals queries
    if (_matchesPattern(lowerQuery, ['goal', 'goals', 'target'])) {
      return _handleGoalsQuery(goals);
    }

    // Pattern 8: Financial reports - "report", "summary", "breakdown", "monthly"
    if (_matchesPattern(lowerQuery, [
      'report',
      'summary',
      'breakdown',
      'monthly',
      'financial',
    ])) {
      return generateMonthlyReport(transactions, budgets);
    }

    // Fallback response with helpful suggestions
    return _getFallbackResponse();
  }

  /// Check if query matches any of the given patterns.
  bool _matchesPattern(String query, List<String> patterns) {
    return patterns.any((pattern) => query.contains(pattern));
  }

  /// Handle spending-related queries.
  String _handleSpendingQuery(String query, List<Transaction> transactions) {
    final now = DateTime.now();
    DateTime startDate;
    String period;

    if (query.contains('today')) {
      startDate = DateTime(now.year, now.month, now.day);
      period = 'today';
    } else if (query.contains('week')) {
      startDate = now.subtract(Duration(days: 7));
      period = 'this week';
    } else {
      startDate = DateTime(now.year, now.month, 1);
      period = 'this month';
    }

    final expenses = transactions
        .where(
          (t) => t.type == TransactionType.expense && t.date.isAfter(startDate),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final transactionCount = transactions
        .where(
          (t) => t.type == TransactionType.expense && t.date.isAfter(startDate),
        )
        .length;

    return 'You have spent ${expenses.toStringAsFixed(0)} UGX $period '
        'across $transactionCount transactions. '
        '${expenses > 100000 ? 'That\'s quite a bit! Consider reviewing your expenses.' : 'Good job keeping expenses in check!'}';
  }

  /// Handle category breakdown queries.
  String _handleCategoryQuery(List<Transaction> transactions) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    final categoryTotals = <String, double>{};

    for (final t in transactions) {
      if (t.type == TransactionType.expense && t.date.isAfter(monthStart)) {
        categoryTotals[t.category] =
            (categoryTotals[t.category] ?? 0.0) + t.amount;
      }
    }

    if (categoryTotals.isEmpty) {
      return 'You haven\'t recorded any expenses this month yet.';
    }

    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top3 = sorted.take(3).toList();
    final total = categoryTotals.values.fold(0.0, (sum, val) => sum + val);

    final response = StringBuffer(
      'This month, your top spending categories are:\n\n',
    );

    for (int i = 0; i < top3.length; i++) {
      final percentage = (top3[i].value / total * 100).toStringAsFixed(0);
      response.writeln(
        '${i + 1}. ${top3[i].key}: ${top3[i].value.toStringAsFixed(0)} UGX ($percentage%)',
      );
    }

    return response.toString().trim();
  }

  /// Handle affordability queries.
  String _handleAffordabilityQuery(
    String query,
    List<Transaction> transactions,
    List<Budget> budgets,
  ) {
    // Try to extract amount from query
    final amountMatch = RegExp(r'\d+').firstMatch(query);
    final amount = amountMatch != null
        ? double.tryParse(amountMatch.group(0)!)
        : null;

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    final income = transactions
        .where(
          (t) => t.type == TransactionType.income && t.date.isAfter(monthStart),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final expenses = transactions
        .where(
          (t) =>
              t.type == TransactionType.expense && t.date.isAfter(monthStart),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = income - expenses;

    if (amount != null) {
      if (amount <= balance * 0.3) {
        return 'Yes, you can afford ${amount.toStringAsFixed(0)} UGX! '
            'Your current balance is ${balance.toStringAsFixed(0)} UGX. '
            'This purchase would use ${(amount / balance * 100).toStringAsFixed(0)}% of your available funds.';
      } else if (amount <= balance) {
        return 'You technically have ${balance.toStringAsFixed(0)} UGX available, '
            'but spending ${amount.toStringAsFixed(0)} UGX would use ${(amount / balance * 100).toStringAsFixed(0)}% of it. '
            'Consider if this is a necessary purchase.';
      } else {
        return 'This purchase of ${amount.toStringAsFixed(0)} UGX exceeds your current balance '
            'of ${balance.toStringAsFixed(0)} UGX. I recommend saving up first!';
      }
    }

    return 'Your current balance this month is ${balance.toStringAsFixed(0)} UGX. '
        'To check if you can afford something, ask me "Can I afford [amount]?"';
  }

  /// Handle savings-related queries.
  String _handleSavingsQuery(
    List<Transaction> transactions,
    List<SavingsGoal> goals,
  ) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    final monthlyIncome = transactions
        .where(
          (t) => t.type == TransactionType.income && t.date.isAfter(monthStart),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final monthlyExpenses = transactions
        .where(
          (t) =>
              t.type == TransactionType.expense && t.date.isAfter(monthStart),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final potentialSavings = monthlyIncome - monthlyExpenses;

    if (goals.isEmpty) {
      return 'You currently have ${potentialSavings.toStringAsFixed(0)} UGX available to save this month. '
          'Consider setting a savings goal to stay motivated! The recommended savings rate is 20% of your income.';
    }

    final activeGoals = goals
        .where((g) => g.currentAmount < g.targetAmount)
        .toList();

    if (activeGoals.isEmpty) {
      return 'Great job! You\'ve achieved all your savings goals! '
          'Your potential savings this month: ${potentialSavings.toStringAsFixed(0)} UGX. '
          'Consider setting a new goal to continue your progress.';
    }

    final goal = activeGoals.first;
    final remaining = goal.targetAmount - goal.currentAmount;
    final daysLeft = goal.targetDate.difference(now).inDays;
    final monthlyNeeded = daysLeft > 0
        ? (remaining / (daysLeft / 30.0))
        : remaining;

    return 'For your goal "$goal.name", you need to save ${monthlyNeeded.toStringAsFixed(0)} UGX per month. '
        'You have ${potentialSavings.toStringAsFixed(0)} UGX available this month. '
        '${potentialSavings >= monthlyNeeded ? 'You\'re on track!' : 'Consider reducing expenses to meet your target.'}';
  }

  /// Handle budget status queries.
  String _handleBudgetQuery(
    List<Budget> budgets,
    List<Transaction> transactions,
  ) {
    if (budgets.isEmpty) {
      return 'You don\'t have any budgets set up yet. Setting budgets helps you control spending and reach your financial goals!';
    }

    final response = StringBuffer('Here\'s your budget status:\n\n');

    for (final budget in budgets) {
      final spent = transactions
          .where(
            (t) =>
                t.type == TransactionType.expense &&
                t.category == budget.categoryId &&
                !t.date.isBefore(budget.startDate) &&
                !t.date.isAfter(budget.endDate),
          )
          .fold(0.0, (sum, t) => sum + t.amount);

      final remaining = budget.limit - spent;
      final percentage = (spent / budget.limit * 100).toStringAsFixed(0);
      final status = spent >= budget.limit
          ? '⚠️'
          : spent >= budget.limit * 0.7
          ? '⚡'
          : '✓';

      response.writeln(
        '$status ${budget.categoryId}: ${spent.toStringAsFixed(0)} / ${budget.limit.toStringAsFixed(0)} UGX ($percentage%) - ${remaining.toStringAsFixed(0)} UGX left',
      );
    }

    return response.toString().trim();
  }

  /// Handle income queries.
  String _handleIncomeQuery(List<Transaction> transactions) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    final monthlyIncome = transactions
        .where(
          (t) => t.type == TransactionType.income && t.date.isAfter(monthStart),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final incomeCount = transactions
        .where(
          (t) => t.type == TransactionType.income && t.date.isAfter(monthStart),
        )
        .length;

    return 'You have earned ${monthlyIncome.toStringAsFixed(0)} UGX this month '
        'from $incomeCount income transactions. Keep up the good work!';
  }

  /// Handle goals queries.
  String _handleGoalsQuery(List<SavingsGoal> goals) {
    if (goals.isEmpty) {
      return 'You don\'t have any savings goals set up yet. Setting goals helps you stay motivated and track your progress!';
    }

    final response = StringBuffer('Here are your savings goals:\n\n');

    for (int i = 0; i < goals.length; i++) {
      final goal = goals[i];
      final progress = (goal.currentAmount / goal.targetAmount * 100)
          .toStringAsFixed(0);
      final remaining = goal.targetAmount - goal.currentAmount;
      final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;

      response.writeln(
        '${i + 1}. $goal.name: ${goal.currentAmount.toStringAsFixed(0)} / ${goal.targetAmount.toStringAsFixed(0)} UGX ($progress%)',
      );
      response.writeln(
        '   ${remaining.toStringAsFixed(0)} UGX remaining, $daysLeft days left\n',
      );
    }

    return response.toString().trim();
  }

  /// Provide fallback response with helpful suggestions.
  String _getFallbackResponse() {
    return 'I can help you with:\n\n'
        '• "How much did I spend this week/month?"\n'
        '• "Where did my money go?"\n'
        '• "Can I afford 50000?"\n'
        '• "How are my budgets?"\n'
        '• "What are my savings goals?"\n'
        '• "Give me savings tips"\n'
        '• "Show me a financial report"\n\n'
        'Try asking me one of these questions!';
  }

  /// Generate a comprehensive monthly financial report
  String generateMonthlyReport(
    List<Transaction> transactions,
    List<Budget> budgets,
  ) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    // Calculate totals
    final income = transactions
        .where(
          (t) => t.type == TransactionType.income && t.date.isAfter(monthStart),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final expenses = transactions
        .where(
          (t) =>
              t.type == TransactionType.expense && t.date.isAfter(monthStart),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = income - expenses;

    // Get top spending categories
    final categoryTotals = <String, double>{};
    for (final t in transactions) {
      if (t.type == TransactionType.expense && t.date.isAfter(monthStart)) {
        categoryTotals[t.category] =
            (categoryTotals[t.category] ?? 0.0) + t.amount;
      }
    }

    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top3 = sorted.take(3).toList();

    // Build report
    final response = StringBuffer('📊 Your Monthly Financial Report\n\n');
    response.writeln('Income: ${income.toStringAsFixed(0)} UGX');
    response.writeln('Expenses: ${expenses.toStringAsFixed(0)} UGX');
    response.writeln('Balance: ${balance.toStringAsFixed(0)} UGX\n');

    if (top3.isNotEmpty) {
      response.writeln('Top Spending Categories:');
      for (int i = 0; i < top3.length; i++) {
        final percentage = (top3[i].value / expenses * 100).toStringAsFixed(0);
        response.writeln(
          '${i + 1}. ${top3[i].key}: ${top3[i].value.toStringAsFixed(0)} UGX ($percentage%)',
        );
      }
      response.writeln('');
    }

    // Budget adherence
    if (budgets.isNotEmpty) {
      response.writeln('Budget Status:');
      for (final budget in budgets) {
        final spent = transactions
            .where(
              (t) =>
                  t.type == TransactionType.expense &&
                  t.category == budget.categoryId &&
                  !t.date.isBefore(budget.startDate) &&
                  !t.date.isAfter(budget.endDate),
            )
            .fold(0.0, (sum, t) => sum + t.amount);

        final remaining = budget.limit - spent;
        final percentage = (spent / budget.limit * 100).toStringAsFixed(0);
        final status = spent >= budget.limit
            ? '⚠️'
            : spent >= budget.limit * 0.8
            ? '⚡'
            : '✓';

        response.writeln(
          '$status ${budget.categoryId}: $percentage% of budget used (${remaining.toStringAsFixed(0)} UGX remaining)',
        );
      }
    }

    // Savings rate
    final savingsRate = income > 0
        ? ((balance / income) * 100).toStringAsFixed(1)
        : '0';
    response.writeln(
      '\nSavings Rate: $savingsRate% (${balance.toStringAsFixed(0)} UGX saved)',
    );

    if (balance > 0) {
      response.writeln('💡 Great job! You\'re saving money this month.');
    } else {
      response.writeln(
        '💡 Consider reviewing your expenses to improve savings.',
      );
    }

    return response.toString().trim();
  }

  /// Generate affordability analysis for a purchase
  String generateAffordabilityReport(
    double amount,
    List<Transaction> transactions,
    List<Budget> budgets,
  ) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    final income = transactions
        .where(
          (t) => t.type == TransactionType.income && t.date.isAfter(monthStart),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final expenses = transactions
        .where(
          (t) =>
              t.type == TransactionType.expense && t.date.isAfter(monthStart),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = income - expenses;

    final response = StringBuffer('💰 Affordability Analysis\n\n');
    response.writeln('Purchase Amount: ${amount.toStringAsFixed(0)} UGX');
    response.writeln('Available Balance: ${balance.toStringAsFixed(0)} UGX\n');

    if (amount <= balance * 0.3) {
      response.writeln('✅ Yes, you can comfortably afford this!');
      response.writeln(
        'This would use ${(amount / balance * 100).toStringAsFixed(0)}% of your balance.',
      );
    } else if (amount <= balance) {
      response.writeln('⚠️  You can afford this, but it\'s significant.');
      response.writeln(
        'This would use ${(amount / balance * 100).toStringAsFixed(0)}% of your balance.',
      );
      response.writeln('Consider if this is necessary right now.');
    } else {
      response.writeln('❌ You cannot afford this right now.');
      response.writeln(
        'You need ${(amount - balance).toStringAsFixed(0)} UGX more.',
      );
    }

    final percentageOfIncome = (amount / income * 100).toStringAsFixed(1);
    response.writeln(
      '\nThis represents $percentageOfIncome% of your monthly income.',
    );

    return response.toString().trim();
  }

  /// Generate personalized savings advice
  String generateSavingsAdvice(
    List<Transaction> transactions,
    List<SavingsGoal> goals,
  ) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    // Get monthly data
    final monthlyIncome = transactions
        .where(
          (t) => t.type == TransactionType.income && t.date.isAfter(monthStart),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final monthlyExpenses = transactions
        .where(
          (t) =>
              t.type == TransactionType.expense && t.date.isAfter(monthStart),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final currentSavings = monthlyIncome - monthlyExpenses;
    final recommendedSavings = monthlyIncome * 0.2; // 20% rule

    // Analyze spending patterns
    final categoryTotals = <String, double>{};
    for (final t in transactions) {
      if (t.type == TransactionType.expense && t.date.isAfter(monthStart)) {
        categoryTotals[t.category] =
            (categoryTotals[t.category] ?? 0.0) + t.amount;
      }
    }

    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final response = StringBuffer('💡 Personalized Savings Tips\n\n');

    if (currentSavings >= recommendedSavings) {
      response.writeln(
        '🌟 Excellent! You\'re already saving ${(currentSavings / monthlyIncome * 100).toStringAsFixed(0)}% of your income!',
      );
    } else if (currentSavings > 0) {
      response.writeln(
        '✅ You\'re saving ${(currentSavings / monthlyIncome * 100).toStringAsFixed(0)}% of your income.',
      );
      response.writeln(
        'Target: Save 20% (${recommendedSavings.toStringAsFixed(0)} UGX) per month.\n',
      );
    } else {
      response.writeln('⚠️ You\'re not saving anything this month.');
      response.writeln(
        'Let\'s find ways to save! Target: ${recommendedSavings.toStringAsFixed(0)} UGX per month.\n',
      );
    }

    // Top spending category advice
    if (sorted.isNotEmpty) {
      final topCategory = sorted.first;
      final topAmount = topCategory.value;
      final cutPercentage = (topAmount * 0.1).toStringAsFixed(0);

      response.writeln('📌 Top Spending Category: $topCategory.key');
      response.writeln(
        'You spent ${topAmount.toStringAsFixed(0)} UGX (${(topAmount / monthlyExpenses * 100).toStringAsFixed(0)}% of expenses)',
      );
      response.writeln(
        'If you cut this by 10%, you\'d save $cutPercentage UGX monthly!\n',
      );
    }

    // Goals advice
    if (goals.isNotEmpty) {
      final activeGoals = goals
          .where((g) => g.currentAmount < g.targetAmount)
          .toList();
      if (activeGoals.isNotEmpty) {
        final goal = activeGoals.first;
        final remaining = goal.targetAmount - goal.currentAmount;
        final daysLeft = goal.targetDate.difference(now).inDays;
        final monthlyNeeded = daysLeft > 0
            ? (remaining / (daysLeft / 30.0))
            : remaining;

        response.writeln('🎯 For your goal $goal.name:');
        response.writeln(
          'Save ${monthlyNeeded.toStringAsFixed(0)} UGX monthly to reach it in time.',
        );
        if (currentSavings >= monthlyNeeded) {
          response.writeln('✅ You\'re on track!');
        } else {
          response.writeln(
            '💪 You need to save ${(monthlyNeeded - currentSavings).toStringAsFixed(0)} UGX more per month.',
          );
        }
      }
    } else {
      response.writeln('💡 Pro Tip: Set a savings goal to stay motivated!');
    }

    return response.toString().trim();
  }
}
