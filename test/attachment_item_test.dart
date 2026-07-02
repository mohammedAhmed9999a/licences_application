// import 'package:flutter_test/flutter_test.dart';
// import 'package:licences_application/app/models/application_model.dart';

// void main() {
//   group('AttachmentItem', () {
//     test('resolves relative image URLs against the base API URL', () {
//       final attachment = AttachmentItem(
//         name: 'image.jpg',
//         url: '/storage/uploads/image.jpg',
//       );

//       expect(
//         attachment.resolveUrl(baseUrl: 'https://example.com/api'),
//         'https://example.com/api/storage/uploads/image.jpg',
//       );
//     });

//     test('keeps absolute URLs unchanged', () {
//       final attachment = AttachmentItem(
//         name: 'image.jpg',
//         url: 'https://example.com/storage/uploads/image.jpg',
//       );

//       expect(
//         attachment.resolveUrl(baseUrl: 'https://example.com/api'),
//         'https://example.com/storage/uploads/image.jpg',
//       );
//     });
//   });
// }
