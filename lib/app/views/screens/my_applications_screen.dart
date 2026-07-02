import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/ministry_logo_widget.dart';
import '../../controllers/dashboard_controller.dart';
import '../../models/license_detail_model.dart';
import '../../routes/app_routes.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DashboardController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/splash_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor.withAlpha(248),
        appBar: const MinistryAppBar(title: 'طلباتي'),
        body: Obx(() {
          if (ctrl.isLoading.value) {
            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: 4,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) => const ShimmerLoadingCard(),
            );
          }
          if (ctrl.applications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // textDirection: TextDirection.rtl,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 60.w,
                    color: AppColors.textHint,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'لا توجد طلبات',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: ctrl.applications.length,
            itemBuilder: (ctx, i) {
              final app = ctrl.applications[i];
              final detail = LicenseDetailModel.fromApplication(app);

              return InkWell(
                onTap: () =>
                    Get.toNamed(AppRoutes.licenseDetails, arguments: detail),
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.25)
                            : Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(app.status).withOpacity(0.16),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              app.statusLabel,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11.sp,
                                color: _statusColor(app.status),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            app.applicationNumber,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        detail.stationName,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            app.governorate ?? 'غير محدد',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.location_on_outlined,
                            size: 16.sp,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        // textDirection: TextDirection.rtl,
                        children: [
                          Text(
                            app.createdAt,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.sp,
                              color: isDark
                                  ? AppColors.textHintDark
                                  : AppColors.textHint,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 15.sp,
                            color: AppColors.textHint,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }
}
