import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../../controllers/license_application_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../../core/validators/form_validator.dart';

class Step1ConditionsScreen extends StatelessWidget {
  const Step1ConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LicenseApplicationController>();
    final theme = Theme.of(context);
    final textPrimary = context.themeTextPrimary;
    final textSecondary = context.themeTextSecondary;
    final textHint = context.themeTextHint;
    final surface = context.themeSurface;
    final surfaceAlt = context.themeSurfaceAlt;
    final borderColor = context.themeBorder;
    final infoColor = theme.colorScheme.secondary;
    final errorColor = theme.colorScheme.error;
    final errorContainer = theme.colorScheme.errorContainer;
    final errorTextColor = theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return SingleChildScrollView(
      controller: ctrl.step1ScrollController,
      child: Column(
        children: [
          // ─── Conditions Section ───────────────────────────────────────
          SectionCard(
            title: 'الشروط والتواصل',
            subtitle:
                'اطلع على ملف الشروط، ويمكنك تحميله أو فتحه في نافذة جديدة عند الحاجة.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action buttons
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  alignment: WrapAlignment.start,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Get.toNamed(AppRoutes.termsPdfViewer);
                      },
                      icon: Icon(Icons.open_in_new, size: 15.sp),
                      label: Text(
                        'فتح في نافذة جديدة',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(0, 36.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 0.h,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Get.toNamed(AppRoutes.termsPdfViewer);
                      },
                      icon: Icon(Icons.download_outlined, size: 15.sp),
                      label: Text(
                        'تحميل الملف',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(0, 36.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 0.h,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // PDF Viewer Card
                Container(
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: surfaceAlt,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      // PDF Header bar
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.r),
                            topRight: Radius.circular(8.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                'الشروط والأحكام الخاصة بطلب ترخيص محطة وقود',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                textDirection: TextDirection.rtl,
                                softWrap: true,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: errorColor,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'PDF',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // PDF content preview
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoutes.termsPdfViewer);

                            // _openFile(file);/
                            print("object");
                          },
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf,
                                  size: 40,
                                  color: textHint,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'اللائحة التنفيذية لاشتراطات محطات الوقود في',
                                  // "sdjflsdjfljsdfjsldfsd",
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: textSecondary,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                                Text(
                                  'الجمهورية العربية السورية',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: textSecondary,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'وزارة الطاقة',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11.sp,
                                    color: textHint,
                                  ),
                                ),
                                Text(
                                  '2026',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11.sp,
                                    color: textHint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Contact Info Section ─────────────────────────────────────
          SectionCard(
            title: 'بيانات التواصل',
            subtitle:
                'سيتم استخدام هذه البيانات للتواصل مع مقدم الطلب بشأن حالة الترخيص.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: infoColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: infoColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          textDirection: TextDirection.rtl,
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.sp,
                              color: textSecondary,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    'يرجى التأكد من صحة بيانات التواصل (وخاصةً البريد الإلكتروني): ',
                              ),
                              TextSpan(
                                text:
                                    'حيث سيتم استخدامها لإرسال تحديثات دراسة طلب ترخيص محطة الوقود، وأي ملاحظات أو متطلبات إضافية من الجهة المختصة.',
                                style: TextStyle(color: textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.info_outline, color: infoColor, size: 18),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Email & Phone row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final useColumnLayout = constraints.maxWidth < 360;

                    if (useColumnLayout) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: ctrl.phoneController,

                            builder: (context, _, __) {
                              return LabeledField(
                                key: ctrl.phoneFieldKey,
                                label: 'رقم التواصل (رقم سوري حصراً)',
                                required: true,
                                errorText: ctrl.phoneController.text.isEmpty
                                    ? null
                                    : (!RegExp(r'^09\d{8}$').hasMatch(
                                            ctrl.phoneController.text.trim(),
                                          )
                                          ? 'رقم التواصل يجب أن يبدأ بـ 09 وأن يكون 10 أرقام'
                                          : null),
                                child: RtlTextField(
                                  controller: ctrl.phoneController,
                                  focusNode: ctrl.phonenumberRequied,

                                  hintText: '09xxxxxxxx',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onSubmitted: (value) {
                                    ctrl.requestFocus(ctrl.emailRequied);
                                  },
                                  maxLength: 10,
                                  enabled: ctrl.isFieldEditable('phone'),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 12.h),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: ctrl.emailController,
                            builder: (context, _, __) {
                              return LabeledField(
                                key: ctrl.emailFieldKey,
                                label: 'عنوان البريد الإلكتروني',
                                required: true,
                                errorText: ctrl.emailController.text.isEmpty
                                    ? null
                                    : FormValidator.validateEmailField(
                                        ctrl.emailController.text,
                                      ),
                                child: RtlTextField(
                                  controller: ctrl.emailController,
                                  focusNode: ctrl.emailRequied,
                                  hintText: 'name@example.com',
                                  keyboardType: TextInputType.emailAddress,
                                  enabled: ctrl.isFieldEditable('email'),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: ctrl.phoneController,
                            builder: (context, _, __) {
                              return LabeledField(
                                key: ctrl.phoneFieldKey,
                                label: 'رقم التواصل (رقم سوري حصراً)',
                                required: true,
                                errorText: ctrl.phoneController.text.isEmpty
                                    ? null
                                    : (!RegExp(r'^09\d{8}$').hasMatch(
                                            ctrl.phoneController.text.trim(),
                                          )
                                          ? 'رقم التواصل يجب أن يبدأ بـ 09 وأن يكون 10 أرقام'
                                          : null),
                                child: RtlTextField(
                                  controller: ctrl.phoneController,
                                  hintText: '09xxxxxxxx',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  maxLength: 10,
                                  enabled: ctrl.isFieldEditable('phone'),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: ctrl.emailController,
                            builder: (context, _, __) {
                              return LabeledField(
                                key: ctrl.emailFieldKey,
                                label: 'عنوان البريد الإلكتروني',
                                required: true,
                                errorText: ctrl.emailController.text.isEmpty
                                    ? null
                                    : FormValidator.validateEmailField(
                                        ctrl.emailController.text,
                                      ),
                                child: RtlTextField(
                                  controller: ctrl.emailController,
                                  hintText: 'name@example.com',
                                  keyboardType: TextInputType.emailAddress,
                                  enabled: ctrl.isFieldEditable('email'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 14.h),

                // Secondary phone
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: ctrl.phone2Controller,
                  builder: (context, _, __) {
                    return LabeledField(
                      key: ctrl.secondaryPhoneFieldKey,
                      label: 'رقم التواصل الثانوي (اختياري)',
                      errorText: ctrl.phone2Controller.text.isEmpty
                          ? null
                          : (!RegExp(
                                  r'^09\d{8}$',
                                ).hasMatch(ctrl.phone2Controller.text.trim())
                                ? 'رقم التواصل الثانوي يجب أن يبدأ بـ 09 وأن يكون 10 أرقام'
                                : null),
                      child: RtlTextField(
                        controller: ctrl.phone2Controller,
                        hintText: '09xxxxxxxx',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        maxLength: 10,
                        enabled: ctrl.isFieldEditable('phone2'),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.h),

                // Terms checkbox
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        key: ctrl.termsFieldKey,
                        onTap: () => ctrl.agreedToTerms.toggle(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                'أوافق على الشروط والأحكام الخاصة بتقديم طلب الترخيص.',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13.sp,
                                  color: textPrimary,
                                ),
                                textDirection: TextDirection.rtl,
                                softWrap: true,
                              ),
                            ),
                            Checkbox(
                              value: ctrl.agreedToTerms.value,
                              onChanged: (v) =>
                                  ctrl.agreedToTerms.value = v ?? false,
                            ),
                          ],
                        ),
                      ),
                      if (!ctrl.agreedToTerms.value &&
                          ctrl.errorMessage.value.contains('الشروط'))
                        Padding(
                          padding: EdgeInsets.only(top: 6.h),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: errorContainer.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: errorColor.withOpacity(0.35),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: errorColor,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    'يجب الموافقة على الشروط والأحكام للمتابعة',
                                    style: TextStyle(
                                      color: errorTextColor,
                                      fontSize: 11.sp,
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Error display
          Obx(() => ErrorBanner(message: ctrl.errorMessage.value)),

          // Next button
          Obx(
            () => NavigationButtons(
              nextLabel: 'التالي',
              onNext: ctrl.submitStep1,
              isLoading: ctrl.isLoading.value,
            ),
          ),

          SizedBox(height: 16.h),
          // Footer
          Text(
            'وزارة الطاقة © 2026',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              color: textHint,
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
