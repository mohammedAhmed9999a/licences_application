import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_theme.dart';
import '../../controllers/settings_controller.dart';
import '../../routes/app_routes.dart';
import '../../../core/constant/app_colors.dart';

class MinistryLogoWidget extends StatelessWidget {
  final double size;
  final bool showText;

  const MinistryLogoWidget({super.key, this.size = 60, this.showText = true});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gold.withOpacity(0.12),
          ),
          child: Center(child: _EagleLogo(size: size * 0.68)),
        ),
        if (showText) ...[
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ministry_name'.tr,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: (size * 0.24).sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.2,
                ),
              ),
              Text(
                'ministry_en'.tr,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: (size * 0.16).sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _EagleLogo extends StatelessWidget {
  final double size;
  const _EagleLogo({required this.size});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _EaglePainter());
}

class _EaglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Body
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + size.height * 0.05),
        width: size.width * 0.35,
        height: size.height * 0.45,
      ),
      paint,
    );
    // Head
    canvas.drawCircle(
      Offset(cx, cy - size.height * 0.22),
      size.width * 0.13,
      paint,
    );

    // Left wing
    final lw = Path()
      ..moveTo(cx - size.width * 0.12, cy)
      ..quadraticBezierTo(
        cx - size.width * 0.5,
        cy - size.height * 0.15,
        cx - size.width * 0.45,
        cy + size.height * 0.1,
      )
      ..quadraticBezierTo(
        cx - size.width * 0.28,
        cy + size.height * 0.05,
        cx - size.width * 0.12,
        cy + size.height * 0.08,
      )
      ..close();
    canvas.drawPath(lw, paint);

    // Right wing
    final rw = Path()
      ..moveTo(cx + size.width * 0.12, cy)
      ..quadraticBezierTo(
        cx + size.width * 0.5,
        cy - size.height * 0.15,
        cx + size.width * 0.45,
        cy + size.height * 0.1,
      )
      ..quadraticBezierTo(
        cx + size.width * 0.28,
        cy + size.height * 0.05,
        cx + size.width * 0.12,
        cy + size.height * 0.08,
      )
      ..close();
    canvas.drawPath(rw, paint);

    // Stars
    for (final off in [
      Offset(cx, cy - size.height * 0.42),
      Offset(cx - size.width * 0.12, cy - size.height * 0.38),
      Offset(cx + size.width * 0.12, cy - size.height * 0.38),
    ]) {
      canvas.drawCircle(off, size.width * 0.045, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Ministry AppBar ───────────────────────────────────────────────────────────
class MinistryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;
  final bool showSettingsBtn;

  const MinistryAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.actions,
    this.showSettingsBtn = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark2 : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Directionality(
      textDirection:
          TextDirection.ltr, // Force LTR for AppBar to keep back button on left
      child: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1.h, color: borderColor),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: back or settings
            Row(
              children: [
                if (showBackButton)
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          textDirection: TextDirection.rtl,
                          size: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'back'.tr,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontFamily: 'Cairo',
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (showSettingsBtn) ...[
                  // Settings icon
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.settings),
                    child: Icon(
                      Icons.settings_outlined,
                      size: 22,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Theme toggle
                  Obx(() {
                    final s = Get.find<SettingsController>();
                    return GestureDetector(
                      onTap: s.toggleTheme,
                      child: Icon(
                        s.themeIcon,
                        size: 22,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    );
                  }),
                ],
              ],
            ),
            // Right: ministry branding
            // Row(
            //   children: [
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.end,
            //       children: [
            //         Text(
            //           title ?? 'energy_services'.tr,
            //           style: TextStyle(
            //             fontSize: 11.sp,
            //             fontFamily: 'Cairo',
            //             color: isDark
            //                 ? AppColors.textSecondaryDark
            //                 : AppColors.textSecondaryLight,
            //           ),
            //         ),
            //         if (title != null)
            //           Text(
            //             'Energy Services Management',
            //             style: TextStyle(
            //               fontSize: 9.sp,
            //               fontFamily: 'Cairo',
            //               color: isDark
            //                   ? AppColors.textHintDark
            //                   : AppColors.textHintLight,
            //             ),
            //           ),
            //       ],
            //     ),
            //     SizedBox(width: 8.w),
            //     const MinistryLogoWidget(size: 38, showText: false),
            //   ],
            // ),
            Shimmer.fromColors(
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
          ],
        ),
        actions: actions,
      ),
    );
  }
}
