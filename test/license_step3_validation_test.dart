import 'package:flutter_test/flutter_test.dart';
import 'package:licences_application/app/controllers/license_application_controller.dart';
import 'package:licences_application/app/models/governorate_model.dart';

void main() {
  test('validateStep3 rejects when district is not selected', () {
    final controller = LicenseApplicationController();
    controller.selectedGovernorate.value = GovernorateModel(id: 1, name: 'حلب');
    controller.selectedDistrict.value = null;
    controller.selectedSubdistrict.value = null;
    controller.selectedTown.value = null;
    controller.latitudeController.text = '36.123456';
    controller.longitudeController.text = '33.123456';

    expect(controller.validateStep3(), isFalse);
    expect(controller.errorMessage.value, contains('المنطقة'));
  });

  test(
    'validateStep3 accepts when district, subdistrict and town are selected',
    () {
      final controller = LicenseApplicationController();
      controller.selectedGovernorate.value = GovernorateModel(
        id: 1,
        name: 'حلب',
      );
      controller.selectedDistrict.value = GovernorateModel(
        id: 10,
        name: 'المنطقة',
      );
      controller.selectedSubdistrict.value = GovernorateModel(
        id: 20,
        name: 'الناحية',
      );
      controller.selectedTown.value = GovernorateModel(id: 30, name: 'البلدة');
      controller.latitudeController.text = '36.123456';
      controller.longitudeController.text = '33.123456';

      expect(controller.validateStep3(), isTrue);
      expect(controller.errorMessage.value, isEmpty);
    },
  );
}
