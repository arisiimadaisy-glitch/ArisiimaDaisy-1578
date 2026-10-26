import '../models/savings_goal_model.dart';

class SavingsRepository {
  final List<SavingsGoal> _goals = [];

  SavingsRepository() {
    _initializeSeedData();
  }

  void _initializeSeedData() {
    final now = DateTime.now();
    final userId = 'user_001';

    final seedGoals = [
      SavingsGoal(
        id: 'goal_001',
        userId: userId,
        name: 'Emergency Fund',
        targetAmount: 2000000,
        currentAmount: 450000,
        targetDate: now.add(const Duration(days: 180)),
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      SavingsGoal(
        id: 'goal_002',
        userId: userId,
        name: 'New Laptop',
        targetAmount: 1500000,
        currentAmount: 300000,
        targetDate: now.add(const Duration(days: 120)),
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    ];

    _goals.addAll(seedGoals);
  }

  Future<List<SavingsGoal>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return List.unmodifiable(_goals);
  }

  Future<SavingsGoal?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _goals.firstWhere((goal) => goal.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<SavingsGoal>> getByUserId(String userId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _goals.where((goal) => goal.userId == userId).toList();
  }

  Future<void> create(SavingsGoal goal) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _goals.add(goal);
  }

  Future<void> update(SavingsGoal goal) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
    }
  }

  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _goals.removeWhere((goal) => goal.id == id);
  }
}
