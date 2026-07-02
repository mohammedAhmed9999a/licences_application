import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/license_application_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/settings_controller.dart';
import '../../app/services/storage_service.dart';
// import '../../app/services/api_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StorageService>(() => StorageService(), fenix: true);
    // Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.put<LicenseApplicationController>(
      LicenseApplicationController(),
      permanent: true,
    );
  }
}
