import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/ministry_logo_widget.dart';
import '../../widgets/common_widgets.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final _scrollController = ScrollController();
  final _emailFieldKey = GlobalKey();
  final _passwordFieldKey = GlobalKey();

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToField(GlobalKey key) async {
    final targetContext = key.currentContext;
    if (targetContext == null) return;
    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  void _scrollToFirstError(AuthController ctrl) {
    final emailError = ctrl.validateEmailField(ctrl.emailController.text);
    final passwordError = ctrl.validateLoginPasswordField(
      ctrl.passwordController.text,
    );

    if (emailError != null) {
      _scrollToField(_emailFieldKey);
    } else if (passwordError != null) {
      _scrollToField(_passwordFieldKey);
    }
  }

  void _handleLogin(AuthController ctrl) {
    _scrollToFirstError(ctrl);
    setState(() {});
    ctrl.login();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuthController>();
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14.sp,
                          color: primaryColor,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'العودة',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: primaryColor,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      'بوابة الخدمات',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        color: textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'استخدم بيانات حسابك للوصول إلى طلبات التراخيص الخاصة بك.',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.sp,
                        color: textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 24.h),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: ctrl.emailController,
                      builder: (context, _, __) {
                        return LabeledField(
                          key: _emailFieldKey,
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
                    SizedBox(height: 18.h),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: ctrl.passwordController,
                      builder: (context, _, __) {
                        return Obx(
                          () => LabeledField(
                            label: 'كلمة المرور',
                            required: true,
                            errorText: ctrl.validateLoginPasswordField(
                              ctrl.passwordController.text,
                            ),
                            successText:
                                ctrl.passwordController.text.isNotEmpty &&
                                    ctrl.validateLoginPasswordField(
                                          ctrl.passwordController.text,
                                        ) ==
                                        null
                                ? 'كلمة المرور مناسبة'
                                : null,
                            child: RtlTextField(
                              key: _passwordFieldKey,
                              controller: ctrl.passwordController,
                              focusNode: passwordFocusNode,
                              hintText: '••••••••••',
                              obscureText: ctrl.obscurePassword.value,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                _handleLogin(ctrl);
                              },
                              suffixIcon: IconButton(
                                icon: Icon(
                                  ctrl.obscurePassword.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: hintColor,
                                  size: 20,
                                ),
                                onPressed: () => ctrl.obscurePassword.toggle(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 14.h),
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Checkbox(
                            value: ctrl.rememberMe.value,
                            onChanged: (v) =>
                                ctrl.rememberMe.value = v ?? false,
                            activeColor: primaryColor,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          Text(
                            'تذكرني',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13.sp,
                              color: textPrimary,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Obx(() => ErrorBanner(message: ctrl.errorMessage.value)),
                    Obx(
                      () => ctrl.showResendVerification.value
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 10.h),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: primaryColor.withOpacity(0.85),
                                    ),
                                    foregroundColor: primaryColor,
                                  ),
                                  onPressed:
                                      (ctrl.isResendingVerification.value ||
                                          ctrl.resendCooldownSeconds.value >
                                              0 ||
                                          ctrl.resendAttemptsLeft.value <= 0)
                                      ? null
                                      : ctrl.resendVerificationEmail,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                    ),
                                    child: Text(
                                      ctrl.isResendingVerification.value
                                          ? 'يتم الإرسال...'
                                          : ctrl.resendAttemptsLeft.value <= 0
                                          ? 'تم استنفاد المحاولات'
                                          : ctrl.resendCooldownSeconds.value > 0
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
                                      : ctrl.resendCooldownSeconds.value > 0
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
                    SizedBox(height: 12.h),
                    Obx(
                      () => PrimaryButton(
                        label: 'تسجيل الدخول',
                        isLoading: ctrl.isLoading.value,
                        onPressed: () => _handleLogin(ctrl),
                      ),
                    ),
                    SizedBox(height: 18.h),
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
                                  decoration: TextDecoration.underline,
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
              SizedBox(height: 20.h),
            ],
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
