import 'package:get/get.dart';

enum InputType { name, address, email, phone, password, nationalId }

bool isValidSyrianPhone(String value) {
  String cleaned = value.replaceAll(RegExp(r'\D'), '');
  if (cleaned.startsWith('963')) cleaned = cleaned.substring(3);
  if (cleaned.startsWith('0')) cleaned = cleaned.substring(1);
  return RegExp(r'^9\d{8}$').hasMatch(cleaned);
}

String? validatePasswordStrength(String value) {
  if (value.length < 8) return 'password_min'.tr;
  if (!RegExp(r'\d').hasMatch(value)) return 'password_number'.tr;
  return null;
}

String? validatePasswordStrengthStrong(String value) {
  if (value.length < 8) return 'password_min'.tr;
  if (!RegExp(r'[A-Z]').hasMatch(value)) return 'password_uppercase'.tr;
  if (!RegExp(r'[a-z]').hasMatch(value)) return 'password_lowercase'.tr;
  if (!RegExp(r'\d').hasMatch(value)) return 'password_number'.tr;
  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\[\]\\\/+=~`]').hasMatch(value)) {
    return 'password_special_char'.tr;
  }
  return null;
}

String? validateInput(
  String? value,
  InputType type, {
  int? min,
  int? max,
  bool strongPassword = false,
}) {
  if (value == null || value.trim().isEmpty) return 'field_empty'.tr;
  final val = value.trim();

  switch (type) {
    case InputType.name:
      final nameRegex = RegExp(r'^[\u0600-\u06FF\s]+$');
      if (!nameRegex.hasMatch(val)) return 'name_arabic_only'.tr;
      if (val.length < 2) return 'name_min'.tr;
      if (val.length > 50) return 'name_max'.tr;
      break;

    case InputType.address:
      final addrRegex = RegExp(r'^[\u0600-\u06FFa-zA-Z0-9\s\-]+$');
      if (!addrRegex.hasMatch(val)) return 'address_invalid'.tr;
      break;

    case InputType.email:
      if (!GetUtils.isEmail(val)) return 'email_invalid'.tr;
      break;

    case InputType.phone:
      final cleaned = val.replaceAll(RegExp(r'\D'), '');
      if (cleaned.length == 1 && cleaned[0] != '9') {
        return 'phone_must_start_with_9'.tr;
      }
      if (!isValidSyrianPhone(val)) return 'phone_invalid'.tr;
      break;

    case InputType.password:
      final err = strongPassword
          ? validatePasswordStrengthStrong(val)
          : validatePasswordStrength(val);
      if (err != null) return err;
      break;

    case InputType.nationalId:
      if (!RegExp(r'^\d+$').hasMatch(val)) return 'numbers_only'.tr;
      if (val.length < 8 || val.length > 11) return 'national_id_length'.tr;
      break;
  }

  if (min != null && val.length < min) {
    return 'min_length'.trParams({'min': '$min'});
  }
  if (max != null && val.length > max) {
    return 'max_length'.trParams({'max': '$max'});
  }
  return null;
}
