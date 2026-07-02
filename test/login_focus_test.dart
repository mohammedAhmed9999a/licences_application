import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:licences_application/app/views/widgets/common_widgets.dart';

void main() {
  testWidgets('RtlTextField supports focus navigation via input action', (
    WidgetTester tester,
  ) async {
    final focusNode = FocusNode();
    final controller = TextEditingController();

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: RtlTextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    focusNode.requestFocus();
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);
  });
}
