import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../theme/app_theme.dart';
import '../../../../../controllers/license_application_controller.dart';
import '../../../../widgets/common_widgets.dart';

class Step2IndividualForm extends StatelessWidget {
  final LicenseApplicationController ctrl;

  const Step2IndividualForm({super.key, required this.ctrl});

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
                            RegExp(r'[A-Za-z\u0600-\u06FF\s]'),
                          ),
                        ],
                        maxLength: 15,
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
                            RegExp(r'[A-Za-z\u0600-\u06FF\s]'),
                          ),
                        ],
                        maxLength: 15,
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
                            RegExp(r'[A-Za-z\u0600-\u06FF\s]'),
                          ),
                        ],
                        maxLength: 15,
                        onChanged: (v) =>
                            ctrl.validateStep2Field('fatherName', v),
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
                        maxLength: 15,
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
                            RegExp(r'[A-Za-z\u0600-\u06FF\s]'),
                          ),
                        ],
                        maxLength: 15,
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
                            RegExp(r'[A-Za-z\u0600-\u06FF\s]'),
                          ),
                        ],
                        maxLength: 15,
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
                            RegExp(r'[A-Za-z\u0600-\u06FF\s]'),
                          ),
                        ],
                        maxLength: 15,
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
                            RegExp(r'[A-Za-z\u0600-\u06FF\s]'),
                          ),
                        ],
                        maxLength: 15,
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
                            RegExp(r'[A-Za-z\u0600-\u06FF\s]'),
                          ),
                        ],
                        maxLength: 30,
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
                        maxLength: 30,
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
        Obx(() {
          final birthDateEditable = ctrl.isFieldEditable('birthDate');
          return LabeledField(
            key: ctrl.birthDateFieldKey,
            label: 'تاريخ الولادة',
            required: true,
            errorText: ctrl.birthDateError.value,
            child: GestureDetector(
              onTap: birthDateEditable
                  ? () async {
                      final today = DateTime.now();
                      final minimumBirthDate = DateTime(
                        today.year - 18,
                        today.month,
                        today.day,
                      );
                      final initialDate = ctrl.birthDate.value != null
                          ? (ctrl.birthDate.value!.isAfter(minimumBirthDate)
                                ? minimumBirthDate
                                : ctrl.birthDate.value!)
                          : minimumBirthDate;
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: DateTime(1920),
                        lastDate: minimumBirthDate,
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
        }),
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
