import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constant/app_constants.dart';
import '../routes/app_routes.dart';
import '../../core/api/dio_factory.dart';

class SettingsController extends GetxController {
  static SettingsController get to => Get.find();

  final _box = GetStorage();

  // ── Observables ───────────────────────────────────────────────────────
  final themeMode = ThemeMode.light.obs;
  final locale = const Locale('ar', 'SY').obs;

  // ── Init ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadTheme();
    _loadLocale();
  }

  // ── Theme ─────────────────────────────────────────────────────────────
  bool get isDark => themeMode.value == ThemeMode.dark;

  void _loadTheme() {
    final saved = _box.read<String>(AppConstants.keyThemeMode) ?? 'light';
    themeMode.value = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(themeMode.value);
  }

  void toggleTheme() {
    final next = isDark ? ThemeMode.light : ThemeMode.dark;
    themeMode.value = next;
    Get.changeThemeMode(next);
    _box.write(AppConstants.keyThemeMode, isDark ? 'dark' : 'light');
    _updateSystemUIOverlay(next);
  }

  void setTheme(ThemeMode mode) {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    _box.write(
      AppConstants.keyThemeMode,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
    _updateSystemUIOverlay(mode);
  }

  // System UI
  void _updateSystemUIOverlay(ThemeMode mode) {
    final isDarkTheme = mode == ThemeMode.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkTheme
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: isDarkTheme
            ? const Color(0xff0d1f1d)
            : Colors.white,
        systemNavigationBarIconBrightness: isDarkTheme
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  // Language
  bool get isArabic => locale.value.languageCode == 'ar';

  void _loadLocale() {
    final saved =
        _box.read<String>(AppConstants.keyLang) ?? AppConstants.langAr;
    _applyLocale(saved);
  }

  void toggleLanguage() {
    final next = isArabic ? AppConstants.langEn : AppConstants.langAr;
    changeLanguage(next);
  }

  void changeLanguage(String lang) {
    _applyLocale(lang);
    _box.write(AppConstants.keyLang, lang);
    DioFactory.updateHeaderWithLang(lang);
  }

  void _applyLocale(String lang) {
    if (lang == AppConstants.langEn) {
      locale.value = const Locale('en', 'US');
      Get.updateLocale(const Locale('en', 'US'));
    } else {
      locale.value = const Locale('ar', 'SY');
      Get.updateLocale(const Locale('ar', 'SY'));
    }
  }

  // Convenience getters for UI
  String get currentLangLabel => isArabic ? 'ar'.tr : 'en'.tr;
  String get currentThemeLabel => isDark ? 'dark_theme'.tr : 'light_theme'.tr;
  IconData get themeIcon =>
      isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined;
  IconData get langIcon => Icons.language_outlined;
}
