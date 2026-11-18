import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/auth_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

class EditExpenseScreen extends StatefulWidget {
  final String? expenseId;

  const EditExpenseScreen({super.key, this.expenseId});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TransactionRepository _repository = TransactionRepository();
  final List<String> _paymentMethods = const [
    'Cash',
    'Mobile Money',
    'Bank Transfer',
    'Card',
    'Unspecified',
  ];

  ExpenseCategory? _selectedCategory;
  String? _selectedPaymentMethod;
  DateTime _selectedDate = DateTime.now();
  Transaction? _transaction;
  String? _userId;
  String? _loadError;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasResolvedUser = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.watch<AuthProvider>().currentUser?.id;
    if (!_hasResolvedUser || userId != _userId) {
      _hasResolvedUser = true;
      _userId = userId;
      _loadTransaction(userId);
    }
  }

  Future<void> _loadTransaction(String? userId) async {
    final expenseId = widget.expenseId;
    if (userId == null || expenseId == null) {
      setState(() {
        _isLoading = false;
        _loadError = 'This expense is not available for your account.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final transaction = await _repository.getById(userId, expenseId);
      if (!mounted || userId != _userId) return;
      if (transaction == null || transaction.type != TransactionType.expense) {
        setState(() {
          _transaction = null;
          _loadError = 'This expense could not be found.';
          _isLoading = false;
        });
        return;
      }

      _transaction = transaction;
      _amountController.text = transaction.amount.toStringAsFixed(0);
      _selectedCategory = AppConstants.defaultCategories
          .where((category) => category.name == transaction.category)
          .firstOrNull;
      _selectedDate = transaction.date;
      _dateController.text = DateFormat('dd MMM yyyy').format(_selectedDate);
      _selectedPaymentMethod =
          _paymentMethods.contains(transaction.paymentMethod)
          ? transaction.paymentMethod
          : 'Unspecified';
      _descriptionController.text = transaction.description;
      setState(() => _isLoading = false);
    } catch (error) {
      if (!mounted || userId != _userId) return;
      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _updateExpense() async {
    if (!_formKey.currentState!.validate()) return;
    final transaction = _transaction;
    if (transaction == null || _userId == null) return;

    setState(() => _isSaving = true);
    try {
      await _repository.update(
        transaction.copyWith(
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update expense: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF17211B),
        title: const Text('Edit expense'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _loadError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF748078)),
                ),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFFE8ECE9)),
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
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              prefixText: 'USh ',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final amount = double.tryParse(
                                value?.trim() ?? '',
                              );
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
                            onChanged: (value) =>
                                setState(() => _selectedCategory = value),
                            validator: (value) =>
                                value == null ? 'Select a category' : null,
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
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Payment method',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedPaymentMethod,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: _paymentMethods
                                .map(
                                  (method) => DropdownMenuItem(
                                    value: method,
                                    child: Text(method),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedPaymentMethod = value),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Description (optional)',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Add a note',
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _isSaving ? null : _updateExpense,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              backgroundColor: const Color(0xFF16833B),
                              foregroundColor: Colors.white,
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
                                : const Text('Save changes'),
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
