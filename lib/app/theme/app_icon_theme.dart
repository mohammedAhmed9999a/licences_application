import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constant/app_colors.dart';

/// نظام موحد لتصميم الأيقونات
class AppIconTheme {
  AppIconTheme._();

  // ============= LIGHT THEME =============

  /// الأيقونات الخاصة بـ App Bar في الـ Light Theme
  static IconThemeData get lightAppBarIcons =>
      const IconThemeData(color: Colors.white, size: 24);

  /// الأيقونات الخاصة بـ Buttons في الـ Light Theme
  static IconThemeData get lightButtonIcons =>
      const IconThemeData(color: Colors.white, size: 18);

  /// الأيقونات العادية في الـ Light Theme
  static IconThemeData get lightNormalIcons =>
      IconThemeData(color: AppColors.primary, size: 24.sp);

  /// الأيقونات الثانوية في الـ Light Theme
  static IconThemeData get lightSecondaryIcons =>
      IconThemeData(color: AppColors.textSecondary, size: 20.sp);

  /// أيقونات الحالة الناجحة في الـ Light Theme
  static IconThemeData get lightSuccessIcons =>
      IconThemeData(color: AppColors.success, size: 20.sp);

  /// أيقونات التحذير في الـ Light Theme
  static IconThemeData get lightWarningIcons =>
      IconThemeData(color: AppColors.warning, size: 20.sp);

  /// أيقونات الخطأ في الـ Light Theme
  static IconThemeData get lightErrorIcons =>
      IconThemeData(color: AppColors.error, size: 20.sp);

  // ============= DARK THEME =============

  /// الأيقونات الخاصة بـ App Bar في الـ Dark Theme
  static IconThemeData get darkAppBarIcons =>
      const IconThemeData(color: Colors.white, size: 24);

  /// الأيقونات الخاصة بـ Buttons في الـ Dark Theme
  static IconThemeData get darkButtonIcons =>
      const IconThemeData(color: Colors.white, size: 18);

  /// الأيقونات العادية في الـ Dark Theme
  static IconThemeData get darkNormalIcons =>
      IconThemeData(color: AppColors.primaryLight, size: 24.sp);

  /// الأيقونات الثانوية في الـ Dark Theme
  static IconThemeData get darkSecondaryIcons =>
      IconThemeData(color: AppColors.textSecondaryDark, size: 20.sp);

  /// أيقونات الحالة الناجحة في الـ Dark Theme
  static IconThemeData get darkSuccessIcons =>
      IconThemeData(color: AppColors.success, size: 20.sp);

  /// أيقونات التحذير في الـ Dark Theme
  static IconThemeData get darkWarningIcons =>
      IconThemeData(color: AppColors.warning, size: 20.sp);

  /// أيقونات الخطأ في الـ Dark Theme
  static IconThemeData get darkErrorIcons =>
      IconThemeData(color: AppColors.error, size: 20.sp);

  // ============= UTILITY METHODS =============

  /// الحصول على IconThemeData حسب البريتنس (Light/Dark)
  static IconThemeData getIconTheme(Brightness brightness, IconType type) {
    if (brightness == Brightness.light) {
      return _getLightIconTheme(type);
    } else {
      return _getDarkIconTheme(type);
    }
  }

  /// الحصول على لون الأيقونة حسب البريتنس والنوع
  static Color getIconColor(Brightness brightness, IconType type) {
    return getIconTheme(brightness, type).color ?? Colors.black;
  }

  /// الحصول على حجم الأيقونة حسب البريتنس والنوع
  static double getIconSize(Brightness brightness, IconType type) {
    return getIconTheme(brightness, type).size ?? 24;
  }

  static IconThemeData _getLightIconTheme(IconType type) {
    return switch (type) {
      IconType.appBar => lightAppBarIcons,
      IconType.button => lightButtonIcons,
      IconType.normal => lightNormalIcons,
      IconType.secondary => lightSecondaryIcons,
      IconType.success => lightSuccessIcons,
      IconType.warning => lightWarningIcons,
      IconType.error => lightErrorIcons,
    };
  }

  static IconThemeData _getDarkIconTheme(IconType type) {
    return switch (type) {
      IconType.appBar => darkAppBarIcons,
      IconType.button => darkButtonIcons,
      IconType.normal => darkNormalIcons,
      IconType.secondary => darkSecondaryIcons,
      IconType.success => darkSuccessIcons,
      IconType.warning => darkWarningIcons,
      IconType.error => darkErrorIcons,
    };
  }
}

/// أنواع الأيقونات المختلفة
enum IconType { appBar, button, normal, secondary, success, warning, error }

/// معلومات مخصصة للأيقونات مع دعم المواضيع
class ThemedIcon extends StatelessWidget {
  final IconData icon;
  final IconType type;
  final double? customSize;
  final Color? customColor;
  final VoidCallback? onTap;

  const ThemedIcon(
    this.icon, {
    this.type = IconType.normal,
    this.customSize,
    this.customColor,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final iconTheme = AppIconTheme.getIconTheme(brightness, type);
    final parentIconColor = IconTheme.of(context).color;
    final color =
        customColor ?? parentIconColor ?? iconTheme.color ?? Colors.black;
    final size = customSize ?? iconTheme.size ?? 24;

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: Icon(icon, color: color, size: size),
      );
    }

    return Icon(icon, color: color, size: size);
  }
}
