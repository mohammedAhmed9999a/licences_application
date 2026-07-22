// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:licences_application/app/views/screens/license/steps/step3_location_screen.dart';

// void main() {
//   testWidgets('StableDropdownField shows selected value and updates on tap', (
//     tester,
//   ) async {
//     String? selected;

//     await tester.pumpWidget(
//       MaterialApp(
//         home: Scaffold(
//           body: StableDropdownField(
//             hint: 'اختر المحافظة',
//             value: 'دمشق',
//             items: const ['دمشق', 'حلب'],
//             onChanged: (value) => selected = value,
//           ),
//         ),
//       ),
//     );

//     expect(find.text('دمشق'), findsOneWidget);

//     await tester.tap(find.byType(StableDropdownField));
//     await tester.pumpAndSettle();

//     expect(find.text('حلب'), findsOneWidget);

//     await tester.tap(find.text('حلب'));
//     await tester.pumpAndSettle();

//     expect(selected, 'حلب');
//     expect(find.text('حلب'), findsOneWidget);
//   });
// }
