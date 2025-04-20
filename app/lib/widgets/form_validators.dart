class FormValidators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!RegExp(r'^\d{10,12}$').hasMatch(value.trim())) {
      return 'Enter a valid phone number (10-12 digits)';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validateCnic(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your CNIC number';
    }
    if (!RegExp(r'^\d{5}-\d{7}-\d{1}$').hasMatch(value.trim()) &&
        !RegExp(r'^\d{13}$').hasMatch(value.trim())) {
      return 'Enter valid CNIC (13 digits or format: #####-#######-#)';
    }
    return null;
  }

  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please use "Use Current Location" to set your city';
    }
    return null;
  }

  static String? validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your date of birth';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateBloodGroup(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your blood group';
    }
    return null;
  }
}
