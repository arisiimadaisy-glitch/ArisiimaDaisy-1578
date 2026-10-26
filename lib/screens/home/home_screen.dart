import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/routes/app_router.dart';
import '../../core/constants/app_constants.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _ink = Color(0xFF111111);
  static const _muted = Color(0xFF777777);
  static const _purple = Color(0xFF7043E8);

  final _tabs = const ['Categories', 'Merchants', 'Payment types'];
  final _bottomItems = const [
    (Icons.home_rounded, 'Home'),
    (Icons.receipt_long_outlined, 'Activity'),
    (Icons.add_circle_outline, 'Add'),
    (Icons.bar_chart_rounded, 'Insights'),
    (Icons.person_outline, 'Profile'),
  ];
  final _weekStart = _mondayOf(DateTime.now());
  int _selectedTab = 0;
  int _selectedBottomItem = 0;
  int _weekOffset = 0;

  final _categories = const [
    _ExpenseCategory(
      name: 'Travel',
      transactions: '2 transactions',
      amount: 115.54,
      icon: Icons.train_outlined,
    ),
    _ExpenseCategory(
      name: 'Groceries',
      transactions: '5 transactions',
      amount: 57.43,
      icon: Icons.shopping_cart_outlined,
    ),
    _ExpenseCategory(
      name: 'Shopping',
      transactions: '9 transactions',
      amount: 51.11,
      icon: Icons.shopping_bag_outlined,
    ),
    _ExpenseCategory(
      name: 'Bills',
      transactions: '1 transaction',
      amount: 41.00,
      icon: Icons.receipt_long_outlined,
    ),
    _ExpenseCategory(
      name: 'Transfers',
      transactions: '2 transactions',
      amount: 25.39,
      icon: Icons.swap_horiz_rounded,
    ),
    _ExpenseCategory(
      name: 'Eating out',
      transactions: '1 transaction',
      amount: 13.37,
      icon: Icons.restaurant_outlined,
    ),
    _ExpenseCategory(
      name: 'Entertainment',
      transactions: '2 transactions',
      amount: 1.59,
      icon: Icons.movie_outlined,
    ),
  ];

  String get _weekLabel {
    final start = _weekStart.add(Duration(days: _weekOffset * 7));
    final end = start.add(const Duration(days: 6));
    return '${start.day} ${_month(start.month)} - ${end.day} ${_month(end.month)}';
  }

  static DateTime _mondayOf(DateTime date) =>
      DateTime(date.year, date.month, date.day - date.weekday + 1);

  String _month(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];
  String _formatAmount(double amount) {
    return '${AppConstants.defaultCurrency.symbol} '
        '${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F3),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildGreetingCard()),
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildQuickActions()),
                  SliverToBoxAdapter(child: _buildPeriodSelector()),
                  SliverToBoxAdapter(child: _buildTabs()),
                  SliverToBoxAdapter(child: _buildTotal()),
                  SliverToBoxAdapter(child: _buildComparison()),
                  SliverList.separated(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) =>
                        _buildCategory(_categories[index]),
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      indent: 84,
                      color: Color(0xFFE8E8E6),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingCard() {
    final now = DateTime.now();
    final timeOfDay = now.hour < 12
        ? 'morning'
        : now.hour < 17
        ? 'afternoon'
        : 'evening';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF08A71D), Color.fromARGB(255, 9, 66, 14)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good $timeOfDay, User 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('EEEE, dd MMM yyyy').format(now),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'USh 245,000 spent this month',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.add_circle_outline,
              label: 'Add Expense',
              color: const Color(0xFF08A71D),
              onTap: () => Navigator.pushNamed(context, AppRoutes.addExpense),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.bar_chart,
              label: 'Reports',
              color: const Color(0xFF7043E8),
              onTap: () => Navigator.pushNamed(context, AppRoutes.reports),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.grid_view,
              label: 'Categories',
              color: const Color(0xFFFF9800),
              onTap: () => Navigator.pushNamed(context, AppRoutes.categories),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.settings_outlined,
              label: 'Settings',
              color: const Color(0xFF2196F3),
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          const SizedBox(
            width: 48,
            child: Icon(Icons.account_balance_wallet_outlined, size: 24),
          ),
          const Expanded(
            child: Text(
              'Spending insights',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _ink,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Choose date',
            onPressed: () => _showDatePicker(),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: 'Previous week',
            onPressed: () => setState(() => _weekOffset -= 1),
            icon: const Icon(Icons.chevron_left, size: 34),
          ),
          Text(
            _weekLabel,
            style: const TextStyle(
              color: _ink,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            tooltip: 'Next week',
            onPressed: _weekOffset >= 0
                ? null
                : () => setState(() => _weekOffset += 1),
            style: IconButton.styleFrom(
              backgroundColor: _weekOffset >= 0
                  ? const Color(0xFFE7E7E5)
                  : Colors.white,
              disabledBackgroundColor: const Color(0xFFE2E2E0),
            ),
            icon: const Icon(Icons.chevron_right, size: 34),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final selected = _selectedTab == index;
          return ChoiceChip(
            label: Text(_tabs[index]),
            selected: selected,
            showCheckmark: false,
            onSelected: (_) => setState(() => _selectedTab = index),
            labelStyle: TextStyle(
              color: selected ? Colors.white : _ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: Colors.transparent,
            selectedColor: _ink,
            side: BorderSide(color: selected ? _ink : const Color(0xFFB8B8B6)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          );
        },
      ),
    );
  }

  Widget _buildTotal() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 38, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Total spent',
            style: TextStyle(
              color: _ink,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '£305.43',
            style: TextStyle(
              color: _ink,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparison() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: _purple,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_downward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '£4,556 less ',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: 'than the previous 7 days'),
                  ],
                ),
                style: TextStyle(fontSize: 14, color: _ink),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(_ExpenseCategory category) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD5D5D3)),
            ),
            child: Icon(category.icon, color: _ink, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  category.transactions,
                  style: const TextStyle(color: _muted, fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            _formatAmount(category.amount),
            style: const TextStyle(
              color: _ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 5),
          const Icon(Icons.chevron_right, color: _ink),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE6E6E4))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: List.generate(_bottomItems.length, (index) {
              final item = _bottomItems[index];
              final selected = _selectedBottomItem == index;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedBottomItem = index);

                    if (index == 0) {
                      // Already on the dashboard.
                      return;
                    }

                    switch (index) {
                      case 1:
                        Navigator.pushNamed(context, AppRoutes.expenseList);
                        break;
                      case 2:
                        Navigator.pushNamed(context, AppRoutes.addExpense);
                        break;
                      case 3:
                        Navigator.pushNamed(context, AppRoutes.reports);
                        break;
                      case 4:
                        Navigator.pushNamed(context, AppRoutes.profile);
                        break;
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.$1,
                        color: selected ? _ink : const Color(0xFF777777),
                        size: 23,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.$2,
                        style: TextStyle(
                          color: selected ? _ink : const Color(0xFF777777),
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'SELECT A DATE',
    );
    if (selected != null && mounted) {
      setState(() {
        final selectedWeek = _mondayOf(selected);
        _weekOffset = selectedWeek.difference(_weekStart).inDays ~/ 7;
      });
    }
  }
}

class _ExpenseCategory {
  const _ExpenseCategory({
    required this.name,
    required this.transactions,
    required this.amount,
    required this.icon,
  });

  final String name;
  final String transactions;
  final double amount;
  final IconData icon;
}
