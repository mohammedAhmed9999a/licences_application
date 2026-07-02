class FormValidator {
  static bool isValidEmail(String value) {
    final email = value.trim();
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  static bool isStrongPassword(String value) {
    return value.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(value) &&
        RegExp(r'[a-z]').hasMatch(value) &&
        RegExp(r'\d').hasMatch(value) &&
        RegExp(r'[!@#\$%\^&\*(),.?":{}|<>]').hasMatch(value);
  }

  static String? validateLoginPasswordField(String password) {
    if (password.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (password.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    return null;
  }

  static String? validateSignupPasswordField(String password) {
    if (password.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (password.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    if (!RegExp(r'[a-z]').hasMatch(password) ||
        !RegExp(r'\d').hasMatch(password) ||
        !RegExp(r'[!@#\$%\^&\*(),.?":{}|<>]').hasMatch(password)) {
      return 'يجب أن تحتوي على أرقام وحروف ورموز';
    }
    return null;
  }

  static bool isArabicName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    return RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(trimmed);
  }

  static String? validateEmailField(String email) {
    if (email.trim().isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    if (!isValidEmail(email)) {
      return ' مثل name@example.com يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  static String? validatePasswordField(String password) {
    if (password.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (password.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    return null;
  }

  static String? validateNameField(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'يرجى إدخال الاسم الكامل';
    }
    if (trimmed.length <= 2) {
      return 'الاسم يجب أن يكون أكثر من حرفين';
    }
    if (!isArabicName(trimmed)) {
      return 'الاسم يجب أن يكون باللغة العربية حصراً';
    }
    return null;
  }

  static String? validateConfirmPasswordField(
    String password,
    String confirmPassword,
  ) {
    if (confirmPassword.isEmpty) {
      return 'يرجى تأكيد كلمة المرور';
    }
    if (password != confirmPassword) {
      return 'كلمتا المرور غير متطابقتين';
    }
    return null;
  }

  static String? validateLoginForm({
    required String email,
    required String password,
  }) {
    final emailError = validateEmailField(email);
    if (emailError != null) {
      return emailError;
    }
    return validatePasswordField(password);
  }

  static String? validateSignupForm({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    final nameError = validateNameField(name);
    if (nameError != null) {
      return nameError;
    }

    final emailError = validateEmailField(email);
    if (emailError != null) {
      return emailError;
    }

    final passwordError = validateSignupPasswordField(password);
    if (passwordError != null) {
      return passwordError;
    }

    return validateConfirmPasswordField(password, confirmPassword);
  }
}
