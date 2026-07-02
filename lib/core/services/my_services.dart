import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyServices extends GetxService {
  static const _fcmKey = 'fcm';
  static const _sentFcmKey = 'sent_fcm';

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  static Future<String> getFCM() async =>
      (await _prefs).getString(_fcmKey) ?? '';

  static Future<void> saveFCM(String fcm) async =>
      (await _prefs).setString(_fcmKey, fcm);

  static Future<String> getSentFCM() async =>
      (await _prefs).getString(_sentFcmKey) ?? '';

  static Future<void> saveSentFCM(String fcm) async =>
      (await _prefs).setString(_sentFcmKey, fcm);

  static Future<void> clearFCM() async {
    final p = await _prefs;
    await p.remove(_fcmKey);
    await p.remove(_sentFcmKey);
  }

  /// Debug helper: print current stored FCM token (if any)
  static Future<void> printFCM() async {
    final token = await getFCM();
    // ignore: avoid_print
    print('MyServices: FCM token = "$token"');
  }
}
