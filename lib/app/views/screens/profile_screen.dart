import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constant/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/common_widgets.dart';
import '../widgets/ministry_logo_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    authCtrl.loadProfile();
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final primaryGradientEnd = primaryColor.withOpacity(
      theme.brightness == Brightness.dark ? 0.95 : 0.8,
    );
    final surface = theme.colorScheme.surface;
    final borderColor = theme.dividerColor;
    final isDark = Get.isDarkMode;
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
            : Theme.of(context).scaffoldBackgroundColor.withAlpha(180),

        // appBar: AppBar(title: Text("الملف الشخصي ",)),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.w),
          child: Directionality(
            textDirection:
                TextDirection.ltr, // Force LTR for layout consistency
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.png'),
                      opacity: 0.1,
                      fit: BoxFit.cover,
                    ),
                    // color: Theme.of(
                    //   context,
                    // ).scaffoldBackgroundColor.withAlpha(125),
                    gradient: LinearGradient(
                      colors: [AppColors.forest1, AppColors.forest1],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textDirection: TextDirection.rtl,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الملف الشخصي',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: onPrimary,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              authCtrl.userName.isNotEmpty
                                  ? authCtrl.userName
                                  : 'مستخدم',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: onPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              authCtrl.userEmail.isNotEmpty
                                  ? authCtrl.userEmail
                                  : 'user@example.com',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                                color: onPrimary.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      CircleAvatar(
                        radius: 30.r,
                        backgroundColor: Colors.white,
                        child: Text(
                          authCtrl.userName.isNotEmpty
                              ? authCtrl.userName[0].toUpperCase()
                              : 'م',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Obx(() {
                  if (authCtrl.isProfileLoading.value) {
                    return Column(
                      children: const [ShimmerLoadingCard(height: 180)],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'معلومات الحساب',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (authCtrl.profileError.value.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 10.h),
                          child: Text(
                            authCtrl.profileError.value,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
                SizedBox(height: 12.h),
                _InfoCard(
                  icon: Icons.person_outline,
                  title: 'الاسم الكامل',
                  value: authCtrl.userName.isNotEmpty
                      ? authCtrl.userName
                      : 'غير متوفر',
                ),
                SizedBox(height: 10.h),
                _InfoCard(
                  icon: Icons.email_outlined,
                  title: 'البريد الإلكتروني',
                  value: authCtrl.userEmail.isNotEmpty
                      ? authCtrl.userEmail
                      : 'غير متوفر',
                ),
                SizedBox(height: 10.h),
                _InfoCard(
                  icon: Icons.badge_outlined,
                  title: 'نوع الحساب',
                  value: 'مستخدم مسجل',
                ),
                SizedBox(height: 24.h),
                Text(
                  'الإجراءات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 12.h),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        // _ActionTile(
                        //   icon: Icons.settings_outlined,
                        //   title: 'الإعدادات',
                        //   subtitle: 'تغيير اللغة والمظهر',
                        //   onTap: () => Get.toNamed(AppRoutes.settings),
                        // ),
                        // Divider(height: 1.h, color: borderColor),
                        _ActionTile(
                          icon: Icons.lock_outline,
                          title: 'الأمان',
                          subtitle: 'تحديث كلمة المرور',
                          onTap: () {},
                        ),
                        Divider(height: 1.h, color: borderColor),
                        _ActionTile(
                          icon: Icons.logout_outlined,
                          title: 'تسجيل الخروج',
                          subtitle: 'الخروج من الحساب الحالي',
                          onTap: () => _showLogoutDialog(context, authCtrl),
                          danger: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(
    BuildContext context,
    AuthController authCtrl,
  ) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: const Text('تسجيل الخروج', textAlign: TextAlign.right),
            content: const Text(
              'هل تريد تسجيل الخروج من الحساب؟',
              textAlign: TextAlign.right,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  authCtrl.logout();
                },
                child: const Text('تأكيد'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  _InfoCard({required this.icon, required this.title, required this.value});
  final bool isDark = Get.isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Icon(icon, color: AppColors.primary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: danger ? AppColors.error : AppColors.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: danger
                ? AppColors.error
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp),
        ),
        trailing: const Icon(
          Icons.arrow_back_ios_new_rounded,
          textDirection: TextDirection.ltr,
          size: 16,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      ),
    );
  }
}
