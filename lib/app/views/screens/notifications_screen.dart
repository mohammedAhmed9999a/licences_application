import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/notifications_controller.dart';
import '../../models/application_model.dart';
import '../../models/license_detail_model.dart';
import '../../models/notification_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsController _controller =
      Get.find<NotificationsController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.loadNotifications();
    });
  }

  int get unreadCount => _controller.unreadCount.value;

  Future<void> _handleNotificationTap(NotificationModel item) async {
    if (!item.isRead) {
      await _controller.markAsRead(item);
    }

    if (item.canOpenLicenseDetails) {
      if (Get.isRegistered<DashboardController>()) {
        final dashboard = Get.find<DashboardController>();
        ApplicationModel? application;
        try {
          application = dashboard.applications.firstWhere(
            (app) => app.id == item.referenceId,
          );
        } catch (_) {
          application = null;
        }

        if (application != null) {
          final detail = LicenseDetailModel.fromApplication(application);
          Get.toNamed(AppRoutes.licenseDetails, arguments: detail);
          return;
        }
      }

      Get.snackbar(
        'تنبيه',
        'لم يتم العثور على تفاصيل الطلب المرتبطة بهذا الإشعار.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(context).colorScheme.surface,
        colorText: Theme.of(context).colorScheme.onSurface,
      );
      return;
    }

    Get.snackbar(
      'معلومات',
      'تم فتح الإشعار بنجاح.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.surface,
      colorText: Theme.of(context).colorScheme.onSurface,
    );
  }

  String _notificationStatusLabel(NotificationModel item) {
    if (item.canOpenLicenseDetails && Get.isRegistered<DashboardController>()) {
      final dashboard = Get.find<DashboardController>();
      try {
        final application = dashboard.applications.firstWhere(
          (app) => app.id == item.referenceId,
        );
        if (application.statusLabel.isNotEmpty) {
          return application.statusLabel;
        }
      } catch (_) {
        // ignore: no-op
      }
    }
    return item.statusLabelTranslated;
  }

  void _markAllAsRead() {
    _controller.markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = context.themeSurface;
    final borderColor = context.themeBorder;
    final textPrimary = theme.colorScheme.onBackground;
    final textSecondary =
        theme.textTheme.bodyMedium?.color ??
        theme.colorScheme.onSurface.withOpacity(0.75);
    final primaryColor = theme.colorScheme.primary;

    Widget bodyContent = Obx(() {
      if (_controller.isLoading.value) {
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          itemCount: 4,
          itemBuilder: (context, index) =>
              const ShimmerNotificationCard(height: 150),
        );
      }

      if (_controller.errorMessage.isNotEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 52.w, color: primaryColor),
                SizedBox(height: 16.h),
                Text(
                  _controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final items = _controller.notifications;

      return RefreshIndicator(
        onRefresh: _controller.loadNotifications,
        child: ListView(
          padding: EdgeInsets.fromLTRB(10.w, 16.h, 10.w, 24.h),
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      Icons.notifications,
                      color: primaryColor,
                      size: 28.w,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مرحباً بك في صفحة الإشعارات',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'عدد الرسائل: ${items.length} · غير المقروءة: ${_controller.unreadCount}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.sp,
                            height: 1.4,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (_controller.unreadCount > 0)
                    IconButton(
                      onPressed: _markAllAsRead,
                      tooltip: 'تعيين الكل كمقروء',
                      icon: Icon(
                        Icons.done_all_rounded,
                        color: primaryColor,
                        size: 20.sp,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            if (items.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 96.w,
                      color: textSecondary.withOpacity(0.35),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'لا توجد إشعارات حتى الآن.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16.sp,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...items.map((item) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: GestureDetector(
                    onTap: () => _handleNotificationTap(item),
                    child: Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      item.body,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 12.sp,
                                        height: 1.5,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                width: 38.w,
                                height: 38.w,
                                decoration: BoxDecoration(
                                  color: item.isRead
                                      ? primaryColor.withOpacity(0.12)
                                      : primaryColor.withOpacity(0.22),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  item.isRead
                                      ? Icons.mark_email_read_outlined
                                      : Icons.notifications_active_outlined,
                                  color: item.isRead
                                      ? textSecondary
                                      : primaryColor,
                                  size: 20.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.time,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11.sp,
                                    color: textSecondary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: item.isRead
                                      ? primaryColor.withOpacity(0.12)
                                      : primaryColor.withOpacity(0.22),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  item.isRead ? 'مقروءة' : 'جديدة',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11.sp,
                                    color: item.isRead
                                        ? textSecondary
                                        : primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      );
    });

    if (widget.embedded) {
      return SafeArea(child: bodyContent);
    }

    return Scaffold(
      // backgroundColor: theme.brightness == Brightness.dark
      //     ? Theme.of(context).scaffoldBackgroundColor.withAlpha(225)
      //     : Theme.of(context).scaffoldBackgroundColor.withAlpha(240),
      // appBar: AppBar(
      //   backgroundColor: surface.withOpacity(0.95),
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      //   titleSpacing: 10.w,
      //   leading: IconButton(
      //     onPressed: Get.back,
      //     icon: Icon(Icons.arrow_back_ios_new, color: primaryColor),
      //   ),
      //   title: Text(
      //     'الإشعارات',
      //     style: TextStyle(
      //       fontFamily: 'Cairo',
      //       fontSize: 18.sp,
      //       fontWeight: FontWeight.bold,
      //       color: textPrimary,
      //     ),
      //   ),
      // ),
      body: bodyContent,
    );
  }
}
