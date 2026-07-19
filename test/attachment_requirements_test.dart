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
        expect(
          attachments.where((item) => item.key == 'id_card').first.isRequired,
          isTrue,
        );
        expect(
          attachments
              .where((item) => item.key == 'land_title')
              .first
              .isRequired,
          isTrue,
        );
        expect(
          attachments
              .where((item) => item.key == 'property_map')
              .first
              .isRequired,
          isTrue,
        );
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
        expect(
          attachments
              .where((item) => item.key == 'commercial_register')
              .first
              .isRequired,
          isFalse,
        );
        expect(
          attachments.where((item) => item.key == 'id_card').first.title,
          contains('شعار الشركة'),
        );
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
        expect(
          attachments
              .where((item) => item.key == 'lease_contract')
              .first
              .isRequired,
          isFalse,
        );
        expect(
          attachments
              .where((item) => item.key == 'commercial_register')
              .first
              .isRequired,
          isFalse,
        );
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
        expect(
          attachments
              .where((item) => item.key == 'lease_contract')
              .first
              .isRequired,
          isFalse,
        );
        expect(
          attachments
              .where((item) => item.key == 'investment_contract')
              .first
              .isRequired,
          isTrue,
        );
      },
    );
  });
}
