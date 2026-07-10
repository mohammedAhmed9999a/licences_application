import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_theme.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/license_application_controller.dart';
import '../../controllers/notifications_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/application_model.dart';
import '../../models/license_detail_model.dart';
import '../../routes/app_routes.dart';
import '../widgets/common_widgets.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? selectedStatus;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
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
          Obx(() {
            final settingsCtrl = Get.find<SettingsController>();
            final isDark = settingsCtrl.isDark;
            return IconButton(
              onPressed: () => settingsCtrl.toggleTheme(),
              tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
              icon: ThemedIcon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                type: IconType.appBar,

                customSize: 26.sp,
              ),
              color: isDark ? AppColors.warning : AppColors.warning,
            );
          }),
          // IconButton(
          //   onPressed: () => Get.to(() => const ProfileScreen()),
          //   tooltip: 'البروفايل',
          //   icon: ThemedIcon(
          //     Icons.person_outline,
          //     type: IconType.appBar,
          //     customSize: 26.sp,
          //   ),
          //   color: AppColors.warning,
          // ),
          // Padding(
          //   padding: EdgeInsets.only(left: 4.w, right: 4.w),
          //   child: GestureDetector(
          //     onTap: () => Get.to(() => const NotificationsScreen()),
          //     child: Obx(() {
          //       final notifCtrl = Get.find<NotificationsController>();
          //       final unreadCount = notifCtrl.unreadCount.value;

          //       return Stack(
          //         alignment: Alignment.topRight,
          //         children: [
          //           IconButton(
          //             onPressed: () {
          //               Get.to(() => const NotificationsScreen());
          //             },
          //             tooltip: 'الإشعارات',
          //             icon: ThemedIcon(
          //               Icons.notifications_none_outlined,
          //               type: IconType.appBar,
          //               customSize: 26.sp,
          //             ),
          //             color: AppColors.warning,
          //           ),
          //           if (unreadCount > 0)
          //             Container(
          //               margin: EdgeInsets.only(top: 8.h, right: 8.w),
          //               padding: EdgeInsets.symmetric(
          //                 horizontal: 5.w,
          //                 vertical: 2.h,
          //               ),
          //               decoration: BoxDecoration(
          //                 color: AppColors.warning,
          //                 borderRadius: BorderRadius.circular(10.r),
          //               ),
          //               child: Text(
          //                 unreadCount > 99 ? '99+' : '$unreadCount',
          //                 style: TextStyle(
          //                   color: Colors.white,
          //                   fontSize: 10.sp,
          //                   fontWeight: FontWeight.bold,
          //                   fontFamily: 'Cairo',
          //                 ),
          //               ),
          //             ),
          //         ],
          //       );
          //     }),
          //   ),
          // ),
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
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(context),
          const NotificationsScreen(),
          const ProfileScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surface,
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: GNav(
              gap: 6.w,
              activeColor: onPrimaryColor,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              tabBackgroundColor: primaryColor.withOpacity(0.12),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              duration: const Duration(milliseconds: 250),
              selectedIndex: _currentIndex,
              onTabChange: (index) => setState(() => _currentIndex = index),
              tabs: [
                GButton(
                  icon: Icons.home_outlined,
                  text: 'الرئيسية',
                  iconActiveColor: primaryColor,
                  textColor: primaryColor,
                ),
                GButton(
                  icon: Icons.notifications_outlined,
                  text: 'الإشعارات',
                  iconActiveColor: primaryColor,
                  textColor: primaryColor,
                ),
                GButton(
                  icon: Icons.person_outline,
                  text: 'الملف الشخصي',
                  iconActiveColor: primaryColor,
                  textColor: primaryColor,
                ),
                GButton(
                  icon: Icons.more_horiz,
                  text: 'المزيد',
                  iconActiveColor: primaryColor,
                  textColor: primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    final dashCtrl = Get.find<DashboardController>();
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimaryColor = theme.colorScheme.onPrimary;
    final surface = context.themeSurface;
    final borderColor = context.themeBorder;

    return Stack(
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
                    onPressed: () {
                      final licenseCtrl =
                          Get.find<LicenseApplicationController>();
                      licenseCtrl.resetForm();
                      Get.toNamed(AppRoutes.licenseApplication);
                    },
                    icon: ThemedIcon(
                      Icons.add,
                      type: IconType.button,
                      customSize: 16.sp,
                    ),
                    label: Text('طلب جديد', style: TextStyle(fontSize: 13.sp)),
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
                    icon: ThemedIcon(
                      Icons.list_alt,
                      type: IconType.normal,
                      customSize: 16.sp,
                    ),
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

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 8.h),
                        child: _buildStatsSection(context, dashCtrl),
                      ),
                      if (filteredApplications.isEmpty)
                        _buildEmptyState(context)
                      else
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildApplicationList(
                            context,
                            dashCtrl,
                            filteredApplications,
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ],
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

    return Obx(() {
      final applications = dashCtrl.applications;
      final total = applications.length;
      final statusCounts = <String, int>{};
      final statusLabels = <String, String>{};

      for (final app in applications) {
        final statusKey = _normalizeStatusKey(app.status);
        statusCounts[statusKey] = (statusCounts[statusKey] ?? 0) + 1;
        statusLabels[statusKey] = app.statusLabel;
      }

      final orderedStatusKeys =
          ['approved', 'pending', 'rejected', 'completed', 'draft', 'cancelled']
              .where(statusCounts.containsKey)
              .followedBy(
                statusCounts.keys.where(
                  (key) => !{
                    'approved',
                    'pending',
                    'rejected',
                    'completed',
                    'draft',
                    'cancelled',
                  }.contains(key),
                ),
              )
              .toList();

      final stats = [
        _StatItem(
          label: 'إجمالي',
          value: '$total',
          color: primaryColor,
          statusKey: null,
        ),
        ...orderedStatusKeys.map((statusKey) {
          return _StatItem(
            label: statusLabels[statusKey] ?? statusKey,
            value: '${statusCounts[statusKey]}',
            color: _statusColor(statusKey),
            statusKey: statusKey,
          );
        }),
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
          textDirection: TextDirection.rtl,
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
                final isSelected = selectedStatus == stat.statusKey;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedStatus = isSelected ? null : stat.statusKey;
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
    });
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.vertical -
              kToolbarHeight,
        ),
        child: Center(
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
                  onPressed: () {
                    final licenseCtrl =
                        Get.find<LicenseApplicationController>();
                    licenseCtrl.resetForm();
                    Get.toNamed(AppRoutes.licenseApplication);
                  },
                  icon: ThemedIcon(
                    Icons.add,
                    type: IconType.button,
                    customSize: 18.sp,
                  ),
                  label: const Text('تقديم طلب جديد'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: onPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationList(
    BuildContext context,
    DashboardController dashCtrl,
    List<ApplicationModel> applications,
  ) {
    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onBackground;
    final textSecondary =
        theme.textTheme.bodyMedium?.color ??
        theme.colorScheme.onSurface.withOpacity(0.75);
    final surface = context.themeSurface;
    final borderColor = context.themeBorder;
    final statusBackground = theme.colorScheme.onBackground.withOpacity(0.06);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 18.h),
      child: Column(
        children: List.generate(applications.length, (idx) {
          final app = applications[idx];
          return InkWell(
            onTap: () {
              final detail = LicenseDetailModel.fromApplication(app);
              Get.toNamed(AppRoutes.licenseDetails, arguments: detail);
            },
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              margin: EdgeInsets.only(
                bottom: idx == applications.length - 1 ? 24.h : 12.h,
              ),
              padding: EdgeInsets.all(16.w),
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
                        context,
                        app.requestTypeLabel,
                        backgroundColor: statusBackground,
                        textColor: theme.colorScheme.primary,
                      ),
                      _buildInfoChip(
                        context,
                        app.investorTypeLabel,
                        backgroundColor: statusBackground,
                        textColor: textSecondary,
                      ),
                      if (app.stationCategory?.isNotEmpty == true)
                        _buildInfoChip(
                          context,
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
        }),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
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

  List<ApplicationModel> _getFilteredApplications(
    List<ApplicationModel> applications,
  ) {
    if (selectedStatus == null) {
      return applications;
    }

    return applications
        .where((app) => _normalizeStatusKey(app.status) == selectedStatus)
        .toList();
  }

  String _normalizeStatusKey(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized.isEmpty) return status;

    if (normalized.contains('pending') ||
        normalized.contains('in_review') ||
        normalized.contains('under_review') ||
        normalized.contains('review') ||
        normalized.contains('in progress') ||
        normalized.contains('processing')) {
      return 'pending';
    }

    if (normalized.contains('approved') || normalized.contains('accepted')) {
      return 'approved';
    }

    if (normalized.contains('rejected') || normalized.contains('declined')) {
      return 'rejected';
    }

    if (normalized.contains('draft')) {
      return 'draft';
    }

    if (normalized.contains('additional') ||
        normalized.contains('additional_info') ||
        normalized.contains('additionalinfo') ||
        normalized.contains('correction')) {
      return 'additional_info_required';
    }

    if (normalized.contains('completed') || normalized.contains('finished')) {
      return 'completed';
    }

    if (normalized.contains('canceled') || normalized.contains('cancelled')) {
      return 'cancelled';
    }

    return normalized;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      case 'additional_info_required':
        return AppColors.warning;
      case 'completed':
        return AppColors.statusCompleted;
      case 'draft':
        return AppColors.info;
      case 'cancelled':
        return AppColors.statusCancelled;
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
    this.statusKey,
  });

  final String label;
  final String value;
  final Color color;
  final String? statusKey;
}
