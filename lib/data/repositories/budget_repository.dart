import '../models/budget_model.dart';

class BudgetRepository {
  final List<Budget> _budgets = [];

  BudgetRepository() {
    _initializeSeedData();
  }

  void _initializeSeedData() {
    final now = DateTime.now();
    final userId = 'user_001';
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final seedBudgets = [
      Budget(
        id: 'budget_001',
        userId: userId,
        categoryId: 'cat_exp_001', // Food
        limit: 150000,
        period: BudgetPeriod.monthly,
        startDate: startOfMonth,
        endDate: endOfMonth,
      ),
      Budget(
        id: 'budget_002',
        userId: userId,
        categoryId: 'cat_exp_002', // Transport
        limit: 100000,
        period: BudgetPeriod.monthly,
        startDate: startOfMonth,
        endDate: endOfMonth,
      ),
      Budget(
        id: 'budget_003',
        userId: userId,
        categoryId: 'cat_exp_006', // Shopping
        limit: 80000,
        period: BudgetPeriod.monthly,
        startDate: startOfMonth,
        endDate: endOfMonth,
      ),
    ];

    _budgets.addAll(seedBudgets);
  }

  Future<List<Budget>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return List.unmodifiable(_budgets);
  }

  Future<Budget?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _budgets.firstWhere((budget) => budget.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Budget>> getByUserId(String userId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _budgets.where((budget) => budget.userId == userId).toList();
  }

  Future<List<Budget>> getByCategoryId(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _budgets
        .where((budget) => budget.categoryId == categoryId)
        .toList();
  }

  Future<void> create(Budget budget) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _budgets.add(budget);
  }

  Future<void> update(Budget budget) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget;
    }
  }

  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _budgets.removeWhere((budget) => budget.id == id);
  }
}
