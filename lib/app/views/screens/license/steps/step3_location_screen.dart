import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../../controllers/license_application_controller.dart';

class Step3LocationScreen extends StatelessWidget {
  const Step3LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LicenseApplicationController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. Location Data ─────────────────────────────────────────
            SectionCard(
              title: 'الموقع والتصنيف',
              subtitle:
                  'أدخل العنوان الكامل، الإحداثيات، ثم اختر موقع المحطة بالنسبة للتنظيم والفئة المناسبة.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const RequiredFieldsBanner(),
                  SizedBox(height: 14.h),
                ],
              ),
            ),

            // ─── Location Data Card ───────────────────────────────────────
            SectionCard(
              title: 'بيانات الموقع',
              stepNumber: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Address / Coordinates tab
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundAlt,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundAlt,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'العنوان والإحداثيات',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  SizedBox(height: 6.h),
                  // Location status
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          _locationStatusText(ctrl.locationStatus.value),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color: _locationStatusColor(
                              ctrl.locationStatus.value,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'الحالة:',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),
                  // Governorate dropdowns
                  LabeledField(
                    label: 'المحافظة',
                    required: true,
                    child: Obx(
                      () => _DropdownField(
                        hint: 'اختر المحافظة',
                        value: ctrl.selectedGovernorate.value?.name,
                        items: ctrl.governorates.map((g) => g.name).toList(),
                        onChanged: (val) {
                          final gov = ctrl.governorates.firstWhereOrNull(
                            (g) => g.name == val,
                          );
                          ctrl.onGovernorateChanged(gov);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  LabeledField(
                    label: 'المنطقة',
                    required: true,
                    child: Obx(
                      () => _DropdownField(
                        hint: 'اختر المنطقة',
                        value: ctrl.selectedDistrict.value?.name,
                        items: ctrl.districts.map((g) => g.name).toList(),
                        onChanged: (val) {
                          final d = ctrl.districts.firstWhereOrNull(
                            (g) => g.name == val,
                          );
                          ctrl.onDistrictChanged(d);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  LabeledField(
                    label: 'الناحية',
                    required: true,
                    child: Obx(
                      () => _DropdownField(
                        hint: 'اختر الناحية',
                        value: ctrl.selectedSubdistrict.value?.name,
                        items: ctrl.subdistricts.map((g) => g.name).toList(),
                        onChanged: (val) {
                          final s = ctrl.subdistricts.firstWhereOrNull(
                            (g) => g.name == val,
                          );
                          ctrl.onSubdistrictChanged(s);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  LabeledField(
                    label: 'البلدة',
                    required: true,
                    child: Obx(
                      () => _DropdownField(
                        hint: 'اختر البلدة',
                        value: ctrl.selectedTown.value?.name,
                        items: ctrl.towns.map((g) => g.name).toList(),
                        onChanged: (val) {
                          final t = ctrl.towns.firstWhereOrNull(
                            (g) => g.name == val,
                          );
                          ctrl.selectedTown.value = t;
                          if (t?.latitude != null && t?.longitude != null) {
                            ctrl.setLocation(t!.latitude!, t.longitude!);
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Map instruction box
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundAlt,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'تحديد الموقع على الخريطة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'حدد موقع المحطة بإحدى الطرق الثلاث: اكتب الإحداثيات يدوياً، أو اضغط على الخريطة لوضع الدبوس، أو اضغط زر "أنا في المحطة الآن استخدم موقعي" لتحديد موقع المحطة تلقائياً إذا كنت هناك الآن.',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        SizedBox(height: 10.h),
                        // Use my location button
                        OutlinedButton.icon(
                          onPressed: () => _useMyLocation(ctrl, context),
                          icon: Icon(Icons.my_location, size: 15.sp),
                          label: Text(
                            'أنا في المحطة الآن استخدم موقعي',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 38.h),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // Warning
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: AppColors.warning.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  'يرجى تحديد موقع محطة الوقود الفعلي بدقة على الخريطة. تجنب اختيار موقع عشوائي؛ إذ قد يؤثر عدم دقة الموقع على سير معالجة الطلب.',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 10.sp,
                                    color: AppColors.warning,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.info_outline,
                                color: AppColors.warning,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Actual map picker
                  Container(
                    height: 280.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: _LocationPickerMap(
                        latitudeController: ctrl.latitudeController,
                        longitudeController: ctrl.longitudeController,
                        onLocationSelected: (position) {
                          ctrl.setLocation(
                            position.latitude,
                            position.longitude,
                          );
                        },
                      ),
                    ),
                  ),
                  // Lat / Long
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final useColumnLayout = constraints.maxWidth < 360;

                      if (useColumnLayout) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            LabeledField(
                              label: 'خط العرض',
                              required: true,
                              child: RtlTextField(
                                controller: ctrl.latitudeController,
                                hintText: '33.xxxxxx',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            LabeledField(
                              label: 'خط الطول',
                              required: true,
                              child: RtlTextField(
                                controller: ctrl.longitudeController,
                                hintText: '36.xxxxxx',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
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
                            child: LabeledField(
                              label: 'خط الطول',
                              required: true,
                              child: RtlTextField(
                                controller: ctrl.longitudeController,
                                hintText: '36.xxxxxx',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: LabeledField(
                              label: 'خط العرض',
                              required: true,
                              child: RtlTextField(
                                controller: ctrl.latitudeController,
                                hintText: '33.xxxxxx',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // ─── 2. Planning Location ─────────────────────────────────────
            SectionCard(
              title: 'موقع المحطة بالنسبة للتنظيم',
              stepNumber: 2,
              badgeText: 'اختيار واحد',
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final useColumnLayout = constraints.maxWidth < 360;
                  return Obx(() {
                    if (useColumnLayout) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ChoiceCard(
                            title: 'خارج التنظيم',
                            subtitle: 'يتطلب تحديد نوع الطريق والفئة المناسبة.',
                            icon: Icons.location_city_outlined,
                            selected: ctrl.planningLocation.value == 'outside',
                            onTap: () =>
                                ctrl.planningLocation.value = 'outside',
                          ),
                          SizedBox(height: 10.h),
                          ChoiceCard(
                            title: 'داخل التنظيم',
                            subtitle:
                                'الفئة ج للطرق المحلية ضمن حدود الوحدات الإدارية.',
                            icon: Icons.home_outlined,
                            selected: ctrl.planningLocation.value == 'inside',
                            onTap: () => ctrl.planningLocation.value = 'inside',
                          ),
                        ],
                      );
                    }

                    return Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          child: ChoiceCard(
                            title: 'خارج التنظيم',
                            subtitle: 'يتطلب تحديد نوع الطريق والفئة المناسبة.',
                            icon: Icons.location_city_outlined,
                            selected: ctrl.planningLocation.value == 'outside',
                            onTap: () =>
                                ctrl.planningLocation.value = 'outside',
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: ChoiceCard(
                            title: 'داخل التنظيم',
                            subtitle:
                                'الفئة ج للطرق المحلية ضمن حدود الوحدات الإدارية.',
                            icon: Icons.home_outlined,
                            selected: ctrl.planningLocation.value == 'inside',
                            onTap: () => ctrl.planningLocation.value = 'inside',
                          ),
                        ),
                      ],
                    );
                  });
                },
              ),
            ),

            // ─── 3. Road Type & Category ──────────────────────────────────
            SectionCard(
              title: 'نوع الطريق والفئة',
              stepNumber: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Planning badge
                  Obx(() {
                    final isInside = ctrl.planningLocation.value == 'inside';
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        isInside
                            ? 'داخل التنظيم: تظهر الفئة ج فقط'
                            : 'خارج التنظيم: تظهر الفئات أ، ب، ج',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 14.h),

                  // Road type - only for outside planning
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final useColumnLayout = constraints.maxWidth < 360;
                      return Obx(() {
                        if (ctrl.planningLocation.value == 'inside') {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'نوع الطريق',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'اختيار نوع الطريق يحدد الفئات المتاحة تلقائياً.',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11.sp,
                                color: AppColors.textSecondary,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            //
                            SizedBox(height: 10.h),
                            if (useColumnLayout)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ChoiceCard(
                                    title: 'طرق مركزية بين المحافظات',
                                    subtitle: 'يسمح باختيار الفئة أ أو ب.',
                                    icon: Icons.swap_horiz,
                                    selected: ctrl.roadType.value == 'central',
                                    onTap: () =>
                                        ctrl.roadType.value = 'central',
                                  ),
                                  SizedBox(height: 10.h),
                                  ChoiceCard(
                                    title: 'طرق دولية (M4 و M5)',
                                    subtitle: 'يسمح باختيار الفئة أ فقط.',
                                    icon: Icons.arrow_outward,
                                    selected:
                                        ctrl.roadType.value == 'international',
                                    onTap: () =>
                                        ctrl.roadType.value = 'international',
                                  ),
                                ],
                              )
                            else
                              Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  Expanded(
                                    child: ChoiceCard(
                                      title: 'طرق مركزية بين المحافظات',
                                      subtitle: 'يسمح باختيار الفئة أ أو ب.',
                                      icon: Icons.swap_horiz,
                                      selected:
                                          ctrl.roadType.value == 'central',
                                      onTap: () =>
                                          ctrl.roadType.value = 'central',
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: ChoiceCard(
                                      title: 'طرق دولية (M4 و M5)',
                                      subtitle: 'يسمح باختيار الفئة أ فقط.',
                                      icon: Icons.arrow_outward,
                                      selected:
                                          ctrl.roadType.value ==
                                          'international',
                                      onTap: () =>
                                          ctrl.roadType.value = 'international',
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(height: 16.h),
                          ],
                        );
                      });
                    },
                  ),

                  // Category
                  Text(
                    'الفئة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: 4.h),
                  Obx(() {
                    final isInside = ctrl.planningLocation.value == 'inside';
                    final isInternational =
                        ctrl.roadType.value == 'international';
                    final subtitle = isInside
                        ? 'داخل التنظيم يسمح بالفئة ج فقط.'
                        : isInternational
                        ? 'خارج التنظيم مع طرق دولية (M4 و M5) يسمح بالفئة أ فقط.'
                        : 'خارج التنظيم مع طرق مركزية بين المحافظات يسمح بالفئة أ أو ب.';
                    return Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                      textDirection: TextDirection.rtl,
                    );
                  }),
                  SizedBox(height: 10.h),

                  // Category buttons
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final useColumnLayout = constraints.maxWidth < 360;
                      return Obx(() {
                        final isInside =
                            ctrl.planningLocation.value == 'inside';
                        final isInternational =
                            ctrl.roadType.value == 'international';
                        final isCentral = ctrl.roadType.value == 'central';

                        final canA =
                            !isInside && (isInternational || isCentral);
                        final canB = !isInside && isCentral;
                        final canC = isInside;

                        // Auto-select restricted category
                        if (isInside && ctrl.stationCategory.value != 'C') {
                          ctrl.stationCategory.value = 'C';
                        } else if (isInternational &&
                            ctrl.stationCategory.value != 'A') {
                          ctrl.stationCategory.value = 'A';
                        } else if (isCentral &&
                            !(ctrl.stationCategory.value == 'A' ||
                                ctrl.stationCategory.value == 'B')) {
                          ctrl.stationCategory.value = 'A';
                        }

                        if (useColumnLayout) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (canC)
                                _CategoryCard(
                                  label: 'الفئة ج',
                                  arabicLetter: 'ج',
                                  description:
                                      'الطرق المحلية ضمن حدود الوحدات الإدارية.',
                                  selected: ctrl.stationCategory.value == 'C',
                                  enabled: canC,
                                  onTap: canC
                                      ? () => ctrl.stationCategory.value = 'C'
                                      : null,
                                ),
                              if (canC) SizedBox(height: 10.h),
                              if (canB)
                                _CategoryCard(
                                  label: 'الفئة ب',
                                  arabicLetter: 'ب',
                                  description: 'الطرق المركزية بين المحافظات.',
                                  selected: ctrl.stationCategory.value == 'B',
                                  enabled: canB,
                                  onTap: canB
                                      ? () => ctrl.stationCategory.value = 'B'
                                      : null,
                                ),
                              if (canB) SizedBox(height: 10.h),
                              if (canA)
                                _CategoryCard(
                                  label: 'الفئة أ',
                                  arabicLetter: 'أ',
                                  description:
                                      'الطرق الدولية أو المسارات الأعلى تصنيفاً.',
                                  selected: ctrl.stationCategory.value == 'A',
                                  enabled: canA,
                                  onTap: canA
                                      ? () => ctrl.stationCategory.value = 'A'
                                      : null,
                                ),
                            ],
                          );
                        }

                        return Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            if (canC)
                              Expanded(
                                child: _CategoryCard(
                                  label: 'الفئة ج',
                                  arabicLetter: 'ج',
                                  description:
                                      'الطرق المحلية ضمن حدود الوحدات الإدارية.',
                                  selected: ctrl.stationCategory.value == 'C',
                                  enabled: canC,
                                  onTap: canC
                                      ? () => ctrl.stationCategory.value = 'C'
                                      : null,
                                ),
                              ),
                            if (canC) SizedBox(width: 8.w),
                            if (canB)
                              Expanded(
                                child: _CategoryCard(
                                  label: 'الفئة ب',
                                  arabicLetter: 'ب',
                                  description: 'الطرق المركزية بين المحافظات.',
                                  selected: ctrl.stationCategory.value == 'B',
                                  enabled: canB,
                                  onTap: canB
                                      ? () => ctrl.stationCategory.value = 'B'
                                      : null,
                                ),
                              ),
                            if (canB) SizedBox(width: 8.w),
                            if (canA)
                              Expanded(
                                child: _CategoryCard(
                                  label: 'الفئة أ',
                                  arabicLetter: 'أ',
                                  description:
                                      'الطرق الدولية أو المسارات الأعلى تصنيفاً.',
                                  selected: ctrl.stationCategory.value == 'A',
                                  enabled: canA,
                                  onTap: canA
                                      ? () => ctrl.stationCategory.value = 'A'
                                      : null,
                                ),
                              ),
                          ],
                        );
                      });
                    },
                  ),

                  // Available badge
                  Obx(() {
                    final isInside = ctrl.planningLocation.value == 'inside';
                    final isInternational =
                        ctrl.roadType.value == 'international';
                    final available = isInside
                        ? 'المتاح: ج'
                        : isInternational
                        ? 'المتاح: أ'
                        : 'المتاح: أ، ب';
                    return Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundAlt,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          available,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Error
            Obx(() => ErrorBanner(message: ctrl.errorMessage.value)),

            // Navigation
            Obx(
              () => NavigationButtons(
                onNext: ctrl.submitStep3,
                onPrev: ctrl.goToPreviousStep,
                isLoading: ctrl.isLoading.value,
              ),
            ),

            SizedBox(height: 16.h),
            Text(
              'وزارة الطاقة © 2026',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.sp,
                color: AppColors.textHint,
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  String _locationStatusText(String status) {
    switch (status) {
      case 'set':
        return 'تم تحديد الموقع بنجاح';
      case 'denied':
        return 'تم رفض إذن الموقع. فضل إذن الموقع أو حدده بدوياً من المتصفح.';
      default:
        return 'لم يتم تحديد الموقع بعد';
    }
  }

  Color _locationStatusColor(String status) {
    switch (status) {
      case 'set':
        return AppColors.success;
      case 'denied':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _useMyLocation(
    LicenseApplicationController ctrl,
    BuildContext context,
  ) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ctrl.locationStatus.value = 'denied';
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('يرجى تفعيل خدمة الموقع على الجهاز أولاً.'),
            ),
          );
          await Geolocator.openLocationSettings();
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        ctrl.locationStatus.value = 'denied';
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم رفض إذن الموقع نهائياً. يرجى تفعيله من إعدادات الجهاز.',
              ),
            ),
          );
          await Geolocator.openAppSettings();
        }
        return;
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        ctrl.locationStatus.value = 'denied';
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم رفض إذن الموقع. يرجى السماح بالوصول إلى الموقع.',
              ),
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      ctrl.setLocation(position.latitude, position.longitude);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديد موقعك الحالي بنجاح.')),
        );
      }
    } catch (_) {
      ctrl.locationStatus.value = 'denied';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر الحصول على الموقع الحالي. حاول مرة أخرى.'),
          ),
        );
      }
    }
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────
class _LocationPickerMap extends StatefulWidget {
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final ValueChanged<LatLng> onLocationSelected;

  const _LocationPickerMap({
    required this.latitudeController,
    required this.longitudeController,
    required this.onLocationSelected,
  });

  @override
  State<_LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<_LocationPickerMap> {
  GoogleMapController? _googleMapController;
  LatLng? _selectedLatLng;

  @override
  void initState() {
    super.initState();
    _selectedLatLng = _parseLatLng();
    widget.latitudeController.addListener(_onTextChanged);
    widget.longitudeController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.latitudeController.removeListener(_onTextChanged);
    widget.longitudeController.removeListener(_onTextChanged);
    super.dispose();
  }

  LatLng? _parseLatLng() {
    final lat = double.tryParse(widget.latitudeController.text);
    final lng = double.tryParse(widget.longitudeController.text);
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  void _onTextChanged() {
    final newLocation = _parseLatLng();
    if (newLocation == null) return;
    if (_selectedLatLng?.latitude != newLocation.latitude ||
        _selectedLatLng?.longitude != newLocation.longitude) {
      setState(() {
        _selectedLatLng = newLocation;
      });
      _moveCamera(newLocation);
    }
  }

  void _moveCamera(LatLng location) {
    _googleMapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition = _selectedLatLng ?? const LatLng(33.5138, 36.2765);

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initialPosition, zoom: 10),
      onMapCreated: (controller) => _googleMapController = controller,
      onTap: (position) {
        widget.onLocationSelected(position);
        setState(() {
          _selectedLatLng = position;
        });
        _moveCamera(position);
      },
      markers: _selectedLatLng == null
          ? {}
          : {
              Marker(
                markerId: const MarkerId('selected-location'),
                position: _selectedLatLng!,
              ),
            },
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: true,
      rotateGesturesEnabled: true,
      tiltGesturesEnabled: true,
      mapType: MapType.hybrid,
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              color: AppColors.textHint,
            ),
          ),
          isExpanded: true,
          alignment: AlignmentDirectional.centerStart,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textHint,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final String arabicLetter;
  final String description;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  const _CategoryCard({
    required this.label,
    required this.arabicLetter,
    required this.description,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.selectedCard
              : enabled
              ? AppColors.surface
              : AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : enabled
                ? AppColors.border
                : AppColors.borderLight,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Radio<bool>(
              value: true,
              groupValue: selected,
              onChanged: enabled ? (_) => onTap?.call() : null,
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : enabled
                    ? AppColors.backgroundAlt
                    : AppColors.borderLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  arabicLetter,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : AppColors.textHint,
                  ),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: selected
                    ? AppColors.primary
                    : enabled
                    ? AppColors.textPrimary
                    : AppColors.textHint,
              ),
            ),
            Text(
              description,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 9.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
