import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../../core/services/core_api_service.dart';

class NotificationsController extends GetxController {
  static NotificationsController get to => Get.find();

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;

  int get unreadCount =>
      notifications.where((notification) => !notification.isRead).length;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await CoreApiService.get('/v1/notifications');
      final rawData = response.data;
      final payload = rawData is Map
          ? rawData['data'] ?? rawData['notifications'] ?? rawData
          : rawData;

      final items = <NotificationModel>[];
      if (payload is List) {
        for (final item in payload) {
          if (item is Map<String, dynamic>) {
            items.add(NotificationModel.fromJson(item));
          } else if (item is Map) {
            items.add(
              NotificationModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            );
          }
        }
      }

      notifications.value = items;
    } catch (e) {
      errorMessage.value = 'تعذر تحميل الإشعارات. حاول مرة أخرى.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      isSaving.value = true;
      await CoreApiService.post('/v1/notifications/${notification.id}/read');
      final index = notifications.indexWhere((n) => n.id == notification.id);
      if (index >= 0) {
        notifications[index] = notifications[index].copyWith(isRead: true);
      }
    } catch (_) {
      errorMessage.value = 'تعذر تحديث حالة الإشعار. حاول مرة أخرى.';
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> markAllAsRead() async {
    final unread = notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;

    try {
      isSaving.value = true;
      for (final notification in unread) {
        try {
          await CoreApiService.post(
            '/v1/notifications/${notification.id}/read',
          );
        } catch (_) {
          // Ignore individual failures and continue updating the local state
        }
      }
      notifications.value = notifications
          .map((notification) => notification.copyWith(isRead: true))
          .toList();
    } finally {
      isSaving.value = false;
    }
  }
}
