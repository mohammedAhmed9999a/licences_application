import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:licences_application/app/services/storage_service.dart';
import 'package:licences_application/core/services/core_api_service.dart';
import 'package:licences_application/core/services/my_services.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse details) {
  final id = int.tryParse(details.payload ?? '');

  if (id != null) {
    GetStorage().write('pending_notification_id', id);
  }
}

class NotificationServices {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static const String _channelId = 'sawt_complaints_channel';
  static const String _channelName = 'Complaints Notifications';

  static Future<void> requestNotificationPermission() async {
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          final id = int.tryParse(details.payload!);
          if (id != null) {
            // Handle notification tap - update with your screen navigation
            // Get.to(() => LicenseDetailsScreen(licenseId: id));
          }
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    firebaseInit();
    setupInteractWhenAppNotOpen();

    await getDeviceToken();
    await syncFcmTokenWithServer();

    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen((newToken) async {
          await MyServices.saveFCM(newToken);
          await syncFcmTokenWithServer();
        });
  }

  static Future<String> getDeviceToken() async {
    final token = await messaging.getToken();
    if (token == null) return '';

    final oldToken = await MyServices.getFCM();
    if (oldToken != token) {
      await MyServices.saveFCM(token);
    }
    return token;
  }

  static Future<void> syncFcmTokenWithServer({bool forceSend = false}) async {
    final token = await getDeviceToken();
    debugPrint(
      'syncFcmTokenWithServer called: token=$token forceSend=$forceSend',
    );
    if (token.isEmpty) {
      debugPrint('syncFcmTokenWithServer: token is empty, aborting');
      return;
    }

    final sentToken = await MyServices.getSentFCM();
    debugPrint('syncFcmTokenWithServer: sentToken=$sentToken');
    if (sentToken == token && !forceSend) {
      debugPrint(
        'syncFcmTokenWithServer: token already sent and forceSend=false, aborting',
      );
      return;
    }

    if (!Get.isRegistered<StorageService>()) {
      Get.put(StorageService(), permanent: true);
    }

    if (!StorageService.to.isLoggedIn) {
      debugPrint('syncFcmTokenWithServer: user not logged in, aborting');
      return;
    }

    try {
      debugPrint('Sending FCM token to server: $token (forceSend=$forceSend)');
      await CoreApiService.post(
        '/v1/user/fcm-token',
        data: {'fcm_token': token, 'device': _getDeviceType()},
      );
      await MyServices.saveSentFCM(token);
      debugPrint('FCM token successfully sent and marked as sent');
    } catch (e) {
      debugPrint('FCM sync failed: $e');
      debugPrint(
        'FCM sync payload: fcm_token=$token device=${_getDeviceType()}',
      );
    }
  }

  static String _getDeviceType() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'web';
  }

  static Future<void> showNotification(RemoteMessage message) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        channelShowBadge: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final complaintId = message.data['complaint_id'];

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      details,
      payload: complaintId?.toString(),
    );
  }

  static void firebaseInit() {
    FirebaseMessaging.onMessage.listen((message) {
      if (Platform.isAndroid) {
        showNotification(message);
      }
    });
  }

  static Future<void> setupInteractWhenAppNotOpen() async {
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleMessage(initialMessage);
    }
  }

  static Future<void> checkInitialNotification() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();

    if (message != null) {
      handleMessage(message);
    }
  }

  static void handleMessage(RemoteMessage message) async {
    int idNotification = 0;
    final box = GetStorage();
    idNotification = int.tryParse(message.data['complaint_id']) ?? 0;
    await box.write('pending_notification_id', idNotification);
    final complaintIdStr = message.data['complaint_id'];
    if (complaintIdStr != null) {
      final id = int.tryParse(complaintIdStr.toString());
      if (id != null) {
        // Handle notification - update with your screen navigation
        // Get.to(() => LicenseDetailsScreen(licenseId: id));
      }
    }
  }
}
