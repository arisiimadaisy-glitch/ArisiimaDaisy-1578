import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/routes/app_router.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final TransactionRepository _repository = TransactionRepository();
  final List<String> _filters = [
    'All',
    ...AppConstants.defaultCategories.map((category) => category.name),
  ];
  Future<List<Transaction>> _transactions = Future.value([]);
  String? _userId;
  String _selectedFilter = 'All';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.watch<AuthProvider>().currentUser?.id;
    if (userId != _userId) {
      _userId = userId;
      _transactions = userId == null
          ? Future.value([])
          : _repository.getByUserId(userId);
    }
  }

  Future<void> _refresh() async {
    final userId = _userId;
    if (userId == null) return;
    setState(() => _transactions = _repository.getByUserId(userId));
    await _transactions;
  }

  Future<void> _addExpense() async {
    final saved = await Navigator.pushNamed<bool>(
      context,
      AppRoutes.addExpense,
    );
    if (saved == true && mounted) await _refresh();
  }

  Future<void> _openTransaction(Transaction transaction) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.expenseDetail,
      arguments: {'expenseId': transaction.id},
    );
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF17211B),
        title: const Text('Transactions'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 58,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final selected = _selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _selectedFilter = filter),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF17211B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF16833B),
                  side: BorderSide(
                    color: selected
                        ? const Color(0xFF16833B)
                        : const Color(0xFFE0E7E2),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Transaction>>(
              future: _transactions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _buildMessage(
                    'Could not load your transactions',
                    snapshot.error.toString(),
                    onRetry: _refresh,
                  );
                }

                final expenses = (snapshot.data ?? []).where((transaction) {
                  return transaction.type == TransactionType.expense &&
                      (_selectedFilter == 'All' ||
                          transaction.category == _selectedFilter);
                }).toList();

                if (_userId == null) {
                  return _buildMessage(
                    'Sign in to view your transactions',
                    'Your expenses are private to your account.',
                  );
                }
                if (expenses.isEmpty) {
                  return _buildMessage(
                    _selectedFilter == 'All'
                        ? 'No expenses yet'
                        : 'No $_selectedFilter expenses',
                    'Expenses you add will appear here.',
                    action: 'Add expense',
                    onAction: _addExpense,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: expenses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final transaction = expenses[index];
                      return _buildTransactionCard(transaction);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        backgroundColor: const Color(0xFF16833B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final category = AppConstants.defaultCategories
        .where((item) => item.name == transaction.category)
        .firstOrNull;
    final title = transaction.description.trim().isEmpty
        ? transaction.category
        : transaction.description;

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE8ECE9)),
      ),
      child: ListTile(
        onTap: () => _openTransaction(transaction),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEAF3EC),
          child: Icon(
            category?.icon ?? Icons.receipt_long_outlined,
            color: const Color(0xFF16833B),
          ),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '${transaction.category} · ${DateFormat('d MMM yyyy').format(transaction.date)}',
          style: const TextStyle(color: Color(0xFF748078), fontSize: 12),
        ),
        trailing: Text(
          '−USh ${NumberFormat('#,##0', 'en').format(transaction.amount)}',
          style: const TextStyle(
            color: Color(0xFF17211B),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(
    String title,
    String message, {
    String? action,
    VoidCallback? onAction,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              color: Color(0xFF16833B),
              size: 38,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF17211B),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF748078), fontSize: 13),
            ),
            if (action != null && onAction != null)
              TextButton(onPressed: onAction, child: Text(action)),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
