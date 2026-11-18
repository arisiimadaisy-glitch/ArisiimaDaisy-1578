import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/routes/app_router.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _ink = Color(0xFF17211B);
  static const _muted = Color(0xFF748078);
  static const _green = Color(0xFF16833B);

  final TransactionRepository _transactionRepository = TransactionRepository();
  List<Transaction> _transactions = [];
  String? _userId;
  String? _loadError;
  bool _isLoading = false;
  bool _hasResolvedUser = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.watch<AuthProvider>().currentUser?.id;
    if (!_hasResolvedUser || userId != _userId) {
      _hasResolvedUser = true;
      _userId = userId;
      _loadTransactions(userId);
    }
  }

  Future<void> _loadTransactions(String? userId) async {
    if (userId == null) {
      setState(() {
        _transactions = [];
        _loadError = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _transactions = [];
      _isLoading = true;
      _loadError = null;
    });

    try {
      final transactions = await _transactionRepository.getByUserId(userId);
      if (!mounted || userId != _userId) return;
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || userId != _userId) return;
      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openAddExpense() async {
    final saved = await Navigator.pushNamed<bool>(
      context,
      AppRoutes.addExpense,
    );
    if (saved == true && mounted) {
      await _loadTransactions(_userId);
    }
  }

  double _totalFor(Iterable<Transaction> transactions, TransactionType type) {
    return transactions
        .where((transaction) => transaction.type == type)
        .fold(0.0, (total, transaction) => total + transaction.amount);
  }

  String _formatAmount(double amount) {
    return 'USh ${NumberFormat('#,##0', 'en').format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final now = DateTime.now();
    final monthTransactions = _transactions.where(
      (transaction) =>
          transaction.date.year == now.year &&
          transaction.date.month == now.month,
    );
    final monthExpenses = _totalFor(monthTransactions, TransactionType.expense);
    final monthIncome = _totalFor(monthTransactions, TransactionType.income);
    final totalIncome = _totalFor(_transactions, TransactionType.income);
    final totalExpenses = _totalFor(_transactions, TransactionType.expense);
    final balance = totalIncome - totalExpenses;
    final categories = _categoryTotals(monthTransactions);
    final greetingName = user?.name.trim();
    final displayName = greetingName == null || greetingName.isEmpty
        ? 'there'
        : greetingName;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _loadTransactions(_userId),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _buildTopBar(user?.name),
              const SizedBox(height: 22),
              _buildBalanceCard(displayName, balance),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      label: 'Income this month',
                      amount: monthIncome,
                      icon: Icons.south_west_rounded,
                      color: _green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      label: 'Spent this month',
                      amount: monthExpenses,
                      icon: Icons.north_east_rounded,
                      color: const Color(0xFFB05A45),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Quick actions'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildAction(
                      icon: Icons.add_rounded,
                      label: 'Add expense',
                      onTap: _openAddExpense,
                      primary: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAction(
                      icon: Icons.receipt_long_outlined,
                      label: 'All transactions',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.expenseList),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _buildSectionHeader(
                'Recent transactions',
                actionLabel: 'See all',
                onAction: () =>
                    Navigator.pushNamed(context, AppRoutes.expenseList),
              ),
              const SizedBox(height: 12),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(28),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_loadError != null)
                _buildErrorCard(_loadError!)
              else if (_transactions.isEmpty)
                _buildEmptyState()
              else
                ..._transactions.take(5).map(_buildTransactionTile),
              if (!_isLoading &&
                  _loadError == null &&
                  categories.isNotEmpty) ...[
                const SizedBox(height: 28),
                _buildSectionHeader('Spending by category'),
                const SizedBox(height: 12),
                _buildCategoryCard(categories),
              ],
              const SizedBox(height: 12),
              Text(
                'Your totals include only transactions saved to your account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _muted.withValues(alpha: 0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildTopBar(String? name) {
    final initials = name == null || name.trim().isEmpty
        ? 'P'
        : name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((part) => part[0].toUpperCase())
              .join();

    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PesaTracker',
                style: TextStyle(
                  color: _ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Your money, in focus',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Profile',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          icon: CircleAvatar(
            radius: 19,
            backgroundColor: const Color(0xFFE0EFE4),
            child: Text(
              initials,
              style: const TextStyle(
                color: _green,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(String name, double balance) {
    final now = DateTime.now();
    final timeOfDay = now.hour < 12
        ? 'morning'
        : now.hour < 17
        ? 'afternoon'
        : 'evening';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF16833B), Color(0xFF0B4E2D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good $timeOfDay, $name',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Total balance',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            _formatAmount(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE, d MMMM').format(now),
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8ECE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 14),
          Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatAmount(amount),
              style: const TextStyle(
                color: _ink,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _ink,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: _green,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    final foreground = primary ? Colors.white : _ink;
    return Material(
      color: primary ? _green : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: primary ? null : Border.all(color: const Color(0xFFE3E9E5)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final title = transaction.description.trim().isEmpty
        ? transaction.category
        : transaction.description;
    final icon = AppConstants.defaultCategories
        .where((category) => category.name == transaction.category)
        .map((category) => category.icon)
        .firstOrNull;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECE9)),
      ),
      child: ListTile(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.expenseDetail,
          arguments: {'expenseId': transaction.id},
        ),
        leading: CircleAvatar(
          backgroundColor: isIncome
              ? const Color(0xFFE5F3E9)
              : const Color(0xFFF1F3F2),
          child: Icon(
            icon ?? (isIncome ? Icons.south_west_rounded : Icons.receipt_long),
            color: isIncome ? _green : _ink,
            size: 20,
          ),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _ink,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${transaction.category} · ${DateFormat('d MMM').format(transaction.date)}',
          style: const TextStyle(color: _muted, fontSize: 12),
        ),
        trailing: Text(
          '${isIncome ? '+' : '−'}${_formatAmount(transaction.amount)}',
          style: TextStyle(
            color: isIncome ? _green : _ink,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8ECE9)),
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_outlined, color: _green, size: 34),
          const SizedBox(height: 10),
          const Text(
            'No transactions yet',
            style: TextStyle(
              color: _ink,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Add your first expense to start tracking your money.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 13),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _openAddExpense,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add an expense'),
            style: FilledButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0D4CD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Could not load your transactions',
            style: TextStyle(color: _ink, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(error, style: const TextStyle(color: _muted, fontSize: 12)),
          TextButton(
            onPressed: () => _loadTransactions(_userId),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Map<String, double> _categoryTotals(Iterable<Transaction> transactions) {
    final totals = <String, double>{};
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        totals.update(
          transaction.category,
          (amount) => amount + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }
    return totals;
  }

  Widget _buildCategoryCard(Map<String, double> categories) {
    final entries = categories.entries.toList()
      ..sort((first, second) => second.value.compareTo(first.value));
    final highest = entries.first.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8ECE9)),
      ),
      child: Column(
        children: [
          for (var index = 0; index < entries.length; index++) ...[
            if (index > 0) const SizedBox(height: 17),
            Row(
              children: [
                Expanded(
                  child: Text(
                    entries[index].key,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  _formatAmount(entries[index].value),
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: highest == 0 ? 0 : entries[index].value / highest,
              minHeight: 6,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: const Color(0xFFEAF0EC),
              color: _green,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE6EAE7))),
        ),
        child: Row(
          children: [
            _buildBottomItem(Icons.home_rounded, 'Home', null),
            _buildBottomItem(
              Icons.receipt_long_outlined,
              'Activity',
              AppRoutes.expenseList,
            ),
            _buildBottomItem(
              Icons.add_circle_outline,
              'Add',
              AppRoutes.addExpense,
            ),
            _buildBottomItem(
              Icons.bar_chart_rounded,
              'Reports',
              AppRoutes.reports,
            ),
            _buildBottomItem(
              Icons.person_outline_rounded,
              'Profile',
              AppRoutes.profile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomItem(IconData icon, String label, String? route) {
    final selected = route == null;
    return Expanded(
      child: InkWell(
        onTap: route == null
            ? null
            : () async {
                if (route == AppRoutes.addExpense) {
                  await _openAddExpense();
                } else {
                  await Navigator.pushNamed(context, route);
                  if (route == AppRoutes.expenseList && mounted) {
                    await _loadTransactions(_userId);
                  }
                }
              },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? _green : _muted, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: selected ? _green : _muted,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
