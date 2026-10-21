import 'package:flutter/material.dart';

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
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
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
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

// Placeholder screens (to be implemented in future features)

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Login Screen - To be implemented'),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Register Screen - To be implemented'),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Home Screen - To be implemented'),
      ),
    );
  }
}

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Add Expense Screen - To be implemented'),
      ),
    );
  }
}

class EditExpenseScreen extends StatelessWidget {
  final String? expenseId;

  const EditExpenseScreen({super.key, this.expenseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Edit Expense Screen - To be implemented\nExpense ID: $expenseId'),
      ),
    );
  }
}

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Expense List Screen - To be implemented'),
      ),
    );
  }
}

class ExpenseDetailScreen extends StatelessWidget {
  final String? expenseId;

  const ExpenseDetailScreen({super.key, this.expenseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Expense Detail Screen - To be implemented\nExpense ID: $expenseId'),
      ),
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Categories Screen - To be implemented'),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Settings Screen - To be implemented'),
      ),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Reports Screen - To be implemented'),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Profile Screen - To be implemented'),
      ),
    );
  }
}
