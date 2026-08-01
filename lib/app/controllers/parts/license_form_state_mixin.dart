import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../license_application_controller.dart';

mixin LicenseFormStateMixin on GetxController {
  LicenseApplicationController get controller =>
      Get.find<LicenseApplicationController>();

  void goToNextStep() {
    if (controller.currentStep.value < 3) {
      controller.currentStep.value++;
    }
  }

  void goToPreviousStep() {
    if (controller.currentStep.value > 0) {
      controller.currentStep.value--;
    }
  }

  void requestFocus(FocusNode nextFocus) {
    FocusScope.of(Get.context!).requestFocus(nextFocus);
  }
}
