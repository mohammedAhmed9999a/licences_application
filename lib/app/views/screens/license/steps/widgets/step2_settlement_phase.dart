import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../theme/app_theme.dart';

class Step2SettlementPhase extends StatelessWidget {
  final String title;
  final String subtitle;

  const Step2SettlementPhase({
    super.key,
    required this.title,
    required this.subtitle,
  });

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
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
