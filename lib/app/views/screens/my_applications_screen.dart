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
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? Theme.of(context).scaffoldBackgroundColor.withAlpha(225)
            : Theme.of(context).scaffoldBackgroundColor.withAlpha(240),
        appBar: const MinistryAppBar(title: 'طلباتي'),
        body: Obx(() {
          if (ctrl.isLoading.value) {
            return ListView.builder(
              padding: EdgeInsets.all(10.w),
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
            padding: EdgeInsets.all(10.w),
            itemCount: ctrl.applications.length,
            itemBuilder: (ctx, i) {
              final app = ctrl.applications[i];
              final detail = LicenseDetailModel.fromApplication(app);
              final theme = Theme.of(ctx);
              final surface = theme.colorScheme.surface;
              final borderColor = theme.dividerColor;
              final textPrimary = theme.colorScheme.onBackground;
              final textSecondary =
                  theme.textTheme.bodyMedium?.color ??
                  theme.colorScheme.onSurface.withOpacity(0.75);
              final statusBackground = theme.colorScheme.onBackground
                  .withOpacity(0.06);

              return InkWell(
                onTap: () =>
                    Get.toNamed(AppRoutes.licenseDetails, arguments: detail),
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app.applicationNumber.isNotEmpty
                                      ? app.applicationNumber
                                      : 'طلب رقم غير محدد',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  app.displayStationName,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12.sp,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(app.status).withOpacity(0.14),
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
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        alignment: WrapAlignment.start,
                        children: [
                          _buildInfoChip(
                            theme,
                            app.requestTypeLabel,
                            backgroundColor: statusBackground,
                            textColor: theme.colorScheme.primary,
                          ),
                          _buildInfoChip(
                            theme,
                            app.investorTypeLabel,
                            backgroundColor: statusBackground,
                            textColor: textSecondary,
                          ),
                          if (app.stationCategory?.isNotEmpty == true)
                            _buildInfoChip(
                              theme,
                              'الفئة: ${app.stationCategory}',
                              backgroundColor: statusBackground,
                              textColor: textSecondary,
                            ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14.sp,
                            color: textSecondary,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              app.applicantName ?? 'مقدم الطلب غير محدد',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                                color: textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14.sp,
                            color: textSecondary,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              [
                                app.governorate,
                                app.district,
                                app.planningLocation,
                              ].where((e) => e?.isNotEmpty == true).join(' - '),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                                color: textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14.sp,
                            color: textSecondary,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              app.createdAt,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11.sp,
                                color: textSecondary,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: statusBackground,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.attach_file_outlined,
                                  size: 12.sp,
                                  color: textSecondary,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${app.attachments.length} مرفقات',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11.sp,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (app.statusNote.isNotEmpty) ...[
                        SizedBox(height: 14.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(app.status).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Text(
                            app.statusNote,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.sp,
                              color: textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
      case 'completed':
        return AppColors.statusCompleted;
      case 'draft':
        return AppColors.info;
      case 'cancelled':
        return AppColors.statusCancelled;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildInfoChip(
    ThemeData theme,
    String label, {
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
