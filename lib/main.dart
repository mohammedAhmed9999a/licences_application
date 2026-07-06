import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:licences_application/core/services/my_services.dart';
import 'package:licences_application/core/services/notification_services.dart';
import 'firebase_options.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'app/bindings/app_bindings.dart';
import 'app/controllers/settings_controller.dart';
import 'translation/app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await GetStorage.init();
  try {
    await MyServices.printFCM();
  } catch (e) {
    //slf
    print('MyServices.printFCM error: $e');
  }
  //
  await NotificationServices.requestNotificationPermission();
  await NotificationServices.checkInitialNotification();

  final fcmToken = await NotificationServices.getDeviceToken();
  print('FCM Token: $fcmToken');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final settingsCtrl = SettingsController();
  Get.put(settingsCtrl, permanent: true);

  _updateSystemUIOverlay(settingsCtrl.themeMode.value);

  runApp(const FuelStationApp());
}

void _updateSystemUIOverlay(ThemeMode themeMode) {
  final isDark = themeMode == ThemeMode.dark;
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDark ? const Color(0xff0d1f1d) : Colors.white,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    ),
  );
}

class FuelStationApp extends StatelessWidget {
  const FuelStationApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return Obx(
          () => GetMaterialApp(
            title: 'app_name'.tr,
            debugShowCheckedModeBanner: false,

            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsCtrl.themeMode.value,

            translations: AppTranslations(),
            locale: const Locale('ar', 'SY'),
            fallbackLocale: const Locale('ar', 'SY'),

            builder: (ctx, appChild) => Directionality(
              textDirection: TextDirection.rtl,
              child: appChild!,
            ),

            initialRoute: AppRoutes.splash,
            getPages: AppRoutes.pages,
            initialBinding: AppBindings(),

            defaultTransition: Transition.fadeIn,
            transitionDuration: const Duration(milliseconds: 250),
          ),
        );
      },
    );
  }
}
