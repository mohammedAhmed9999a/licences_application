import 'package:get/get.dart';
import '../views/screens/splash_screen.dart';
import '../views/screens/home_screen.dart';
import '../views/screens/auth/login_screen.dart';
import '../views/screens/auth/signup_screen.dart';
import '../views/screens/auth/email_confirmation_screen.dart';
import '../views/screens/dashboard_screen.dart';
import '../views/screens/license/license_application_screen.dart';
import '../views/screens/license/application_success_screen.dart';
import '../views/screens/my_applications_screen.dart';
import '../views/screens/license/license_details_screen.dart';
import '../views/screens/settings_screen.dart';
import '../views/screens/profile_screen.dart';
import '../views/screens/notifications_screen.dart';
import '../views/screens/terms_pdf_viewer_screen.dart';
import '../bindings/app_bindings.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String emailConfirmation = '/email-confirmation';
  static const String dashboard = '/dashboard';
  static const String licenseApplication = '/license-application';
  static const String applicationSuccess = '/application-success';
  static const String myApplications = '/my-applications';
  static const String licenseDetails = '/license-details';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String termsPdfViewer = '/terms-pdf-viewer';

  static List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      binding: AppBindings(),
    ),
    GetPage(name: home, page: () => const HomeScreen(), binding: AppBindings()),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: AppBindings(),
    ),
    GetPage(
      name: signup,
      page: () => const SignupScreen(),
      binding: AppBindings(),
    ),
    GetPage(
      name: emailConfirmation,
      page: () => const EmailConfirmationScreen(),
      binding: AppBindings(),
    ),
    GetPage(
      name: dashboard,
      page: () => const DashboardScreen(),
      binding: AppBindings(),
    ),
    GetPage(
      name: licenseApplication,
      page: () => const LicenseApplicationScreen(),
      binding: AppBindings(),
    ),
    GetPage(
      name: applicationSuccess,
      page: () => const ApplicationSuccessScreen(),
      binding: AppBindings(),
    ),
    GetPage(
      name: myApplications,
      page: () => const MyApplicationsScreen(),
      binding: AppBindings(),
    ),
    GetPage(
      name: licenseDetails,
      page: () => const LicenseDetailsScreen(),
      binding: AppBindings(),
    ),
    GetPage(
      name: settings,
      page: () => const SettingsScreen(),
      binding: AppBindings(),
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      binding: AppBindings(),
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationsScreen(),
      binding: AppBindings(),
    ),
    GetPage(
      name: termsPdfViewer,
      page: () => const TermsPdfViewerScreen(),
      binding: AppBindings(),
    ),
  ];
}
