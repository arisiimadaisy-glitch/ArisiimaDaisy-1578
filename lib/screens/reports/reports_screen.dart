import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const _green = Color(0xFF16833B);
  static const _colors = [
    Color(0xFF16833B),
    Color(0xFF7043E8),
    Color(0xFFFF9800),
    Color(0xFF2196F3),
    Color(0xFFE91E63),
    Color(0xFF607D8B),
  ];

  final TransactionRepository _repository = TransactionRepository();
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
      final transactions = await _repository.getByUserId(userId);
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthTransactions = _transactions.where(
      (transaction) =>
          transaction.date.year == now.year &&
          transaction.date.month == now.month,
    );
    final monthExpenses = monthTransactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .toList();
    final monthTotal = monthExpenses.fold<double>(
      0,
      (total, transaction) => total + transaction.amount,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF17211B),
        title: const Text('Reports & analytics'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? _buildLoadError(_loadError!)
          : RefreshIndicator(
              onRefresh: () => _loadTransactions(_userId),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildMonthSummary(monthTotal, now),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Monthly spending'),
                  const SizedBox(height: 12),
                  _buildMonthlyChart(now),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Spending by category'),
                  const SizedBox(height: 12),
                  _buildCategoryBreakdown(monthExpenses, monthTotal),
                ],
              ),
            ),
    );
  }

  Widget _buildMonthSummary(double total, DateTime now) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16833B), Color(0xFF0B4E2D)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spent in ${DateFormat('MMMM').format(now)}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 7),
          Text(
            'USh ${NumberFormat('#,##0', 'en').format(total)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Calculated from your saved expenses',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF17211B),
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildMonthlyChart(DateTime now) {
    final months = List.generate(
      6,
      (index) => DateTime(now.year, now.month - 5 + index),
    );
    final totals = months.map((month) {
      return _transactions
          .where(
            (transaction) =>
                transaction.type == TransactionType.expense &&
                transaction.date.year == month.year &&
                transaction.date.month == month.month,
          )
          .fold<double>(0, (total, transaction) => total + transaction.amount);
    }).toList();
    final highest = totals.fold<double>(
      0,
      (value, total) => total > value ? total : value,
    );

    return _chartCard(
      SizedBox(
        height: 210,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: highest == 0 ? 1 : highest * 1.2,
            minY: 0,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= months.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('MMM').format(months[index]),
                        style: const TextStyle(
                          color: Color(0xFF748078),
                          fontSize: 11,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: highest == 0 ? 1 : highest / 4,
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: Color(0xFFE8ECE9), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(months.length, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: totals[index],
                    color: _green,
                    width: 18,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<Transaction> expenses, double total) {
    final totals = <String, double>{};
    for (final transaction in expenses) {
      totals.update(
        transaction.category,
        (amount) => amount + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
    final categories = totals.entries.toList()
      ..sort((first, second) => second.value.compareTo(first.value));

    if (categories.isEmpty) {
      return _chartCard(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Center(
            child: Text(
              'No expenses recorded this month yet.',
              style: TextStyle(color: Color(0xFF748078), fontSize: 13),
            ),
          ),
        ),
      );
    }

    return _chartCard(
      Column(
        children: [
          SizedBox(
            height: 190,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 48,
                sections: List.generate(categories.length, (index) {
                  final entry = categories[index];
                  final percentage = total == 0 ? 0 : entry.value / total * 100;
                  return PieChartSectionData(
                    value: entry.value,
                    color: _colors[index % _colors.length],
                    title: '${percentage.round()}%',
                    radius: 55,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < categories.length; index++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: _colors[index % _colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      categories[index].key,
                      style: const TextStyle(
                        color: Color(0xFF17211B),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    'USh ${NumberFormat('#,##0', 'en').format(categories[index].value)}',
                    style: const TextStyle(
                      color: Color(0xFF17211B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _chartCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8ECE9)),
      ),
      child: child,
    );
  }

  Widget _buildLoadError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Could not load reports',
              style: TextStyle(
                color: Color(0xFF17211B),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF748078)),
            ),
            TextButton(
              onPressed: () => _loadTransactions(_userId),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
