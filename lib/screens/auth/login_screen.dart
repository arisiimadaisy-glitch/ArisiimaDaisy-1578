import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/routes/app_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;
  bool _isGithubLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn(AuthProvider authProvider) async {
    if (authProvider.isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isEmailLoading = true);
    try {
      authProvider.clearError();
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted && success) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } finally {
      if (mounted) setState(() => _isEmailLoading = false);
    }
  }

  void _signInWithGoogle(AuthProvider authProvider) async {
    if (authProvider.isLoading) return;
    setState(() => _isGoogleLoading = true);
    try {
      authProvider.clearError();

      final success = await authProvider.signInWithGoogle();

      if (mounted && success) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _signInWithGithub(AuthProvider authProvider) async {
    if (authProvider.isLoading) return;
    setState(() => _isGithubLoading = true);
    try {
      authProvider.clearError();

      final success = await authProvider.signInWithGithub();

      if (mounted && success) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } finally {
      if (mounted) setState(() => _isGithubLoading = false);
    }
  }

  void _showPasswordResetSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset email sent. Check your inbox.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xfff2f6f0), Color(0xffdce9e4)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Hero Section
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: AppConstants.ugandaGreen,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'PesaTrack',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppConstants.ugandaGreen,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Your Smart Money Companion',
                                  style: TextStyle(
                                    color: AppConstants.ugandaGreen,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Welcome back',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF111111),
                                ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sign in to your account.',
                            style: TextStyle(
                              color: Color.fromARGB(255, 12, 12, 12),
                              fontSize: 13,
                            ),
                          ),

                          // Error Banner
                          if (authProvider.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppConstants.ugandaRed.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppConstants.ugandaRed,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      authProvider.errorMessage!,
                                      style: const TextStyle(
                                        color: AppConstants.ugandaRed,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 28),
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.mail_outline),
                              border: OutlineInputBorder(),
                              hintText: 'your@email.com',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter your email address';
                              }
                              if (!value.contains('@')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) =>
                                _signIn(context.read<AuthProvider>()),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: const OutlineInputBorder(),
                              hintText: 'password',
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Show password'
                                    : 'Hide password',
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter your password'
                                : null,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showPasswordResetSnackbar,
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: AppConstants.ugandaGreen,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FilledButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : () => _signIn(context.read<AuthProvider>()),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(54),
                              backgroundColor: AppConstants.ugandaGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              disabledBackgroundColor: AppConstants.ugandaGreen
                                  .withValues(alpha: 0.5),
                            ),
                            child: _isEmailLoading
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
                                : const Text('Sign In'),
                          ),
                          const SizedBox(height: 24),
                          const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'Or continue with',
                                  style: TextStyle(
                                    color: Color(0xFF777777),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              OutlinedButton.icon(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () => _signInWithGoogle(
                                        context.read<AuthProvider>(),
                                      ),
                                icon: _isGoogleLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFF4285F4),
                                              ),
                                        ),
                                      )
                                    : const FaIcon(
                                        FontAwesomeIcons.google,
                                        color: Color(0xFF4285F4),
                                        size: 18,
                                      ),
                                label: const Text('Continue with Google'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF3C4043),
                                  backgroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(48),
                                  side: const BorderSide(
                                    color: Color(0xFFDADCE0),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () => _signInWithGithub(
                                        context.read<AuthProvider>(),
                                      ),
                                icon: _isGithubLoading
                                    ? SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppConstants.ugandaGreen,
                                              ),
                                        ),
                                      )
                                    : const FaIcon(
                                        FontAwesomeIcons.github,
                                        size: 18,
                                      ),
                                label: const Text('GitHub'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color.fromARGB(
                                    255,
                                    14,
                                    15,
                                    14,
                                  ),
                                  side: const BorderSide(
                                    color: Color.fromARGB(255, 8, 8, 8),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  color: Color(0xFF777777),
                                  fontSize: 13,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.register,
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: AppConstants.ugandaGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
