import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/routes/app_router.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final String? expenseId;

  const ExpenseDetailScreen({super.key, this.expenseId});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  final TransactionRepository _repository = TransactionRepository();
  Future<Transaction?> _transaction = Future.value(null);
  String? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.watch<AuthProvider>().currentUser?.id;
    if (userId != _userId) {
      _userId = userId;
      _transaction = userId == null || widget.expenseId == null
          ? Future.value(null)
          : _repository.getById(userId, widget.expenseId!);
    }
  }

  Future<void> _reload() async {
    final userId = _userId;
    final expenseId = widget.expenseId;
    if (userId == null || expenseId == null) return;
    setState(() => _transaction = _repository.getById(userId, expenseId));
    await _transaction;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF17211B),
        title: const Text('Transaction details'),
      ),
      body: FutureBuilder<Transaction?>(
        future: _transaction,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildMessage(
              'Could not load this transaction',
              snapshot.error.toString(),
              onRetry: _reload,
            );
          }

          final transaction = snapshot.data;
          if (transaction == null) {
            return _buildMessage(
              'Transaction not found',
              'It may have been removed or may not belong to this account.',
            );
          }
          return _buildDetails(transaction);
        },
      ),
    );
  }

  Widget _buildDetails(Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final category = AppConstants.defaultCategories
        .where((item) => item.name == transaction.category)
        .firstOrNull;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE8ECE9)),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: isIncome
                    ? const Color(0xFFE5F3E9)
                    : const Color(0xFFF1F3F2),
                child: Icon(
                  category?.icon ??
                      (isIncome
                          ? Icons.south_west_rounded
                          : Icons.receipt_long_outlined),
                  color: isIncome
                      ? const Color(0xFF16833B)
                      : const Color(0xFF17211B),
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                transaction.description.trim().isEmpty
                    ? transaction.category
                    : transaction.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF17211B),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                transaction.category,
                style: const TextStyle(color: Color(0xFF748078), fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                '${isIncome ? '+' : '−'}USh ${NumberFormat('#,##0', 'en').format(transaction.amount)}',
                style: TextStyle(
                  color: isIncome
                      ? const Color(0xFF16833B)
                      : const Color(0xFF17211B),
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8ECE9)),
          ),
          child: Column(
            children: [
              _buildDetailRow(
                Icons.calendar_today_outlined,
                'Date',
                DateFormat('EEEE, d MMM yyyy').format(transaction.date),
              ),
              const Divider(height: 24),
              _buildDetailRow(
                Icons.payment_outlined,
                'Payment method',
                transaction.paymentMethod,
              ),
              if (transaction.description.trim().isNotEmpty) ...[
                const Divider(height: 24),
                _buildDetailRow(
                  Icons.notes_rounded,
                  'Notes',
                  transaction.description,
                ),
              ],
            ],
          ),
        ),
        if (!isIncome) ...[
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.editExpense,
                arguments: {'expenseId': transaction.id},
              );
              if (mounted) await _reload();
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit expense'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF16833B),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF748078), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Color(0xFF748078), fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF17211B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessage(String title, String message, {VoidCallback? onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF17211B),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF748078)),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
