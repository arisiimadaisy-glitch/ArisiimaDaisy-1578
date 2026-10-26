import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final List<Category> _categories = [];

  CategoryRepository() {
    _initializeSeedData();
  }

  void _initializeSeedData() {
    // Expense categories
    final expenseCategories = [
      Category(
        id: 'cat_exp_001',
        userId: null,
        name: 'Food',
        type: CategoryType.expense,
        icon: Icons.restaurant.codePoint.toString(),
        color: 0xFFFF6B6B,
        isDefault: true,
      ),
      Category(
        id: 'cat_exp_002',
        userId: null,
        name: 'Transport',
        type: CategoryType.expense,
        icon: Icons.directions_car.codePoint.toString(),
        color: 0xFF4ECDC4,
        isDefault: true,
      ),
      Category(
        id: 'cat_exp_003',
        userId: null,
        name: 'Rent',
        type: CategoryType.expense,
        icon: Icons.home.codePoint.toString(),
        color: 0xFF95E1D3,
        isDefault: true,
      ),
      Category(
        id: 'cat_exp_004',
        userId: null,
        name: 'Education',
        type: CategoryType.expense,
        icon: Icons.school.codePoint.toString(),
        color: 0xFF5F9EA0,
        isDefault: true,
      ),
      Category(
        id: 'cat_exp_005',
        userId: null,
        name: 'Airtime',
        type: CategoryType.expense,
        icon: Icons.phone.codePoint.toString(),
        color: 0xFFFFAA4D,
        isDefault: true,
      ),
      Category(
        id: 'cat_exp_006',
        userId: null,
        name: 'Shopping',
        type: CategoryType.expense,
        icon: Icons.shopping_bag.codePoint.toString(),
        color: 0xFFFF8B94,
        isDefault: true,
      ),
      Category(
        id: 'cat_exp_007',
        userId: null,
        name: 'Health',
        type: CategoryType.expense,
        icon: Icons.local_hospital.codePoint.toString(),
        color: 0xFFA8E6CF,
        isDefault: true,
      ),
      Category(
        id: 'cat_exp_008',
        userId: null,
        name: 'Entertainment',
        type: CategoryType.expense,
        icon: Icons.movie.codePoint.toString(),
        color: 0xFFDDA8E6,
        isDefault: true,
      ),
      Category(
        id: 'cat_exp_009',
        userId: null,
        name: 'Other',
        type: CategoryType.expense,
        icon: Icons.more_horiz.codePoint.toString(),
        color: 0xFFB0B0B0,
        isDefault: true,
      ),
    ];

    // Income categories
    final incomeCategories = [
      Category(
        id: 'cat_inc_001',
        userId: null,
        name: 'Salary',
        type: CategoryType.income,
        icon: Icons.attach_money.codePoint.toString(),
        color: 0xFF4CAF50,
        isDefault: true,
      ),
      Category(
        id: 'cat_inc_002',
        userId: null,
        name: 'Business',
        type: CategoryType.income,
        icon: Icons.business.codePoint.toString(),
        color: 0xFF8BC34A,
        isDefault: true,
      ),
      Category(
        id: 'cat_inc_003',
        userId: null,
        name: 'Freelance',
        type: CategoryType.income,
        icon: Icons.laptop.codePoint.toString(),
        color: 0xFF9CCC65,
        isDefault: true,
      ),
      Category(
        id: 'cat_inc_004',
        userId: null,
        name: 'Allowance',
        type: CategoryType.income,
        icon: Icons.card_giftcard.codePoint.toString(),
        color: 0xFFAED581,
        isDefault: true,
      ),
      Category(
        id: 'cat_inc_005',
        userId: null,
        name: 'Gifts',
        type: CategoryType.income,
        icon: Icons.redeem.codePoint.toString(),
        color: 0xFFC5E1A5,
        isDefault: true,
      ),
      Category(
        id: 'cat_inc_006',
        userId: null,
        name: 'Other',
        type: CategoryType.income,
        icon: Icons.more_horiz.codePoint.toString(),
        color: 0xFFB0B0B0,
        isDefault: true,
      ),
    ];

    _categories.addAll(expenseCategories);
    _categories.addAll(incomeCategories);
  }

  Future<List<Category>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return List.unmodifiable(_categories);
  }

  Future<Category?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Category>> getByType(CategoryType type) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _categories.where((cat) => cat.type == type).toList();
  }

  Future<void> create(Category category) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _categories.add(category);
  }

  Future<void> update(Category category) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _categories.indexWhere((cat) => cat.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }
  }

  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _categories.removeWhere((cat) => cat.id == id);
  }
}
