import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/ministry_logo_widget.dart';
import '../../widgets/common_widgets.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuthController>();
    final emailFocusNode = FocusNode();
    final passwordFocusNode = FocusNode();
    final theme = Theme.of(context);
    final textPrimary = theme.brightness == Brightness.dark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface;
    final textSecondary = theme.brightness == Brightness.dark
        ? theme.colorScheme.onSurface.withOpacity(0.82)
        : theme.colorScheme.onSurface.withOpacity(0.75);
    final hintColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.onSurface.withOpacity(0.6)
        : context.themeTextHint;
    final cardColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.95)
        : theme.cardColor;
    final borderColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.outline.withOpacity(0.35)
        : theme.dividerColor;
    final primaryColor = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/splash_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor.withAlpha(248),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Back button row
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Row(
                          children: [
                            Text(
                              'العودة إلى الصفحة الرئيسية',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: primaryColor,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w600,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 13.sp,
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10.h),

                // Ministry Logo
                Shimmer.fromColors(
                  baseColor: AppColors.gold.withOpacity(0.6),
                  highlightColor: Colors.white,
                  period: const Duration(seconds: 2),
                  child: Container(
                    width: 250.w,
                    height: 100.h,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/h-logo.webp'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                // const MinistryLogoWidget(size: 56),
                SizedBox(height: 20.h),

                // Title
                Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'إلى بوابة طلبات ترخيص محطات الوقود',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    color: textSecondary,
                  ),
                ),

                SizedBox(height: 24.h),

                // Form Card
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
                    child: Column(
                      children: [
                        // Tabs
                        // _buildTabs(context, ctrl),

                        // Tab content - Login
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مرحباً بعودتك',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'استخدم بريدك الإلكتروني وكلمة المرور الخاصة بك.',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  color: textSecondary,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              Divider(height: 24.h),

                              // Email
                              SizedBox(height: 4.h),
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: ctrl.emailController,
                                builder: (context, _, __) {
                                  return LabeledField(
                                    label: 'البريد الإلكتروني',
                                    required: true,
                                    errorText: ctrl.validateEmailField(
                                      ctrl.emailController.text,
                                    ),

                                    successText:
                                        ctrl.emailController.text.isNotEmpty &&
                                            ctrl.validateEmailField(
                                                  ctrl.emailController.text,
                                                ) ==
                                                null
                                        ? 'البريد الإلكتروني صالح'
                                        : null,
                                    child: RtlTextField(
                                      controller: ctrl.emailController,
                                      focusNode: emailFocusNode,
                                      hintText: 'name@example.com',
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      onSubmitted: (_) {
                                        FocusScope.of(
                                          context,
                                        ).requestFocus(passwordFocusNode);
                                      },
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 16.h),

                              // Password
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: ctrl.passwordController,
                                builder: (context, _, __) {
                                  return Obx(
                                    () => LabeledField(
                                      label: 'كلمة المرور',
                                      required: true,
                                      errorText: ctrl
                                          .validateLoginPasswordField(
                                            ctrl.passwordController.text,
                                          ),
                                      successText:
                                          ctrl
                                                  .passwordController
                                                  .text
                                                  .isNotEmpty &&
                                              ctrl.validateLoginPasswordField(
                                                    ctrl
                                                        .passwordController
                                                        .text,
                                                  ) ==
                                                  null
                                          ? 'كلمة المرور مناسبة'
                                          : null,
                                      child: RtlTextField(
                                        controller: ctrl.passwordController,
                                        focusNode: passwordFocusNode,
                                        hintText: '••••••••••',
                                        obscureText: ctrl.obscurePassword.value,
                                        textInputAction: TextInputAction.done,
                                        onSubmitted: (_) {
                                          ctrl.login();
                                        },
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            ctrl.obscurePassword.value
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: hintColor,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              ctrl.obscurePassword.toggle(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 12.h),

                              // Remember me
                              Obx(
                                () => Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'تذكرني',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 13.sp,
                                        color: textPrimary,
                                      ),
                                      textDirection: TextDirection.rtl,
                                    ),
                                    Checkbox(
                                      value: ctrl.rememberMe.value,
                                      onChanged: (v) =>
                                          ctrl.rememberMe.value = v ?? false,
                                      activeColor: primaryColor,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ],
                                ),
                              ),

                              // Error
                              Obx(
                                () => ErrorBanner(
                                  message: ctrl.errorMessage.value,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Obx(
                                () => ctrl.showResendVerification.value
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          SizedBox(height: 10.h),
                                          OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                color: primaryColor.withOpacity(
                                                  0.85,
                                                ),
                                              ),
                                              foregroundColor: primaryColor,
                                            ),
                                            onPressed:
                                                (ctrl
                                                        .isResendingVerification
                                                        .value ||
                                                    ctrl
                                                            .resendCooldownSeconds
                                                            .value >
                                                        0 ||
                                                    ctrl
                                                            .resendAttemptsLeft
                                                            .value <=
                                                        0)
                                                ? null
                                                : ctrl.resendVerificationEmail,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 12.h,
                                              ),
                                              child: Text(
                                                ctrl
                                                        .isResendingVerification
                                                        .value
                                                    ? 'يتم الإرسال...'
                                                    : ctrl
                                                              .resendAttemptsLeft
                                                              .value <=
                                                          0
                                                    ? 'تم استنفاد المحاولات'
                                                    : ctrl
                                                              .resendCooldownSeconds
                                                              .value >
                                                          0
                                                    ? 'أعد المحاولة بعد ${_formatDuration(ctrl.resendCooldownSeconds.value)}'
                                                    : 'إعادة إرسال رابط التفعيل',
                                                style: TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            ctrl.resendAttemptsLeft.value <= 0
                                                ? 'لم يعد مسموحاً بإعادة الإرسال بعد 3 محاولات.'
                                                : ctrl
                                                          .resendCooldownSeconds
                                                          .value >
                                                      0
                                                ? 'الوقت المتبقي لإعادة المحاولة: ${_formatDuration(ctrl.resendCooldownSeconds.value)}'
                                                : 'إذا كان حسابك غير مفعل، اضغط على زر إعادة الإرسال للتحقق من بريدك.',
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 12.sp,
                                              color: textSecondary,
                                            ),
                                            textDirection: TextDirection.rtl,
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              SizedBox(height: 8.h),

                              // Login Button
                              Obx(
                                () => PrimaryButton(
                                  label: 'تسجيل الدخول',
                                  isLoading: ctrl.isLoading.value,
                                  onPressed: ctrl.login,
                                ),
                              ),
                              SizedBox(height: 16.h),

                              // Go to signup
                              GestureDetector(
                                onTap: () => Get.offNamed(AppRoutes.signup),
                                child: Center(
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'لا تملك حساباً؟ ',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 13.sp,
                                        color: textSecondary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'إنشاء حساب جديد',
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 60.h),
                // Islamic pattern decoration at bottom - subtle
                // _buildIslamicPattern(theme.dividerColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final minutesText = minutes.toString().padLeft(2, '0');
    final secondsText = seconds.toString().padLeft(2, '0');
    return '$minutesText:$secondsText';
  }

  Widget _buildTabs(BuildContext context, AuthController ctrl) {
    final theme = Theme.of(context);
    final textSecondary =
        theme.textTheme.bodyMedium?.color ??
        theme.colorScheme.onBackground.withOpacity(0.75);
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = theme.colorScheme.surface;
    final borderColor = theme.dividerColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = constraints.maxWidth / 2;
        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: borderColor),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: segmentWidth,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: Container(color: primaryColor.withOpacity(0.16)),
              ),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Get.offNamed(AppRoutes.signup),
                        child: Container(
                          height: 52.h,
                          alignment: Alignment.center,
                          child: Text(
                            'إنشاء حساب',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          height: 52.h,
                          alignment: Alignment.center,
                          child: Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIslamicPattern(Color color) {
    return SizedBox(
      height: 60.h,
      child: CustomPaint(
        painter: _IslamicPatternPainter(color),
        size: const Size(double.infinity, 60),
      ),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  _IslamicPatternPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 10, paint);
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 14.w, height: 14.h),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
