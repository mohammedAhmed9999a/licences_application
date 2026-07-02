import 'package:flutter_test/flutter_test.dart';
import 'package:licences_application/app/controllers/license_application_controller.dart';

void main() {
  group('Attachment requirements', () {
    late LicenseApplicationController controller;

    setUp(() {
      controller = LicenseApplicationController();
    });

    test(
      'returns the correct required attachments for new individual requests',
      () {
        controller.requestType.value = 'new';
        controller.investorType.value = 'individual';

        final attachments = controller.getRequiredAttachments();

        expect(attachments.map((item) => item.key).toList(), [
          'id_card',
          'land_title',
          'property_map',
        ]);
      },
    );

    test(
      'returns the correct required attachments for new company requests',
      () {
        controller.requestType.value = 'new';
        controller.investorType.value = 'company';

        final attachments = controller.getRequiredAttachments();

        expect(attachments.map((item) => item.key).toList(), [
          'id_card',
          'land_title',
          'property_map',
          'commercial_register',
        ]);
      },
    );

    test(
      'returns the correct required attachments for settlement company requests',
      () {
        controller.requestType.value = 'settlement';
        controller.investorType.value = 'company';

        final attachments = controller.getRequiredAttachments();

        expect(attachments.map((item) => item.key).toList(), [
          'id_card',
          'land_title',
          'property_map',
          'valid_license',
          'lease_contract',
          'commercial_register',
        ]);
      },
    );

    test(
      'returns the correct required attachments for settlement individual requests',
      () {
        controller.requestType.value = 'settlement';
        controller.investorType.value = 'individual';

        final attachments = controller.getRequiredAttachments();

        expect(attachments.map((item) => item.key).toList(), [
          'id_card',
          'land_title',
          'property_map',
          'valid_license',
          'lease_contract',
          'investment_contract',
        ]);
      },
    );
  });
}
