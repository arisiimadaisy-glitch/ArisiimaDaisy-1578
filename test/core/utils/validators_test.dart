import 'package:flutter_test/flutter_test.dart';
import 'package:login_app/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('returns error for null or empty email', () {
        expect(Validators.validateEmail(null), isNotNull);
        expect(Validators.validateEmail(''), isNotNull);
        expect(Validators.validateEmail('   '), isNotNull);
      });

      test('returns error for invalid email format', () {
        expect(Validators.validateEmail('invalid'), isNotNull);
        expect(Validators.validateEmail('test@'), isNotNull);
        expect(Validators.validateEmail('@test.com'), isNotNull);
        expect(Validators.validateEmail('test@test'), isNotNull);
      });

      test('returns null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), isNull);
        expect(Validators.validateEmail('user+tag@domain.co.uk'), isNull);
      });
    });

    group('validatePassword', () {
      test('returns error for null or empty password', () {
        expect(Validators.validatePassword(null), isNotNull);
        expect(Validators.validatePassword(''), isNotNull);
      });

      test('returns error for password shorter than 6 characters', () {
        expect(Validators.validatePassword('12345'), isNotNull);
        expect(Validators.validatePassword('pass'), isNotNull);
      });

      test('returns null for password with 6+ characters', () {
        expect(Validators.validatePassword('123456'), isNull);
        expect(Validators.validatePassword('password123'), isNull);
      });
    });

    group('validateStrongPassword', () {
      test('returns error for password without uppercase', () {
        expect(Validators.validateStrongPassword('password123'), isNotNull);
      });

      test('returns error for password without lowercase', () {
        expect(Validators.validateStrongPassword('PASSWORD123'), isNotNull);
      });

      test('returns error for password without digit', () {
        expect(Validators.validateStrongPassword('Password'), isNotNull);
      });

      test('returns null for strong password', () {
        expect(Validators.validateStrongPassword('Password123'), isNull);
      });
    });

    group('validatePasswordMatch', () {
      test('returns error when passwords do not match', () {
        expect(Validators.validatePasswordMatch('password', 'different'), isNotNull);
      });

      test('returns null when passwords match', () {
        expect(Validators.validatePasswordMatch('password', 'password'), isNull);
      });
    });

    group('validateAmount', () {
      test('returns error for null or empty amount', () {
        expect(Validators.validateAmount(null), isNotNull);
        expect(Validators.validateAmount(''), isNotNull);
        expect(Validators.validateAmount('   '), isNotNull);
      });

      test('returns error for invalid amount format', () {
        expect(Validators.validateAmount('abc'), isNotNull);
        expect(Validators.validateAmount('12.34.56'), isNotNull);
      });

      test('returns error for zero or negative amount', () {
        expect(Validators.validateAmount('0'), isNotNull);
        expect(Validators.validateAmount('-10'), isNotNull);
      });

      test('returns null for valid positive amount', () {
        expect(Validators.validateAmount('100'), isNull);
        expect(Validators.validateAmount('1234.56'), isNull);
        expect(Validators.validateAmount('\$1,234.56'), isNull);
      });
    });

    group('validateRequired', () {
      test('returns error for null or empty value', () {
        expect(Validators.validateRequired(null), isNotNull);
        expect(Validators.validateRequired(''), isNotNull);
        expect(Validators.validateRequired('   '), isNotNull);
      });

      test('returns null for non-empty value', () {
        expect(Validators.validateRequired('value'), isNull);
      });

      test('uses custom field name in error message', () {
        final error = Validators.validateRequired(null, fieldName: 'Name');
        expect(error, contains('Name'));
      });
    });

    group('validatePhone', () {
      test('returns error for invalid phone format', () {
        expect(Validators.validatePhone('123'), isNotNull);
        expect(Validators.validatePhone('abc'), isNotNull);
      });

      test('returns null for valid phone numbers', () {
        expect(Validators.validatePhone('1234567890'), isNull);
        expect(Validators.validatePhone('+256700123456'), isNull);
        expect(Validators.validatePhone('(123) 456-7890'), isNull);
      });
    });

    group('validateName', () {
      test('returns error for short names', () {
        expect(Validators.validateName('A'), isNotNull);
      });

      test('returns error for names with invalid characters', () {
        expect(Validators.validateName('Name123'), isNotNull);
        expect(Validators.validateName('Name@test'), isNotNull);
      });

      test('returns null for valid names', () {
        expect(Validators.validateName('John'), isNull);
        expect(Validators.validateName('Mary Jane'), isNull);
        expect(Validators.validateName("O'Connor"), isNull);
        expect(Validators.validateName('Smith-Jones'), isNull);
      });
    });

    group('validateUrl', () {
      test('returns error for invalid URLs', () {
        expect(Validators.validateUrl('not a url'), isNotNull);
        expect(Validators.validateUrl('ftp://example.com'), isNotNull);
      });

      test('returns null for valid URLs', () {
        expect(Validators.validateUrl('https://example.com'), isNull);
        expect(Validators.validateUrl('http://example.com'), isNull);
      });
    });

    group('validatePositiveInteger', () {
      test('returns error for non-numeric values', () {
        expect(Validators.validatePositiveInteger('abc'), isNotNull);
        expect(Validators.validatePositiveInteger('12.5'), isNotNull);
      });

      test('returns error for zero or negative', () {
        expect(Validators.validatePositiveInteger('0'), isNotNull);
        expect(Validators.validatePositiveInteger('-5'), isNotNull);
      });

      test('returns null for positive integers', () {
        expect(Validators.validatePositiveInteger('1'), isNull);
        expect(Validators.validatePositiveInteger('100'), isNull);
      });
    });

    group('validateMinLength', () {
      test('returns error for strings shorter than minimum', () {
        expect(Validators.validateMinLength('abc', 5), isNotNull);
      });

      test('returns null for strings meeting minimum length', () {
        expect(Validators.validateMinLength('abcde', 5), isNull);
        expect(Validators.validateMinLength('abcdef', 5), isNull);
      });
    });

    group('validateMaxLength', () {
      test('returns error for strings longer than maximum', () {
        expect(Validators.validateMaxLength('abcdefgh', 5), isNotNull);
      });

      test('returns null for strings within maximum length', () {
        expect(Validators.validateMaxLength('abc', 5), isNull);
        expect(Validators.validateMaxLength('abcde', 5), isNull);
        expect(Validators.validateMaxLength(null, 5), isNull);
      });
    });
  });
}
