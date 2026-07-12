import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/ministry_logo_widget.dart';
import '../../widgets/common_widgets.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();
  final _scrollController = ScrollController();
  final _nameFieldKey = GlobalKey();
  final _emailFieldKey = GlobalKey();
  final _passwordFieldKey = GlobalKey();
  final _confirmPasswordFieldKey = GlobalKey();

  @override
  void dispose() {
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
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
    final nameError = ctrl.validateNameField(ctrl.nameController.text);
    final emailError = ctrl.validateEmailField(ctrl.signupEmailController.text);
    final passwordError = ctrl.validateSignupPasswordField(
      ctrl.signupPasswordController.text,
    );
    final confirmError = ctrl.validateConfirmPasswordField(
      ctrl.signupPasswordController.text,
      ctrl.confirmPasswordController.text,
    );

    if (nameError != null) {
      _scrollToField(_nameFieldKey);
    } else if (emailError != null) {
      _scrollToField(_emailFieldKey);
    } else if (passwordError != null) {
      _scrollToField(_passwordFieldKey);
    } else if (confirmError != null) {
      _scrollToField(_confirmPasswordFieldKey);
    }
  }

  void _handleSignup(AuthController ctrl) {
    _scrollToFirstError(ctrl);
    setState(() {});
    ctrl.signup();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuthController>();
    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;
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
            controller: _scrollController,
            child: Column(
              children: [
                SizedBox(height: 16.h),
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
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 20.w),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: [const MinistryLogoWidget(size: 48)],
                //   ),
                // ),
                SizedBox(height: 16.h),

                // Title
                Text(
                  'إنشاء حساب',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'إلى بوابة طلبات تراخيص محطات الوقود',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    color: textSecondary,
                  ),
                ),
                SizedBox(height: 20.h),

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
                        // _buildTabs(context),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'بيانات الحساب',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'أدخل بياناتك الأساسية. ثم تحقق من بريدك الإلكتروني لتفعيل الحساب.',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  color: textSecondary,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              Divider(height: 20.h),

                              // Full Name
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: ctrl.nameController,
                                builder: (context, _, __) {
                                  return LabeledField(
                                    key: _nameFieldKey,
                                    label: 'الاسم الكامل',
                                    required: true,
                                    errorText: ctrl.validateNameField(
                                      ctrl.nameController.text,
                                    ),
                                    successText:
                                        ctrl.nameController.text.isNotEmpty &&
                                            ctrl.validateNameField(
                                                  ctrl.nameController.text,
                                                ) ==
                                                null
                                        ? 'الاسم صحيح'
                                        : null,
                                    child: RtlTextField(
                                      controller: ctrl.nameController,
                                      focusNode: nameFocusNode,
                                      hintText: 'الاسم الكامل',
                                      textInputAction: TextInputAction.next,
                                      onSubmitted: (_) {
                                        FocusScope.of(
                                          context,
                                        ).requestFocus(emailFocusNode);
                                      },
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 14.h),

                              // Email
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: ctrl.signupEmailController,
                                builder: (context, _, __) {
                                  return LabeledField(
                                    key: _emailFieldKey,
                                    label: 'البريد الإلكتروني',
                                    required: true,
                                    errorText: ctrl.validateEmailField(
                                      ctrl.signupEmailController.text,
                                    ),
                                    successText:
                                        ctrl
                                                .signupEmailController
                                                .text
                                                .isNotEmpty &&
                                            ctrl.validateEmailField(
                                                  ctrl
                                                      .signupEmailController
                                                      .text,
                                                ) ==
                                                null
                                        ? 'البريد الإلكتروني صالح'
                                        : null,
                                    child: RtlTextField(
                                      controller: ctrl.signupEmailController,
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
                              SizedBox(height: 14.h),

                              // Password & Confirm - stacked on mobile for better UX
                              Column(
                                children: [
                                  ValueListenableBuilder<TextEditingValue>(
                                    valueListenable:
                                        ctrl.signupPasswordController,
                                    builder: (context, _, __) {
                                      return Obx(
                                        () => LabeledField(
                                          label: 'كلمة المرور',
                                          required: true,
                                          errorText: ctrl
                                              .validateSignupPasswordField(
                                                ctrl
                                                    .signupPasswordController
                                                    .text,
                                              ),
                                          successText:
                                              ctrl
                                                      .signupPasswordController
                                                      .text
                                                      .isNotEmpty &&
                                                  ctrl.validateSignupPasswordField(
                                                        ctrl
                                                            .signupPasswordController
                                                            .text,
                                                      ) ==
                                                      null
                                              ? 'كلمة المرور قوية'
                                              : null,
                                          child: RtlTextField(
                                            key: _passwordFieldKey,
                                            controller:
                                                ctrl.signupPasswordController,
                                            focusNode: passwordFocusNode,
                                            hintText: 'أدخل كلمة مرور قوية',
                                            obscureText: ctrl
                                                .obscureSignupPassword
                                                .value,
                                            textInputAction:
                                                TextInputAction.next,
                                            onSubmitted: (_) {
                                              FocusScope.of(
                                                context,
                                              ).requestFocus(
                                                confirmPasswordFocusNode,
                                              );
                                            },
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                ctrl.obscureSignupPassword.value
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                          .visibility_off_outlined,
                                                size: 18,
                                                color: hintColor,
                                              ),
                                              onPressed: () => ctrl
                                                  .obscureSignupPassword
                                                  .toggle(),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 14.h),
                                  ValueListenableBuilder<TextEditingValue>(
                                    valueListenable:
                                        ctrl.confirmPasswordController,
                                    builder: (context, _, __) {
                                      return Obx(
                                        () => LabeledField(
                                          label: 'تأكيد كلمة المرور',
                                          required: true,
                                          errorText: ctrl
                                              .validateConfirmPasswordField(
                                                ctrl
                                                    .signupPasswordController
                                                    .text,
                                                ctrl
                                                    .confirmPasswordController
                                                    .text,
                                              ),
                                          successText:
                                              ctrl
                                                      .confirmPasswordController
                                                      .text
                                                      .isNotEmpty &&
                                                  ctrl.validateConfirmPasswordField(
                                                        ctrl
                                                            .signupPasswordController
                                                            .text,
                                                        ctrl
                                                            .confirmPasswordController
                                                            .text,
                                                      ) ==
                                                      null
                                              ? 'كلمتا المرور متطابقتان'
                                              : null,
                                          child: RtlTextField(
                                            key: _confirmPasswordFieldKey,
                                            controller:
                                                ctrl.confirmPasswordController,
                                            focusNode: confirmPasswordFocusNode,
                                            hintText: 'أعد إدخال كلمة المرور',
                                            obscureText: ctrl
                                                .obscureConfirmPassword
                                                .value,
                                            textInputAction:
                                                TextInputAction.done,
                                            onSubmitted: (_) {
                                              _handleSignup(ctrl);
                                            },
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                ctrl
                                                        .obscureConfirmPassword
                                                        .value
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                          .visibility_off_outlined,
                                                size: 18,
                                                color: hintColor,
                                              ),
                                              onPressed: () => ctrl
                                                  .obscureConfirmPassword
                                                  .toggle(),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              // Padding(
                              //   padding: EdgeInsets.only(top: 4.h),
                              //   child: Align(
                              //     alignment: AlignmentDirectional.centerEnd,
                              //     child: Text(
                              //       'اكتب كلمة مرور قوية: 8 أحرف على الأقل، حروف ورقم',
                              //       style: TextStyle(
                              //         fontFamily: 'Cairo',
                              //         fontSize: 11.sp,
                              //         color: hintColor,
                              //       ),
                              //       textDirection: TextDirection.rtl,
                              //       textAlign: TextAlign.right,
                              //     ),
                              //   ),
                              // ),

                              // Error
                              Obx(
                                () => ErrorBanner(
                                  message: ctrl.errorMessage.value,
                                ),
                              ),
                              SizedBox(height: 12.h),

                              // Signup Button
                              Obx(
                                () => PrimaryButton(
                                  label: 'إنشاء الحساب',
                                  isLoading: ctrl.isLoading.value,
                                  onPressed: () => _handleSignup(ctrl),
                                ),
                              ),
                              SizedBox(height: 14.h),

                              // Go to login
                              GestureDetector(
                                onTap: () => Get.offNamed(AppRoutes.login),
                                child: Center(
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'لديك حساب؟ ',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 13.sp,
                                        color: textSecondary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'تسجيل الدخول',
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
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
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
                        onTap: () => Get.offNamed(AppRoutes.login),
                        child: Container(
                          height: 52.h,
                          alignment: Alignment.center,
                          child: Text(
                            'تسجيل الدخول',
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
                            'إنشاء حساب',
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
}
