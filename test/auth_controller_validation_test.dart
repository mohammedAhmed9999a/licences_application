import 'package:flutter_test/flutter_test.dart';
import 'package:licences_application/app/controllers/auth_controller.dart';

void main() {
  late AuthController controller;

  setUp(() {
    controller = AuthController();
  });

  test('returns field error for empty login values', () {
    final error = controller.validateLoginForm(email: '', password: '');

    expect(error, isNotNull);
    expect(error, contains('البريد'));
  });

  test('returns field error for weak signup password', () {
    final error = controller.validateSignupForm(
      name: 'مستخدم',
      email: 'user@example.com',
      password: 'weak',
      confirmPassword: 'weak',
    );

    expect(error, isNotNull);
    expect(error, contains('كلمة المرور'));
  });

  test('rejects non-Arabic names in signup', () {
    final error = controller.validateSignupForm(
      name: 'John',
      email: 'user@example.com',
      password: 'Abc123!@#',
      confirmPassword: 'Abc123!@#',
    );

    expect(error, isNotNull);
    expect(error, contains('العربية'));
  });
}
