import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:licences_application/app/controllers/dashboard_controller.dart';
import 'package:licences_application/app/models/application_model.dart';
import 'package:licences_application/app/models/license_detail_model.dart';
import 'package:licences_application/app/routes/app_routes.dart';
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
        debugPrint('Local notification tapped: payload=${details.payload}');
        if (details.payload != null) {
          final id = int.tryParse(details.payload!);
          if (id != null) {
            _handleNotificationPayload(id);
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
    debugPrint('Showing notification. data=${message.data}');
    debugPrint(
      'Notification title=${message.notification?.title} body=${message.notification?.body}',
    );
    // Prefer admin_message from data if provided
    final adminMessage = message.data['admin_message']?.toString();
    final bodyText = adminMessage ?? message.notification?.body ?? '';
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
        icon: 'ic_notification',
        channelShowBadge: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final applicationId = _extractNotificationId(message);
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? '',
      bodyText,
      details,
      payload: applicationId,
    );
  }

  static String? _extractNotificationId(RemoteMessage message) {
    return message.data['application_id']?.toString().trim() ??
        message.data['complaint_id']?.toString().trim() ??
        message.data['reference_id']?.toString().trim() ??
        message.data['id']?.toString().trim();
  }

  static Future<ApplicationModel?> _findApplicationById(
    String applicationId,
  ) async {
    if (Get.isRegistered<DashboardController>()) {
      final dashboard = Get.find<DashboardController>();
      try {
        return dashboard.applications.firstWhere(
          (app) => app.id == applicationId,
        );
      } catch (_) {
        // ignore: no-op
      }
    }

    try {
      final response = await CoreApiService.get(
        '/v1/license-applications/$applicationId',
      );
      final data = response.data is Map<String, dynamic>
          ? (response.data['data'] ?? response.data)
          : response.data;
      if (data is Map<String, dynamic>) {
        return ApplicationModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Failed to load application $applicationId: $e');
    }
    return null;
  }

  static Future<void> _navigateToComplaintId(int id) async {
    final box = GetStorage();
    final applicationId = id.toString();
    final application = await _findApplicationById(applicationId);
    if (application != null) {
      final detail = LicenseDetailModel.fromApplication(application);
      debugPrint(
        'Navigating to license details for application_id=$applicationId',
      );
      Get.toNamed(AppRoutes.licenseDetails, arguments: detail);
      await box.remove('pending_notification_id');
      return;
    }
    debugPrint(
      'Application not found for notification id=$applicationId, storing pending id',
    );
    await box.write('pending_notification_id', id);
  }

  static Future<void> _handleNotificationPayload(int id) async {
    debugPrint('Handling notification payload for id=$id');
    await _navigateToComplaintId(id);
  }

  static Future<void> processPendingNotification() async {
    final box = GetStorage();
    final storedId = box.read('pending_notification_id');
    if (storedId == null) return;
    final id = int.tryParse(storedId.toString());
    if (id == null) return;
    await _navigateToComplaintId(id);
  }

  static void firebaseInit() {
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('FCM onMessage received: data=${message.data}');
      debugPrint(
        'FCM onMessage notification: title=${message.notification?.title} body=${message.notification?.body}',
      );
      // Refresh applications when an app-related notification arrives.
      final notificationId = _extractNotificationId(message);
      if (notificationId != null && notificationId.isNotEmpty) {
        _refreshDashboardApplications();
      }
      // Show a local notification on all platforms (foreground)
      showNotification(message);
    });
  }

  static Future<void> _refreshDashboardApplications() async {
    try {
      if (Get.isRegistered<DashboardController>()) {
        final dashboard = Get.find<DashboardController>();
        await dashboard.loadApplications();
      } else {
        debugPrint('DashboardController not registered; skipping refresh.');
      }
    } catch (e) {
      debugPrint('Failed to refresh dashboard applications: $e');
    }
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
    debugPrint('FCM handleMessage: data=${message.data}');
    final box = GetStorage();
    final idString = _extractNotificationId(message);
    final idNotification = int.tryParse(idString ?? '') ?? 0;
    if (idNotification > 0) {
      await box.write('pending_notification_id', idNotification);
      debugPrint('Opening license details for notification id=$idNotification');
      await _navigateToComplaintId(idNotification);
    } else {
      debugPrint(
        'No valid notification id found in payload. keys: ${message.data.keys.toList()}',
      );
    }
  }
}
