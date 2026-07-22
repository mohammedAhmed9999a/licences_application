import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:licences_application/core/constant/app_colors.dart';
import 'package:licences_application/core/services/notification_services.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_theme.dart';
import '../widgets/ministry_logo_widget.dart';
import '../../routes/app_routes.dart';
import '../../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFade;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6200),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    _pulseAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigate();
      }
    });
  }

  void _navigate() {
    if (StorageService.to.isLoggedIn) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
    NotificationServices.processPendingNotification();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  late final Animation<double> _pulseAnimation;

  Widget _buildLogo() {
    final Widget logo = Image.asset(
      'assets/images/logo.webp',
      width: 300.w,
      height: 200.h,
      fit: BoxFit.contain,
    );

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = 0.98 + (_pulseAnimation.value * 0.04);
        return Transform.scale(scale: scale, child: child);
      },
      child: Shimmer.fromColors(
        baseColor: AppColors.golden1.withOpacity(0.65),
        highlightColor: AppColors.golden1.withOpacity(0.95),
        period: const Duration(milliseconds: 1500),
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [AppColors.golden2, AppColors.golden, AppColors.golden1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          blendMode: BlendMode.srcATop,
          child: logo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _logoFade,
                  child: Column(
                    children: [
                      // Eagle logo large
                      Padding(
                        padding: EdgeInsets.only(top: 48.h),
                        child: Align(
                          alignment: Alignment.center,
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutBack,
                            tween: Tween<double>(begin: 0, end: 1),
                            builder: (context, value, child) {
                              // final safeValue = value.clamp(0.0, 1.0);
                              final safeValue = value.isNaN
                                  ? 0.0
                                  : value.clamp(0.0, 1.0);
                              return Opacity(
                                opacity: safeValue,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - value) * 30.h),
                                  child: Transform.scale(
                                    scale: 0.8 + (0.2 * value),
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: _buildLogo(),
                          ),
                        ),
                      ),
                      // Container(
                      //   width: 120.w,
                      //   height: 120.h,
                      //   decoration: BoxDecoration(
                      //     shape: BoxShape.circle,
                      //     color: AppColors.gold.withOpacity(0.1),
                      //   ),
                      //   child: const MinistryLogoWidget(
                      //     size: 90,
                      //     showText: false,
                      //   ),
                      // ),
                      SizedBox(height: 20.h),
                      // Ministry name
                      Text(
                        'وزارة الطاقـة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'MINISTRY OF ENERGY',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'نجهز الأمور لك...',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                // Progress bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: AppColors.borderLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      minHeight: 5,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
