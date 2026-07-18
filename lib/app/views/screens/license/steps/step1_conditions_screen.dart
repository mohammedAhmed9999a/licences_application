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

  String? _getPhoneErrorText(LicenseApplicationController ctrl) {
    if (ctrl.step1ErrorField.value == 'phone' &&
        ctrl.errorMessage.value.isNotEmpty) {
      return ctrl.errorMessage.value;
    }

    final phone = ctrl.phoneController.text.trim();
    if (phone.isEmpty) {
      return null;
    }

    return RegExp(r'^09\d{8}$').hasMatch(phone)
        ? null
        : 'رقم التواصل يجب أن يبدأ بـ 09 وأن يكون 10 أرقام';
  }

  String? _getEmailErrorText(LicenseApplicationController ctrl) {
    if (ctrl.step1ErrorField.value == 'email' &&
        ctrl.errorMessage.value.isNotEmpty) {
      return ctrl.errorMessage.value;
    }

    final email = ctrl.emailController.text.trim();
    if (email.isEmpty) {
      return null;
    }

    return FormValidator.validateEmailField(email);
  }

  String? _getSecondaryPhoneErrorText(LicenseApplicationController ctrl) {
    final phone2 = ctrl.phone2Controller.text.trim();
    if (phone2.isEmpty) {
      return null;
    }

    if (ctrl.step1ErrorField.value == 'phone2' &&
        ctrl.errorMessage.value.isNotEmpty) {
      return ctrl.errorMessage.value;
    }

    return RegExp(r'^09\d{8}$').hasMatch(phone2)
        ? null
        : 'رقم التواصل الثانوي يجب أن يبدأ بـ 09 وأن يكون 10 أرقام';
  }

  String? _getTermsErrorText(LicenseApplicationController ctrl) {
    if (ctrl.step1ErrorField.value == 'terms' &&
        ctrl.errorMessage.value.isNotEmpty) {
      return ctrl.errorMessage.value;
    }

    return (!ctrl.agreedToTerms.value &&
            ctrl.errorMessage.value.contains('الشروط'))
        ? 'يجب الموافقة على الشروط والأحكام للمتابعة'
        : null;
  }

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
                // // Action buttons
                // ─── Official Document Card ───────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.10),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Column(
                      children: [
                        // Header with gradient
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withOpacity(0.75),
                              ],
                            ),
                          ),
                          child: Row(
                            textDirection: TextDirection.ltr,

                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified_outlined,
                                      size: 12.sp,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'مستند رسمي',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'وثيقة الشروط والأحكام',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Body
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 24.h,
                          ),
                          color: surface,
                          child: Column(
                            children: [
                              // Document icon with badge
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 80.w,
                                    height: 80.h,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(10.r),
                                      border: Border.all(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.25),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.description_outlined,
                                      size: 30.sp,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 4.h,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.error,
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.15,
                                            ),
                                            blurRadius: 4,
                                          ),
                                        ],
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
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'اللائحة التنفيذية لاشتراطات محطات الوقود',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'الجمهورية العربية السورية - وزارة الطاقة - 2026',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11.sp,
                                  color: textSecondary,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              SizedBox(height: 20.h),

                              // Action buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Get.toNamed(AppRoutes.termsPdfViewer);
                                      },
                                      icon: Icon(
                                        Icons.visibility_outlined,
                                        size: 16.sp,
                                      ),
                                      label: Text(
                                        'عرض المستند',
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        foregroundColor:
                                            theme.colorScheme.onPrimary,
                                        minimumSize: Size(0, 40.h),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // SizedBox(width: 10.w),
                                  // Expanded(
                                  //   child: OutlinedButton.icon(
                                  //     onPressed: () {
                                  //       Get.toNamed(AppRoutes.termsPdfViewer);
                                  //     },
                                  //     icon: Icon(
                                  //       Icons.download_outlined,
                                  //       size: 16.sp,
                                  //     ),
                                  //     label: Text(
                                  //       'تحميل',
                                  //       style: TextStyle(fontSize: 12.sp),
                                  //     ),
                                  //     style: OutlinedButton.styleFrom(
                                  //       foregroundColor:
                                  //           theme.colorScheme.primary,
                                  //       side: BorderSide(
                                  //         color: theme.colorScheme.primary
                                  //             .withOpacity(0.4),
                                  //       ),
                                  //       minimumSize: Size(0, 40.h),
                                  //       shape: RoundedRectangleBorder(
                                  //         borderRadius: BorderRadius.circular(
                                  //           10.r,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Wrap(
                //   spacing: 8.w,
                //   runSpacing: 8.h,
                //   alignment: WrapAlignment.start,
                //   children: [
                //     OutlinedButton.icon(
                //       onPressed: () {
                //         Get.toNamed(AppRoutes.termsPdfViewer);
                //       },
                //       icon: Icon(Icons.open_in_new, size: 15.sp),
                //       label: Text(
                //         'فتح في نافذة جديدة',
                //         style: TextStyle(fontSize: 12.sp),
                //       ),
                //       style: OutlinedButton.styleFrom(
                //         minimumSize: Size(0, 36.h),
                //         padding: EdgeInsets.symmetric(
                //           horizontal: 12.w,
                //           vertical: 0.h,
                //         ),
                //       ),
                //     ),
                //     OutlinedButton.icon(
                //       onPressed: () {
                //         Get.toNamed(AppRoutes.termsPdfViewer);
                //       },
                //       icon: Icon(Icons.download_outlined, size: 15.sp),
                //       label: Text(
                //         'تحميل الملف',
                //         style: TextStyle(fontSize: 12.sp),
                //       ),
                //       style: OutlinedButton.styleFrom(
                //         minimumSize: Size(0, 36.h),
                //         padding: EdgeInsets.symmetric(
                //           horizontal: 12.w,
                //           vertical: 0.h,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                // SizedBox(height: 12.h),

                // // PDF Viewer Card
                // Container(
                //   height: 200.h,
                //   decoration: BoxDecoration(
                //     color: surfaceAlt,
                //     borderRadius: BorderRadius.circular(8.r),
                //     border: Border.all(color: borderColor),
                //   ),
                //   child: Column(
                //     children: [
                //       // PDF Header bar
                //       Container(
                //         padding: EdgeInsets.symmetric(
                //           horizontal: 12.w,
                //           vertical: 8.h,
                //         ),
                //         decoration: BoxDecoration(
                //           color: surface,
                //           borderRadius: BorderRadius.only(
                //             topLeft: Radius.circular(8.r),
                //             topRight: Radius.circular(8.r),
                //           ),
                //         ),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.end,
                //           children: [
                //             Expanded(
                //               child: Text(
                //                 'الشروط والأحكام الخاصة بطلب ترخيص محطة وقود',
                //                 style: TextStyle(
                //                   fontFamily: 'Cairo',
                //                   fontSize: 12.sp,
                //                   fontWeight: FontWeight.w600,
                //                 ),
                //                 textDirection: TextDirection.rtl,
                //                 softWrap: true,
                //               ),
                //             ),
                //             SizedBox(width: 8.w),
                //             Container(
                //               padding: EdgeInsets.symmetric(
                //                 horizontal: 6.w,
                //                 vertical: 2.h,
                //               ),
                //               decoration: BoxDecoration(
                //                 color: errorColor,
                //                 borderRadius: BorderRadius.circular(4.r),
                //               ),
                //               child: Text(
                //                 'PDF',
                //                 style: TextStyle(
                //                   color: Colors.white,
                //                   fontSize: 9.sp,
                //                   fontWeight: FontWeight.bold,
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //       // PDF content preview
                //       Expanded(
                //         child: GestureDetector(
                //           onTap: () {
                //             Get.toNamed(AppRoutes.termsPdfViewer);

                //             // _openFile(file);/
                //             print("object");
                //           },
                //           child: Center(
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: [
                //                 Icon(
                //                   Icons.picture_as_pdf,
                //                   size: 40,
                //                   color: textHint,
                //                 ),
                //                 SizedBox(height: 8.h),
                //                 Text(
                //                   'اللائحة التنفيذية لاشتراطات محطات الوقود في',
                //                   // "sdjflsdjfljsdfjsldfsd",
                //                   style: TextStyle(
                //                     fontFamily: 'Cairo',
                //                     fontSize: 12.sp,
                //                     fontWeight: FontWeight.w600,
                //                     color: textSecondary,
                //                   ),
                //                   textDirection: TextDirection.rtl,
                //                 ),
                //                 Text(
                //                   'الجمهورية العربية السورية',
                //                   style: TextStyle(
                //                     fontFamily: 'Cairo',
                //                     fontSize: 12.sp,
                //                     fontWeight: FontWeight.w600,
                //                     color: textSecondary,
                //                   ),
                //                   textDirection: TextDirection.rtl,
                //                 ),
                //                 SizedBox(height: 4.h),
                //                 Text(
                //                   'وزارة الطاقة',
                //                   style: TextStyle(
                //                     fontFamily: 'Cairo',
                //                     fontSize: 11.sp,
                //                     color: textHint,
                //                   ),
                //                 ),
                //                 Text(
                //                   '2026',
                //                   style: TextStyle(
                //                     fontFamily: 'Cairo',
                //                     fontSize: 11.sp,
                //                     color: textHint,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),

          SectionCard(
            title: 'بيانات التواصل',
            subtitle:
                'سيتم استخدام هذه البيانات للتواصل مع مقدم الطلب بشأن حالة الترخيص.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: infoColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: infoColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.ltr,

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
                            valueListenable: ctrl.emailController,
                            builder: (context, _, __) {
                              return Obx(
                                () => LabeledField(
                                  key: ctrl.emailFieldKey,
                                  label: 'عنوان البريد الإلكتروني',
                                  required: true,
                                  errorText: _getEmailErrorText(ctrl),
                                  child: RtlTextField(
                                    controller: ctrl.emailController,
                                    focusNode: ctrl.emailRequied,
                                    hintText: 'name@example.com',
                                    keyboardType: TextInputType.emailAddress,
                                    enabled: ctrl.isFieldEditable('email'),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 12.h),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: ctrl.phoneController,
                            builder: (context, _, __) {
                              return Obx(
                                () => LabeledField(
                                  key: ctrl.phoneFieldKey,
                                  label: 'رقم التواصل (رقم سوري حصراً)',
                                  required: true,
                                  errorText: _getPhoneErrorText(ctrl),
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
                              return Obx(
                                () => LabeledField(
                                  key: ctrl.phoneFieldKey,
                                  label: 'رقم التواصل (رقم سوري حصراً)',
                                  required: true,
                                  errorText: _getPhoneErrorText(ctrl),
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
                              return Obx(
                                () => LabeledField(
                                  key: ctrl.emailFieldKey,
                                  label: 'عنوان البريد الإلكتروني',
                                  required: true,
                                  errorText: _getEmailErrorText(ctrl),
                                  child: RtlTextField(
                                    controller: ctrl.emailController,
                                    hintText: 'name@example.com',
                                    keyboardType: TextInputType.emailAddress,
                                    enabled: ctrl.isFieldEditable('email'),
                                  ),
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
                    return Obx(
                      () => LabeledField(
                        key: ctrl.secondaryPhoneFieldKey,
                        label: 'رقم التواصل الثانوي (اختياري)',
                        errorText: _getSecondaryPhoneErrorText(ctrl),
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
                      if (_getTermsErrorText(ctrl) != null)
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
                                    _getTermsErrorText(ctrl)!,
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
