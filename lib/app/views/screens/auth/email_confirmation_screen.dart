import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../widgets/common_widgets.dart';
import '../../../routes/app_routes.dart';

class EmailConfirmationScreen extends StatelessWidget {
  const EmailConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.brightness == Brightness.dark
        ? theme.colorScheme.onSurface.withOpacity(0.82)
        : theme.colorScheme.onSurface.withOpacity(0.75);
    final cardColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.95)
        : theme.cardColor;
    final borderColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.outline.withOpacity(0.35)
        : theme.dividerColor;
    final primaryColor = theme.colorScheme.primary;

    final args = Get.arguments;
    final email = args is Map && args['email'] is String
        ? args['email'] as String
        : '';

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor.withAlpha(248),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 16.h),
                Container(
                  width: 250.w,
                  height: 100.h,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/h-logo.webp'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'تأكيد البريد الإلكتروني',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'يجب تفعيل البريد الإلكتروني قبل الدخول أو تقديم طلب ترخيص.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    color: textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 26.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: theme.brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.25)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'لقد أرسلنا رابط التفعيل إلى بريدك الإلكتروني.',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'تحقق من بريدك الإلكتروني لإكمال إنشاء الحساب.',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              color: textSecondary,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          SizedBox(height: 18.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.22),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  email.isNotEmpty
                                      ? email
                                      : 'البريد الإلكتروني غير متوفر',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.right,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  '(Spam) إذا لم تجد الرسالة في البريد الوارد، يرجى التحقق من مجلد الرسائل غير المرغوب فيها.',
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
                          SizedBox(height: 22.h),
                          PrimaryButton(
                            label: 'المتابعة إلى تسجيل الدخول',
                            onPressed: () => Get.offAllNamed(AppRoutes.login),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'بعد تأكيد البريد الإلكتروني، استخدم بياناتك لتسجيل الدخول.',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              color: textSecondary,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
