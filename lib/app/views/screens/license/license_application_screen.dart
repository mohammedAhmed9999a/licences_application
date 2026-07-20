import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/ministry_logo_widget.dart';
import '../../widgets/step_indicator_widget.dart';
import '../../../controllers/license_application_controller.dart';
import 'steps/step1_conditions_screen.dart';
import 'steps/step2_license_info_screen.dart';
import 'steps/step3_location_screen.dart';
import 'steps/step4_attachments_screen.dart';

class LicenseApplicationScreen extends StatelessWidget {
  const LicenseApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LicenseApplicationController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: MinistryAppBar(
        title: 'إصدار ترخيص محطة وقود',
        showBackButton: true,
        // actions: [
        //   // Notification bell
        //   IconButton(
        //     icon: Icon(
        //       Icons.notifications_outlined,
        //       color: AppColors.textSecondary,
        //       size: 24.sp,
        //     ),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: Column(
      
        children: [
          // Step indicator
          Obx(
            () => StepIndicatorWidget(
              currentStep: ctrl.currentStep.value,
              onStepTapped: (index) {
                ctrl.currentStep.value = index;
              },
              onBlockedStepTap: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'يرجى إكمال الخطوة الحالية أولاً قبل الانتقال إلى الخطوة التالية',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),

          // Page content
          Expanded(
            child: Obx(() {
              switch (ctrl.currentStep.value) {
                case 0:
                  return const Step1ConditionsScreen();
                case 1:
                  return const Step2LicenseInfoScreen();
                case 2:
                  return const Step3LocationScreen();
                case 3:
                  return const Step4AttachmentsScreen();
                default:
                  return const Step1ConditionsScreen();
              }
            }),
          ),
        ],
      ),
    );
  }
}
