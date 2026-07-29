import 'package:flutter_test/flutter_test.dart';
import 'package:licences_application/app/controllers/license_application_controller.dart';

void main() {
  group('License application request payload', () {
    test('builds individual user info fields for the API', () {
      final controller = LicenseApplicationController();
      controller.investorType.value = 'individual';
      controller.firstNameController.text = 'محمد';
      controller.fatherNameController.text = 'عبدالله';
      controller.nicknameController.text = 'أحمد';
      controller.motherNameController.text = 'سارة';
      controller.nationalIdController.text = '123456789';
      controller.birthPlaceController.text = 'دمشق';
      controller.birthDate.value = DateTime(1995, 4, 10);

      final payload = controller.buildUserInfoPayload();

      expect(payload, {
        'user_info': {
          'first_name': 'محمد',
          'father_name': 'عبدالله',
          'last_name': 'أحمد',
          'mother_name': 'سارة',
          'national_id': '123456789',
          'place_of_birth': 'دمشق',
          'date_of_birth': '1995-04-10',
        },
      });
    });

    test('flattens company partners for multipart correction payloads', () {
      final controller = LicenseApplicationController();
      controller.isCorrectionMode.value = true;
      controller.editApplicationId.value = '123';
      controller.investorType.value = 'company';
      controller.correctionTargets.assignAll(['licenseDetails']);
      controller.companyNameController.text = 'شركة الاختبار';
      controller.companyLicenseNumberController.text = '123456';
      controller.companyLicenseDate.value = DateTime(2026, 7, 28);
      controller.partners.assignAll(['مروان', 'سامي']);

      final fields = controller.buildCorrectionFormDataFields();

      expect(fields['applicant[company_name]'], 'شركة الاختبار');
      expect(fields['applicant[partners][0]'], 'مروان');
      expect(fields['applicant[partners][1]'], 'سامي');
      expect(fields.containsKey('applicant[partners]'), isFalse);
    });
  });
}
