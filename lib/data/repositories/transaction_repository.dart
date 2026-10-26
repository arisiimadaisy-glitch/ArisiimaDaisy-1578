import '../models/transaction_model.dart';

class TransactionRepository {
  final List<Transaction> _transactions = [];

  TransactionRepository() {
    _initializeSeedData();
  }

  void _initializeSeedData() {
    final now = DateTime.now();
    final userId = 'user_001';

    // Seed 18 transactions over last 60 days
    final seedTransactions = [
      // Income transactions
      Transaction(
        id: 'txn_001',
        userId: userId,
        type: TransactionType.income,
        amount: 450000,
        category: 'Salary',
        date: now.subtract(const Duration(days: 5)),
        paymentMethod: 'Bank Transfer',
        description: 'Monthly salary',
      ),
      Transaction(
        id: 'txn_002',
        userId: userId,
        type: TransactionType.income,
        amount: 120000,
        category: 'Freelance',
        date: now.subtract(const Duration(days: 15)),
        paymentMethod: 'Mobile Money',
        description: 'Web design project',
      ),
      Transaction(
        id: 'txn_003',
        userId: userId,
        type: TransactionType.income,
        amount: 35000,
        category: 'Gifts',
        date: now.subtract(const Duration(days: 22)),
        paymentMethod: 'Cash',
        description: 'Birthday gift',
      ),
      Transaction(
        id: 'txn_004',
        userId: userId,
        type: TransactionType.income,
        amount: 450000,
        category: 'Salary',
        date: now.subtract(const Duration(days: 35)),
        paymentMethod: 'Bank Transfer',
        description: 'Monthly salary',
      ),
      
      // Expense transactions
      Transaction(
        id: 'txn_005',
        userId: userId,
        type: TransactionType.expense,
        amount: 25000,
        category: 'Food',
        date: now.subtract(const Duration(days: 1)),
        paymentMethod: 'Mobile Money',
        description: 'Groceries at Nakumatt',
      ),
      Transaction(
        id: 'txn_006',
        userId: userId,
        type: TransactionType.expense,
        amount: 15000,
        category: 'Transport',
        date: now.subtract(const Duration(days: 2)),
        paymentMethod: 'Cash',
        description: 'Uber rides',
      ),
      Transaction(
        id: 'txn_007',
        userId: userId,
        type: TransactionType.expense,
        amount: 8000,
        category: 'Airtime',
        date: now.subtract(const Duration(days: 3)),
        paymentMethod: 'Mobile Money',
        description: 'MTN airtime',
      ),
      Transaction(
        id: 'txn_008',
        userId: userId,
        type: TransactionType.expense,
        amount: 45000,
        category: 'Shopping',
        date: now.subtract(const Duration(days: 7)),
        paymentMethod: 'Card',
        description: 'Clothes shopping',
      ),
      Transaction(
        id: 'txn_009',
        userId: userId,
        type: TransactionType.expense,
        amount: 180000,
        category: 'Rent',
        date: now.subtract(const Duration(days: 8)),
        paymentMethod: 'Bank Transfer',
        description: 'Monthly rent',
      ),
      Transaction(
        id: 'txn_010',
        userId: userId,
        type: TransactionType.expense,
        amount: 30000,
        category: 'Food',
        date: now.subtract(const Duration(days: 10)),
        paymentMethod: 'Cash',
        description: 'Restaurant dinner',
      ),
      Transaction(
        id: 'txn_011',
        userId: userId,
        type: TransactionType.expense,
        amount: 12000,
        category: 'Transport',
        date: now.subtract(const Duration(days: 12)),
        paymentMethod: 'Cash',
        description: 'Matatu fare',
      ),
      Transaction(
        id: 'txn_012',
        userId: userId,
        type: TransactionType.expense,
        amount: 55000,
        category: 'Entertainment',
        date: now.subtract(const Duration(days: 18)),
        paymentMethod: 'Card',
        description: 'Movie tickets and dinner',
      ),
      Transaction(
        id: 'txn_013',
        userId: userId,
        type: TransactionType.expense,
        amount: 28000,
        category: 'Food',
        date: now.subtract(const Duration(days: 20)),
        paymentMethod: 'Mobile Money',
        description: 'Groceries',
      ),
      Transaction(
        id: 'txn_014',
        userId: userId,
        type: TransactionType.expense,
        amount: 95000,
        category: 'Health',
        date: now.subtract(const Duration(days: 25)),
        paymentMethod: 'Cash',
        description: 'Medical checkup',
      ),
      Transaction(
        id: 'txn_015',
        userId: userId,
        type: TransactionType.expense,
        amount: 65000,
        category: 'Education',
        date: now.subtract(const Duration(days: 30)),
        paymentMethod: 'Bank Transfer',
        description: 'Online course fee',
      ),
      Transaction(
        id: 'txn_016',
        userId: userId,
        type: TransactionType.expense,
        amount: 18000,
        category: 'Transport',
        date: now.subtract(const Duration(days: 40)),
        paymentMethod: 'Cash',
        description: 'Boda boda rides',
      ),
      Transaction(
        id: 'txn_017',
        userId: userId,
        type: TransactionType.expense,
        amount: 32000,
        category: 'Food',
        date: now.subtract(const Duration(days: 45)),
        paymentMethod: 'Card',
        description: 'Lunch meetings',
      ),
      Transaction(
        id: 'txn_018',
        userId: userId,
        type: TransactionType.expense,
        amount: 22000,
        category: 'Shopping',
        date: now.subtract(const Duration(days: 55)),
        paymentMethod: 'Mobile Money',
        description: 'Home supplies',
      ),
    ];

    _transactions.addAll(seedTransactions);
  }

  Future<List<Transaction>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return List.unmodifiable(_transactions);
  }

  Future<Transaction?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _transactions.firstWhere((txn) => txn.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Transaction>> getByUserId(String userId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _transactions.where((txn) => txn.userId == userId).toList();
  }

  Future<List<Transaction>> getByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _transactions
        .where((txn) =>
            txn.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            txn.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  Future<List<Transaction>> getByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _transactions.where((txn) => txn.category == category).toList();
  }

  Future<void> create(Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _transactions.add(transaction);
  }

  Future<void> update(Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _transactions.indexWhere((txn) => txn.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }
  }

  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _transactions.removeWhere((txn) => txn.id == id);
  }
}
