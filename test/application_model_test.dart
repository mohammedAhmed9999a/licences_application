import 'package:flutter_test/flutter_test.dart';
import 'package:licences_application/app/models/application_model.dart';

void main() {
  test(
    'detects correction-required applications from status and correction targets',
    () {
      final app = ApplicationModel.fromJson({
        'id': 1,
        'license_request_number': 'LR-1001',
        'status': 'AdditionalInfoRequired',
        'correction_targets': ['phone', 'email'],
        'created_at': '2026-01-01T00:00:00Z',
        'location': {},
        'allowed_category': {},
        'applicantable': {},
        'user': {},
        'attachments': [],
      });

      expect(app.needsCorrection, isTrue);
      expect(app.correctionTargets, contains('phone'));
    },
  );

  test(
    'normalizes Arabic operation_type name to internal requestType values',
    () {
      final settlementApp = ApplicationModel.fromJson({
        'id': 6,
        'license_request_number': 'LR-1006',
        'status': 'Pending',
        'created_at': '2026-01-01T00:00:00Z',
        'location': {},
        'allowed_category': {},
        'applicantable': {},
        'user': {},
        'operation_type': {'id': 2, 'name': 'تسوية'},
      });

      expect(settlementApp.requestType, 'settlement');
      expect(settlementApp.requestTypeLabel, 'تسوية');

      final newApp = ApplicationModel.fromJson({
        'id': 7,
        'license_request_number': 'LR-1007',
        'status': 'Pending',
        'created_at': '2026-01-01T00:00:00Z',
        'location': {},
        'allowed_category': {},
        'applicantable': {},
        'user': {},
        'operation_type': {'id': 1, 'name': 'جديد'},
      });

      expect(newApp.requestType, 'new');
      expect(newApp.requestTypeLabel, 'طلب جديد');
    },
  );

  test('stores attachment document type labels from API payload', () {
    final app = ApplicationModel.fromJson({
      'id': 2,
      'license_request_number': 'LR-1002',
      'status': 'Pending',
      'created_at': '2026-01-01T00:00:00Z',
      'location': {},
      'allowed_category': {},
      'applicantable': {},
      'user': {},
      'attachments': [
        {
          'doc_type': {'name': 'هوية', 'notes': 'بطاقة الهوية'},
          'file_name': 'identity.png',
          'file_path': 'storage/identity.png',
        },
      ],
    });

    expect(app.attachments, hasLength(1));
    expect(app.attachments.first.docTypeName, 'هوية');
    expect(app.attachments.first.displayName, 'هوية');
  });

  test('prefers doc_name when present in attachment payload', () {
    final app = ApplicationModel.fromJson({
      'id': 3,
      'license_request_number': 'LR-1003',
      'status': 'Pending',
      'created_at': '2026-01-01T00:00:00Z',
      'location': {},
      'allowed_category': {},
      'applicantable': {},
      'user': {},
      'attachments': [
        {
          'doc_name': 'بيان قيد عقاري',
          'file_name': 'property.pdf',
          'file_path': 'storage/property.pdf',
        },
      ],
    });

    expect(app.attachments.first.displayName, 'بيان قيد عقاري');
    expect(app.attachments.first.docTypeName, 'بيان قيد عقاري');
  });

  test('reads attachment name from nested doc_type map', () {
    final app = ApplicationModel.fromJson({
      'id': 4,
      'license_request_number': 'LR-1004',
      'status': 'Pending',
      'created_at': '2026-01-01T00:00:00Z',
      'location': {},
      'allowed_category': {},
      'applicantable': {},
      'user': {},
      'attachments': [
        <String, Object?>{
          'doc_type': <String, Object?>{
            'id': 2,
            'name': 'بيان قيد عقاري',
            'notes': 'بيان قيد عقاري',
          },
          'file_name': 'property.pdf',
          'file_path': 'storage/property.pdf',
        },
      ],
    });

    expect(app.attachments.first.displayName, 'بيان قيد عقاري');
    expect(app.attachments.first.docTypeName, 'بيان قيد عقاري');
  });

  test('uses doc_type name as the attachment name instead of file_name', () {
    final app = ApplicationModel.fromJson({
      'id': 5,
      'license_request_number': 'LR-1005',
      'status': 'Pending',
      'created_at': '2026-01-01T00:00:00Z',
      'location': {},
      'allowed_category': {},
      'applicantable': {},
      'user': {},
      'attachments': [
        {
          'doc_type': {'name': 'هوية'},
          'file_name': 'identity.png',
          'file_path': 'storage/identity.png',
        },
      ],
    });

    expect(app.attachments.first.name, 'هوية');
    expect(app.attachments.first.fileName, 'هوية');
  });
}
