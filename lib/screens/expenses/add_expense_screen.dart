import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/auth_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();

  ExpenseCategory? _selectedCategory;
  String? _selectedPaymentMethod;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  final TransactionRepository _transactionRepository = TransactionRepository();

  final List<String> _paymentMethods = [
    'Cash',
    'Mobile Money',
    'Bank Transfer',
    'Card',
  ];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd MMM yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in before saving an expense.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _transactionRepository.create(
        Transaction(
          id: '',
          userId: userId,
          type: TransactionType.expense,
          amount: double.parse(_amountController.text.trim()),
          category: _selectedCategory!.name,
          date: _selectedDate,
          paymentMethod: _selectedPaymentMethod ?? 'Unspecified',
          description: _descriptionController.text.trim(),
        ),
      );

      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save expense: $error')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 9, 66, 14),
        title: const Text('Add Expense'),
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
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Amount',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        prefixText: 'USh ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter an amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Enter a valid amount greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Category',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<ExpenseCategory>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Select a category'),
                      items: AppConstants.defaultCategories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Row(
                                children: [
                                  Icon(category.icon, size: 20),
                                  const SizedBox(width: 12),
                                  Text(category.name),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                      validator: (value) {
                        if (value == null) return 'Select a category';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Date',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(),
                      ),
                      onTap: _selectDate,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Select a date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Payment Method',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPaymentMethod,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Select payment method'),
                      items: _paymentMethods
                          .map(
                            (method) => DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedPaymentMethod = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description (Optional)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter description',
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSaving ? null : _saveExpense,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        backgroundColor: const Color.fromARGB(255, 8, 167, 29),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Save Expense'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
