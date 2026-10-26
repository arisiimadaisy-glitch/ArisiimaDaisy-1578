import 'package:flutter/material.dart';

import '../../screens/auth/login_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/expenses/add_expense_screen.dart';
import '../../screens/expenses/edit_expense_screen.dart';
import '../../screens/expenses/expense_list_screen.dart';
import '../../screens/expenses/expense_detail_screen.dart';
import '../../screens/categories/categories_screen.dart';
import '../../screens/reports/reports_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/profile/profile_screen.dart';

/// Named route constants for the app
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String addExpense = '/add-expense';
  static const String editExpense = '/edit-expense';
  static const String expenseList = '/expense-list';
  static const String expenseDetail = '/expense-detail';
  static const String categories = '/categories';
  static const String settings = '/settings';
  static const String reports = '/reports';
  static const String profile = '/profile';
}

/// App router class to handle navigation
class AppRouter {
  AppRouter._();

  /// Generate routes based on route settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const DashboardPage(),
          settings: settings,
        );

      case AppRoutes.addExpense:
        return MaterialPageRoute(
          builder: (_) => const AddExpenseScreen(),
          settings: settings,
        );

      case AppRoutes.editExpense:
        // Extract expense ID from arguments
        final args = settings.arguments as Map<String, dynamic>?;
        final expenseId = args?['expenseId'] as String?;
        return MaterialPageRoute(
          builder: (_) => EditExpenseScreen(expenseId: expenseId),
          settings: settings,
        );

      case AppRoutes.expenseList:
        return MaterialPageRoute(
          builder: (_) => const ExpenseListScreen(),
          settings: settings,
        );

      case AppRoutes.expenseDetail:
        // Extract expense ID from arguments
        final args = settings.arguments as Map<String, dynamic>?;
        final expenseId = args?['expenseId'] as String?;
        return MaterialPageRoute(
          builder: (_) => ExpenseDetailScreen(expenseId: expenseId),
          settings: settings,
        );

      case AppRoutes.categories:
        return MaterialPageRoute(
          builder: (_) => const CategoriesScreen(),
          settings: settings,
        );

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      case AppRoutes.reports:
        return MaterialPageRoute(
          builder: (_) => const ReportsScreen(),
          settings: settings,
        );

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
