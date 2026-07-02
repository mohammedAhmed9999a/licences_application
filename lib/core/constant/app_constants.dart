class AppConstants {
  AppConstants._();

  // ── API ───────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://petro-stations.moenergy.gov.sy/api';

  // ── Storage keys ──────────────────────────────────────────────────────
  static const String keyToken = 'auth_token';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyRememberMe = 'remember_me';
  static const String keyThemeMode = 'theme_mode'; // 'light' | 'dark'
  static const String keyLang = 'lang'; // 'ar' | 'en'

  // ── Supported locales ─────────────────────────────────────────────────
  static const String langAr = 'ar';
  static const String langEn = 'en';

  // ── App info ──────────────────────────────────────────────────────────
  static const String appVersion = '1.0.0';
  static const int appYear = 2026;
}
