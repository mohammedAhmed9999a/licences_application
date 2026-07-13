import 'package:flutter_test/flutter_test.dart';
import 'package:licences_application/app/controllers/license_application_controller.dart';
import 'package:licences_application/app/models/governorate_model.dart';

void main() {
  test(
    'applyLocationSelectionFromIds selects matching lookup values',
    () async {
      final controller = LicenseApplicationController();

      controller.governorates.value = [
        GovernorateModel(id: 1, name: 'درعا'),
        GovernorateModel(id: 2, name: 'دمشق'),
      ];
      controller.districts.value = [
        GovernorateModel(id: 10, name: 'إزرع'),
        GovernorateModel(id: 11, name: 'السويداء'),
      ];
      controller.subdistricts.value = [GovernorateModel(id: 100, name: 'جاسم')];
      controller.towns.value = [GovernorateModel(id: 1000, name: 'جاسم')];

      await controller.applyLocationSelectionFromIds(
        governorateId: '1',
        districtId: '10',
        subDistrictId: '100',
        townId: '1000',
      );

      expect(controller.selectedGovernorate.value?.id, 1);
      expect(controller.selectedDistrict.value?.id, 10);
      expect(controller.selectedSubdistrict.value?.id, 100);
      expect(controller.selectedTown.value?.id, 1000);
    },
  );
}
