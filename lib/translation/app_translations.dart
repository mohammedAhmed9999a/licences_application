import 'package:get/get.dart';
import 'ar.dart';
import 'en.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ar_SY': arStrings,
        'ar_AR': arStrings,
        'en_US': enStrings,
        'en_GB': enStrings,
      };
}
