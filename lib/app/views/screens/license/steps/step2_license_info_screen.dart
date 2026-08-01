import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../../controllers/license_application_controller.dart';
import 'widgets/step2_company_form.dart';
import 'widgets/step2_individual_form.dart';
import 'widgets/step2_question_label.dart';
import 'widgets/step2_settlement_phase.dart';

class Step2LicenseInfoScreen extends StatelessWidget {
  const Step2LicenseInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LicenseApplicationController>();
    final theme = Theme.of(context);
    final textPrimary = context.themeTextPrimary;
    final textSecondary = context.themeTextSecondary;
    final surfaceAlt = context.themeSurfaceAlt;
    final borderColor = context.themeBorder;
    final primaryColor = theme.colorScheme.primary;
    final errorColor = theme.colorScheme.error;
    final isMobile = MediaQuery.of(context).size.width < 650;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        controller: ctrl.step2ScrollController,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 5.h),
          child: Column(
            children: [
              SectionCard(
                title: 'نوع الطلب وبيانات الترخيص',
                subtitle:
                    'اختر مسار الطلب، ثم حدد إن كان الترخيص لمستثمر فردي أو شركة.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const RequiredFieldsBanner(),
                    SizedBox(height: 14.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Obx(
                              () => Text(
                                'الطلب الحالي: ${ctrl.requestType.value == 'settlement' ? 'تسوية' : 'جديد'} • المستثمر: ${ctrl.investorType.value == 'company' ? 'شركة' : 'فردي'}',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.info_outline,
                            size: 18.sp,
                            color: primaryColor,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    // Question 1
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Step2QuestionLabel(number: 1, text: 'ما نوع الطلب؟'),
                          SizedBox(height: 10.h),
                          Obx(
                            () => isMobile
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      ChoiceCard(
                                        title: 'تسوية (منشآت مرخصة سابقاً)',
                                        subtitle:
                                            'تسوية وضع قائم حسب المتطلبات.',
                                        icon: Icons.description_outlined,
                                        selected:
                                            ctrl.requestType.value ==
                                            'settlement',
                                        enabled: !ctrl.isCorrectionMode.value,
                                        onTap: () => ctrl.requestType.value =
                                            'settlement',
                                      ),
                                      SizedBox(height: 10.h),
                                      ChoiceCard(
                                        title: 'جديد',
                                        subtitle: 'طلب ترخيص جديد لمحطة وقود.',
                                        icon: Icons.add_circle_outline,
                                        selected:
                                            ctrl.requestType.value == 'new',
                                        enabled: !ctrl.isCorrectionMode.value,
                                        onTap: () =>
                                            ctrl.requestType.value = 'new',
                                      ),
                                    ],
                                  )
                                : Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Expanded(
                                        child: ChoiceCard(
                                          title: 'تسوية (منشآت مرخصة سابقاً)',
                                          subtitle:
                                              'تسوية وضع قائم حسب المتطلبات.',
                                          icon: Icons.description_outlined,
                                          selected:
                                              ctrl.requestType.value ==
                                              'settlement',
                                          enabled: !ctrl.isCorrectionMode.value,
                                          onTap: () => ctrl.requestType.value =
                                              'settlement',
                                        ),
                                      ),
                                      SizedBox(width: 10.w),

                                      Expanded(
                                        child: ChoiceCard(
                                          title: 'جديد',
                                          subtitle:
                                              'طلب ترخيص جديد لمحطة وقود.',
                                          icon: Icons.add_circle_outline,
                                          selected:
                                              ctrl.requestType.value == 'new',
                                          enabled: !ctrl.isCorrectionMode.value,
                                          onTap: () =>
                                              ctrl.requestType.value = 'new',
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                    //Settlement: show previous license field + info
                    Obx(() {
                      if (ctrl.requestType.value != 'settlement') {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(height: 16.h),
                          Obx(
                            () => LabeledField(
                              key: ctrl.previousLicenseNumberFieldKey,
                              label: 'رقم الترخيص السابق',
                              required: true,
                              errorText:
                                  ctrl.settlementPreviousLicenseError.value,
                              child: RtlTextField(
                                controller: ctrl.previousLicenseNumber,
                                hintText: 'رقم الترخيص السابق',
                                // Allow all input so we can validate and show message on submit
                                onChanged: (v) => ctrl.validateStep2Field(
                                  'previousLicenseNumber',
                                  v,
                                ),
                                onSubmitted: (_) {
                                  ctrl.validateStep2Field(
                                    'previousLicenseNumber',
                                    ctrl.previousLicenseNumber.text,
                                  );
                                  FocusScope.of(context).unfocus();
                                },
                                maxLength: 30,
                                enabled: ctrl.isFieldEditable('license_number'),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          // Settlement info box
                          Container(
                            // transformAlignment: Alignment.centerRight,
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: surfaceAlt,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                RichText(
                                  textDirection: TextDirection.rtl,
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12.sp,
                                      color: textSecondary,
                                      height: 1.6,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            'يتم قبول طلبات التسوية خلال مدة أقصاها ',
                                      ),
                                      TextSpan(
                                        text: '30 يوم',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const TextSpan(
                                        text:
                                            ' من تاريخ نشر اللائحة التنفيذية، على أن تقوم اللجنة بدراسة الطلب وإعطاء ',
                                      ),
                                      TextSpan(
                                        text: 'الموافقة المبدئية',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                      const TextSpan(text: ' خلال مدة أقصاها '),
                                      TextSpan(
                                        text: '15 يوم',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: errorColor,
                                        ),
                                      ),
                                      const TextSpan(
                                        text:
                                            ' من تاريخ تقديم الطلب، وتقسّم المهلة الانتقالية إلى ',
                                      ),
                                      TextSpan(
                                        text: 'المراحل الإلزامية',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textPrimary,
                                        ),
                                      ),
                                      TextSpan(text: ' التالية:'),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Step2SettlementPhase(
                                  title:
                                      'السنة الأولى: مرحلة متطلبات البيئة والسلامة المهنية والأساسيات الضرورية',
                                  subtitle:
                                      'تحقيق شروط السلامة المهنية والبيئية بالإضافة إلى الأساسيات كالمسافات والأبعاد وحركة المرور.',
                                ),
                                Step2SettlementPhase(
                                  title:
                                      'السنة الثانية: مرحلة التكيّف الهندسي والتنظيمي',
                                  subtitle:
                                      'تحقيق المعدات، كالخزانات والمضخات والشمسيات مع بناء الإدارة.',
                                ),
                                Step2SettlementPhase(
                                  title:
                                      'السنة الثالثة: مرحلة الامتثال والاستقرار النهائي',
                                  subtitle:
                                      'بإكمال بقية الشروط الواردة في اشتراطات محطات الوقود وبحسب الفئة.',
                                ),
                                SizedBox(height: 10.h),
                                // Settlement agree checkbox
                                Obx(
                                  () => Container(
                                    key: ctrl.settlementAgreementFieldKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            ctrl.settledAgreed.toggle();
                                            if (ctrl.settledAgreed.value) {
                                              ctrl
                                                      .settlementAgreementError
                                                      .value =
                                                  '';
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Checkbox(
                                                value: ctrl.settledAgreed.value,
                                                onChanged: (v) {
                                                  ctrl.settledAgreed.value =
                                                      v ?? false;
                                                  if (ctrl
                                                      .settledAgreed
                                                      .value) {
                                                    ctrl
                                                            .settlementAgreementError
                                                            .value =
                                                        '';
                                                  }
                                                },
                                              ),
                                              SizedBox(width: 8.w),

                                              Flexible(
                                                child: Text(
                                                  'أقر بالاطلاع على متطلبات ومراحل تسوية أوضاع المحطات وأوافق على الالتزام بها.',
                                                  style: TextStyle(
                                                    fontFamily: 'Cairo',
                                                    fontSize: 12.sp,
                                                    color: textPrimary,
                                                  ),
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  softWrap: true,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (ctrl
                                            .settlementAgreementError
                                            .value
                                            .isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.only(top: 6.h),
                                            child: Text(
                                              ctrl
                                                  .settlementAgreementError
                                                  .value,
                                              style: TextStyle(
                                                fontFamily: 'Cairo',
                                                fontSize: 11.sp,
                                                color: errorColor,
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
                      );
                    }),

                    SizedBox(height: 20.h),
                    // Question 2
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Step2QuestionLabel(
                            number: 2,
                            text: 'باسم من سيصدر الترخيص؟',
                          ),
                          SizedBox(height: 10.h),
                          Obx(
                            () => isMobile
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      ChoiceCard(
                                        title: 'شركة',
                                        subtitle:
                                            'يتم إدخال اسم الشركة وأسماء الشركاء.',
                                        icon: Icons.business_outlined,
                                        selected:
                                            ctrl.investorType.value ==
                                            'company',
                                        enabled: !ctrl.isCorrectionMode.value,
                                        onTap: () =>
                                            ctrl.investorType.value = 'company',
                                      ),
                                      SizedBox(height: 10.h),
                                      ChoiceCard(
                                        title: 'مستثمر فردي',
                                        subtitle:
                                            'يتم إدخال الاسم الثلاثي لصاحب الطلب.',
                                        icon: Icons.person_outline,
                                        selected:
                                            ctrl.investorType.value ==
                                            'individual',
                                        enabled: !ctrl.isCorrectionMode.value,
                                        onTap: () => ctrl.investorType.value =
                                            'individual',
                                      ),
                                    ],
                                  )
                                : Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Expanded(
                                        child: ChoiceCard(
                                          title: 'شركة',
                                          subtitle:
                                              'يتم إدخال اسم الشركة وأسماء الشركاء.',
                                          icon: Icons.business_outlined,
                                          selected:
                                              ctrl.investorType.value ==
                                              'company',
                                          enabled: !ctrl.isCorrectionMode.value,
                                          onTap: () => ctrl.investorType.value =
                                              'company',
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: ChoiceCard(
                                          title: 'مستثمر فردي',
                                          subtitle:
                                              'يتم إدخال الاسم الثلاثي لصاحب الطلب.',
                                          icon: Icons.person_outline,
                                          selected:
                                              ctrl.investorType.value ==
                                              'individual',
                                          enabled: !ctrl.isCorrectionMode.value,
                                          onTap: () => ctrl.investorType.value =
                                              'individual',
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),

                    // Badge showing selection
                    Obx(() {
                      final label = ctrl.investorType.value == 'individual'
                          ? 'تم اختيار مستثمر فردي'
                          : 'تم اختيار شركة';
                      return Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Container(
                          margin: EdgeInsets.only(top: 10.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.sp,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Applicant Data
              Obx(
                () => SectionCard(
                  title: 'بيانات مقدم الطلب',
                  subtitle:
                      'أدخل البيانات الشخصية لمقدم الطلب كما هي مسجلة في الوثائق الرسمية.',
                  stepNumber: 3,
                  child: ctrl.investorType.value == 'individual'
                      ? Step2IndividualForm(ctrl: ctrl)
                      : Step2CompanyForm(ctrl: ctrl),
                ),
              ),

              // Error
              Obx(() => ErrorBanner(message: ctrl.errorMessage.value)),

              // Navigation
              Obx(
                () => NavigationButtons(
                  onNext: ctrl.submitStep2,
                  onPrev: ctrl.goToPreviousStep,
                  isLoading: ctrl.isLoading.value,
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
