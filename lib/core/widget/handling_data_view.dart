import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../class/statusrequest.dart';

class HandlingDataView extends StatelessWidget {
  final StatusRequest statusRequest;
  final Widget Function() onSuccess;
  final String? loadingMessage;

  const HandlingDataView({
    super.key,
    required this.statusRequest,
    required this.onSuccess,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    switch (statusRequest) {
      case StatusRequest.loading:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF1B5E3B)),
              if (loadingMessage != null) ...[
                SizedBox(height: 12.h),
                Text(
                  loadingMessage!,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp),
                ),
              ],
            ],
          ),
        );

      case StatusRequest.offlinefailure:
        return _ErrorView(
          icon: Icons.wifi_off_outlined,
          title: 'no_internet'.tr,
          subtitle: 'check_connection'.tr,
          onRetry: null,
        );

      case StatusRequest.serverfailure:
      case StatusRequest.serverException:
        return _ErrorView(
          icon: Icons.cloud_off_outlined,
          title: 'server_error'.tr,
          subtitle: 'try_again_later'.tr,
          onRetry: null,
        );

      case StatusRequest.failure:
        return _ErrorView(
          icon: Icons.error_outline,
          title: 'error'.tr,
          subtitle: 'unexpected_error'.tr,
          onRetry: null,
        );

      case StatusRequest.success:
      case StatusRequest.none:
        return onSuccess();
    }
  }
}

class _ErrorView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  const _ErrorView({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(fontFamily: 'Cairo', color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh),
                label: Text('retry'.tr),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
