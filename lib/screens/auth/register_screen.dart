import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/routes/app_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _passwordStrengthScore = 0;
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;
  bool _isGithubLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int _calculatePasswordStrength(String password) {
    int score = 0;

    // Rule 1: At least 8 characters
    if (password.length >= 8) score++;

    // Rule 2: Contains uppercase letter
    if (password.contains(RegExp(r'[A-Z]'))) score++;

    // Rule 3: Contains lowercase letter
    if (password.contains(RegExp(r'[a-z]'))) score++;

    // Rule 4: Contains digit
    if (password.contains(RegExp(r'\d'))) score++;

    // Rule 5: Contains special character
    if (password.contains(RegExp(r'[!@#\$%^&*]'))) score++;

    return score;
  }

  bool _isRulemet(String password, int ruleIndex) {
    switch (ruleIndex) {
      case 0:
        return password.length >= 8;
      case 1:
        return password.contains(RegExp(r'[A-Z]'));
      case 2:
        return password.contains(RegExp(r'[a-z]'));
      case 3:
        return password.contains(RegExp(r'\d'));
      case 4:
        return password.contains(RegExp(r'[!@#\$%^&*]'));
      default:
        return false;
    }
  }

  Color _getStrengthColor() {
    if (_passwordStrengthScore <= 1) return AppConstants.ugandaRed;
    if (_passwordStrengthScore <= 3) return Colors.amber;
    return AppConstants.ugandaGreen;
  }

  String _getStrengthLabel() {
    if (_passwordStrengthScore == 0) return '';
    if (_passwordStrengthScore <= 1) return 'Weak';
    if (_passwordStrengthScore <= 3) return 'Fair';
    return 'Strong';
  }

  void _register(AuthProvider authProvider) async {
    if (authProvider.isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    if (_passwordStrengthScore < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must meet all strength requirements'),
          backgroundColor: AppConstants.ugandaRed,
        ),
      );
      return;
    }

    setState(() => _isEmailLoading = true);
    try {
      authProvider.clearError();
      final success = await authProvider.register(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      if (mounted && success) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } finally {
      if (mounted) setState(() => _isEmailLoading = false);
    }
  }

  void _signUpWithGoogle(AuthProvider authProvider) async {
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

  void _signUpWithGithub(AuthProvider authProvider) async {
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
                            'Create Account',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF111111),
                                ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sign up to get started.',
                            style: TextStyle(
                              color: AppConstants.ugandaRed,
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
                            'Full Name',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                              hintText: 'Your name',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter your full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
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
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              setState(() {
                                _passwordStrengthScore =
                                    _calculatePasswordStrength(value);
                              });
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: const OutlineInputBorder(),
                              hintText: '••••••••',
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter a password';
                              }
                              return null;
                            },
                          ),

                          // Password Strength Indicator
                          if (_passwordController.text.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Password Strength',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF777777),
                                  ),
                                ),
                                Text(
                                  _getStrengthLabel(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getStrengthColor(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _passwordStrengthScore / 5,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getStrengthColor(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStrengthRule(
                                  'At least 8 characters',
                                  _isRulemet(_passwordController.text, 0),
                                ),
                                _buildStrengthRule(
                                  'Contains uppercase letter (A-Z)',
                                  _isRulemet(_passwordController.text, 1),
                                ),
                                _buildStrengthRule(
                                  'Contains lowercase letter (a-z)',
                                  _isRulemet(_passwordController.text, 2),
                                ),
                                _buildStrengthRule(
                                  'Contains digit (0-9)',
                                  _isRulemet(_passwordController.text, 3),
                                ),
                                _buildStrengthRule(
                                  'Contains special character (!@#\$%^&*)',
                                  _isRulemet(_passwordController.text, 4),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 16),
                          const Text(
                            'Confirm Password',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) =>
                                _register(context.read<AuthProvider>()),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: const OutlineInputBorder(),
                              hintText: '••••••••',
                              suffixIcon: IconButton(
                                tooltip: _obscureConfirmPassword
                                    ? 'Show password'
                                    : 'Hide password',
                                onPressed: () => setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                                ),
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : () => _register(context.read<AuthProvider>()),
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
                                : const Text('Create Account'),
                          ),
                          const SizedBox(height: 20),
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
                                    : () => _signUpWithGoogle(
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
                                    : () => _signUpWithGithub(
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
                                  foregroundColor: AppConstants.ugandaGreen,
                                  side: const BorderSide(
                                    color: AppConstants.ugandaGreen,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'Already have an account?',
                                style: TextStyle(
                                  color: Color(0xFF777777),
                                  fontSize: 13,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Sign In',
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

  Widget _buildStrengthRule(String label, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isMet ? AppConstants.ugandaGreen : AppConstants.ugandaRed,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? AppConstants.ugandaGreen : AppConstants.ugandaRed,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
