import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:licences_application/app/views/widgets/step_indicator_widget.dart';

void main() {
  testWidgets('future steps do not trigger callback', (tester) async {
    int? tappedStep;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StepIndicatorWidget(
            currentStep: 0,
            onStepTapped: (index) => tappedStep = index,
          ),
        ),
      ),
    );

    await tester.tap(find.text('بيانات الترخيص'));
    await tester.pump();

    expect(tappedStep, isNull);
  });

  testWidgets('current step still triggers callback', (tester) async {
    int? tappedStep;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StepIndicatorWidget(
            currentStep: 0,
            onStepTapped: (index) => tappedStep = index,
          ),
        ),
      ),
    );

    await tester.tap(find.text('الشروط والتواصل'));
    await tester.pump();

    expect(tappedStep, 0);
  });
}
