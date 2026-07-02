import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constant/app_colors.dart';
import '../../theme/app_theme.dart';

// ─── Section Card ─────────────────────────────────────────────────────────────
class SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int? stepNumber;
  final Widget child;
  final String? badgeText;

  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.stepNumber,
    required this.child,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.cardColor;
    final borderColor = theme.dividerColor;
    final textPrimary = theme.colorScheme.onSurface;
    final surfaceAlt = context.themeSurfaceAlt;
    final primaryColor = theme.colorScheme.primary;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        // textDirection: TextDirection.rtl,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.ltr,
                        children: [
                          // Center the title vertity play Google
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                                fontFamily: 'Cairo',
                              ),
                              // text direction follows app Directionality
                              softWrap: true,
                            ),
                          ),
                          if (stepNumber != null) ...[
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
                                  '$stepNumber',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                            fontFamily: 'Cairo',
                          ),
                          textAlign: TextAlign.start,
                          softWrap: true,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (badgeText != null)
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 8),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    badgeText!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: primaryColor,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            ),
          Divider(height: 1.h, color: AppColors.borderLight),
          Padding(padding: EdgeInsets.all(16.w), child: child),
        ],
      ),
    );
  }
}

// ─── Labeled Field ────────────────────────────────────────────────────────────
class LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final bool required;
  final String? errorText;
  final String? successText;

  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
    this.errorText,
    this.successText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    fontFamily: 'Cairo',
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  softWrap: true,
                ),
              ),
              if (required)
                Text(
                  ' *',
                  style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                ),
            ],
          ),
          SizedBox(height: 6.h),
          child,
          if (errorText != null && errorText!.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    errorText!,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.error,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(Icons.error_outline, size: 14.sp, color: AppColors.error),
              ],
            ),
          ] else if (successText != null && successText!.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    successText!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.green.shade600,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.check_circle_outline,
                  size: 14.sp,
                  color: Colors.green.shade600,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── RTL Text Field ───────────────────────────────────────────────────────────
class RtlTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? helperText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final int? maxLines;
  final bool enabled;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const RtlTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText,
    this.helperText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.start,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          enabled: enabled,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: hintText,
            // hint direction follows app Directionality
            suffixIcon: suffixIcon,
          ),
        ),
        if (helperText != null) ...[
          SizedBox(height: 4.h),
          Text(
            helperText!,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textHint,
              fontFamily: 'Cairo',
            ),
            // text direction follows app Directionality
          ),
        ],
      ],
    );
  }
}

// ─── Choice Card ──────────────────────────────────────────────────────────────
class ChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const ChoiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.cardColor;
    final borderColor = theme.dividerColor;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary =
        theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;
    final surfaceAlt = context.themeSurfaceAlt;
    final primaryColor = theme.colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: selected ? surfaceAlt : surface,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: selected ? primaryColor : borderColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: selected ? primaryColor : textPrimary,
                        fontFamily: 'Cairo',
                      ),
                      textDirection: TextDirection.rtl,
                      softWrap: true,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: textSecondary,
                        fontFamily: 'Cairo',
                      ),
                      textDirection: TextDirection.rtl,
                      softWrap: true,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: selected ? primaryColor.withOpacity(0.15) : surfaceAlt,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: selected ? primaryColor : textSecondary,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerPlaceholder extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const ShimmerPlaceholder({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade300;
    final highlightColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height.h,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
    );
  }
}

class ShimmerLoadingCard extends StatelessWidget {
  final double height;

  const ShimmerLoadingCard({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade300;
    final highlightColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1200),
      child: Container(
        height: height.h,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 120.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: 180.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: 140.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error Banner ─────────────────────────────────────────────────────────────
class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.error,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: 8.w),
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
        ],
      ),
    );
  }
}

// ─── Required Fields Banner ───────────────────────────────────────────────────
class RequiredFieldsBanner extends StatelessWidget {
  const RequiredFieldsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.06),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.error, size: 16),
          SizedBox(width: 6.w),

          Text(
            'الحقول أدناه مطلوبة',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.error,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(label),
      ),
    );
  }
}

// ─── Navigation Buttons (Previous / Next) ─────────────────────────────────────
class NavigationButtons extends StatelessWidget {
  final String nextLabel;
  final String? prevLabel;
  final VoidCallback onNext;
  final VoidCallback? onPrev;
  final bool isLoading;

  const NavigationButtons({
    super.key,
    this.nextLabel = 'التالي',
    this.prevLabel = 'السابق',
    required this.onNext,
    this.onPrev,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (onPrev != null) ...[
            SizedBox(
              width: 100.w,
              height: 46.h,
              child: OutlinedButton(
                onPressed: onPrev,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                ),
                child: Text(prevLabel ?? 'السابق'),
              ),
            ),
            SizedBox(width: 12.w),
          ],
          SizedBox(
            width: 100.w,
            height: 46.h,
            child: ElevatedButton(
              onPressed: isLoading ? null : onNext,
              style: ElevatedButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(nextLabel),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Attachment Upload Card ────────────────────────────────────────────────────
class AttachmentCard extends StatelessWidget {
  final String title;
  final String description;
  final bool required;
  final bool uploaded;
  final String? fileName;
  final VoidCallback onUpload;
  final VoidCallback? onView;
  final VoidCallback? onRemove;

  const AttachmentCard({
    super.key,
    required this.title,
    required this.description,
    this.required = true,
    this.uploaded = false,
    this.fileName,
    required this.onUpload,
    this.onView,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: uploaded
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.border,
        ),
      ),
      child: Column(
        // textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(12.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundAlt,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    uploaded
                        ? Icons.check_circle
                        : Icons.insert_drive_file_outlined,
                    color: uploaded
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'Cairo',
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textSecondary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      if (required)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            'مطلوب',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.error,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // SizedBox(width: 10.w),
              ],
            ),
          ),
          Divider(height: 1.h, color: AppColors.borderLight),
          // Upload area
          GestureDetector(
            onTap: uploaded ? onView ?? onUpload : onUpload,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: uploaded
                    ? AppColors.primary.withOpacity(0.05)
                    : AppColors.backgroundAlt,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: uploaded
                      ? AppColors.primary.withOpacity(0.3)
                      : AppColors.border,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    uploaded
                        ? Icons.cloud_done_outlined
                        : Icons.cloud_upload_outlined,
                    size: 32,
                    color: uploaded ? AppColors.primary : AppColors.textHint,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    uploaded ? (fileName ?? 'تم رفع الملف') : 'إضافة مرفق',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: uploaded
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    uploaded
                        ? 'اضغط لعرض الملف أو استخدم الأزرار أدناه'
                        : 'اضغط لاختيار الملف',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textHint,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  if (uploaded && (onView != null || onRemove != null)) ...[
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (onView != null)
                          TextButton.icon(
                            onPressed: onView,
                            icon: Icon(Icons.remove_red_eye, size: 16),
                            label: Text(
                              'عرض',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ),
                        if (onRemove != null)
                          TextButton.icon(
                            onPressed: onRemove,
                            icon: Icon(Icons.delete_outline, size: 16),
                            label: Text(
                              'إزالة',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
