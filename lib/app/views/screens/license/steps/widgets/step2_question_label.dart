import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../theme/app_theme.dart';

class Step2QuestionLabel extends StatelessWidget {
  final int number;
  final String text;

  const Step2QuestionLabel({
    super.key,
    required this.number,
    required this.text,
  });

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
