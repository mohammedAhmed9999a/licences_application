import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:licences_application/core/services/core_api_service.dart';
import 'package:licences_application/core/services/notification_services.dart';
import 'package:licences_application/core/validators/form_validator.dart';
import '../services/storage_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  // Login form
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rememberMe = false.obs;
  final obscurePassword = true.obs;

  // Signup form
  final nameController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final obscureSignupPassword = true.obs;
  final obscureConfirmPassword = true.obs;

  final isLoading = false.obs;
  final isResendingVerification = false.obs;
  final errorMessage = ''.obs;
  final showResendVerification = false.obs;
  final verificationEmail = ''.obs;
  final resendAttemptsLeft = 3.obs;
  final resendCooldownSeconds = 0.obs;
  Timer? _resendTimer;
  final isProfileLoading = false.obs;
  final profileError = ''.obs;
  final hasLoadedProfile = false.obs;
  final profileName = ''.obs;
  final profileEmail = ''.obs;

  final currentAuthTab = 1.obs; // 0=signup, 1=login

  @override
  void onInit() {
    super.onInit();
    profileName.value = StorageService.to.userName ?? '';
    profileEmail.value = StorageService.to.userEmail ?? '';
    // Pre-fill email if remember me was checked
    if (StorageService.to.rememberMe && StorageService.to.userEmail != null) {
      emailController.text = StorageService.to.userEmail!;
      rememberMe.value = true;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    confirmPasswordController.dispose();
    _resendTimer?.cancel();
    super.onClose();
  }

  String? validateEmailField(String email) =>
      FormValidator.validateEmailField(email);

  String? validatePasswordField(String password) =>
      FormValidator.validatePasswordField(password);

  String? validateLoginPasswordField(String password) =>
      FormValidator.validateLoginPasswordField(password);

  String? validateSignupPasswordField(String password) =>
      FormValidator.validateSignupPasswordField(password);

  String? validateNameField(String name) =>
      FormValidator.validateNameField(name);

  String? validateConfirmPasswordField(
    String password,
    String confirmPassword,
  ) => FormValidator.validateConfirmPasswordField(password, confirmPassword);

  String? validateLoginForm({
    required String email,
    required String password,
  }) => FormValidator.validateLoginForm(email: email, password: password);

  String? validateSignupForm({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) => FormValidator.validateSignupForm(
    name: name,
    email: email,
    password: password,
    confirmPassword: confirmPassword,
  );

  Future<void> login() async {
    errorMessage.value = '';
    showResendVerification.value = false;
    verificationEmail.value = '';
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'يرجى إدخال البريد الإلكتروني وكلمة المرور';
      return;
    }

    if (!FormValidator.isValidEmail(email)) {
      errorMessage.value = 'يرجى إدخال بريد إلكتروني صحيح';
      return;
    }

    try {
      isLoading.value = true;
      final response = await CoreApiService.post(
        '/v1/login',
        data: {'email': email, 'password': password},
      );

      debugPrint(
        'LOGIN REQUEST: ${response.requestOptions.method} ${response.requestOptions.uri}',
      );
      debugPrint('LOGIN RESPONSE STATUS: ${response.statusCode}');
      debugPrint('LOGIN RESPONSE DATA: ${response.data}');

      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};

      final userData = data['user'];
      final userName = userData is Map
          ? userData['name']?.toString() ?? ''
          : '';
      final token = data['token']?.toString() ?? '';

      if (token.isEmpty) {
        throw dio.DioException(
          requestOptions: dio.RequestOptions(path: '/v1/login'),
          error: 'لم يتم استلام رمز التوثيق من الخادم',
          type: dio.DioExceptionType.badResponse,
        );
      }

      await StorageService.to.saveToken(token);
      await StorageService.to.saveUserEmail(email);
      await StorageService.to.saveUserName(userName);
      await StorageService.to.saveRememberMe(rememberMe.value);
      profileEmail.value = email;
      profileName.value = userName;

      print(
        'Calling NotificationServices.syncFcmTokenWithServer() after login',
      );
      await NotificationServices.syncFcmTokenWithServer();
      print(
        'login successful, navigating to dashboard...>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>',
      );
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      if (e is dio.DioException) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          final errors = responseData['errors'];
          if (errors is Map) {
            final verificationErrors = errors['requires_verification'];
            if (verificationErrors is List && verificationErrors.isNotEmpty) {
              errorMessage.value =
                  responseData['message']?.toString().trim() ??
                  verificationErrors.first.toString();
              showResendVerification.value = true;
              verificationEmail.value = email;
              resendAttemptsLeft.value = 3;
              return;
            }

            final emailErrors = errors['email'];
            if (emailErrors is List && emailErrors.isNotEmpty) {
              errorMessage.value = emailErrors.first.toString();
              return;
            }
          }

          final message =
              responseData['message']?.toString().trim() ??
              responseData['error']?.toString().trim() ??
              responseData['msg']?.toString().trim() ??
              '';
          if (message.isNotEmpty) {
            errorMessage.value = message;
            return;
          }
        }
        errorMessage.value = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      } else {
        errorMessage.value = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendVerificationEmail() async {
    final email = verificationEmail.value;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value =
          'يرجى إدخال البريد الإلكتروني وكلمة المرور لإعادة إرسال رابط التفعيل.';
      return;
    }

    try {
      if (resendAttemptsLeft.value <= 0) {
        errorMessage.value = 'تم استنفاد عدد محاولات إعادة الإرسال.';
        return;
      }
      isResendingVerification.value = true;
      await CoreApiService.post(
        '/v1/email/verification-notification',
        data: {'email': email, 'password': password},
      );
      _startResendCooldown();
      Get.snackbar(
        'تم الإرسال',
        'تم إرسال رابط التفعيل إلى البريد الإلكتروني مرة أخرى.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.92),
        colorText: Colors.white,
      );
    } catch (_) {
      resendAttemptsLeft.value = (resendAttemptsLeft.value > 0)
          ? resendAttemptsLeft.value - 1
          : 0;
      errorMessage.value =
          'تعذر إعادة إرسال رابط التفعيل. يرجى التحقق من البريد وكلمة المرور والمحاولة مرة أخرى.';
    } finally {
      isResendingVerification.value = false;
    }
  }

  void _startResendCooldown() {
    resendCooldownSeconds.value = 300;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCooldownSeconds.value <= 1) {
        resendCooldownSeconds.value = 0;
        timer.cancel();
      } else {
        resendCooldownSeconds.value -= 1;
      }
    });
  }

  Future<void> signup() async {
    print('signup called ..........................................');
    errorMessage.value = '';
    final name = nameController.text.trim();
    final email = signupEmailController.text.trim();
    final password = signupPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      errorMessage.value = 'يرجى تعبئة جميع الحقول المطلوبة';
      return;
    }

    if (!FormValidator.isValidEmail(email)) {
      errorMessage.value = 'يرجى إدخال بريد إلكتروني صحيح';
      return;
    }

    if (!FormValidator.isStrongPassword(password)) {
      errorMessage.value =
          'كلمة المرور يجب أن تكون 8 أحرف على الأقل وتحتوي على حروف كبيرة وصغيرة ورقم';
      return;
    }

    if (password != confirmPassword) {
      errorMessage.value = 'كلمتا المرور غير متطابقتين';
      return;
    }
    try {
      isLoading.value = true;
      final response = await CoreApiService.post(
        '/v1/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        },
      );

      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      await StorageService.to.saveToken(data['token'] ?? '');
      await StorageService.to.saveUserEmail(email);
      await StorageService.to.saveUserName(name);
      profileEmail.value = email;
      profileName.value = name;
      Get.offAllNamed(AppRoutes.emailConfirmation, arguments: {'email': email});
    } catch (_) {
      errorMessage.value = 'حدث خطأ في إنشاء الحساب، يرجى المحاولة مرة أخرى';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await CoreApiService.post('/v1/logout');
    } catch (_) {}
    await StorageService.to.clearAuth();
    Get.offAllNamed(AppRoutes.home);
  }

  bool get isLoggedIn => StorageService.to.isLoggedIn;
  String get userName => profileName.value.isNotEmpty
      ? profileName.value
      : StorageService.to.userName ?? '';
  String get userEmail => profileEmail.value.isNotEmpty
      ? profileEmail.value
      : StorageService.to.userEmail ?? '';

  Future<void> loadProfile() async {
    if (!StorageService.to.isLoggedIn) return;
    if (hasLoadedProfile.value) return;

    isProfileLoading.value = true;
    profileError.value = '';

    try {
      final response = await CoreApiService.get('/v1/myProfile');
      final rawData = response.data;
      final data = rawData is Map && rawData['data'] is Map
          ? Map<String, dynamic>.from(rawData['data'] as Map)
          : <String, dynamic>{};

      final name =
          data['name']?.toString().trim() ??
          '${data['first_name']?.toString().trim() ?? ''} ${data['last_name']?.toString().trim() ?? ''}'
              .trim();
      final email = data['email']?.toString().trim() ?? '';

      if (name.isNotEmpty) {
        profileName.value = name;
        await StorageService.to.saveUserName(name);
      }

      if (email.isNotEmpty) {
        profileEmail.value = email;
        await StorageService.to.saveUserEmail(email);
      }

      hasLoadedProfile.value = true;
    } catch (_) {
      profileError.value = 'تعذر تحميل الملف الشخصي. يرجى المحاولة مرة أخرى.';
    } finally {
      isProfileLoading.value = false;
    }
  }
}
