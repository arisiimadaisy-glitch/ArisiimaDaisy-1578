# Implementation Plan

## Overview
Replace all placeholder screens in the Flutter expense tracker app (PesaTracker) with fully functional screens. The app currently has 10 placeholder screens in `app_router.dart` that display "To be implemented" messages. This plan covers implementing all screens, updating the router, and enhancing the home dashboard.

## Design System (Applied consistently across all screens)
- Primary green: `Color(0xFF08A71D)`
- Dark green: `Color.fromARGB(255, 9, 66, 14)`
- Background: `Color(0xFFF5F5F3)`
- Card background: `Colors.white`
- Text primary: `Color(0xFF111111)`
- Text muted: `Color(0xFF777777)`
- Accent purple: `Color(0xFF7043E8)`
- Currency: `AppConstants.defaultCurrency` (UGX / USh)
- All AppBars: white background with dark green title
- Forms: `OutlineInputBorder` with `prefixIcon` and proper validators from `Validators` class
- Buttons: `FilledButton` with green background matching login screen
- Cards: elevation 0, `RoundedRectangleBorder` with radius 16-20

## Dependencies Available
- `provider` for state management
- `intl` for date/number formatting
- `fl_chart` for charts
- `hive` & `hive_flutter` for local storage
- `firebase_auth`, `cloud_firestore` (not configured yet)
- Utility classes: `Validators`, `CurrencyFormatter`
- Constants: `AppConstants.defaultCategories`, `AppConstants.currencies`

---

- [ ] 1. Create splash screen with branding and auto-navigation.
      Implement `SplashScreen` as a separate file with app logo/name, replaces the placeholder in `app_router.dart` that currently shows `CircularProgressIndicator`. Auto-navigates to login after 2 seconds (already implemented in placeholder).
      Files: `c:\APP PROJECT\login_app\lib\screens\splash\splash_screen.dart`
      Verify: Run `flutter analyze` on the workspace — no errors for splash_screen.dart.

- [ ] 2. Create registration screen with sign-up form and validation.
      Implement `RegisterScreen` with form fields: full name (use `Validators.validateName`), email (use `Validators.validateEmail`), password and confirm password (use `Validators.validatePassword` and `Validators.validatePasswordMatch`). Match the card-based design from `login_screen.dart` with same colors and styling. Include "Sign In" link at bottom that navigates to `AppRoutes.login`. On successful validation, navigate to `AppRoutes.home` with `Navigator.pushReplacementNamed`.
      Files: `c:\APP PROJECT\login_app\lib\screens\auth\register_screen.dart`
      Verify: Run `flutter analyze` — no errors for register_screen.dart.

- [ ] 3. Fix login screen navigation to register.
      Update the "Sign Up" `TextButton` in `login_screen.dart` from `onPressed: () {}` to `onPressed: () => Navigator.pushNamed(context, AppRoutes.register)`.
      Files: `c:\APP PROJECT\login_app\lib\screens\auth\login_screen.dart`
      Verify: Run `flutter analyze` — no errors for login_screen.dart.

- [ ] 4. Create add expense screen with form for new expenses.
      Implement `AddExpenseScreen` with form: amount field (use `Validators.validateAmount`), category dropdown populated from `AppConstants.defaultCategories`, date picker (defaults to today), optional description TextField, payment method dropdown (Cash, Card, Mobile Money, Bank Transfer). Use `Scaffold` with `backgroundColor: Color(0xFFF5F5F3)`, white AppBar with dark green title "Add Expense", and back button. `FilledButton` with green background labeled "Save" validates form and shows success `SnackBar`, then navigates back with `Navigator.pop(context)`.
      Files: `c:\APP PROJECT\login_app\lib\screens\expenses\add_expense_screen.dart`
      Verify: Run `flutter analyze` — no errors for add_expense_screen.dart.

- [ ] 5. Create edit expense screen with pre-filled form.
      Implement `EditExpenseScreen` that accepts optional `String? expenseId` parameter. Same form structure as `AddExpenseScreen` but with title "Edit Expense" and fields pre-filled with mock data when `expenseId` is not null (use mock values: amount: 25000, category: Food & Dining, date: yesterday, description: "Lunch at Java", payment: Mobile Money). Include delete button (red outlined button) alongside save button. Save shows success SnackBar and pops. Delete shows confirmation dialog, then pops.
      Files: `c:\APP PROJECT\login_app\lib\screens\expenses\edit_expense_screen.dart`
      Verify: Run `flutter analyze` — no errors for edit_expense_screen.dart.

- [ ] 6. Create expense list screen with filter and sort options.
      Implement `ExpenseListScreen` with scrollable list of mock expenses (generate 10-15 mock items using various categories from `AppConstants.defaultCategories`). Top of screen has filter chips (All, This Week, This Month) and sort chips (Date, Amount, Category). Each expense row shows: category icon in circle, category name and date on left, amount in UGX on right, chevron icon. Tapping row navigates to `AppRoutes.expenseDetail` passing `expenseId` in arguments `{'expenseId': 'expense_123'}`. Floating action button (FAB) with plus icon navigates to `AppRoutes.addExpense`.
      Files: `c:\APP PROJECT\login_app\lib\screens\expenses\expense_list_screen.dart`
      Verify: Run `flutter analyze` — no errors for expense_list_screen.dart.

- [ ] 7. Create expense detail screen showing full information.
      Implement `ExpenseDetailScreen` that accepts optional `String? expenseId`. Display a large card with full expense details: amount (large, bold), category with icon, date (formatted with `intl`), description, payment method. AppBar has back button and edit IconButton (pencil icon) that navigates to `AppRoutes.editExpense` passing `{'expenseId': expenseId}`. Mock data when expenseId is not null (same as edit screen). Include a receipt/attachment section placeholder (icon + text "No receipt attached").
      Files: `c:\APP PROJECT\login_app\lib\screens\expenses\expense_detail_screen.dart`
      Verify: Run `flutter analyze` — no errors for expense_detail_screen.dart.

- [ ] 8. Create categories screen displaying all expense categories.
      Implement `CategoriesScreen` with GridView of `AppConstants.defaultCategories`. Each grid tile shows category icon in colored circle, category name below. 2 columns, proper spacing. Tapping a tile shows SnackBar "Viewing expenses in [category name] - feature coming soon". AppBar title "Categories" with back button.
      Files: `c:\APP PROJECT\login_app\lib\screens\categories\categories_screen.dart`
      Verify: Run `flutter analyze` — no errors for categories_screen.dart.

- [ ] 9. Create reports screen with charts and spending summary.
      Implement `ReportsScreen` with: hero card showing monthly total spending in large text with green gradient background, bar chart using `fl_chart` BarChart showing 6 months of mock spending data (Jan-Jun with values 450000, 520000, 380000, 610000, 490000, 550000 UGX), pie chart using `fl_chart` PieChart showing category breakdown (5-6 categories with percentages). Section headers "Monthly Overview" and "Spending by Category". Use green color scheme for charts matching app theme.
      Files: `c:\APP PROJECT\login_app\lib\screens\reports\reports_screen.dart`
      Verify: Run `flutter analyze` — no errors for reports_screen.dart.

- [ ] 10. Create settings screen with app preferences.
      Implement `SettingsScreen` with ListView of settings options. Section 1 "Preferences": Currency ListTile showing current currency (UGX) with trailing chevron (tap shows SnackBar "Currency settings coming soon"), Theme ListTile with Switch widget that calls `Provider.of<ThemeProvider>(context).toggleTheme()`, Notifications ListTile with Switch (no-op for now). Section 2 "About": App version ListTile showing `AppConstants.appVersion`, Privacy Policy ListTile with chevron. Use `SwitchListTile` widgets. Dividers between sections.
      Files: `c:\APP PROJECT\login_app\lib\screens\settings\settings_screen.dart`
      Verify: Run `flutter analyze` — no errors for settings_screen.dart.

- [ ] 11. Create profile screen with user information and sign-out.
      Implement `ProfileScreen` with: large `CircleAvatar` at top with initials "JD" on colored background, display name "John Doe" (large, bold), email "john.doe@example.com" (muted color), edit profile button (outlined), sign out button (filled, green) that shows confirmation dialog then navigates to `AppRoutes.login` using `Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false)`. Include section with ListTiles: Personal Information, Security, Linked Accounts (all show SnackBar "Coming soon").
      Files: `c:\APP PROJECT\login_app\lib\screens\profile\profile_screen.dart`
      Verify: Run `flutter analyze` — no errors for profile_screen.dart.

- [ ] 12. Update app router to use real screen classes.
      Remove all placeholder screen classes from `app_router.dart` (SplashScreen, RegisterScreen, AddExpenseScreen, EditExpenseScreen, ExpenseListScreen, ExpenseDetailScreen, CategoriesScreen, SettingsScreen, ReportsScreen, ProfileScreen). Add imports for all 10 newly created screen files at the top. Keep `AppRoutes` class unchanged. Keep `AppRouter.generateRoute` method structure unchanged — only the return statements now reference imported classes instead of local placeholders. The SplashScreen placeholder already has auto-navigation logic; ensure imported SplashScreen has same behavior.
      Files: `c:\APP PROJECT\login_app\lib\core\routes\app_router.dart`
      Verify: Run `flutter analyze` — no errors for app_router.dart and all imports resolve correctly.

- [ ] 13. Enhance home screen with greeting, hero card, and quick actions.
      Update `home_screen.dart` (DashboardPage class): Add greeting header at top of CustomScrollView showing "Good morning, [User]" with current date formatted using `intl`. Add hero summary card below greeting with green gradient background (`LinearGradient` using primary green and dark green) showing "Total Monthly Spending" label and large amount in UGX (mock: 1,250,000 UGX) using `CurrencyFormatter.formatCurrency`. Add Quick Actions section below hero card with horizontal scrollable row of 4 tappable cards: "Add Expense" (navigates to addExpense), "View Reports" (navigates to reports), "Categories" (navigates to categories), "Settings" (navigates to settings). Each card has icon, label, and white background with shadow. Keep existing week selector, tabs, category list unchanged. Update bottom navigation tap handlers to set `setState(() => _selectedBottomItem = index)` before navigation so selected item highlights properly.
      Files: `c:\APP PROJECT\login_app\lib\screens\home\home_screen.dart`
      Verify: Run `flutter analyze` — no errors for home_screen.dart.

- [ ] 14. Final verification across entire app.
      Run `flutter analyze` on the entire workspace to ensure no errors. Verify all 10 screen files compile, app_router.dart imports all screens correctly, and home_screen.dart enhancements integrate cleanly.
      Files: All files in `c:\APP PROJECT\login_app\lib\`
      Verify: Run `flutter analyze` on workspace root — zero errors reported.

---

## Summary
This plan implements 10 new screen files, updates the router to wire them together, fixes the login-to-register navigation, and enhances the home dashboard with professional UI elements. Every screen follows the established design system from `login_screen.dart` and uses existing utility classes (`Validators`, `CurrencyFormatter`) and constants (`AppConstants.defaultCategories`, `AppConstants.currencies`). The implementation is ordered by dependency: splash → auth screens → expense CRUD screens → supporting screens (categories, reports, settings, profile) → router update → home enhancement → final verification.
