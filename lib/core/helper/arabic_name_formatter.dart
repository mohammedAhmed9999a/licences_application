import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ArabicNameFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (RegExp(r'[a-zA-Z]').hasMatch(newValue.text)) {
      Get.snackbar(
        'warning'.tr,
        'arabic_only'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return oldValue;
    }
    return newValue;
  }
}
