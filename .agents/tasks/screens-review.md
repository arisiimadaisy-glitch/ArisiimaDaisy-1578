# Expense tracker screen implementation

The coder implemented 10 new screens and updated 3 existing files to replace "To be implemented" placeholders with functional UI. All screens now render real content, include proper navigation wiring, and follow the established green color scheme. Forms validate input, controllers are properly disposed, and the routing table correctly maps all paths to screen classes.

**Watch for:** Bottom navigation state doesn't persist across screen changes (confirmed), expense data is mocked rather than persisted (confirmed).

**Verdict**: APPROVED

## High-level view

The splash screen navigates to login after 2 seconds using a mounted check. Login and register screens validate email format, password length, and password matching before navigating to the home dashboard. The home screen serves as the main hub with a greeting card, monthly spending summary, quick action buttons for common tasks, spending insights with weekly navigation, category tabs, and a bottom navigation bar that routes to activity, add expense, insights, and profile.

Expense screens form a complete CRUD flow: add creates new expenses with category dropdown, date picker, and payment method selection; list displays expenses with category filtering; detail shows full expense information with an edit button; edit pre-populates form fields with mock data. All expense forms validate required fields (amount > 0, category selected, date selected) and display success snackbars on save.

Categories screen displays a grid of all 15 default categories with icons. Reports screen renders bar charts for monthly spending and pie charts for category distribution using the fl_chart library. Settings screen provides toggles for dark mode and notifications, along with currency selection. Profile screen displays user information and a sign-out dialog that confirms before navigating back to login and clearing the stack.

The app router maps all 13 routes to screen classes, extracts arguments for expense detail and edit screens, and provides a fallback for undefined routes. All imports resolve correctly to the new screen files. TextEditingControllers in forms (login, register, add expense, edit expense) are disposed in dispose() methods to prevent memory leaks.

<details>
<summary>Issues (2)</summary>

1. **Bottom navigation state doesn't persist** — The home screen's `_selectedBottomItem` tracks which nav item is active, but navigating to another screen and returning resets it to 0. Use a state management solution or pass selected index via route arguments if cross-screen persistence is needed.

2. **Mock data not persisted** — Expenses, user profile, and spending totals use hardcoded values. The save/update buttons show success snackbars but don't persist changes. Wire these to Firebase Firestore (already in pubspec.yaml) or Hive local storage to make the app functional.

</details>

<details>
<summary>Details</summary>

## Splash to auth flow

Both auth screens validate inputs: email must contain '@', password must exist (login) or be at least 6 characters (register), and confirm password must match.

## Home dashboard composition

Tabs filter by "Categories", "Merchants", or "Payment types", but the filter selection doesn't change the displayed data. The category list shows 7 mock categories with transaction counts and amounts, but tapping them does nothing.

The bottom navigation bar displays 5 items. The `_selectedBottomItem` state tracks the active item, but returning from a navigated screen resets it to 0 because the state is local to the home widget instance.

## Expense CRUD operations

Save/update buttons validate the form, show a snackbar, and pop the screen. No data is persisted. A filter bar at the top of the expense list lets you select "All" or specific categories, but filtering doesn't affect the displayed list.

## Category and settings screens

Tapping a category shows a snackbar but doesn't navigate anywhere. The dark mode and notifications toggles in settings update local state but don't persist or affect the app theme.

## Reports and profile

The charts use the fl_chart library with hardcoded data.

</details>

<details>
<summary>File map</summary>

**New screens (10 files):**
- `lib/screens/splash/splash_screen.dart` — 2-second splash with app branding, navigates to login
- `lib/screens/auth/register_screen.dart` — Sign-up form with name, email, password, confirm password validation
- `lib/screens/expenses/add_expense_screen.dart` — Expense form with amount, category, date, payment method, description
- `lib/screens/expenses/edit_expense_screen.dart` — Same form as add, pre-populated with mock data
- `lib/screens/expenses/expense_list_screen.dart` — Scrollable list of 8 mock expenses with category filter bar
- `lib/screens/expenses/expense_detail_screen.dart` — Full expense view with amount, category icon, date, payment method, description
- `lib/screens/categories/categories_screen.dart` — 3-column grid of 15 categories from constants
- `lib/screens/reports/reports_screen.dart` — Bar chart (monthly) and pie chart (category breakdown) with fl_chart
- `lib/screens/settings/settings_screen.dart` — Preferences (currency, dark mode, notifications) and About (version, policy, terms)
- `lib/screens/profile/profile_screen.dart` — User card, menu items (expenses, reports, linked accounts), sign-out dialog

**Updated screens (3 files):**
- `lib/core/routes/app_router.dart` — Added 9 new route cases (register, all expense screens, categories, settings, reports, profile)
- `lib/screens/auth/login_screen.dart` — Added "Sign Up" navigation to register route
- `lib/screens/home/home_screen.dart` — Replaced placeholder with full dashboard: greeting card, quick actions, spending insights, category list, bottom nav

Full diff available via `git diff`.

</details>
