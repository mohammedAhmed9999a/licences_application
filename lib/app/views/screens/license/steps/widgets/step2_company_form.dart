import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../theme/app_theme.dart';
import '../../../../../controllers/license_application_controller.dart';
import '../../../../widgets/common_widgets.dart';

class Step2CompanyForm extends StatelessWidget {
  final LicenseApplicationController ctrl;

  const Step2CompanyForm({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final textSecondary = context.themeTextSecondary;
    final surface = context.themeSurface;
    final surfaceAlt = context.themeSurfaceAlt;
    final borderColor = context.themeBorder;
    final textPrimary = context.themeTextPrimary;
    final textHint = context.themeTextHint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                FilteringTextInputFormatter.allow(
                  RegExp(r'[A-Za-z\u0600-\u06FF\s]'),
                ),
              ],
              maxLength: 15,
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
                FilteringTextInputFormatter.allow(
                  RegExp(r'[A-Za-z\u0600-\u06FF\s]'),
                ),
              ],
              maxLength: 15,
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
                FilteringTextInputFormatter.allow(
                  RegExp(r'[A-Za-z\u0600-\u06FF\s]'),
                ),
              ],
              maxLength: 15,
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
                FilteringTextInputFormatter.allow(
                  RegExp(r'[A-Za-z\u0600-\u06FF\s]'),
                ),
              ],
              maxLength: 15,
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
                FilteringTextInputFormatter.allow(
                  RegExp(r'[A-Za-z\u0600-\u06FF\s]'),
                ),
              ],
              maxLength: 30,
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
        Divider(height: 28.h),
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
              maxLength: 30,
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
                  onChanged: (v) =>
                      ctrl.validateStep2Field('companyLicenseNumber', v),
                  onSubmitted: (_) {
                    ctrl.validateStep2Field(
                      'companyLicenseNumber',
                      ctrl.companyLicenseNumberController.text,
                    );
                    FocusScope.of(context).unfocus();
                  },
                  maxLength: 30,
                  enabled: ctrl.isFieldEditable('companyLicenseNumber'),
                ),
              ),
            ),
            SizedBox(height: 16),
            Obx(() {
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
                          final initialDate =
                              ctrl.companyLicenseDate.value != null &&
                                  ctrl.companyLicenseDate.value!.isBefore(
                                    yesterday,
                                  )
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
            }),
          ],
        ),
        SizedBox(height: 16.h),
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
        Obx(() {
          final partnersText = ctrl.partners
              .map((p) => p.trim())
              .where((p) => p.isNotEmpty)
              .join('، ');
          if (partnersText.isEmpty) {
            return const SizedBox.shrink();
          }
          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: surfaceAlt,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              partnersText,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                color: textPrimary,
                height: 1.4,
              ),
              textDirection: TextDirection.rtl,
              softWrap: true,
            ),
          );
        }),
        Obx(() {
          final partnersEditable = ctrl.isFieldEditable('partners');
          return Column(
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
                          if (partnersEditable && ctrl.partners.length > 1)
                            IconButton(
                              onPressed: () => ctrl.removePartner(i),
                              icon: Icon(Icons.delete_outline, size: 18.r),
                              tooltip: 'حذف الشريك',
                            ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      TextField(
                        controller: ctrl.partnerTextControllers[i],
                        enabled: partnersEditable,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        onChanged: partnersEditable
                            ? (v) => ctrl.updatePartner(i, v)
                            : null,
                        maxLength: 50,
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
          );
        }),
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
        Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() {
              final partnersEditable = ctrl.isFieldEditable('partners');
              return OutlinedButton.icon(
                onPressed: partnersEditable ? ctrl.addPartner : null,
                icon: const Icon(Icons.add, size: 16),
                label: Text(
                  'إضافة شريك',
                  style: TextStyle(fontSize: 12.sp, fontFamily: 'Cairo'),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(0, 36.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                ),
              );
            }),
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
      ],
    );
  }
}
