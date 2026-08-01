import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:licences_application/app/theme/app_theme.dart';
import 'package:licences_application/app/views/widgets/ministry_logo_widget.dart';
import '../../../core/constant/app_colors.dart';
import '../../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SettingsController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? Theme.of(context).scaffoldBackgroundColor.withAlpha(225)
          : Theme.of(context).scaffoldBackgroundColor.withAlpha(100),

      // appBar: const MinistryAppBar(title: null),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),

            // Title
            Text(
              'settings'.tr,
              style: Theme.of(context).textTheme.headlineMedium,
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 20.h),

            // ── Language Section ────────────────────────────────────────
            // _SectionHeader(title: 'language'.tr),

            // SizedBox(height: 10.h),
            // _LanguageCard(ctrl: ctrl),
            SizedBox(height: 24.h),

            // ── Theme Section ───────────────────────────────────────────
            _SectionHeader(title: 'theme'.tr),
            SizedBox(height: 10.h),
            _ThemeCard(ctrl: ctrl),

            SizedBox(height: 250.h),
            // Spacer(),

            // App version footer
            Center(
              child: Text(
                'footer_copy'.tr,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

// ── Language Card ──────────────────────────────────────────────────────────
class _LanguageCard extends StatelessWidget {
  final SettingsController ctrl;
  const _LanguageCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          _LangOption(
            label: 'العربية',
            sublabel: 'Arabic',
            langCode: 'ar',
            selected: ctrl.isArabic,
            onTap: () => ctrl.changeLanguage('ar'),
            isDark: isDark,
            isFirst: true,
          ),
          Divider(height: 1.h, color: border),
          _LangOption(
            label: 'English',
            sublabel: 'الإنجليزية',
            langCode: 'en',
            selected: !ctrl.isArabic,
            onTap: () => ctrl.changeLanguage('en'),
            isDark: isDark,
            isFirst: false,
          ),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String label;
  final String sublabel;
  final String langCode;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;
  final bool isFirst;

  const _LangOption({
    required this.label,
    required this.sublabel,
    required this.langCode,
    required this.selected,
    required this.onTap,
    required this.isDark,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: selected ? primaryColor.withOpacity(0.07) : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: isFirst ? Radius.circular(12.r) : Radius.zero,
            topRight: isFirst ? Radius.circular(12.r) : Radius.zero,
            bottomLeft: !isFirst ? Radius.circular(12.r) : Radius.zero,
            bottomRight: !isFirst ? Radius.circular(12.r) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22.w,
              height: 22.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? primaryColor
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: selected ? 5 : 2,
                ),
                color: selected ? primaryColor : Colors.transparent,
              ),
            ),
            const Spacer(),
            // Text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.ltr,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15.sp,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    color: selected
                        ? primaryColor
                        : (Theme.of(context).textTheme.bodyLarge?.color ??
                              Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                Text(
                  sublabel,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    color:
                        Theme.of(context).textTheme.bodySmall?.color ??
                        Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),
            // Flag emoji
            Text(
              langCode == 'ar' ? '🇸🇾' : '🇺🇸',
              style: TextStyle(fontSize: 24.sp),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Theme Card ─────────────────────────────────────────────────────────────
class _ThemeCard extends StatelessWidget {
  final SettingsController ctrl;
  const _ThemeCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          _ThemeOption(
            label: 'light_theme'.tr,
            icon: Icons.light_mode_outlined,
            themeMode: ThemeMode.light,
            selected: !ctrl.isDark,
            onTap: () => ctrl.setTheme(ThemeMode.light),
            isDark: isDark,
            isFirst: true,
          ),
          Divider(height: 1.h, color: border),
          _ThemeOption(
            label: 'dark_theme'.tr,
            icon: Icons.dark_mode_outlined,
            themeMode: ThemeMode.dark,
            selected: ctrl.isDark,
            onTap: () => ctrl.setTheme(ThemeMode.dark),
            isDark: isDark,
            isFirst: false,
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final ThemeMode themeMode;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;
  final bool isFirst;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.themeMode,
    required this.selected,
    required this.onTap,
    required this.isDark,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: selected ? primaryColor.withOpacity(0.07) : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: isFirst ? Radius.circular(12.r) : Radius.zero,
            topRight: isFirst ? Radius.circular(12.r) : Radius.zero,
            bottomLeft: !isFirst ? Radius.circular(12.r) : Radius.zero,
            bottomRight: !isFirst ? Radius.circular(12.r) : Radius.zero,
          ),
        ),
        child: Row(
          textDirection: TextDirection.ltr,
          children: [
            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22.w,
              height: 22.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? primaryColor
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: selected ? 5 : 2,
                ),
                color: selected ? primaryColor : Colors.transparent,
              ),
            ),
            const Spacer(),
            // Label
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15.sp,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected
                    ? primaryColor
                    : (Theme.of(context).textTheme.bodyLarge?.color ??
                          Theme.of(context).colorScheme.onSurface),
              ),
            ),
            SizedBox(width: 12.w),
            // Icon
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: selected
                    ? primaryColor.withOpacity(0.12)
                    : (isDark
                          ? AppColors.backgroundDark
                          : AppColors.backgroundAlt),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: selected
                    ? primaryColor
                    : (Theme.of(context).textTheme.bodySmall?.color ??
                          Theme.of(context).colorScheme.onSurface),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
