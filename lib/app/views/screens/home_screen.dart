import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:licences_application/core/services/video_player.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../controllers/settings_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();
    final isDark = settingsCtrl.isDark;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        // backgroundColor: Colors.black,
        backgroundColor: isDark
            ? Theme.of(context).scaffoldBackgroundColor.withAlpha(225)
            : Theme.of(context).scaffoldBackgroundColor.withAlpha(240),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: Theme.of(context).colorScheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Obx(
                        () => IconButton(
                          onPressed: settingsCtrl.toggleTheme,
                          icon: Icon(
                            settingsCtrl.isDark
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color ??
                                Theme.of(context).colorScheme.onSurface,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(height: 10.h),
                  // Ministry Logo & Welcome
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        Container(
                          width: 300.w,
                          height: 80.h,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/h-logo.webp'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        // Shimmer.fromColors(
                        //   baseColor: AppColors.gold.withOpacity(0.6),
                        //   highlightColor: Colors.white,
                        //   period: const Duration(seconds: 2),
                        //   child: Container(
                        //     width: 300.w,
                        //     height: 80.h,
                        //     decoration: const BoxDecoration(
                        //       image: DecorationImage(
                        //         image: AssetImage('assets/images/h-logo.webp'),
                        //         fit: BoxFit.contain,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // const MinistryLogoWidget(size: 72),
                        SizedBox(height: 28.h),
                        Text(
                          'مرحباً بكم في وزارة الطاقة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(
                                  context,
                                ).textTheme.displayMedium?.color ??
                                Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'بوابة خدمات الطاقة الإلكترونية لتقديم طلبات تراخيص محطاتات الوقود\nومتابعة إجراءاتها بشكل آمن وسهل.',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color ??
                                Theme.of(context).colorScheme.onSurface,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Auth Cards Column
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Login Card
                        _AuthCard(
                          question: 'لديك حساب في بوابة خدمات الطاقة؟',
                          description:
                              'سجّل دخولك باستخدام البريد الإلكتروني وكلمة المرور للمتابعة إلى طلباتك.',
                          buttonText: 'تسجيل الدخول',
                          buttonFilled: true,
                          onPressed: () => Get.toNamed(AppRoutes.login),
                          icon: Icons.person,
                        ),
                        SizedBox(height: 12.h),
                        // Signup Card
                        _AuthCard(
                          question: 'ليس لديك حساب؟',
                          description:
                              'أنشئ حساباً جديداً، فعل ببريدك الإلكتروني، ثم ابدأ بتقديم طلب الترخيص.',
                          buttonText: 'إنشاء حساب',
                          buttonFilled: false,
                          onPressed: () => Get.toNamed(AppRoutes.signup),
                          icon: Icons.person_add_outlined,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Usage Guide Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        // Label
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'دليل الاستخدام',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          'لا تعرف من أين تبدأ؟',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(
                                  context,
                                ).textTheme.displayMedium?.color ??
                                Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'شاهد هذا الفيديو لمعرفة طريقة إنشاء حساب ، تسجيل الدخول ، وتقديم طلب ترخيص محطة وقود خطوة بخطوة.',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color ??
                                Theme.of(context).colorScheme.onSurface,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.h),

                        // Video placeholder
                        Container(
                          height: 220.h,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 0.5,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Thumbnail overlay
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  color: Theme.of(context).colorScheme.surface,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'الفيديو التوضيحي لشرح آلية التقدم بطلب الحصول على رخصة',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            color:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium?.color ??
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                            fontSize: 13.sp,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          'وزارة الطاقة السورية',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            color:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodySmall?.color ??
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Play button
                              const TutorialVideo(),
                              // GestureDetector(
                              //   onTap: () {
                              //     // Launch YouTube video
                              //   },
                              //   child: Container(
                              //     width: 60.w,
                              //     height: 60.h,
                              //     decoration: BoxDecoration(
                              //       color:
                              //           Theme.of(context).brightness ==
                              //               Brightness.dark
                              //           ? AppColors.primaryLight.withOpacity(0.9)
                              //           : Colors.white.withOpacity(0.9),
                              //       shape: BoxShape.circle,
                              //       boxShadow: [
                              //         BoxShadow(
                              //           color: Colors.black.withOpacity(0.4),
                              //           blurRadius: 16,
                              //           offset: const Offset(0, 4),
                              //         ),
                              //       ],
                              //     ),
                              //     child: Icon(
                              //       Icons.play_arrow_rounded,
                              //       size: 36,
                              //       color:
                              //           Theme.of(context).brightness ==
                              //               Brightness.dark
                              //           ? Colors.white
                              //           : AppColors.primary,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),
                  // Footer
                  Text(
                    'وزارة الطاقة © 2026',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      color:
                          Theme.of(context).textTheme.bodySmall?.color ??
                          Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  final String question;
  final String description;
  final String buttonText;
  final bool buttonFilled;
  final VoidCallback onPressed;
  final IconData icon;

  const _AuthCard({
    required this.question,
    required this.description,
    required this.buttonText,
    required this.buttonFilled,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor.withAlpha(245),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.dividerColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.04),
            blurRadius: isDark ? 12 : 8,
            offset: Offset(0, isDark ? 4.0 : 2.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color:
                    theme.textTheme.bodyMedium?.color ??
                    theme.colorScheme.onSurface,
                size: 22.sp,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            question,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color:
                  theme.textTheme.bodyLarge?.color ??
                  theme.colorScheme.onSurface,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 6.h),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              description,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.sp,
                color:
                    theme.textTheme.bodySmall?.color ??
                    theme.colorScheme.onSurface,
                height: 1.5,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 42.h,
            child: buttonFilled
                ? ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(minimumSize: Size.zero),
                    child: Text(buttonText, style: TextStyle(fontSize: 13.sp)),
                  )
                : OutlinedButton(
                    onPressed: onPressed,
                    style: OutlinedButton.styleFrom(minimumSize: Size.zero),
                    child: Text(buttonText, style: TextStyle(fontSize: 13.sp)),
                  ),
          ),
        ],
      ),
    );
  }
}
