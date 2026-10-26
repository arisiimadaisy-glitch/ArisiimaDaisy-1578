import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_router.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final String? expenseId;

  const ExpenseDetailScreen({super.key, this.expenseId});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final category = AppConstants.defaultCategories[0];
    final amount = 45000.0;
    final date = DateTime.now();
    final paymentMethod = 'Mobile Money';
    final description = 'Lunch at restaurant';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 9, 66, 14),
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.editExpense,
                arguments: {'expenseId': expenseId},
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Amount',
                    style: TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'USh ${amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF08A71D),
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF08A71D),
                      child: Icon(
                        category.icon,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildDetailRow(
                    Icons.calendar_today_outlined,
                    'Date',
                    DateFormat('EEEE, dd MMM yyyy').format(date),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.payment_outlined,
                    'Payment Method',
                    paymentMethod,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.note_outlined,
                    'Description',
                    description,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          color: Color(0xFF777777),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'No receipt attached',
                          style: TextStyle(
                            color: Color(0xFF777777),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF777777), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
