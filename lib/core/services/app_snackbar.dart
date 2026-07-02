import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AppSnackbar {
  AppSnackbar._();

  static const Duration _duration = Duration(seconds: 3);

  static void success({String? title, required String message}) => _show(
    title: title ?? 'success'.tr,
    message: message,
    color: const Color(0xff16A34A),
    icon: Icons.check_circle_rounded,
  );

  static void error({String? title, required String message}) => _show(
    title: title ?? 'error'.tr,
    message: message,
    color: const Color(0xffDC2626),
    icon: Icons.error_outline_rounded,
  );

  static void warning({String? title, required String message}) => _show(
    title: title ?? 'warning'.tr,
    message: message,
    color: const Color(0xffF59E0B),
    icon: Icons.warning_amber_rounded,
  );

  static void info({String? title, required String message}) => _show(
    title: title ?? 'info'.tr,
    message: message,
    color: const Color(0xff1B5E3B),
    icon: Icons.info_outline_rounded,
  );

  static void _show({
    required String title,
    required String message,
    required Color color,
    required IconData icon,
  }) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.rawSnackbar(
      snackPosition: SnackPosition.BOTTOM,
      snackStyle: SnackStyle.FLOATING,
      backgroundColor: Colors.transparent,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.zero,
      borderRadius: 18,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      duration: _duration,
      animationDuration: const Duration(milliseconds: 400),
      messageText: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          message,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13.sp,
                            height: 1.3,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    splashRadius: 20,
                    onPressed: Get.closeCurrentSnackbar,
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1, end: 0),
              duration: _duration,
              builder: (_, value, __) => ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18.r),
                  bottomRight: Radius.circular(18.r),
                ),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 4,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
