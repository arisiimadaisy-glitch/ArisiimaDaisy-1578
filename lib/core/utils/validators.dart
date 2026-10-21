/// Form validation helper functions
class Validators {
  Validators._();

  /// Validate email address format
  /// Returns error message if invalid, null if valid
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }

    final trimmedValue = value.trim();

    // Basic email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password (minimum 6 characters)
  /// Returns error message if invalid, null if valid
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Validate password with additional strength requirements
  /// Returns error message if invalid, null if valid
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validate that passwords match
  /// Returns error message if they don't match, null if they do
  static String? validatePasswordMatch(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate amount (positive number)
  /// Returns error message if invalid, null if valid
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }

    final trimmedValue = value.trim();

    // Remove currency symbols and thousand separators
    final cleanValue = trimmedValue.replaceAll(RegExp(r'[^\d.]'), '');

    final amount = double.tryParse(cleanValue);

    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount <= 0) {
      return 'Amount must be greater than zero';
    }

    return null;
  }

  /// Validate required field
  /// Returns error message if empty, null if valid
  static String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate phone number (basic validation)
  /// Returns error message if invalid, null if valid
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final trimmedValue = value.trim();

    // Remove spaces, dashes, and parentheses
    final cleanValue = trimmedValue.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check if it contains only digits and optional plus sign at start
    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(cleanValue)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate name (at least 2 characters, only letters and spaces)
  /// Returns error message if invalid, null if valid
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return '$fieldName must be at least 2 characters';
    }

    // Allow letters, spaces, hyphens, and apostrophes
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(trimmedValue)) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  /// Validate URL format
  /// Returns error message if invalid, null if valid
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }

    final trimmedValue = value.trim();

    try {
      final uri = Uri.parse(trimmedValue);
      if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return 'Please enter a valid URL (must start with http:// or https://)';
      }
    } catch (e) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validate that value is a positive integer
  /// Returns error message if invalid, null if valid
  static String? validatePositiveInteger(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final number = int.tryParse(value.trim());

    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number <= 0) {
      return '$fieldName must be greater than zero';
    }

    return null;
  }

  /// Validate minimum length
  /// Returns error message if invalid, null if valid
  static String? validateMinLength(String? value, int minLength, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    return null;
  }

  /// Validate maximum length
  /// Returns error message if invalid, null if valid
  static String? validateMaxLength(String? value, int maxLength, {String fieldName = 'This field'}) {
    if (value == null) return null;

    if (value.length > maxLength) {
      return '$fieldName must be at most $maxLength characters';
    }

    return null;
  }
}
