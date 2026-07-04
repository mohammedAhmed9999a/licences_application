import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constant/app_colors.dart';
import 'app_icon_theme.dart';

export '../../core/constant/app_colors.dart';
export 'app_icon_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Cairo',
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.gold,
      surface: AppColors.surface,
      surfaceVariant: AppColors.surfaceVariant,
      background: AppColors.background,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
      outline: AppColors.border,
    ),
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.surface,
    cardColor: AppColors.surface,
    dialogBackgroundColor: AppColors.surface,
    dividerColor: AppColors.border,
    shadowColor: Colors.black.withOpacity(0.08),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    iconTheme: AppIconTheme.lightNormalIcons,
    cardTheme: CardThemeData(
      color: AppColors.surfaceVariant,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      hintStyle: TextStyle(
        color: AppColors.textHint,
        fontSize: 13.sp,
        fontFamily: 'Cairo',
      ),
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontFamily: 'Cairo',
      ),
      errorStyle: TextStyle(
        color: AppColors.error,
        fontSize: 11.sp,
        fontFamily: 'Cairo',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        textStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
        ),
        elevation: 0,
        shadowColor: AppColors.primary.withOpacity(0.15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: Size(double.infinity, 50.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        textStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.primary
            : Colors.transparent,
      ),
      side: const BorderSide(color: AppColors.borderLight, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.borderLight,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 17.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      contentTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14.sp,
        color: AppColors.textSecondary,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.border,
    ),
    textTheme: _textTheme(AppColors.textPrimary, AppColors.textSecondary),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Cairo',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      secondary: AppColors.gold,
      surface: AppColors.darkSurface,
      surfaceVariant: AppColors.darkSurfaceVariant,
      background: AppColors.darkBg,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimaryDark,
      onBackground: AppColors.textPrimaryDark,
      outline: AppColors.borderDark,
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
    canvasColor: AppColors.darkSurface,
    cardColor: AppColors.darkSurfaceVariant,
    dialogBackgroundColor: AppColors.darkSurfaceVariant,
    dividerColor: AppColors.darkDivider,
    shadowColor: Colors.black.withOpacity(0.5),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    iconTheme: AppIconTheme.darkNormalIcons,
    cardTheme: CardThemeData(
      color: AppColors.darkSurfaceVariant,
      elevation: 2,
      shadowColor: AppColors.primaryLight.withOpacity(0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: AppColors.borderDark, width: 0.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.borderDark, width: 1.w),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.borderDark, width: 1.w),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.primaryLight, width: 2.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      hintStyle: TextStyle(
        color: AppColors.darkTextHint,
        fontSize: 13.sp,
        fontFamily: 'Cairo',
      ),
      labelStyle: const TextStyle(
        color: AppColors.textSecondaryDark,
        fontFamily: 'Cairo',
      ),
      errorStyle: TextStyle(
        color: AppColors.error,
        fontSize: 11.sp,
        fontFamily: 'Cairo',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        textStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
        ),
        elevation: 4,
        shadowColor: AppColors.primaryLight.withOpacity(0.3),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        side: const BorderSide(color: AppColors.primaryLight),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        textStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        textStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.primaryLight
            : Colors.transparent,
      ),
      side: const BorderSide(color: AppColors.borderDark, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.primaryLight
            : AppColors.borderDark,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
      space: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 17.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
      ),
      contentTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14.sp,
        color: AppColors.textSecondaryDark,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.darkSurfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryLight,
      linearTrackColor: AppColors.borderDark,
    ),
    textTheme: _textTheme(
      AppColors.textPrimaryDark,
      AppColors.textSecondaryDark,
    ),
  );

  static TextTheme _textTheme(Color primary, Color secondary) => TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Cairo',
      fontWeight: FontWeight.bold,
      color: primary,
      fontSize: 32.sp,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Cairo',
      fontWeight: FontWeight.bold,
      color: primary,
      fontSize: 28.sp,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Cairo',
      fontWeight: FontWeight.bold,
      color: primary,
      fontSize: 24.sp,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Cairo',
      fontWeight: FontWeight.bold,
      color: primary,
      fontSize: 20.sp,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Cairo',
      fontWeight: FontWeight.w600,
      color: primary,
      fontSize: 18.sp,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Cairo',
      fontWeight: FontWeight.w600,
      color: primary,
      fontSize: 16.sp,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Cairo',
      fontWeight: FontWeight.w600,
      color: primary,
      fontSize: 14.sp,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Cairo',
      color: primary,
      fontSize: 15.sp,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Cairo',
      color: secondary,
      fontSize: 13.sp,
      height: 1.45,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Cairo',
      color: secondary,
      fontSize: 11.sp,
      height: 1.35,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Cairo',
      fontWeight: FontWeight.w600,
      color: primary,
      fontSize: 14.sp,
    ),
  );
}

extension AppThemeExtensions on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get themeBackground => Theme.of(this).colorScheme.background;
  Color get themeSurface => Theme.of(this).colorScheme.surface;
  Color get themeSurfaceVariant => Theme.of(this).colorScheme.surfaceVariant;
  Color get themeSurfaceAlt =>
      isDarkMode ? AppColors.darkSurfaceAlt : AppColors.backgroundAlt;
  Color get themeCard => Theme.of(this).cardColor;
  Color get themeBorder => Theme.of(this).dividerColor;
  Color get themeTextPrimary => Theme.of(this).colorScheme.onBackground;
  Color get themeTextSecondary =>
      Theme.of(this).textTheme.bodyMedium?.color ??
      Theme.of(this).colorScheme.onSurface;
  Color get themeTextHint =>
      isDarkMode ? AppColors.darkTextHint : AppColors.textHint;
}
