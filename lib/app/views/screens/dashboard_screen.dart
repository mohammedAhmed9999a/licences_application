import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_theme.dart';
import '../../controllers/dashboard_controller.dart';
import '../../models/license_detail_model.dart';
import '../../routes/app_routes.dart';
import '../widgets/common_widgets.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? selectedStatus;

  @override
  Widget build(BuildContext context) {
    final dashCtrl = Get.find<DashboardController>();
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimaryColor = theme.colorScheme.onPrimary;
    final surface = context.themeSurface;
    final borderColor = context.themeBorder;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1.h, color: borderColor),
        ),
        titleSpacing: 10.w,
        // leading: Padding(
        //   padding: EdgeInsets.only(left: 8.w, right: 4.w),
        //   child: GestureDetector(
        //     onTap: () => Get.to(() => const ProfileScreen()),
        //     child: Container(
        //       width: 36.w,
        //       height: 36.h,
        //       decoration: BoxDecoration(
        //         color: primaryColor,
        //         shape: BoxShape.circle,
        //       ),
        //       child: Center(
        //         child: Text(
        //           authCtrl.userName.isNotEmpty
        //               ? authCtrl.userName[0].toUpperCase()
        //               : 'م',
        //           style: TextStyle(
        //             color: onPrimaryColor,
        //             fontFamily: 'Cairo',
        //             fontWeight: FontWeight.bold,
        //             fontSize: 16.sp,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const ProfileScreen()),
            tooltip: 'البروفايل',
            icon: Icon(Icons.person, color: primaryColor, size: 30.sp),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8.w, right: 8.w),
            child: GestureDetector(
              onTap: () => Get.to(() => const NotificationsScreen()),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    onPressed: () {},
                    // onPressed: () => Get.to(() => const NotificationsScreen()),
                    // onPressed: () => _showNotificationsSheet(context),
                    tooltip: 'الإشعارات',
                    icon: Icon(
                      Icons.notifications_none_outlined,
                      color: primaryColor,
                      size: 30.sp,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8.h, right: 8.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        title: Container(
          alignment: Alignment.centerRight,
          child: Shimmer.fromColors(
            baseColor: AppColors.gold.withOpacity(0.6),
            highlightColor: Colors.white,
            period: const Duration(seconds: 2),
            child: Container(
              width: 180.w,
              height: 40.h,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/h-logo.webp'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/splash_background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    surface,
                    surface.withOpacity(0.58),
                    surface.withOpacity(0.28),
                    // Colors.white.withOpacity(0.92),
                    // Colors.white.withOpacity(0.28),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                color: surface,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () =>
                          Get.toNamed(AppRoutes.licenseApplication),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(
                        'طلب جديد',
                        style: TextStyle(fontSize: 13.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: onPrimaryColor,
                        minimumSize: const Size(120, 38),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    OutlinedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.myApplications),
                      icon: const Icon(Icons.list_alt, size: 16),
                      label: Text('طلباتي', style: TextStyle(fontSize: 13.sp)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: borderColor),
                        minimumSize: const Size(100, 38),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                child: _buildStatsSection(context, dashCtrl),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: dashCtrl.loadApplications,
                  color: primaryColor,
                  child: Obx(() {
                    if (dashCtrl.isLoading.value) {
                      return _buildDashboardLoading(context);
                    }
                    final filteredApplications = _getFilteredApplications(
                      dashCtrl.applications,
                    );

                    if (filteredApplications.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    return _buildApplicationList(
                      context,
                      dashCtrl,
                      filteredApplications,
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    DashboardController dashCtrl,
  ) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final surface = context.themeSurface;
    final borderColor = context.themeBorder;
    final textPrimary = theme.colorScheme.onBackground;
    final textSecondary =
        theme.textTheme.bodyMedium?.color ??
        theme.colorScheme.onSurface.withOpacity(0.75);

    final total = dashCtrl.applications.length;
    final approved = dashCtrl.applications
        .where((app) => app.status == 'approved')
        .length;
    final pending = dashCtrl.applications
        .where((app) => app.status == 'pending')
        .length;
    final rejected = dashCtrl.applications
        .where((app) => app.status == 'rejected')
        .length;

    final stats = [
      _StatItem(label: 'إجمالي', value: '$total', color: primaryColor),
      _StatItem(label: 'مقبولة', value: '$approved', color: AppColors.success),
      _StatItem(
        label: 'قيد المراجعة',
        value: '$pending',
        color: AppColors.warning,
      ),
      _StatItem(label: 'مرفوضة', value: '$rejected', color: AppColors.error),
    ];

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إحصائيات الطلبات',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 1.7,
            ),
            itemBuilder: (context, index) {
              final stat = stats[index];
              final isSelected =
                  selectedStatus == _statusKeyForLabel(stat.label);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedStatus = isSelected
                        ? null
                        : _statusKeyForLabel(stat.label);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? stat.color.withOpacity(0.2)
                        : stat.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected ? stat.color : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        stat.value,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: stat.color,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        stat.label,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.sp,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardLoading(BuildContext context) {
    final surface = context.themeSurface;
    final borderColor = context.themeBorder;
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerPlaceholder(height: 18, width: 140, borderRadius: 12),
              SizedBox(height: 14.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: List.generate(
                  4,
                  (index) => Container(
                    width: (MediaQuery.of(context).size.width - 80.w) / 2,
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ShimmerPlaceholder(
                          height: 20,
                          width: 50,
                          borderRadius: 10,
                        ),
                        SizedBox(height: 8.h),
                        ShimmerPlaceholder(
                          height: 12,
                          width: 40,
                          borderRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 18.h),
        const ShimmerLoadingCard(height: 140),
        const ShimmerLoadingCard(height: 140),
        const ShimmerLoadingCard(height: 140),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimaryColor = theme.colorScheme.onPrimary;
    final textPrimary = theme.colorScheme.onBackground;
    final textSecondary =
        theme.textTheme.bodyMedium?.color ??
        theme.colorScheme.onSurface.withOpacity(0.75);
    final hintColor = context.themeTextHint;
    final surfaceAlt = context.themeSurfaceAlt;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_outlined,
                size: 36,
                color: hintColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد طلبات بعد',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'قدم طلبا جديدا لترخيص محطة وقود',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                color: textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.licenseApplication),
              icon: const Icon(Icons.add),
              label: const Text('تقديم طلب جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: onPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationList(
    BuildContext context,
    DashboardController dashCtrl,
    List<dynamic> applications,
  ) {
    final textPrimary = Theme.of(context).colorScheme.onBackground;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ??
        Theme.of(context).colorScheme.onSurface.withOpacity(0.75);
    final surface = context.themeSurface;
    final borderColor = context.themeBorder;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: applications.length,
      itemBuilder: (ctx, i) {
        final app = applications[i];
        return InkWell(
          onTap: () {
            final detail = LicenseDetailModel.fromApplication(app);
            Get.toNamed(AppRoutes.licenseDetails, arguments: detail);
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.applicationNumber,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            app.stationCategory?.isNotEmpty == true
                                ? app.stationCategory!
                                : app.requestTypeLabel,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              color: textSecondary,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(app.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        app.statusLabel,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.sp,
                          color: _statusColor(app.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        app.requestTypeLabel,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          color: textSecondary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        app.investorTypeLabel,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          color: textSecondary,
                        ),
                        textAlign: TextAlign.right,
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
                    Text(
                      app.governorate ?? 'غير محدد',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        color: textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14.sp,
                      color: textSecondary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      app.createdAt,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<dynamic> _getFilteredApplications(List<dynamic> applications) {
    if (selectedStatus == null) {
      return applications;
    }

    return applications.where((app) => app.status == selectedStatus).toList();
  }

  String? _statusKeyForLabel(String label) {
    switch (label) {
      case 'مقبولة':
        return 'approved';
      case 'مرفوضة':
        return 'rejected';
      case 'قيد المراجعة':
        return 'pending';
      default:
        return null;
    }
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
        return Theme.of(Get.context!).textTheme.bodyMedium?.color ??
            Theme.of(Get.context!).colorScheme.onSurface.withOpacity(0.75);
    }
  }
}

class _StatItem {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;
}
