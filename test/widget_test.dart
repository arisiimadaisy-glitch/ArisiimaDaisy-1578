import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:login_app/core/providers/auth_provider.dart';
import 'package:login_app/core/routes/app_router.dart';
import 'package:login_app/data/models/user_model.dart';
import 'package:login_app/screens/auth/login_screen.dart';

void main() {
  testWidgets('shows validation errors for an empty login form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildLoginApp(_FakeAuthProvider()));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email address'), findsOneWidget);
  });

  testWidgets('successful login opens the dashboard', (
    WidgetTester tester,
  ) async {
    final authProvider = _FakeAuthProvider();
    await tester.pumpWidget(_buildLoginApp(authProvider));

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'daisy@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(authProvider.lastEmail, 'daisy@example.com');
    expect(authProvider.lastPassword, 'password123');
    expect(find.text('Dashboard opened'), findsOneWidget);
  });
}

Widget _buildLoginApp(_FakeAuthProvider authProvider) {
  return ChangeNotifierProvider<AuthProvider>.value(
    value: authProvider,
    child: MaterialApp(
      home: const LoginPage(),
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.home) {
          return MaterialPageRoute<void>(
            builder: (_) =>
                const Scaffold(body: Center(child: Text('Dashboard opened'))),
          );
        }
        return null;
      },
    ),
  );
}

class _FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  String? lastEmail;
  String? lastPassword;

  @override
  User? get currentUser => null;

  @override
  String? get errorMessage => null;

  @override
  bool get isAuthenticated => false;

  @override
  bool get isLoading => false;

  @override
  void clearError() {}

  @override
  Future<bool> login(String email, String password) async {
    lastEmail = email;
    lastPassword = password;
    return true;
  }

  @override
  Future<bool> register(String email, String password, String name) async =>
      false;

  @override
  Future<bool> signInWithGithub() async => false;

  @override
  Future<bool> signInWithGoogle() async => false;

  @override
  Future<void> logout() async {}
}
