import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_NotificationItem> _items = [
    _NotificationItem(
      title: 'تمت الموافقة على طلبك',
      body: 'تمت مراجعة طلب الترخيص الخاص بك بنجاح ويمكنك متابعة الحالة الآن.',
      time: 'منذ 10 دقائق',
      isRead: false,
    ),
    _NotificationItem(
      title: 'طلبك في انتظار المراجعة',
      body:
          'لا يزال الطلب قيد المراجعة من قبل الإدارة، وسنرسل لك إشعاراً عند التحديث.',
      time: 'منذ 1 ساعة',
      isRead: false,
    ),
    _NotificationItem(
      title: 'تمت إضافة ملاحظات جديدة',
      body:
          'تمت إضافة ملاحظات على الطلب، يمكنك الاطلاع عليها من صفحة التفاصيل.',
      time: 'أمس',
      isRead: true,
    ),
  ];

  int get unreadCount => _items.where((item) => !item.isRead).length;

  void _markAsRead(_NotificationItem item) {
    setState(() {
      final index = _items.indexOf(item);
      if (index >= 0) {
        _items[index] = _items[index].copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var i = 0; i < _items.length; i++) {
        _items[i] = _items[i].copyWith(isRead: true);
      }
    });
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 10.w,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back_ios_new, color: primaryColor),
        ),
        title: Text(
          'الإشعارات',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'تعيين الكل كمقروء',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: primaryColor,
                  fontSize: 12.sp,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: surface,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'عدد الرسائل: ${_items.length}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    color: textSecondary,
                  ),
                ),
                Text(
                  'غير المقروءة: $unreadCount',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: _items.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final item = _items[index];
                return InkWell(
                  onTap: () => _markAsRead(item),
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: item.isRead
                          ? surface
                          : primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 10.w, top: 2.h),
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: item.isRead
                                ? Colors.grey.shade400
                                : AppColors.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.time,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11.sp,
                                      color: textSecondary,
                                    ),
                                  ),
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                item.body,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  color: textSecondary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  item.isRead ? 'مقروءة' : 'غير مقروءة',
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
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
  });

  final String title;
  final String body;
  final String time;
  final bool isRead;

  _NotificationItem copyWith({
    String? title,
    String? body,
    String? time,
    bool? isRead,
  }) {
    return _NotificationItem(
      title: title ?? this.title,
      body: body ?? this.body,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
    );
  }
}
