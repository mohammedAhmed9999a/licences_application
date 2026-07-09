import 'package:dio/dio.dart' as dio;
import 'package:flutter_test/flutter_test.dart';
import 'package:licences_application/app/controllers/license_application_controller.dart';

void main() {
  group('License application submission errors', () {
    test('extracts the server message from a 422 response', () {
      final controller = LicenseApplicationController();
      final exception = dio.DioException(
        requestOptions: dio.RequestOptions(path: '/test'),
        response: dio.Response(
          requestOptions: dio.RequestOptions(path: '/test'),
          statusCode: 422,
          data: {
            'message': 'تاريخ ترخيص الشركة يجب أن يكون قبل اليوم.',
            'errors': {
              'applicant.company_license_date': [
                'تاريخ ترخيص الشركة يجب أن يكون قبل اليوم.',
              ],
            },
          },
        ),
        type: dio.DioExceptionType.badResponse,
      );

      expect(
        controller.extractSubmissionErrorMessage(exception),
        'تاريخ ترخيص الشركة يجب أن يكون قبل اليوم.',
      );
    });

    test(
      'falls back to the generic message when the payload is not structured',
      () {
        final controller = LicenseApplicationController();
        final exception = dio.DioException(
          requestOptions: dio.RequestOptions(path: '/test'),
          response: dio.Response(
            requestOptions: dio.RequestOptions(path: '/test'),
            statusCode: 500,
            data: {'message': 'Server exploded'},
          ),
          type: dio.DioExceptionType.badResponse,
        );

        expect(
          controller.extractSubmissionErrorMessage(exception),
          'Server exploded',
        );
      },
    );
  });
}
