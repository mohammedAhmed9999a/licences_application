import 'package:flutter_test/flutter_test.dart';
import 'package:licences_application/app/controllers/license_application_controller.dart';

void main() {
  test('validateStep1 rejects invalid email and phone format', () {
    final controller = LicenseApplicationController();
    controller.emailController.text = 'invalid-email';
    controller.phoneController.text = '123456';
    controller.agreedToTerms.value = true;

    expect(controller.validateStep1(), isFalse);
    expect(controller.errorMessage.value, contains('بريد إلكتروني'));
  });

  test('validateStep1 accepts valid step1 data', () {
    final controller = LicenseApplicationController();
    controller.emailController.text = 'user@example.com';
    controller.phoneController.text = '0955123456';
    controller.agreedToTerms.value = true;

    expect(controller.validateStep1(), isTrue);
    expect(controller.errorMessage.value, isEmpty);
  });

  test('validateStep1 rejects phone numbers longer than 10 digits', () {
    final controller = LicenseApplicationController();
    controller.emailController.text = 'user@example.com';
    controller.phoneController.text = '09551234567';
    controller.agreedToTerms.value = true;

    expect(controller.validateStep1(), isFalse);
    expect(controller.errorMessage.value, contains('09'));
  });

  test('validateStep1 rejects invalid optional secondary phone', () {
    final controller = LicenseApplicationController();
    controller.emailController.text = 'user@example.com';
    controller.phoneController.text = '0955123456';
    controller.phone2Controller.text = '12345';
    controller.agreedToTerms.value = true;

    expect(controller.validateStep1(), isFalse);
    expect(controller.errorMessage.value, contains('الثانوي'));
  });
}
