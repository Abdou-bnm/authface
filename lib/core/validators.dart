class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty || !value.contains('@')) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  static String? validateNotEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    return null;
  }
}
