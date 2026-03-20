/// Utility class with common input validators.
class Validators {
  Validators._();

  /// Validates an email address format.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates a phone number (basic: at least 7 digits).
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 7 || digitsOnly.length > 15) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates that a field is not empty.
  static String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates a date string in YYYY-MM-DD format.
  static String? validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date of birth is required';
    }
    try {
      final date = DateTime.parse(value.trim());
      if (date.isAfter(DateTime.now())) {
        return 'Date cannot be in the future';
      }
      return null;
    } catch (_) {
      return 'Please use YYYY-MM-DD format';
    }
  }

  /// Validates minimum text length for ingredient entry.
  static String? validateIngredients(String? value, {int minLength = 3}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter some ingredients';
    }
    if (value.trim().length < minLength) {
      return 'Please enter at least $minLength characters';
    }
    return null;
  }
}
