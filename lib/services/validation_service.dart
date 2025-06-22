class ValidationService {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    // Validate against special characters apart from "-"
    RegExp regex = RegExp(r'^[a-zA-Z\s-]*$');
    if (!regex.hasMatch(value)) {
      return 'Name field can only contain letters, spaces and dashes';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an e-mail address';
    }
     value = value.trim();
    // Validate email format
    RegExp regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid e-mail address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    // Validate password length
    if (value.length < 6) {
      return 'The password must contain at least 6 characters';
    }
    return null;
  }
}