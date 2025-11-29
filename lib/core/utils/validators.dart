class FormValidator {
  // 1. Generic required validation for text fields
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  // 2. Age Validation (18-65)
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required.';
    }
    final age = int.tryParse(value);
    if (age == null || age < 18 || age > 65) {
      return 'Age must be between 18 and 65 for donation.';
    }
    return null;
  }

  // 3. Mobile Validation (Egyptian format)
  static String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required.';
    }
    final mobileNumber = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (mobileNumber.length != 11) {
      return 'Mobile number must be exactly 11 digits.';
    }
    if (!mobileNumber.startsWith('010') &&
        !mobileNumber.startsWith('011') &&
        !mobileNumber.startsWith('012') &&
        !mobileNumber.startsWith('015')) {
      return 'Mobile must start with 010, 011, 012, or 015.';
    }
    return null;
  }

  // 4. Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  // 5. Password Strength Validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    return null;
  }

  // 6. Confirm Password Validation
  static String? validateConfirmPassword(
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password.';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }
    return null;
  }
}