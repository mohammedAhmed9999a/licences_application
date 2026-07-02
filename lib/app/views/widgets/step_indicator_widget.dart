import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors.dart';
import '../../theme/app_theme.dart';

class StepIndicatorWidget extends StatelessWidget {
  final int currentStep; // 0-based
  final int totalSteps;

  const StepIndicatorWidget({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  static const _steps = [
    _StepInfo(
      'الشروط والتواصل',
      'البريد، رقم الهاتف والموافقة',
      Icons.check_circle_outline,
    ),
    _StepInfo(
      'بيانات الترخيص',
      'نوع الطلب وصاحب الصلاحية',
      Icons.person_outline,
    ),
    _StepInfo(
      'الموقع والتصنيف',
      'العنوان والإحداثيات وفئة الطريق',
      Icons.location_on_outlined,
    ),
    _StepInfo(
      'المرفقات والإرسال',
      'رفع الملفات ومراجعة الطلب',
      Icons.attach_file,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          // Steps row
          Container(
            color: AppColors.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true, // RTL
              child: Row(
                children: List.generate(_steps.length, (i) {
                  // Display in reverse for RTL (step 1 on right)
                  final stepIndex = _steps.length - 1 - i;
                  return _buildStep(stepIndex);
                }),
              ),
            ),
          ),
          // Progress bar
          Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'الخطوة ${currentStep + 1} من $totalSteps',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontFamily: 'Cairo',
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: (currentStep + 1) / totalSteps,
                      backgroundColor: AppColors.borderLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int stepIndex) {
    final isDone = stepIndex < currentStep;
    final isActive = stepIndex == currentStep;

    Color bgColor;
    Color textColor;
    Widget leadingIcon;

    if (isDone) {
      bgColor = AppColors.surface;
      textColor = AppColors.textSecondary;
      leadingIcon = Container(
        width: 28.w,
        height: 28.h,
        decoration: BoxDecoration(
          color: AppColors.stepDone,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check, color: Colors.white, size: 16.sp),
      );
    } else if (isActive) {
      bgColor = AppColors.primary;
      textColor = Colors.white;
      leadingIcon = Container(
        width: 28.w,
        height: 28.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.w),
        ),
        child: Center(
          child: Text(
            '${stepIndex + 1}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      );
    } else {
      bgColor = AppColors.backgroundAlt;
      textColor = AppColors.textHint;
      leadingIcon = Container(
        width: 28.w,
        height: 28.h,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 2.w),
        ),
        child: Center(
          child: Icon(
            _steps[stepIndex].icon,
            color: AppColors.textHint,
            size: 14.sp,
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 90),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: isActive ? AppColors.primary : Colors.transparent,
            width: 3.w,
          ),
          right: BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leadingIcon,
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _steps[stepIndex].title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontFamily: 'Cairo',
                ),
                textDirection: TextDirection.rtl,
              ),
              Text(
                _steps[stepIndex].subtitle,
                style: TextStyle(
                  fontSize: 9.sp,
                  color: isActive
                      ? Colors.white70
                      : isDone
                      ? AppColors.textHint
                      : AppColors.textHint,
                  fontFamily: 'Cairo',
                ),
                textDirection: TextDirection.rtl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  const _StepInfo(this.title, this.subtitle, this.icon);
}
