import 'package:flutter_test/flutter_test.dart';
import 'package:licences_application/app/controllers/license_application_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'validateStep2 rejects non-Arabic name, invalid national ID and underage birth date',
    () {
      final controller = LicenseApplicationController();
      controller.requestType.value = 'new';
      controller.investorType.value = 'individual';
      controller.firstNameController.text = 'John';
      controller.fatherNameController.text = 'محمد';
      controller.nicknameController.text = 'الكنية';
      controller.motherNameController.text = 'سارة';
      controller.nationalIdController.text = '12345678';
      controller.birthPlaceController.text = 'دمشق';
      controller.birthDate.value = DateTime.now().subtract(
        const Duration(days: 365 * 15),
      );

      expect(controller.validateStep2(), isFalse);
      expect(controller.firstNameError.value, contains('الاسم'));
    },
  );

  test('validateStep2 marks empty personal fields as required', () {
    final controller = LicenseApplicationController();
    controller.requestType.value = 'new';
    controller.investorType.value = 'individual';
    controller.firstNameController.text = '';
    controller.fatherNameController.text = '';
    controller.nicknameController.text = '';
    controller.motherNameController.text = '';
    controller.nationalIdController.text = '';
    controller.birthPlaceController.text = '';
    controller.birthDate.value = null;

    expect(controller.validateStep2(), isFalse);
    expect(controller.firstNameError.value, contains('يرجى إدخال'));
    expect(controller.fatherNameError.value, contains('يرجى إدخال'));
    expect(controller.nicknameError.value, contains('يرجى إدخال'));
    expect(controller.motherNameError.value, contains('يرجى إدخال'));
    expect(controller.nationalIdError.value, contains('يرجى إدخال'));
    expect(controller.birthPlaceError.value, contains('يرجى إدخال'));
    expect(controller.birthDateError.value, contains('يرجى اختيار'));
  });

  test('validateStep2 accepts valid individual data', () {
    final controller = LicenseApplicationController();
    controller.requestType.value = 'new';
    controller.investorType.value = 'individual';
    controller.firstNameController.text = 'محمد';
    controller.fatherNameController.text = 'علي';
    controller.nicknameController.text = 'الكنية';
    controller.motherNameController.text = 'سارة';
    controller.nationalIdController.text = '123456789012';

    controller.birthPlaceController.text = 'دمشق';
    controller.birthDate.value = DateTime.now().subtract(
      const Duration(days: 365 * 25),
    );

    expect(controller.validateStep2(), isTrue);
    expect(controller.errorMessage.value, isEmpty);
  });

  test(
    'validateStep2 requires both personal and company fields for company requests',
    () {
      final controller = LicenseApplicationController();
      controller.requestType.value = 'new';
      controller.investorType.value = 'company';
      controller.firstNameController.text = '';
      controller.fatherNameController.text = '';
      controller.nicknameController.text = '';
      controller.motherNameController.text = '';
      controller.nationalIdController.text = '';
      controller.birthPlaceController.text = '';
      controller.birthDate.value = null;
      controller.companyNameController.text = '';
      controller.companyLicenseNumberController.text = '';
      controller.companyLicenseDate.value = null;

      expect(controller.validateStep2(), isFalse);
      expect(controller.firstNameError.value, contains('الاسم الأول'));
      expect(controller.companyNameError.value, contains('اسم الشركة'));
    },
  );

  test(
    'validateStep2 requires settlement agreement when settlement is selected',
    () {
      final controller = LicenseApplicationController();
      controller.requestType.value = 'settlement';
      controller.settledAgreed.value = false;
      controller.investorType.value = 'individual';
      controller.firstNameController.text = 'محمد';
      controller.fatherNameController.text = 'علي';
      controller.nicknameController.text = 'الكنية';
      controller.motherNameController.text = 'سارة';
      controller.nationalIdController.text = '123456789012';
      controller.birthPlaceController.text = 'دمشق';
      controller.birthDate.value = DateTime.now().subtract(
        const Duration(days: 365 * 25),
      );
      controller.previousLicenseNumber.text = '123456';

      expect(controller.validateStep2(), isFalse);
      expect(controller.errorMessage.value, contains('تسوية'));
      expect(controller.settlementAgreementError.value, contains('المراحل'));
    },
  );

  test(
    'validateStep2 requires company section fields when company is selected',
    () {
      final controller = LicenseApplicationController();
      controller.requestType.value = 'new';
      controller.investorType.value = 'company';
      controller.firstNameController.text = 'محمد';
      controller.fatherNameController.text = 'علي';
      controller.nicknameController.text = 'الكنية';
      controller.motherNameController.text = 'سارة';
      controller.nationalIdController.text = '123456789012';
      controller.birthPlaceController.text = 'دمشق';
      controller.birthDate.value = DateTime.now().subtract(
        const Duration(days: 365 * 25),
      );
      controller.companyNameController.text = '';
      controller.companyLicenseNumberController.text = '';
      controller.companyLicenseDate.value = null;

      expect(controller.validateStep2(), isFalse);
      expect(controller.companyNameError.value, contains('اسم الشركة'));
      expect(controller.companyLicenseNumberError.value, contains('رقم ترخيص'));
      expect(controller.companyLicenseDateError.value, contains('تاريخ ترخيص'));
    },
  );

  test(
    'validateStep2 requires previous license number for settlement requests',
    () {
      final controller = LicenseApplicationController();
      controller.requestType.value = 'settlement';
      controller.settledAgreed.value = true;
      controller.investorType.value = 'individual';
      controller.firstNameController.text = 'محمد';
      controller.fatherNameController.text = 'علي';
      controller.nicknameController.text = 'الكنية';
      controller.motherNameController.text = 'سارة';
      controller.nationalIdController.text = '123456789012';
      controller.birthPlaceController.text = 'دمشق';
      controller.birthDate.value = DateTime.now().subtract(
        const Duration(days: 365 * 25),
      );

      expect(controller.validateStep2(), isFalse);
      expect(
        controller.settlementPreviousLicenseError.value,
        contains('رقم الترخيص'),
      );
    },
  );
}
