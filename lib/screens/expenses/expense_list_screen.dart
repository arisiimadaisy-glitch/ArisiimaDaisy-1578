import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_router.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = [
    'All',
    'Food & Dining',
    'Transport',
    'Shopping',
    'Entertainment',
  ];

  final List<_MockExpense> _expenses = [
    _MockExpense(
      id: 'exp_1',
      name: 'Lunch at Java',
      category: AppConstants.defaultCategories[0],
      date: 'Today',
      amount: 45000,
    ),
    _MockExpense(
      id: 'exp_2',
      name: 'Uber to Office',
      category: AppConstants.defaultCategories[1],
      date: 'Today',
      amount: 12000,
    ),
    _MockExpense(
      id: 'exp_3',
      name: 'Grocery Shopping',
      category: AppConstants.defaultCategories[7],
      date: 'Yesterday',
      amount: 85000,
    ),
    _MockExpense(
      id: 'exp_4',
      name: 'Movie Tickets',
      category: AppConstants.defaultCategories[3],
      date: 'Yesterday',
      amount: 30000,
    ),
    _MockExpense(
      id: 'exp_5',
      name: 'Dinner at Cafe',
      category: AppConstants.defaultCategories[0],
      date: '2 days ago',
      amount: 55000,
    ),
    _MockExpense(
      id: 'exp_6',
      name: 'New Shoes',
      category: AppConstants.defaultCategories[2],
      date: '3 days ago',
      amount: 120000,
    ),
    _MockExpense(
      id: 'exp_7',
      name: 'Boda Boda',
      category: AppConstants.defaultCategories[1],
      date: '3 days ago',
      amount: 8000,
    ),
    _MockExpense(
      id: 'exp_8',
      name: 'Internet Bill',
      category: AppConstants.defaultCategories[4],
      date: '4 days ago',
      amount: 150000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 9, 66, 14),
        title: const Text('All Expenses'),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final selected = _selectedFilter == index;
                  return ChoiceChip(
                    label: Text(_filters[index]),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _selectedFilter = index),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF111111),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: Colors.transparent,
                    selectedColor: const Color(0xFF08A71D),
                    side: BorderSide(
                      color: selected
                          ? const Color(0xFF08A71D)
                          : const Color(0xFFB8B8B6),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final expense = _expenses[index];
                return Card(
                  elevation: 0,
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF08A71D),
                      child: Icon(expense.category.icon, color: Colors.white),
                    ),
                    title: Text(
                      expense.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      expense.date,
                      style: const TextStyle(
                        color: Color(0xFF777777),
                        fontSize: 13,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'USh ${expense.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 20),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.expenseDetail,
                        arguments: {'expenseId': expense.id},
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addExpense);
        },
        backgroundColor: const Color(0xFF08A71D),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MockExpense {
  final String id;
  final String name;
  final ExpenseCategory category;
  final String date;
  final double amount;

  _MockExpense({
    required this.id,
    required this.name,
    required this.category,
    required this.date,
    required this.amount,
  });
}
