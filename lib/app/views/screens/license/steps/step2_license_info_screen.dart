import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../../controllers/license_application_controller.dart';

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
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 12.h),
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
                    // Question 1
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _QuestionLabel(number: 1, text: 'ما نوع الطلب؟'),
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
                                _SettlementPhase(
                                  title:
                                      'السنة الأولى: مرحلة متطلبات البيئة والسلامة المهنية والأساسيات الضرورية',
                                  subtitle:
                                      'تحقيق شروط السلامة المهنية والبيئية بالإضافة إلى الأساسيات كالمسافات والأبعاد وحركة المرور.',
                                ),
                                _SettlementPhase(
                                  title:
                                      'السنة الثانية: مرحلة التكيّف الهندسي والتنظيمي',
                                  subtitle:
                                      'تحقيق المعدات، كالخزانات والمضخات والشمسيات مع بناء الإدارة.',
                                ),
                                _SettlementPhase(
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
                                              SizedBox(width: 8.w),
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
                          _QuestionLabel(
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
                            color: primaryColor.withOpacity(0.16),
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

              // ─── 3. Applicant Data ────────────────────────────────────────
              Obx(
                () => SectionCard(
                  title: 'بيانات مقدم الطلب',
                  subtitle:
                      'أدخل البيانات الشخصية لمقدم الطلب كما هي مسجلة في الوثائق الرسمية.',
                  stepNumber: 3,
                  child: ctrl.investorType.value == 'individual'
                      ? _IndividualForm(ctrl: ctrl)
                      : _CompanyForm(ctrl: ctrl),
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

class _QuestionLabel extends StatelessWidget {
  final int number;
  final String text;
  const _QuestionLabel({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.themeTextPrimary;

    final borderColor = context.themeBorder;
    final surfaceAlt = context.themeSurfaceAlt;

    return Row(
      textDirection: TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          textDirection: TextDirection.rtl,
        ),
        SizedBox(width: 8.w),
        Container(
          width: 26.w,
          height: 26.h,
          decoration: BoxDecoration(
            color: surfaceAlt,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: borderColor),
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettlementPhase extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SettlementPhase({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textSecondary = context.themeTextSecondary;
    final primaryColor = theme.colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    color: textSecondary,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.circle, size: 8.r, color: primaryColor),
        ],
      ),
    );
  }
}

// ─── Individual Form ──────────────────────────────────────────────────────────
class _IndividualForm extends StatelessWidget {
  final LicenseApplicationController ctrl;
  const _IndividualForm({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final textSecondary = context.themeTextSecondary;
    final surface = context.themeSurface;
    final borderColor = context.themeBorder;
    final textPrimary = context.themeTextPrimary;
    final textHint = context.themeTextHint;
    return Column(
      textDirection: TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'بيانات مقدم الطلب',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: 4.h),
        Text(
          'أدخل البيانات الشخصية لمقدم الطلب كما هي مسجلة في الوثائق الرسمية.',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11.sp,
            color: textSecondary,
          ),
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: 16.h),
        // Row 1: First name + Father name
        LayoutBuilder(
          builder: (context, constraints) {
            final useColumnLayout = constraints.maxWidth < 360;

            if (useColumnLayout) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Obx(
                    () => LabeledField(
                      key: ctrl.firstNameFieldKey,
                      label: 'الاسم الأول',
                      required: true,
                      errorText: ctrl.firstNameError.value,
                      child: RtlTextField(
                        controller: ctrl.firstNameController,
                        focusNode: ctrl.firstNameFocus,
                        hintText: 'الاسم الأول بالهوية الشخصية',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\u0600-\u06FF\s]'),
                          ),
                        ],
                        maxLength: 50,
                        textInputAction: TextInputAction.next,
                        onChanged: (v) =>
                            ctrl.validateStep2Field('firstName', v),
                        onSubmitted: (_) =>
                            ctrl.requestFocus(ctrl.fatherNameFocus),
                        enabled: ctrl.isFieldEditable('firstName'),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Obx(
                    () => LabeledField(
                      key: ctrl.fatherNameFieldKey,
                      label: 'اسم الأب',
                      required: true,
                      errorText: ctrl.fatherNameError.value,

                      child: RtlTextField(
                        controller: ctrl.fatherNameController,
                        focusNode: ctrl.fatherNameFocus,
                        hintText: 'اسم الأب',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\u0600-\u06FF\s]'),
                          ),
                        ],
                        maxLength: 50,
                        textInputAction: TextInputAction.next,
                        onChanged: (v) =>
                            ctrl.validateStep2Field('fatherName', v),
                        onSubmitted: (_) =>
                            ctrl.requestFocus(ctrl.nicknameFocus),
                        enabled: ctrl.isFieldEditable('fatherName'),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: Obx(
                    () => LabeledField(
                      key: ctrl.fatherNameFieldKey,
                      label: 'اسم الأب',
                      required: true,
                      errorText: ctrl.fatherNameError.value,
                      child: RtlTextField(
                        controller: ctrl.fatherNameController,
                        hintText: 'اسم الأب',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\u0600-\u06FF\s]'),
                          ),
                        ],
                        maxLength: 50,
                        onChanged: (_) => ctrl.fatherNameError.value = '',
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Obx(
                    () => LabeledField(
                      key: ctrl.firstNameFieldKey,
                      label: 'الاسم الأول',
                      required: true,
                      errorText: ctrl.firstNameError.value,
                      child: RtlTextField(
                        controller: ctrl.firstNameController,
                        focusNode: ctrl.firstNameFocus,
                        hintText: 'الاسم الأول بالهوية الشخصية',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\u0600-\u06FF\s]'),
                          ),
                        ],
                        maxLength: 50,
                        textInputAction: TextInputAction.next,
                        onChanged: (v) =>
                            ctrl.validateStep2Field('firstName', v),
                        onSubmitted: (_) =>
                            ctrl.requestFocus(ctrl.fatherNameFocus),
                        enabled: ctrl.isFieldEditable('firstName'),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: 12.h),
        // Row 2: Nickname + Mother name
        LayoutBuilder(
          builder: (context, constraints) {
            final useColumnLayout = constraints.maxWidth < 360;

            if (useColumnLayout) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Obx(
                    () => LabeledField(
                      key: ctrl.nicknameFieldKey,
                      label: 'الكنية',
                      required: true,
                      errorText: ctrl.nicknameError.value,
                      child: RtlTextField(
                        controller: ctrl.nicknameController,
                        focusNode: ctrl.nicknameFocus,
                        hintText: 'الكنية',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\u0600-\u06FF\s]'),
                          ),
                        ],
                        maxLength: 50,
                        textInputAction: TextInputAction.next,
                        onChanged: (v) =>
                            ctrl.validateStep2Field('nickname', v),
                        onSubmitted: (_) =>
                            ctrl.requestFocus(ctrl.motherNameFocus),
                        enabled: ctrl.isFieldEditable('nickname'),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Obx(
                    () => LabeledField(
                      key: ctrl.motherNameFieldKey,
                      label: 'اسم الأم',
                      required: true,
                      errorText: ctrl.motherNameError.value,
                      child: RtlTextField(
                        controller: ctrl.motherNameController,
                        focusNode: ctrl.motherNameFocus,
                        hintText: 'اسم الأم',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\u0600-\u06FF\s]'),
                          ),
                        ],
                        maxLength: 50,
                        textInputAction: TextInputAction.next,
                        onChanged: (v) =>
                            ctrl.validateStep2Field('motherName', v),
                        onSubmitted: (_) =>
                            ctrl.requestFocus(ctrl.nationalIdFocus),
                        enabled: ctrl.isFieldEditable('motherName'),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: Obx(
                    () => LabeledField(
                      key: ctrl.motherNameFieldKey,
                      label: 'اسم الأم',
                      required: true,
                      errorText: ctrl.motherNameError.value,
                      child: RtlTextField(
                        controller: ctrl.motherNameController,
                        focusNode: ctrl.motherNameFocus,
                        hintText: 'اسم الأم',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\u0600-\u06FF\s]'),
                          ),
                        ],
                        maxLength: 50,
                        textInputAction: TextInputAction.next,
                        onChanged: (v) =>
                            ctrl.validateStep2Field('motherName', v),
                        onSubmitted: (_) =>
                            ctrl.requestFocus(ctrl.nationalIdFocus),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Obx(
                    () => LabeledField(
                      key: ctrl.nicknameFieldKey,
                      label: 'الكنية',
                      required: true,
                      errorText: ctrl.nicknameError.value,
                      child: RtlTextField(
                        controller: ctrl.nicknameController,
                        focusNode: ctrl.nicknameFocus,
                        hintText: 'الكنية',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\u0600-\u06FF\s]'),
                          ),
                        ],
                        maxLength: 50,
                        textInputAction: TextInputAction.next,
                        onChanged: (v) =>
                            ctrl.validateStep2Field('nickname', v),
                        onSubmitted: (_) =>
                            ctrl.requestFocus(ctrl.motherNameFocus),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: 12.h),
        // Row 3: Birth place + National ID
        LayoutBuilder(
          builder: (context, constraints) {
            final useColumnLayout = constraints.maxWidth < 360;

            if (useColumnLayout) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Obx(
                    () => LabeledField(
                      key: ctrl.nationalIdFieldKey,
                      label: 'الرقم الوطني',
                      required: true,
                      errorText: ctrl.nationalIdError.value,

                      child: RtlTextField(
                        controller: ctrl.nationalIdController,
                        focusNode: ctrl.nationalIdFocus,
                        hintText: 'مثال: 070XXXXX',
                        keyboardType: TextInputType.number,

                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        maxLength: 12,
                        textInputAction: TextInputAction.next,
                        onChanged: (v) =>
                            ctrl.validateStep2Field('nationalId', v),
                        onSubmitted: (_) =>
                            ctrl.requestFocus(ctrl.birthPlaceFocus),
                        enabled: ctrl.isFieldEditable('nationalId'),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Obx(
                    () => LabeledField(
                      key: ctrl.birthPlaceFieldKey,
                      label: 'مكان الولادة',
                      required: true,
                      errorText: ctrl.birthPlaceError.value,
                      child: RtlTextField(
                        controller: ctrl.birthPlaceController,
                        focusNode: ctrl.birthPlaceFocus,
                        hintText: 'مكان الولادة',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\u0600-\u06FF\s]'),
                          ),
                        ],
                        maxLength: 50,
                        textInputAction: TextInputAction.next,
                        onChanged: (v) =>
                            ctrl.validateStep2Field('birthPlace', v),
                        onSubmitted: (_) =>
                            ctrl.requestFocus(ctrl.birthPlaceFocus),
                        enabled: ctrl.isFieldEditable('birthPlace'),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: Obx(
                    () => LabeledField(
                      key: ctrl.birthPlaceFieldKey,
                      label: 'مكان الولادة',
                      required: true,
                      errorText: ctrl.birthPlaceError.value,
                      child: RtlTextField(
                        controller: ctrl.birthPlaceController,
                        focusNode: ctrl.birthPlaceFocus,
                        hintText: 'مكان الولادة',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\u0600-\u06FF\s]'),
                          ),
                        ],
                        maxLength: 50,
                        textInputAction: TextInputAction.next,
                        onChanged: (v) =>
                            ctrl.validateStep2Field('birthPlace', v),
                        onSubmitted: (_) =>
                            ctrl.requestFocus(ctrl.nationalIdFocus),
                        enabled: ctrl.isFieldEditable('birthPlace'),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Obx(
                    () => LabeledField(
                      key: ctrl.nationalIdFieldKey,
                      label: 'الرقم الوطني',
                      required: true,
                      errorText: ctrl.nationalIdError.value,
                      child: RtlTextField(
                        controller: ctrl.nationalIdController,
                        onChanged: (v) =>
                            ctrl.validateStep2Field('nationalId', v),
                        hintText: 'مثال: 070XXXXX',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        maxLength: 12,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: 12.h),
        // Birth date
        Obx(
          () {
            final birthDateEditable = ctrl.isFieldEditable('birthDate');
            return LabeledField(
              key: ctrl.birthDateFieldKey,
              label: 'تاريخ الولادة',
              required: true,
              errorText: ctrl.birthDateError.value,
              child: GestureDetector(
                onTap: birthDateEditable
                    ? () async {
                        final lastDate = DateTime.now().subtract(
                          const Duration(days: 365 * 18),
                        );
                        final initialDate = ctrl.birthDate.value != null
                            ? (ctrl.birthDate.value!.isBefore(lastDate)
                                  ? ctrl.birthDate.value!
                                  : lastDate)
                            : DateTime(1990);
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime(1920),
                          lastDate: lastDate,
                          builder: (ctx, child) => Directionality(
                            textDirection: TextDirection.rtl,
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          ctrl.birthDate.value = picked;
                          ctrl.validateStep2Field('birthDate', '');
                        }
                      }
                    : null,
                child: AbsorbPointer(
                  absorbing: !birthDateEditable,
                  child: Container(
                    height: 48.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Obx(
                          () => Text(
                            ctrl.birthDate.value != null
                                ? '${ctrl.birthDate.value!.day}/${ctrl.birthDate.value!.month}/${ctrl.birthDate.value!.year}'
                                : 'انقر لتحديد تاريخ ميلادك',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13.sp,
                              color: ctrl.birthDate.value != null
                                  ? textPrimary
                                  : textHint,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 18.r,
                          color: textHint,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 6.h),
        Text(
          'يجب أن لا يقل عمر مقدم الطلب عن 18 سنة.',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10.sp,
            color: textHint,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}

// ─── Company Form ─────────────────────────────────────────────────────────────
class _CompanyForm extends StatelessWidget {
  final LicenseApplicationController ctrl;
  const _CompanyForm({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final textSecondary = context.themeTextSecondary;
    final surface = context.themeSurface;
    final surfaceAlt = context.themeSurfaceAlt;
    final borderColor = context.themeBorder;
    final textPrimary = context.themeTextPrimary;
    final textHint = context.themeTextHint;

    return Column(
      // textDirection: TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'بيانات مقدم الطلب',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: 16.h),
        Text(
          'البيانات الأساسية لممثل الشركة',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: 6.h),
        Text(
          'يتم طلب الاسم الأول والكنية والرقم الوطني فقط لممثل الشركة؛ ويمكن إدخال باقي بيانات مقدم الطلب اختيارياً.',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11.sp,
            color: textSecondary,
          ),
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: 12.h),
        Obx(
          () => LabeledField(
            key: ctrl.firstNameFieldKey,
            label: 'الاسم الأول',
            required: true,
            errorText: ctrl.firstNameError.value,
            child: RtlTextField(
              controller: ctrl.firstNameController,
              focusNode: ctrl.firstNameFocus,
              hintText: 'الاسم الأول',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]')),
              ],
              maxLength: 50,
              textInputAction: TextInputAction.next,
              onChanged: (v) => ctrl.validateStep2Field('firstName', v),
              onSubmitted: (_) => ctrl.requestFocus(ctrl.nicknameFocus),
              enabled: ctrl.isFieldEditable('firstName'),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => LabeledField(
            key: ctrl.nicknameFieldKey,
            label: 'الكنية',
            required: true,
            errorText: ctrl.nicknameError.value,
            child: RtlTextField(
              controller: ctrl.nicknameController,
              focusNode: ctrl.nicknameFocus,
              hintText: 'الكنية',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]')),
              ],
              maxLength: 50,
              textInputAction: TextInputAction.next,
              onChanged: (v) => ctrl.validateStep2Field('nickname', v),
              onSubmitted: (_) => ctrl.requestFocus(ctrl.nationalIdFocus),
              enabled: ctrl.isFieldEditable('nickname'),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => LabeledField(
            key: ctrl.nationalIdFieldKey,
            label: 'الرقم الوطني',
            required: true,
            errorText: ctrl.nationalIdError.value,
            child: RtlTextField(
              controller: ctrl.nationalIdController,
              focusNode: ctrl.nationalIdFocus,
              hintText: 'مثال: 070XXXXX',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 12,
              textInputAction: TextInputAction.next,
              onChanged: (v) => ctrl.validateStep2Field('nationalId', v),
              onSubmitted: (_) => ctrl.requestFocus(ctrl.fatherNameFocus),
              enabled: ctrl.isFieldEditable('nationalId'),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => LabeledField(
            key: ctrl.fatherNameFieldKey,
            label: 'اسم الأب',
            required: false,
            errorText: ctrl.fatherNameError.value,
            child: RtlTextField(
              controller: ctrl.fatherNameController,
              focusNode: ctrl.fatherNameFocus,
              hintText: 'اسم الأب',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]')),
              ],
              maxLength: 50,
              textInputAction: TextInputAction.next,
              onChanged: (v) => ctrl.validateStep2Field('fatherName', v),
              onSubmitted: (_) => ctrl.requestFocus(ctrl.motherNameFocus),
              enabled: ctrl.isFieldEditable('fatherName'),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => LabeledField(
            key: ctrl.motherNameFieldKey,
            label: 'اسم الأم',
            required: false,
            errorText: ctrl.motherNameError.value,
            child: RtlTextField(
              controller: ctrl.motherNameController,
              focusNode: ctrl.motherNameFocus,
              hintText: 'اسم الأم',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]')),
              ],
              maxLength: 50,
              textInputAction: TextInputAction.next,
              onChanged: (v) => ctrl.validateStep2Field('motherName', v),
              onSubmitted: (_) => ctrl.requestFocus(ctrl.birthPlaceFocus),
              enabled: ctrl.isFieldEditable('motherName'),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => LabeledField(
            key: ctrl.birthPlaceFieldKey,
            label: 'مكان الولادة',
            required: false,
            errorText: ctrl.birthPlaceError.value,
            child: RtlTextField(
              controller: ctrl.birthPlaceController,
              focusNode: ctrl.birthPlaceFocus,
              hintText: 'مكان الولادة',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]')),
              ],
              maxLength: 50,
              textInputAction: TextInputAction.next,
              onChanged: (v) => ctrl.validateStep2Field('birthPlace', v),
              onSubmitted: (_) => ctrl.requestFocus(ctrl.birthDateFocus),
              enabled: ctrl.isFieldEditable('birthPlace'),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() {
          final birthDateEditable = ctrl.isFieldEditable('birthDate');
          return LabeledField(
            key: ctrl.birthDateFieldKey,
            label: 'تاريخ الولادة',
            required: false,
            errorText: ctrl.birthDateError.value,
            child: GestureDetector(
              onTap: birthDateEditable
                  ? () async {
                      final lastDate = DateTime.now().subtract(
                        const Duration(days: 365 * 18),
                      );
                      final initialDate = ctrl.birthDate.value != null
                          ? (ctrl.birthDate.value!.isBefore(lastDate)
                                ? ctrl.birthDate.value!
                                : lastDate)
                          : DateTime(1990);
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: DateTime(1920),
                        lastDate: lastDate,
                        builder: (ctx, child) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        ctrl.birthDate.value = picked;
                        ctrl.validateStep2Field('birthDate', '');
                      }
                    }
                  : null,
              child: AbsorbPointer(
                absorbing: !birthDateEditable,
                child: Container(
                  height: 48.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Obx(
                        () => Text(
                          ctrl.birthDate.value != null
                              ? '${ctrl.birthDate.value!.day}/${ctrl.birthDate.value!.month}/${ctrl.birthDate.value!.year}'
                              : 'انقر لتحديد تاريخ ميلادك',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.sp,
                            color: ctrl.birthDate.value != null
                                ? textPrimary
                                : textHint,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.calendar_today_outlined, size: 18.r, color: textHint),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        Divider(height: 28.h),

        // Company data
        Obx(
          () => LabeledField(
            key: ctrl.companyNameFieldKey,
            label: 'اسم الشركة',
            required: true,
            errorText: ctrl.companyNameError.value,
            child: RtlTextField(
              controller: ctrl.companyNameController,
              focusNode: ctrl.companyNameFocus,
              hintText: 'اسم الشركة',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]')),
              ],
              maxLength: 100,
              textInputAction: TextInputAction.next,
              onChanged: (v) => ctrl.validateStep2Field('companyName', v),
              onSubmitted: (_) =>
                  ctrl.requestFocus(ctrl.companyLicenseNumberFocus),
              enabled: ctrl.isFieldEditable('companyName'),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Column(
          children: [
            // رقم ترخيص الشركة
            Obx(
              () => LabeledField(
                key: ctrl.companyLicenseNumberFieldKey,
                label: 'رقم ترخيص الشركة',
                required: true,
                errorText: ctrl.companyLicenseNumberError.value,
                child: RtlTextField(
                  controller: ctrl.companyLicenseNumberController,
                  focusNode: ctrl.companyLicenseNumberFocus,
                  hintText: 'رقم ترخيص الشركة',
                  keyboardType: TextInputType.text,
                  // Allow all input so we can validate and show message on submit
                  onChanged: (v) =>
                      ctrl.validateStep2Field('companyLicenseNumber', v),
                  onSubmitted: (_) {
                    ctrl.validateStep2Field(
                      'companyLicenseNumber',
                      ctrl.companyLicenseNumberController.text,
                    );
                    FocusScope.of(context).unfocus();
                  },
                  enabled: ctrl.isFieldEditable('companyLicenseNumber'),
                ),
              ),
            ),

            SizedBox(height: 16),

            // تاريخ ترخيص الشركة
            Obx(
              () {
                final editable = ctrl.isFieldEditable('companyLicenseDate');
                return LabeledField(
                  key: ctrl.companyLicenseDateFieldKey,
                  label: 'تاريخ ترخيص الشركة',
                  required: true,
                  errorText: ctrl.companyLicenseDateError.value,
                  child: GestureDetector(
                    onTap: editable
                        ? () async {
                            final yesterday = DateTime.now().subtract(
                              const Duration(days: 1),
                            );
                            final initialDate = ctrl.companyLicenseDate.value != null &&
                                    ctrl.companyLicenseDate.value!.isBefore(yesterday)
                                ? ctrl.companyLicenseDate.value!
                                : yesterday;
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: DateTime(1950),
                              lastDate: yesterday,
                            );
                            if (picked != null) {
                              ctrl.companyLicenseDate.value = picked;
                              ctrl.validateStep2Field('companyLicenseDate', '');
                            }
                          }
                        : null,
                    child: AbsorbPointer(
                      absorbing: !editable,
                      child: Container(
                        height: 48.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                ctrl.companyLicenseDate.value != null
                                    ? '${ctrl.companyLicenseDate.value!.day}/${ctrl.companyLicenseDate.value!.month}/${ctrl.companyLicenseDate.value!.year}'
                                    : 'اختر تاريخ الترخيص',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13.sp,
                                  color: ctrl.companyLicenseDate.value != null
                                      ? textPrimary
                                      : textHint,
                                ),
                              ),
                            ),
                            SizedBox(width: 170.w),
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 18.r,
                              color: textHint,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),

        SizedBox(height: 16.h),
        // Partners
        Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: ctrl.addPartner,
              icon: const Icon(Icons.add, size: 16),
              label: Text(
                'إضافة شريك',
                style: TextStyle(fontSize: 12.sp, fontFamily: 'Cairo'),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(0, 36.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
              ),
            ),
            Text(
              'أسماء الشركاء (اختياري)',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          'أدخل أسماء الشركاء المسجلين في الشركة إن وجدت، وهي اختيارية.',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11.sp,
            color: textSecondary,
          ),
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: 10.h),
        Obx(
          () => Column(
            children: List.generate(
              ctrl.partners.length,
              (i) => Padding(
                key: ctrl.partnersKeys[i],
                padding: EdgeInsets.only(bottom: 8.h),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: surfaceAlt,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'اسم الشريك ${i + 1}',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ctrl.partners.length > 1
                              ? IconButton(
                                  onPressed: () => ctrl.removePartner(i),
                                  icon: Icon(Icons.delete_outline, size: 18.r),
                                  tooltip: 'حذف الشريك',
                                )
                              : Container(),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      TextField(
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        onChanged: (v) => ctrl.updatePartner(i, v),
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp),
                        decoration: InputDecoration(
                          hintText: 'الاسم الثلاثي للشريك',
                          hintTextDirection: TextDirection.rtl,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Obx(
          () => ctrl.partners.isEmpty
              ? Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: surfaceAlt,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'شريك واحد حالياً',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.sp,
                          color: textHint,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
