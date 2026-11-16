# Implementation Plan: PesaTrack AI MVP Review Fixes + Professional Multi-Auth

This plan addresses two coordinated tasks for the PesaTracker Flutter app:
1. **TASK 1**: Fix three blocking issues in PesaTrack AI MVP (duplicate import, generic error messages, non-functional microphone button)
2. **TASK 2**: Build professional authentication system with Email, Google, and GitHub sign-in/signup

The work is decomposed into three features executed sequentially. Each feature leaves the codebase in a buildable state.

---

## Files to Read First (Before Implementation)

Understanding the existing patterns is critical. Read these in order:

1. `lib/main.dart` — Current Firebase setup (commented out), provider registration pattern, Hive initialization
2. `lib/core/providers/pesatrack_ai_provider.dart` — ChangeNotifier pattern, error handling, chat logic
3. `lib/screens/auth/login_screen.dart` — Existing form validation, UI patterns
4. `lib/data/models/user_model.dart` — Current User model structure
5. `lib/core/theme/app_theme.dart` — Design system (colors, fonts, border radius)
6. `lib/core/constants/app_constants.dart` — Uganda green (#11BD2E), app constants
7. `lib/core/routes/app_router.dart` — Routing setup
8. `lib/services/voice_service.dart` — Speech-to-text implementation (will be disabled for MVP)

---

## Context & Decisions

### Build & Test Commands
- **Build**: `flutter build apk --debug` (Android); `flutter build ios --debug` (iOS)
- **Analyze**: `flutter analyze` (linting, imports, type checking)
- **Fetch**: `flutter pub get` (download dependencies)
- **Run**: `flutter run --debug` (launch on connected device/emulator)
- **Test**: `flutter test` (if unit tests are added; currently minimal test coverage expected)

### Firebase Setup (Manual Prerequisites)
Before implementing FEAT-002, the developer must:
1. Create a Firebase project in [Firebase Console](https://console.firebase.google.com/)
2. Enable **Email/Password** authentication provider
3. Enable **Google** sign-in and add OAuth2 credentials (or use the auto-linking in Firebase Console)
4. Enable **GitHub** sign-in and add OAuth2 credentials (GitHub App ID and Secret from [GitHub Developer Settings](https://github.com/settings/developers))
5. Run `flutterfire configure` locally in the project root to generate `lib/firebase_options.dart` with project credentials
6. Add app SHA-1 fingerprint to Firebase Console (for Android) — get via: `keytool -list -v -keystore ~/.android/debug.keystore`

**Note**: `firebase_options.dart` is auto-generated and must NOT be manually created or committed as a template. Each developer must run `flutterfire configure` with their own Firebase project credentials.

### Design System Decisions
- **Primary color**: `#11BD2E` (Uganda green) — use `AppConstants.ugandaGreen`
- **Error color**: `#D90000` (Uganda red) — use `AppConstants.ugandaRed`
- **Button border radius**: `BorderRadius.circular(14)` for buttons, `circular(28)` for cards
- **State management**: ChangeNotifier + Provider pattern (consistent with existing app)
- **Error messages**: Specific, actionable, differentiated by error type (not generic)
- **Social sign-in icons**: Font Awesome (google, github icons from font_awesome_flutter package)

### Architecture Decisions

**AuthService (Single Source of Truth)**
- Wraps Firebase Auth and Google Sign-In
- All auth logic flows through this service
- Returns custom `User` model (not Firebase's `User`)
- Handles all Firebase exceptions and converts to specific error messages

**AuthProvider (State Management)**
- ChangeNotifier wrapping AuthService
- Exposes: `currentUser`, `isAuthenticated`, `isLoading`, `errorMessage`
- Listens to Firebase Auth state stream automatically
- Methods: `login()`, `register()`, `signInWithGoogle()`, `signInWithGithub()`, `logout()`, `clearError()`
- Updates listeners after every state change

**SplashScreen (Auth Check)**
- Reads AuthProvider to determine if user is authenticated
- Routes to home if `isAuthenticated == true`, else routes to login
- Waits for initial Firebase Auth state (3-second timeout) to avoid infinite splash

**PesaTrackAIProvider (Dynamic User ID)**
- Currently hardcoded to `'user_001'` via `PesaTrackAIConstants.defaultUserId`
- Will be updated to accept userId from authenticated user's UID
- On logout, clears chat history and userId

### Dependency Changes
**pubspec.yaml additions:**
```yaml
font_awesome_flutter: ^10.0.0  # For Google/GitHub icons
# flutter_appauth: ^8.0.0        # Optional: only if GitHub OAuth via device flow
```

GitHub OAuth can be implemented two ways:
1. **Firebase's GitHub provider** (simpler, recommended) — sign in via Firebase Auth's GitHub provider, already configured in Firebase Console, handled by firebase_auth automatically
2. **Device flow** (alternative, if Firebase's provider is unavailable) — use flutter_appauth package; requires more setup but works without Firebase directly

For MVP, attempt option 1 (Firebase). If it doesn't work cleanly, stub with clear instructions in `UnimplementedError`.

---

## Implementation Plan

### Feature 1: Fix PesaTrack AI MVP Review Blockers (FEAT-001)

Fix three blocking issues: duplicate import, generic error messages, disabled microphone button.

**Duration**: ~30 minutes

- [ ] **1.1 Fix duplicate import in pesatrack_ai_page.dart**
  
  Remove the second occurrence of `import 'package:flutter/material.dart';` (line 2). Keep only the first import.
  
  **Files**: `lib/screens/pesatrack_ai/pesatrack_ai_page.dart`
  
  **Verify**: 
  ```bash
  flutter analyze
  # Expected: No duplicate import errors
  ```

---

- [ ] **1.2 Fix corrupted sendMessage() method and differentiate error messages in pesatrack_ai_provider.dart**
  
  The current file has a malformed `sendMessage()` method that appears twice with broken syntax. Reconstruct it as a single, well-formed method. Replace all generic error messages with specific ones:
  
  - "Failed to load your financial data. Please check your connection and try again." — for repository/network failures (line ~90–92)
  - "Failed to save your message. Please try again." — for Hive persistence of user message (line ~104)
  - "Response received but failed to save. Please try again." — for Hive persistence of AI response (line ~107)
  - "Unable to process your request. Please try again." — for AI processing failures (line ~95)
  - "An unexpected error occurred. Please try again." — for outer catch-all
  
  **Files**: `lib/core/providers/pesatrack_ai_provider.dart`
  
  **Verify**:
  ```bash
  flutter analyze
  # Expected: No syntax errors, method is well-formed
  flutter pub get
  # Expected: Dependencies resolve without error
  ```

---

- [ ] **1.3 Disable microphone button and add "Coming soon" tooltip in chat_input_area.dart**
  
  The microphone button is wired to `VoiceInputButton` but the callback is not connected, so tapping it calls null. For MVP, disable the button visually and add a tooltip.
  
  In `lib/screens/pesatrack_ai/widgets/chat_input_area.dart`, update the VoiceInputButton instantiation to disable it:
  - Set `onPressed: null` or `enabled: false`
  - Wrap with `Tooltip(message: 'Voice recording coming soon', child: ...)`
  - Update VoiceInputButton styling to show disabled state (grayed out, low opacity)
  
  **Files**: `lib/screens/pesatrack_ai/widgets/chat_input_area.dart`, `lib/screens/pesatrack_ai/widgets/voice_input_button.dart`
  
  **Verify**:
  ```bash
  flutter build apk --debug
  # Expected: Build succeeds
  flutter run --debug
  # Expected: App launches, navigate to PesaTrack AI, verify microphone button is grayed out and tooltip shows on hover
  # Tapping microphone button should not crash or cause error
  ```

---

### Feature 2: Implement Professional Authentication Service (FEAT-002)

Build the backend auth service, Firebase integration, and state management layer.

**Duration**: ~2–3 hours

- [ ] **2.1 Create AuthService in lib/services/auth_service.dart**
  
  Implement a new service class that wraps Firebase Auth and Google Sign-In. This is the single source of truth for all authentication logic.
  
  **Methods**:
  - `Future<User?> signInWithEmail(String email, String password)` — attempt login via Firebase Auth, catch exceptions, return User or null
  - `Future<User?> registerWithEmail(String email, String password, String name)` — create user in Firebase Auth, store document in Firestore at `users/{uid}`, return User
  - `Future<User?> signInWithGoogle()` — use google_sign_in to get ID token, sign in via Firebase Auth, store/update user document in Firestore, return User
  - `Future<User?> signInWithGithub()` — attempt GitHub sign-in via Firebase Auth's GitHub provider; if unavailable, throw UnimplementedError with setup instructions
  - `Future<void> signOut()` — sign out of Firebase Auth and google_sign_in
  - `User? getCurrentUser()` — synchronous getter returning currently logged-in User or null
  - `bool get isAuthenticated` — true if currentUser is not null
  - Private method `Future<void> _storeUserInFirestore(firebase_auth.User firebaseUser, String authProvider)` — creates or updates user document in Firestore
  - Error handling: catch Firebase exceptions (user-not-found, wrong-password, email-already-in-use, weak-password, network-request-failed, etc.) and convert to specific user messages like "Invalid credentials", "Email already in use", "Weak password", "Network error"
  
  **Files**: `lib/services/auth_service.dart` (new)
  
  **Verify**:
  ```bash
  flutter analyze
  # Expected: No errors, AuthService class is recognized
  ```

---

- [ ] **2.2 Enhance User model in lib/data/models/user_model.dart**
  
  Add new fields to support auth provider tracking and profile data. Update toJson/fromJson, add fromFirebaseUser factory.
  
  **New fields**:
  - `String? profilePictureUrl` — nullable for users without profile pictures
  - `String authProvider` — 'email', 'google', 'github'
  - `DateTime? lastLogin` — track last login time
  
  **New methods**:
  - `factory User.fromFirebaseUser(firebase_auth.User firebaseUser, String authProvider)` — construct User from Firebase User and auth provider
  - Update `toJson()` and `fromJson()` to serialize/deserialize new fields
  - Update `copyWith()` to include new fields
  
  **Files**: `lib/data/models/user_model.dart`
  
  **Verify**:
  ```bash
  flutter analyze
  # Expected: User model compiles, fromFirebaseUser is recognized
  ```

---

- [ ] **2.3 Create AuthProvider in lib/core/providers/auth_provider.dart**
  
  State management layer wrapping AuthService, exposing auth state and methods. Follows same ChangeNotifier pattern as PesaTrackAIProvider.
  
  **Properties**:
  - `User? currentUser` — currently logged-in user or null
  - `bool isAuthenticated` — true if currentUser is not null
  - `bool isLoading` — true while async auth operations are in progress
  - `String? errorMessage` — error message from last failed operation
  
  **Methods**:
  - `Future<void> login(String email, String password)` — call authService.signInWithEmail, set isLoading, handle errors, notify listeners
  - `Future<void> register(String email, String password, String name)` — call authService.registerWithEmail, set isLoading, handle errors, notify listeners
  - `Future<void> signInWithGoogle()` — call authService.signInWithGoogle, set isLoading, handle errors, notify listeners
  - `Future<void> signInWithGithub()` — call authService.signInWithGithub, set isLoading, handle errors, notify listeners
  - `Future<void> logout()` — call authService.signOut, clear currentUser, set isAuthenticated=false, notify listeners
  - `void clearError()` — clear errorMessage and notify listeners
  
  **Constructor**: Listen to Firebase Auth state stream via authService. Update currentUser automatically when auth state changes. Example: `_authService.authStateChanges().listen((firebaseUser) { _currentUser = firebaseUser != null ? _buildUserFromFirebaseUser(firebaseUser) : null; notifyListeners(); })`
  
  **Error handling**: Catch exceptions from AuthService, set errorMessage with specific error text, notify listeners, set isLoading=false.
  
  **Files**: `lib/core/providers/auth_provider.dart` (new)
  
  **Verify**:
  ```bash
  flutter analyze
  # Expected: AuthProvider class compiles, extends ChangeNotifier
  ```

---

- [ ] **2.4 Update main.dart to enable Firebase and register AuthProvider**
  
  Uncomment Firebase initialization, update MultiProvider to include AuthProvider before PesaTrackAIProvider, import firebase_core and firebase_options.
  
  **Changes**:
  1. Uncomment lines in main() after Hive setup:
     ```dart
     // Initialize Firebase after running: flutterfire configure
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     ```
  2. Update MultiProvider in MyApp.build():
     ```dart
     MultiProvider(
       providers: [
         ChangeNotifierProvider(create: (_) => ThemeProvider()),
         ChangeNotifierProvider(create: (_) => AuthProvider()), // Add this
         ChangeNotifierProvider(create: (_) => PesaTrackAIProvider()), // Keep this
       ],
       ...
     )
     ```
  3. Add imports at top:
     ```dart
     import 'package:firebase_core/firebase_core.dart';
     import 'firebase_options.dart';
     import 'core/providers/auth_provider.dart';
     ```
  
  **Files**: `lib/main.dart`
  
  **Verify**:
  ```bash
  flutter pub get
  # Expected: Dependencies fetch (note: firebase_options.dart must exist, generated by flutterfire configure)
  flutter analyze
  # Expected: Firebase imports resolve, AuthProvider is recognized
  ```

---

- [ ] **2.5 Update SplashScreen to check authentication state**
  
  Replace hardcoded 2-second delay with dynamic auth check. Read AuthProvider to determine destination route.
  
  **Changes**:
  1. In `initState()`, use `context.read<AuthProvider>()` to access auth state
  2. Check `authProvider.isAuthenticated` or `authProvider.currentUser != null`
  3. If authenticated, navigate to home route; if not, navigate to login
  4. Add timeout (e.g., 3 seconds) to prevent infinite splash if auth state check is slow
  5. Use `Future.delayed()` or `Firebase.initializeApp()` completion as reference
  
  **Pattern**:
  ```dart
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }
  
  void _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 3)); // timeout
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }
  ```
  
  **Files**: `lib/screens/splash/splash_screen.dart`
  
  **Verify**:
  ```bash
  flutter run --debug
  # Expected: App launches, SplashScreen displays for 2–3 seconds, then routes to login (if not authenticated) or home (if already logged in from previous session)
  ```

---

- [ ] **2.6 Update pubspec.yaml with new dependencies**
  
  Add font_awesome_flutter for social icons. Optionally add flutter_appauth if GitHub OAuth via device flow is chosen.
  
  **Add to dependencies section**:
  ```yaml
  font_awesome_flutter: ^10.0.0
  # flutter_appauth: ^8.0.0  # Uncomment only if GitHub OAuth via device flow is implemented
  ```
  
  **Files**: `pubspec.yaml`
  
  **Verify**:
  ```bash
  flutter pub get
  # Expected: New dependencies are fetched successfully
  ```

---

### Feature 3: Build Professional Login & Registration Screens (FEAT-003)

Build user-facing auth UI with professional design, form validation, password strength indicator, and social sign-in buttons.

**Duration**: ~2–3 hours

- [ ] **3.1 Replace LoginScreen in lib/screens/auth/login_screen.dart**
  
  Build a professional login screen with email/password form, Google/GitHub buttons, forgot password link, and sign-up link.
  
  **Structure**:
  1. **Hero section** (top):
     - PesaTrack logo/icon (use existing wallet icon or assets)
     - App name "PesaTracker" (large, bold)
     - Tagline "Your Smart Money Companion" (subtitle)
  
  2. **Email/Password form**:
     - "Email" label, TextFormField with email validation (must contain '@')
     - "Password" label, TextFormField with obscure toggle (visibility icon)
     - Validation: non-empty, valid email format
  
  3. **Social sign-in buttons**:
     - Google button: Icon(FontAwesomeIcons.google), blue color, text "Sign in with Google"
     - GitHub button: Icon(FontAwesomeIcons.github), dark/black color, text "Sign in with GitHub"
     - Each button has independent loading state (showing CircularProgressIndicator)
  
  4. **Additional links**:
     - "Forgot password?" TextButton (stub for MVP, can navigate to password reset screen or show dialog)
     - "Don't have an account? Sign up" TextButton → navigate to RegisterScreen
  
  5. **Error display**:
     - Red banner below form showing error message if errorMessage is not null
     - Error dismissible on next action or by tapping an X button
  
  6. **Design**:
     - Use existing gradient background (optional, per existing login_screen.dart)
     - White Card with BorderRadius.circular(28)
     - Buttons use BorderRadius.circular(14) and AppConstants.ugandaGreen
     - Text uses Theme.of(context).textTheme for consistency
  
  **Wiring**:
  - "Sign in" button → `authProvider.login(email, password)`
  - "Google" button → `authProvider.signInWithGoogle()`
  - "GitHub" button → `authProvider.signInWithGithub()`
  - On success, navigate to home route
  - On error, display errorMessage in red banner
  - Show loading state on buttons while `authProvider.isLoading == true`
  
  **Files**: `lib/screens/auth/login_screen.dart`
  
  **Verify**:
  ```bash
  flutter build apk --debug
  # Expected: Build succeeds
  flutter run --debug
  # Expected: Launch app, reach LoginScreen, verify all UI elements are present and properly styled
  ```

---

- [ ] **3.2 Replace RegisterScreen in lib/screens/auth/register_screen.dart**
  
  Build a professional registration screen with Name/Email/Password form, Google/GitHub buttons, and password strength indicator.
  
  **Structure**:
  1. **Hero section** (same as LoginScreen):
     - PesaTrack logo, app name, tagline
  
  2. **Form fields**:
     - "Full Name" TextFormField (validation: non-empty)
     - "Email" TextFormField (validation: non-empty, valid email)
     - "Password" TextFormField (validation: non-empty, length >= 8)
     - "Confirm Password" TextFormField (validation: matches password field)
  
  3. **Password strength indicator** (real-time update):
     - Visual strength bar: Red (weak) → Yellow (medium) → Green (strong)
     - Bar fills as user enters password characters
     - Below bar, display checklist of strength rules:
       - ✓/✗ At least 8 characters
       - ✓/✗ Contains uppercase letter (A-Z)
       - ✓/✗ Contains lowercase letter (a-z)
       - ✓/✗ Contains number (0-9)
       - ✓/✗ Contains special character (!@#$%^&*)
     - Color: Red if 0–1 rules met, Yellow if 2–3 rules, Green if 4+ rules
     - Update in real-time as user types in password field
  
  4. **Social sign-up buttons** (same as LoginScreen):
     - Google and GitHub buttons with icons and independent loading states
  
  5. **Additional links**:
     - "Already have an account? Sign in" TextButton → navigate back to LoginScreen (or pop)
  
  6. **Error display**:
     - Red banner showing errorMessage
  
  **Wiring**:
  - "Create Account" button → `authProvider.register(name, email, password)`
  - "Google" button → `authProvider.signInWithGoogle()`
  - "GitHub" button → `authProvider.signInWithGithub()`
  - On success, navigate to home route
  - On error, display errorMessage
  - Show loading state on buttons while `authProvider.isLoading == true`
  - Password strength updates in real-time (use setState or Consumer to update UI)
  
  **Implementation hints for password strength**:
  - Create a helper method to calculate strength score:
    ```dart
    int _calculatePasswordStrength(String password) {
      int score = 0;
      if (password.length >= 8) score++;
      if (password.contains(RegExp(r'[A-Z]'))) score++;
      if (password.contains(RegExp(r'[a-z]'))) score++;
      if (password.contains(RegExp(r'[0-9]'))) score++;
      if (password.contains(RegExp(r'[!@#$%^&*]'))) score++;
      return score;
    }
    ```
  - Use onChanged callback on password field to update strength
  - Display rules with icons and colors based on regex checks
  
  **Files**: `lib/screens/auth/register_screen.dart`
  
  **Verify**:
  ```bash
  flutter run --debug
  # Expected: RegisterScreen displays all form fields, password strength indicator, Google/GitHub buttons
  # Type password: verify indicator updates in real-time and shows color/rules correctly
  # Test signup: fill form, click Create Account, verify loading state and navigation to home on success
  ```

---

- [ ] **3.3 Update PesaTrackAIProvider to accept userId from authenticated user**
  
  Remove hardcoded userId dependency on constants. Initialize with authenticated user's UID from AuthProvider.
  
  **Changes**:
  1. Update constructor or add a new `setUserId(String userId)` method
  2. In `main.dart`, after creating AuthProvider, pass the authenticated user's UID to PesaTrackAIProvider
  3. Alternative: PesaTrackAIProvider constructor reads from context: `AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false); _userId = authProvider.currentUser?.id ?? 'guest';`
  4. Update initial load: when user logs out, clear messages and userId, or ensure provider re-initializes on auth state change
  
  **Files**: `lib/core/providers/pesatrack_ai_provider.dart`, `lib/main.dart`
  
  **Verify**:
  ```bash
  flutter run --debug
  # Expected: After login, navigate to home, then PesaTrack AI page; verify chat history is empty and no errors are shown for hardcoded userId
  # Logout: verify chat history is cleared
  ```

---

- [ ] **3.4 Update constants to remove hardcoded defaultUserId**
  
  Remove or comment out `defaultUserId = 'user_001'` from `lib/core/constants/pesatrack_ai_constants.dart` since it's now dynamic.
  
  **Files**: `lib/core/constants/pesatrack_ai_constants.dart`
  
  **Verify**:
  ```bash
  flutter analyze
  # Expected: No errors even though defaultUserId is not used
  ```

---

## Verification Checklist (Full Integration Test)

After all three features are implemented, run this comprehensive test:

```bash
# 1. Build and analyze
flutter pub get
flutter analyze
flutter build apk --debug

# 2. Launch app
flutter run --debug

# 3. Test flow: Not authenticated (first time)
# - SplashScreen appears for 2–3 seconds
# - Auto-navigate to LoginScreen
# - Verify hero section, email/password form, Google/GitHub buttons, forgot password, sign-up link

# 4. Test email signup
# - Tap "Sign up" link
# - RegisterScreen appears
# - Fill form: name, email, password
# - Verify password strength indicator updates in real-time (Red → Yellow → Green)
# - Click "Create Account"
# - Verify loading state on button
# - On success, navigate to home screen
# - Verify authenticated user data appears in Firestore at users/{uid}

# 5. Test logout
# - From home, navigate to Settings or Profile screen
# - Find logout button
# - Tap logout
# - Verify navigation to LoginScreen
# - Verify PesaTrack AI chat history is cleared

# 6. Test email login
# - On LoginScreen, enter email and password from signup
# - Click "Sign in"
# - Verify loading state
# - On success, navigate to home
# - Verify user data matches stored Firestore record

# 7. Test Google sign-in
# - Tap "Sign in with Google" button
# - Verify Google OAuth flow launches (browser opens, Google login/consent screen)
# - Complete Google login
# - Verify app returns to home
# - Verify new user document created in Firestore (if new account)

# 8. Test GitHub sign-in
# - Tap "Sign in with GitHub" button
# - If Firebase GitHub provider is configured: verify OAuth flow, complete login, verify Firestore document
# - If not configured: verify clear error message or UnimplementedError dialog

# 9. Test PesaTrack AI with authenticated user
# - From home, navigate to PesaTrack AI page
# - Verify chat initializes with authenticated user's UID (not 'user_001')
# - Send a message: verify chat works
# - Verify microphone button is disabled with "Voice recording coming soon" tooltip
# - Verify all error messages are specific (not generic)

# 10. Test error handling
# - On LoginScreen, try: invalid email format, non-existent email, wrong password
# - Verify each shows specific error message (not generic)
# - On RegisterScreen, try: weak password, duplicate email, passwords not matching
# - Verify specific error messages

# 11. Test dark mode (if app supports it)
# - Toggle dark mode in Settings
# - Verify auth screens and PesaTrack AI screens adapt correctly
# - Verify colors use theme (not hardcoded)
```

---

## Manual Firebase Setup Instructions (For Developer)

This is a **manual prerequisite** before implementation. Document this for the developer:

1. **Create Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project", name it (e.g., "PesaTracker"), follow prompts
   - Select or create a Google Cloud project
   - Enable Google Analytics (optional)

2. **Enable Authentication Providers**:
   - In Firebase Console, go to **Authentication** > **Sign-in method**
   - Enable **Email/Password**
   - Enable **Google** (auto-linked if project was linked to Google Cloud)
   - Enable **GitHub**: 
     - Go to [GitHub Developer Settings](https://github.com/settings/developers)
     - Create a new OAuth App: provide name, homepage URL, authorization callback URL (get from Firebase Console)
     - Copy Client ID and Client Secret
     - Paste into Firebase Console GitHub provider settings

3. **Configure Android SHA-1 Fingerprint** (for Google sign-in):
   - Get debug keystore SHA-1:
     ```bash
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     # Copy the SHA-1 value
     ```
   - Add to Firebase Console: **Project Settings** > **Your apps** > **Android** > **SHA certificate fingerprints** > Add the SHA-1

4. **Run flutterfire configure**:
   - In project root, run:
     ```bash
     flutterfire configure
     ```
   - Select Firebase project when prompted
   - Select Android, iOS (or other platforms)
   - Command auto-generates `lib/firebase_options.dart`
   - Commit this file to version control (it contains project-specific credentials)

5. **Verify Firebase Connection**:
   - Run `flutter pub get` to ensure all Firebase packages are fetched
   - Run `flutter run --debug` and manually test auth flows

---

## Commit Strategy

Commits should follow Conventional Commits format. Suggested commits per feature:

**FEAT-001 commits**:
```
fix: remove duplicate flutter/material import in pesatrack_ai_page
fix: differentiate error messages in pesatrack_ai_provider
fix: disable microphone button with 'Coming soon' tooltip
```

**FEAT-002 commits**:
```
feat: add AuthService with Email/Google/GitHub sign-in support
feat: enhance User model with authProvider and profile fields
feat: create AuthProvider state management
feat: enable Firebase init and register AuthProvider in main.dart
feat: update SplashScreen to check auth state
chore: add font_awesome_flutter and firebase dependencies to pubspec.yaml
```

**FEAT-003 commits**:
```
feat: build professional LoginScreen with multi-auth buttons
feat: build professional RegisterScreen with password strength indicator
feat: update PesaTrackAIProvider to use authenticated user's ID
chore: remove hardcoded userId from pesatrack_ai_constants
```

---

## Summary

This plan addresses all requirements from the original task:

✅ **TASK 1 (MVP Review Fixes)**:
- Remove duplicate import
- Differentiate error messages by type
- Disable microphone button for MVP

✅ **TASK 2 (Professional Multi-Auth)**:
- Email signup/login with validation and specific error messages
- Google sign-in integration
- GitHub sign-in integration (Firebase provider or stub)
- AuthService (single source of truth for auth logic)
- AuthProvider (state management via ChangeNotifier)
- Professional UI with hero sections, social buttons, password strength indicator
- Firestore user persistence with authProvider field
- Dynamic user ID for PesaTrackAIProvider (no more hardcoded 'user_001')
- SplashScreen auth check and routing
- Font Awesome icons for social buttons
- Proper error handling with specific messages

All changes follow existing app conventions (ChangeNotifier, AppTheme, AppConstants) and leave the codebase in a buildable, testable state after each feature.

---

**Next Steps**: A coder agent will implement FEAT-001, FEAT-002, and FEAT-003 sequentially, running `flutter analyze` and `flutter build apk --debug` after each to verify correctness.
