# Implementation Plan: Uganda Expense Tracker App

## Overview
Transform the existing basic Flutter login_app into a complete expense tracker app for Uganda with multi-currency support, Firebase authentication, custom categories, and 10+ screens.

**Existing State:** Basic Flutter project with login UI (no real auth) and dashboard UI (hardcoded data) in lib/src/. Material 3 theme with green seed color. No Firebase, no state management yet.

**Target:** Production-ready expense tracker with Firebase backend, Provider state management, 16 screens total, UGX default currency, offline support with Hive.

---

## FEAT-001: Project Foundation (Core Architecture)

- [ ] 1. **Add all required dependencies to pubspec.yaml**
      Dependencies: firebase_core ^3.0.0, firebase_auth ^5.0.0, cloud_firestore ^5.0.0, firebase_storage ^12.0.0, google_sign_in ^6.2.0, provider ^6.1.0, hive ^2.2.3, hive_flutter ^1.1.0, path_provider ^2.1.0, image_picker ^1.0.0, intl ^0.19.0, fl_chart ^0.66.0, cached_network_image ^3.3.0, shared_preferences ^2.2.0
      Files: pubspec.yaml
      Verify: Run `flutter pub get` and confirm all packages download without conflicts

- [ ] 2. **Create core constants module with currencies and app config**
      Create lib/core/constants/app_constants.dart with List<Currency> containing at least 20 world currencies (code, name, symbol), UGX as default, default expense categories list, Uganda color palette constants
      Files: lib/core/constants/app_constants.dart
      Verify: Import in another file and access currencies list without errors

- [ ] 3. **Create theme system with light/dark modes**
      Create lib/core/theme/app_theme.dart with ThemeData for light/dark modes using Uganda colors (green #11BD2E, yellow #FCDC04, red #D90000, black), custom component themes matching existing style (rounded corners, Material 3)
      Files: lib/core/theme/app_theme.dart
      Verify: Apply theme in MaterialApp and toggle between light/dark - UI updates correctly

- [ ] 4. **Create utility modules for date, currency, validation**
      Create lib/core/utils/date_helper.dart (formatDate, getDateFilters, date range helpers), lib/core/utils/currency_formatter.dart (formatCurrency, getCurrencySymbol), lib/core/utils/validators.dart (validateEmail, validatePassword, validateAmount)
      Files: lib/core/utils/date_helper.dart, lib/core/utils/currency_formatter.dart, lib/core/utils/validators.dart
      Verify: Run `flutter test` on unit tests for each utility function

- [ ] 5. **Create routing system with named routes**
      Create lib/core/routes/app_router.dart with route name constants and generateRoute function for all 16 screens (splash, onboarding, login, register, forgot_password, home, add_expense, edit_expense, expense_list, expense_detail, categories, add_category, edit_category, settings, reports, profile)
      Files: lib/core/routes/app_router.dart
      Verify: Routes compile without errors, import in main.dart successfully

- [ ] 6. **Restructure existing screens into new architecture**
      Move lib/src/login.dart → lib/screens/auth/login_screen.dart, lib/src/dashboard.dart → lib/screens/home/home_screen.dart, update all imports
      Files: lib/screens/auth/login_screen.dart, lib/screens/home/home_screen.dart (delete lib/src/)
      Verify: Run `flutter analyze` - zero errors, app still compiles

- [ ] 7. **Update main.dart with Provider and routing**
      Wrap MaterialApp with MultiProvider (prepare for auth/expense/category providers), use app_router.onGenerateRoute, apply theme, set initialRoute to '/splash'
      Files: lib/main.dart
      Verify: Run `flutter run` - app compiles and attempts to navigate to splash route

---

## FEAT-002: Data Layer (Models, Services, Providers)

- [ ] 8. **Create data models with serialization**
      Create lib/models/user_model.dart (id, email, displayName, photoUrl, selectedCurrency, createdAt, toJson/fromJson), lib/models/category_model.dart (id, name, iconCodePoint, colorValue, isDefault, userId, default categories list, toJson/fromJson), lib/models/expense_model.dart (id, userId, amount, currencyCode, categoryId, note, date, receiptImageUrl, timestamps, toJson/fromJson)
      Files: lib/models/user_model.dart, lib/models/category_model.dart, lib/models/expense_model.dart
      Verify: Run unit tests for toJson/fromJson roundtrip - all fields preserved

- [ ] 9. **Implement Firebase Authentication service**
      Create lib/services/auth_service.dart with signInWithGoogle (google_sign_in + firebase_auth), signInWithEmailAndPassword, createUserWithEmailAndPassword, signOut, authStateChanges stream, getCurrentUser, sendPasswordResetEmail, updateUserProfile methods
      Files: lib/services/auth_service.dart
      Verify: Mock test or manual Firebase console check - methods compile and structure is correct

- [ ] 10. **Implement Firestore database service**
       Create lib/services/database_service.dart with methods: addExpense, updateExpense, deleteExpense, getExpenseById, getExpensesStream (with userId, dateRange, category filters), addCategory, updateCategory, deleteCategory, getCategoriesStream, getUserProfile, updateUserProfile
       Files: lib/services/database_service.dart
       Verify: Methods compile, Firestore collection/document structure is logical

- [ ] 11. **Implement Firebase Storage service for receipts**
       Create lib/services/storage_service.dart with uploadReceiptImage(File, expenseId) returns URL, deleteReceiptImage(url) methods
       Files: lib/services/storage_service.dart
       Verify: Service compiles, imports firebase_storage correctly

- [ ] 12. **Implement currency and local storage services**
       Create lib/services/currency_service.dart (getAllCurrencies, getDefaultCurrency, saveCurrencyPreference), lib/services/local_storage_service.dart (Hive init, cache/retrieve expenses and categories for offline support)
       Files: lib/services/currency_service.dart, lib/services/local_storage_service.dart
       Verify: Hive boxes register correctly, currency service returns UGX as default

- [ ] 13. **Create Provider state management classes**
       Create lib/providers/auth_provider.dart (ChangeNotifier with currentUser, AuthStatus, signIn/signOut methods listening to authStateChanges), lib/providers/category_provider.dart (categories list, CRUD operations), lib/providers/expense_provider.dart (expenses list, filters, CRUD, totals calculations)
       Files: lib/providers/auth_provider.dart, lib/providers/category_provider.dart, lib/providers/expense_provider.dart
       Verify: Providers compile, notifyListeners called after state changes

- [ ] 14. **Register providers in main.dart**
       Update lib/main.dart MultiProvider with AuthProvider, CategoryProvider, ExpenseProvider
       Files: lib/main.dart
       Verify: Run `flutter run` - providers initialize without errors

- [ ] 15. **Setup Firebase project and configuration**
       Manual step: Create Firebase project at console.firebase.google.com, enable Authentication (Email/Password + Google), Firestore Database, Storage. Run `flutterfire configure` to generate config files. Add google-services.json (Android) and GoogleService-Info.plist (iOS) to respective directories
       Files: android/app/google-services.json, ios/Runner/GoogleService-Info.plist (not checked into git per .gitignore)
       Verify: Run `flutter run` - Firebase.initializeApp() succeeds in logs, no Firebase config errors

---

## FEAT-003: Authentication Screens

- [ ] 16. **Create splash screen with Firebase initialization**
       Create lib/screens/splash/splash_screen.dart with centered app logo, "Pocket Spend" title, version text, initializeApp() calls Firebase.initializeApp() and checks first launch flag (shared_preferences), navigates to onboarding (first time) or login after 2 seconds
       Files: lib/screens/splash/splash_screen.dart
       Verify: Run app - splash displays for 2 seconds, navigates correctly

- [ ] 17. **Create onboarding screen with intro slides**
       Create lib/screens/onboarding/onboarding_screen.dart with PageView, 3 pages ("Track Your Expenses" with wallet icon, "Multi-Currency Support" with globe icon, "Get Insights" with chart icon), page indicators, Skip button (pages 1-2) and Get Started button (page 3) navigate to login, saves first-launch flag
       Files: lib/screens/onboarding/onboarding_screen.dart
       Verify: First app launch shows onboarding, subsequent launches skip it

- [ ] 18. **Update login screen with Firebase integration**
       Update lib/screens/auth/login_screen.dart: integrate auth_provider.signInWithEmail and signInWithGoogle, add Google Sign-In button below form with logo, show CircularProgressIndicator during loading, SnackBar for errors, navigate to home on success, link to register and forgot_password screens
       Files: lib/screens/auth/login_screen.dart
       Verify: Test email login - navigates to home, test Google button appears and triggers auth

- [ ] 19. **Create registration screen**
       Create lib/screens/auth/register_screen.dart with form: name, email, password, confirm password (using validators), call auth_provider.signUpWithEmail, show loading/errors, navigate to home on success, link to login
       Files: lib/screens/auth/register_screen.dart
       Verify: Register new user - account created in Firebase Auth, user logged in automatically

- [ ] 20. **Create forgot password screen**
       Create lib/screens/auth/forgot_password_screen.dart with email field, Reset Password button calls auth_service.sendPasswordResetEmail, show success dialog, back button to login
       Files: lib/screens/auth/forgot_password_screen.dart
       Verify: Enter valid email - password reset email sent (check email inbox or Firebase console logs)

---

## FEAT-004: Expense Management Screens

- [ ] 21. **Create reusable expense UI widgets**
       Create lib/widgets/common/currency_selector.dart (dropdown of currencies), category_picker.dart (GridView of category icons), date_filter_chips.dart (horizontal chips for date ranges), expense_card.dart (Card showing expense summary)
       Files: lib/widgets/common/currency_selector.dart, lib/widgets/common/category_picker.dart, lib/widgets/common/date_filter_chips.dart, lib/widgets/common/expense_card.dart
       Verify: Widgets compile and can be imported in screens

- [ ] 22. **Create add expense screen**
       Create lib/screens/expense/add_expense_screen.dart with form: amount TextField (number input), CurrencySelector, CategoryPicker (bottom sheet), DatePicker (default today), note TextField, ImagePicker button for receipt (shows thumbnail), Save button calls expense_provider.addExpense with loading state and error handling, pops on success
       Files: lib/screens/expense/add_expense_screen.dart
       Verify: Fill form and save - expense appears in Firestore, receipt uploads to Storage if added

- [ ] 23. **Create edit expense screen**
       Create lib/screens/expense/edit_expense_screen.dart (same form as add but pre-filled with Expense object from route arguments), Save calls expense_provider.updateExpense
       Files: lib/screens/expense/edit_expense_screen.dart
       Verify: Edit existing expense - changes save to Firestore, UI updates immediately

- [ ] 24. **Create expense list screen with filters**
       Create lib/screens/expense/expense_list_screen.dart with AppBar search field, DateFilterChips, category filter button (bottom sheet), Consumer/StreamBuilder for expense_provider.expenses, ListView.builder grouped by date, ExpenseCards, FAB to add expense, empty state widget
       Files: lib/screens/expense/expense_list_screen.dart
       Verify: Expense list shows all expenses, filters work (date/category/search), tap expense opens detail

- [ ] 25. **Create expense detail screen**
       Create lib/screens/expense/expense_detail_screen.dart showing all expense fields (amount, currency, category with icon/color, date, note, receipt image if present using cached_network_image with zoom), Edit FAB, Delete action in menu (confirmation dialog), back button
       Files: lib/screens/expense/expense_detail_screen.dart
       Verify: Tap expense - detail loads, tap edit - goes to edit screen, tap delete - expense removed

- [ ] 26. **Update home screen with real data and charts**
       Update lib/screens/home/home_screen.dart: replace hardcoded data with Consumer<ExpenseProvider>, add summary cards (total spent this month, expense count, top category) using lib/widgets/common/summary_card.dart, add BarChart from fl_chart (lib/widgets/common/spending_chart.dart shows last 7 days), recent expenses ListView with ExpenseCards, bottom navigation (Home, Expenses, Add [FAB], Reports, Profile) with navigation logic
       Files: lib/screens/home/home_screen.dart, lib/widgets/common/summary_card.dart, lib/widgets/common/spending_chart.dart
       Verify: Home dashboard shows correct totals and chart, bottom nav switches screens, Add FAB works

---

## FEAT-005: Categories, Settings, Reports, Profile Screens

- [ ] 27. **Create icon and color picker dialogs**
       Create lib/widgets/common/icon_picker_dialog.dart (GridView of 30+ Material Icons - payment, food, transport, shopping, health, etc., returns IconData), lib/widgets/common/color_picker_dialog.dart (GridView of Material colors + Uganda theme colors, returns Color)
       Files: lib/widgets/common/icon_picker_dialog.dart, lib/widgets/common/color_picker_dialog.dart
       Verify: Dialogs open, icon/color selection works, returns selected value

- [ ] 28. **Create categories management screens**
       Create lib/screens/categories/categories_screen.dart (ListView of categories with icon/color/name, FAB to add, tap to edit, swipe to delete custom ones), add_category_screen.dart (form: name, icon picker, color picker, Save calls category_provider.addCategory), edit_category_screen.dart (pre-filled form, updates category)
       Files: lib/screens/categories/categories_screen.dart, lib/screens/categories/add_category_screen.dart, lib/screens/categories/edit_category_screen.dart
       Verify: Add custom category with icon/color - appears in list and Firestore, edit/delete works, default categories protected

- [ ] 29. **Create theme provider and settings screen**
       Create lib/providers/theme_provider.dart (ThemeMode state, toggleTheme, persistence with shared_preferences), lib/screens/settings/settings_screen.dart (ListTile groups: Account - currency selector, Appearance - theme toggle, Data - export CSV/clear cache buttons, About - version/terms/privacy, Sign Out button at bottom)
       Files: lib/providers/theme_provider.dart, lib/screens/settings/settings_screen.dart
       Verify: Toggle theme - app switches light/dark immediately and persists, change currency - saves to Firestore user doc

- [ ] 30. **Create reports/analytics screen with charts**
       Create lib/screens/reports/reports_screen.dart with date range selector dropdown, TabBarView (Overview - total spent/avg per day/count, By Category - PieChart using lib/widgets/common/spending_pie_chart.dart with percentages and list, Trends - LineChart using lib/widgets/common/spending_line_chart.dart showing spending over time)
       Files: lib/screens/reports/reports_screen.dart, lib/widgets/common/spending_pie_chart.dart, lib/widgets/common/spending_line_chart.dart
       Verify: Reports load with correct data for selected date range, pie chart shows category breakdown, line chart shows trend

- [ ] 31. **Create profile screen**
       Create lib/screens/profile/profile_screen.dart with Card containing CircleAvatar (user photo or initials), displayName, email, "Member since" date, stats row (total expenses, total spent, categories used), Edit Profile button, Change Password button (if email auth), Sign Out button (confirmation dialog)
       Files: lib/screens/profile/profile_screen.dart
       Verify: Profile displays user data correctly, Sign Out logs out and returns to login

- [ ] 32. **Final integration and testing**
       Update lib/main.dart to register ThemeProvider, ensure all routes work, test navigation flow between all 16 screens, verify bottom navigation works from home, test offline mode (airplane mode - cached data loads), run full app flow from splash to sign out
       Files: lib/main.dart
       Verify: Run `flutter analyze` (zero issues), complete user journey test (splash → onboarding → register → add expense → view reports → change settings → sign out), verify 16 screens exist and are accessible

---

## Assumptions & Notes

**Assumptions:**
1. Firebase project will be created manually at console.firebase.google.com
2. Google Sign-In requires SHA-1 fingerprint added to Firebase for Android
3. Offline mode uses Hive for basic caching, not full sync
4. Currency conversion uses static rates (real conversion API integration is out of scope)
5. Receipt images stored in Firebase Storage under `/receipts/{userId}/{expenseId}/`
6. Firestore structure: `/users/{userId}`, `/expenses/{expenseId}`, `/categories/{categoryId}`
7. Default categories (Food, Transport, Shopping, Bills, Health, Entertainment, Travel, Education, Other) are created on first user registration
8. UGX is hard-coded default, user can change in settings
9. Dark mode persists via shared_preferences
10. CSV export generates file with all user expenses, downloads to device

**Firebase Configuration Required:**
- Run `flutterfire configure` after creating Firebase project
- Enable Authentication methods: Email/Password and Google
- Create Firestore database in test mode initially
- Create Storage bucket with security rules allowing authenticated users
- Add SHA-1 fingerprint for Google Sign-In on Android

**Total Screens (16):**
1. Splash
2. Onboarding
3. Login
4. Register
5. Forgot Password
6. Home/Dashboard
7. Add Expense
8. Edit Expense
9. Expense List
10. Expense Detail
11. Categories
12. Add Category
13. Edit Category
14. Settings
15. Reports
16. Profile

**Package Versions (as of plan creation):**
All versions are suggested minimums; `flutter pub get` will resolve compatible versions. If conflicts arise, adjust versions downward to latest compatible set.
