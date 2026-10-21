// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:login_app/main.dart';
import 'package:login_app/src/dashboard.dart';

void main() {
  testWidgets('renders the login form', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);

    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Enter your email address'), findsOneWidget);
  });

  testWidgets('signing in opens spending insights', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'daisy@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardPage), findsOneWidget);
    expect(find.text('Spending insights'), findsOneWidget);
    expect(find.text('£305.43'), findsOneWidget);
  });
}
