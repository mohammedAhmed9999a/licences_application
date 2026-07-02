import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/controllers/auth_controller.dart';
import 'my_services.dart';

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
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

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

    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen((newToken) async {
          await MyServices.saveFCM(newToken);
          if (Get.isRegistered<AuthController>()) {
            // Update auth controller if needed
          }
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
