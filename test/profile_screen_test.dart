import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:licences_application/app/controllers/auth_controller.dart';
import 'package:licences_application/app/views/screens/profile_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('profile screen shows account summary', (tester) async {
    final authCtrl = AuthController();
    Get.put<AuthController>(authCtrl);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => GetMaterialApp(
          home: const ProfileScreen(),
          locale: const Locale('ar'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('الملف الشخصي'), findsWidgets);
    expect(find.text('معلومات الحساب'), findsOneWidget);
  });
}
