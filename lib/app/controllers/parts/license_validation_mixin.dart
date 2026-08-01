import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/validators/form_validator.dart';
import '../license_application_controller.dart';

mixin LicenseValidationMixin on GetxController {
  LicenseApplicationController get controller =>
      Get.find<LicenseApplicationController>();

  void scrollToStep1Field(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          alignment: 0.16,
        );
      } catch (_) {}
    });
  }

  void scrollToStep1Error() {
    if (controller.step1ErrorField.value == 'phone' &&
        controller.phoneFieldKey.currentContext != null) {
      scrollToStep1Field(controller.phoneFieldKey);
      return;
    }
    if (controller.step1ErrorField.value == 'email' &&
        controller.emailFieldKey.currentContext != null) {
      scrollToStep1Field(controller.emailFieldKey);
      return;
    }
    if (controller.step1ErrorField.value == 'phone2' &&
        controller.secondaryPhoneFieldKey.currentContext != null) {
      scrollToStep1Field(controller.secondaryPhoneFieldKey);
      return;
    }
    if (controller.step1ErrorField.value == 'terms' &&
        controller.termsFieldKey.currentContext != null) {
      scrollToStep1Field(controller.termsFieldKey);
      return;
    }

    if (controller.phoneController.text.trim().isEmpty &&
        controller.phoneFieldKey.currentContext != null) {
      scrollToStep1Field(controller.phoneFieldKey);
      return;
    }
    if (controller.emailController.text.trim().isEmpty &&
        controller.emailFieldKey.currentContext != null) {
      scrollToStep1Field(controller.emailFieldKey);
      return;
    }
    if (!controller.agreedToTerms.value &&
        controller.termsFieldKey.currentContext != null) {
      scrollToStep1Field(controller.termsFieldKey);
      return;
    }
  }

  bool validateStep1() {
    controller.hasAttemptedStep1Submission.value = true;
    controller.errorMessage.value = '';
    controller.step1ErrorField.value = '';

    final emailError = FormValidator.validateEmailField(
      controller.emailController.text,
    );
    if (emailError != null) {
      controller.errorMessage.value = emailError;
      controller.step1ErrorField.value = 'email';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToStep1Error();
      });
      return false;
    }

    final phone = controller.phoneController.text.trim();
    if (phone.isEmpty) {
      controller.errorMessage.value = 'يرجى إدخال رقم التواصل';
      controller.step1ErrorField.value = 'phone';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToStep1Error();
      });
      return false;
    }
    if (!RegExp(r'^09\d{8}$').hasMatch(phone)) {
      controller.errorMessage.value =
          'رقم التواصل يجب أن يبدأ بـ 09 وأن يكون 10 أرقام';
      controller.step1ErrorField.value = 'phone';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToStep1Error();
      });
      return false;
    }

    final secondaryPhone = controller.phone2Controller.text.trim();
    if (secondaryPhone.isNotEmpty &&
        !RegExp(r'^09\d{8}$').hasMatch(secondaryPhone)) {
      controller.errorMessage.value =
          'رقم التواصل الثانوي يجب أن يبدأ بـ 09 وأن يكون 10 أرقام';
      controller.step1ErrorField.value = 'phone2';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToStep1Error();
      });
      return false;
    }

    if (!controller.agreedToTerms.value) {
      controller.errorMessage.value =
          'يجب الموافقة على الشروط والأحكام للمتابعة';
      controller.step1ErrorField.value = 'terms';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToStep1Error();
      });
      return false;
    }
    return true;
  }

  bool validateStep2() {
    controller.errorMessage.value = '';
    clearStep2FieldErrors();

    if (controller.requestType.value == 'settlement') {
      final hasPreviousLicenseNumber = controller.previousLicenseNumber.text
          .trim()
          .isNotEmpty;
      final hasSettlementAgreement = controller.settledAgreed.value;

      if (!hasPreviousLicenseNumber) {
        controller.settlementPreviousLicenseError.value =
            'يرجى إدخال رقم الترخيص السابق';
      } else if (!RegExp(
        r'^[A-Za-z0-9-]+$',
      ).hasMatch(controller.previousLicenseNumber.text.trim())) {
        controller.settlementPreviousLicenseError.value =
            'رقم الترخيص يجب أن يحتوي على أحرف إنكليزية وأرقام وواصلة (-) فقط، بدون مسافات أو رموز أخرى';
      } else {
        controller.settlementPreviousLicenseError.value = '';
      }

      if (!hasSettlementAgreement) {
        controller.settlementAgreementError.value =
            'يجب الموافقة على المراحل الإلزامية للتسوية';
      } else {
        controller.settlementAgreementError.value = '';
      }

      if (!hasPreviousLicenseNumber || !hasSettlementAgreement) {
        controller.errorMessage.value = 'يرجى إكمال بيانات التسوية المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
    }

    if (controller.investorType.value == 'individual') {
      final firstName = controller.firstNameController.text.trim();
      if (firstName.isEmpty) {
        controller.firstNameError.value = 'يرجى إدخال الاسم الأول';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
      if (firstName.length <= 2) {
        controller.firstNameError.value = 'الاسم يجب أن يكون أكثر من حرفين';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }
      if (!FormValidator.isArabicName(firstName)) {
        controller.firstNameError.value =
            'الاسم يجب أن يكون باللغة العربية حصراً';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }

      final fatherName = controller.fatherNameController.text.trim();
      if (fatherName.isEmpty) {
        controller.fatherNameError.value = 'يرجى إدخال اسم الأب';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
      if (fatherName.length <= 2) {
        controller.fatherNameError.value = 'اسم الأب يجب أن يكون أكثر من حرفين';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }
      if (!FormValidator.isArabicName(fatherName)) {
        controller.fatherNameError.value =
            'اسم الأب يجب أن يكون باللغة العربية حصراً';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }

      final motherName = controller.motherNameController.text.trim();
      if (motherName.isEmpty) {
        controller.motherNameError.value = 'يرجى إدخال اسم الأم';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
      if (motherName.length <= 2) {
        controller.motherNameError.value = 'اسم الأم يجب أن يكون أكثر من حرفين';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }
      if (!FormValidator.isArabicName(motherName)) {
        controller.motherNameError.value =
            'اسم الأم يجب أن يكون باللغة العربية حصراً';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }

      final nickname = controller.nicknameController.text.trim();
      if (nickname.isEmpty) {
        controller.nicknameError.value = 'يرجى إدخال الكنية';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
      if (nickname.length <= 2) {
        controller.nicknameError.value = 'الكنية يجب أن تكون أكثر من حرفين';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }
      if (!FormValidator.isArabicName(nickname)) {
        controller.nicknameError.value =
            'الكنية يجب أن تكون باللغة العربية حصراً';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }

      final nationalId = controller.nationalIdController.text.trim();
      if (nationalId.isEmpty) {
        controller.nationalIdError.value = 'يرجى إدخال الرقم الوطني';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
      if (!RegExp(r'^\d+$').hasMatch(nationalId)) {
        controller.nationalIdError.value =
            'الرقم الوطني يجب أن يحتوي على أرقام فقط';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }
      if (nationalId.length < 8 || nationalId.length > 12) {
        controller.nationalIdError.value =
            'الرقم الوطني يجب أن يكون بين 8 و12 رقماً';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }

      final birthPlace = controller.birthPlaceController.text.trim();
      if (birthPlace.isEmpty) {
        controller.birthPlaceError.value = 'يرجى إدخال مكان الولادة';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
      if (birthPlace.length <= 2) {
        controller.birthPlaceError.value =
            'مكان الولادة يجب أن يكون أكثر من حرفين';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }
      if (!FormValidator.isArabicName(birthPlace)) {
        controller.birthPlaceError.value =
            'مكان الولادة يجب أن يكون باللغة العربية حصراً';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }

      final selectedBirthDate = controller.birthDate.value;
      if (selectedBirthDate == null) {
        controller.birthDateError.value = 'يرجى اختيار تاريخ الولادة';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }

      final now = DateTime.now();
      var age = now.year - selectedBirthDate.year;
      if (now.month < selectedBirthDate.month ||
          (now.month == selectedBirthDate.month &&
              now.day < selectedBirthDate.day)) {
        age--;
      }
      if (age < 18) {
        controller.birthDateError.value =
            'يجب أن لا يقل عمر مقدم الطلب عن 18 سنة';
        controller.errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
    } else if (controller.investorType.value == 'company') {
      var hasRepresentativeErrors = false;
      var hasCompanyErrors = false;

      final firstName = controller.firstNameController.text.trim();
      if (firstName.isEmpty) {
        controller.firstNameError.value = 'يرجى إدخال الاسم الأول';
        hasRepresentativeErrors = true;
      } else if (firstName.length <= 2) {
        controller.firstNameError.value = 'الاسم يجب أن يكون أكثر من حرفين';
        hasRepresentativeErrors = true;
      } else if (!FormValidator.isArabicName(firstName)) {
        controller.firstNameError.value =
            'الاسم يجب أن يكون باللغة العربية حصراً';
        hasRepresentativeErrors = true;
      } else {
        controller.firstNameError.value = '';
      }

      final nickname = controller.nicknameController.text.trim();
      if (nickname.isEmpty) {
        controller.nicknameError.value = 'يرجى إدخال الكنية';
        hasRepresentativeErrors = true;
      } else if (nickname.length <= 2) {
        controller.nicknameError.value = 'الكنية يجب أن تكون أكثر من حرفين';
        hasRepresentativeErrors = true;
      } else if (!FormValidator.isArabicName(nickname)) {
        controller.nicknameError.value =
            'الكنية يجب أن تكون باللغة العربية حصراً';
        hasRepresentativeErrors = true;
      } else {
        controller.nicknameError.value = '';
      }

      final nationalId = controller.nationalIdController.text.trim();
      if (nationalId.isEmpty) {
        controller.nationalIdError.value = 'يرجى إدخال الرقم الوطني';
        hasRepresentativeErrors = true;
      } else if (!RegExp(r'^\d+$').hasMatch(nationalId)) {
        controller.nationalIdError.value =
            'الرقم الوطني يجب أن يحتوي على أرقام فقط';
        hasRepresentativeErrors = true;
      } else if (nationalId.length < 8 || nationalId.length > 12) {
        controller.nationalIdError.value =
            'الرقم الوطني يجب أن يكون بين 8 و12 رقماً';
        hasRepresentativeErrors = true;
      } else {
        controller.nationalIdError.value = '';
      }

      final companyName = controller.companyNameController.text.trim();
      if (companyName.isEmpty) {
        controller.companyNameError.value = 'يرجى إدخال اسم الشركة';
        hasCompanyErrors = true;
      } else if (companyName.length <= 2) {
        controller.companyNameError.value =
            'اسم الشركة يجب أن يكون أكثر من حرفين';
        hasCompanyErrors = true;
      } else if (!FormValidator.isArabicName(companyName)) {
        controller.companyNameError.value =
            'اسم الشركة يجب أن يكون باللغة العربية حصراً';
        hasCompanyErrors = true;
      } else {
        controller.companyNameError.value = '';
      }

      final licenseNum = controller.companyLicenseNumberController.text.trim();
      if (licenseNum.isEmpty) {
        controller.companyLicenseNumberError.value =
            'يرجى إدخال رقم ترخيص الشركة';
        hasCompanyErrors = true;
      } else if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(licenseNum)) {
        controller.companyLicenseNumberError.value =
            'غير مسموح بإدخال مسافات أو رموز أو أحرف عربية. الرجاء استخدام أحرف إنكليزية وأرقام فقط.';
        hasCompanyErrors = true;
      } else {
        controller.companyLicenseNumberError.value = '';
      }

      if (controller.companyLicenseDate.value == null) {
        controller.companyLicenseDateError.value =
            'يرجى اختيار تاريخ ترخيص الشركة';
        hasCompanyErrors = true;
      } else {
        controller.companyLicenseDateError.value = '';
      }

      if (hasRepresentativeErrors || hasCompanyErrors) {
        controller.errorMessage.value =
            'يرجى إدخال البيانات الشخصية والشركة المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
    }
    return true;
  }

  void clearStep2FieldErrors() {
    controller.firstNameError.value = '';
    controller.fatherNameError.value = '';
    controller.motherNameError.value = '';
    controller.nicknameError.value = '';
    controller.nationalIdError.value = '';
    controller.birthPlaceError.value = '';
    controller.birthDateError.value = '';
    controller.settlementPreviousLicenseError.value = '';
    controller.settlementAgreementError.value = '';
    controller.companyNameError.value = '';
    controller.companyLicenseNumberError.value = '';
    controller.companyLicenseDateError.value = '';
  }

  void scrollToField(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;

    try {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
      return;
    } catch (_) {}

    final renderBox = ctx.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final widgetOffset = renderBox.localToGlobal(Offset.zero).dy;

    double scrollTop = 0.0;
    try {
      final scrollableRenderBox =
          Scrollable.of(ctx).context.findRenderObject() as RenderBox?;
      if (scrollableRenderBox != null) {
        scrollTop = scrollableRenderBox.localToGlobal(Offset.zero).dy;
      }
    } catch (_) {}

    final targetOffset =
        controller.step2ScrollController.offset +
        (widgetOffset - scrollTop) -
        24.0;
    final clamped = targetOffset < 0
        ? 0.0
        : (controller.step2ScrollController.hasClients
              ? targetOffset.clamp(
                  0.0,
                  controller.step2ScrollController.position.maxScrollExtent,
                )
              : targetOffset);
    if (controller.step2ScrollController.hasClients) {
      controller.step2ScrollController.animateTo(
        clamped,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void scrollToFirstError() {
    if (controller.firstNameError.value.isNotEmpty &&
        controller.firstNameFieldKey.currentContext != null) {
      scrollToField(controller.firstNameFieldKey);
      return;
    }
    if (controller.fatherNameError.value.isNotEmpty &&
        controller.fatherNameFieldKey.currentContext != null) {
      scrollToField(controller.fatherNameFieldKey);
      return;
    }
    if (controller.motherNameError.value.isNotEmpty &&
        controller.motherNameFieldKey.currentContext != null) {
      scrollToField(controller.motherNameFieldKey);
      return;
    }
    if (controller.nicknameError.value.isNotEmpty &&
        controller.nicknameFieldKey.currentContext != null) {
      scrollToField(controller.nicknameFieldKey);
      return;
    }
    if (controller.nationalIdError.value.isNotEmpty &&
        controller.nationalIdFieldKey.currentContext != null) {
      scrollToField(controller.nationalIdFieldKey);
      return;
    }
    if (controller.birthPlaceError.value.isNotEmpty &&
        controller.birthPlaceFieldKey.currentContext != null) {
      scrollToField(controller.birthPlaceFieldKey);
      return;
    }
    if (controller.birthDateError.value.isNotEmpty &&
        controller.birthDateFieldKey.currentContext != null) {
      scrollToField(controller.birthDateFieldKey);
      return;
    }
    if (controller.settlementPreviousLicenseError.value.isNotEmpty &&
        controller.previousLicenseNumberFieldKey.currentContext != null) {
      scrollToField(controller.previousLicenseNumberFieldKey);
      return;
    }
    if (controller.settlementAgreementError.value.isNotEmpty &&
        controller.settlementAgreementFieldKey.currentContext != null) {
      scrollToField(controller.settlementAgreementFieldKey);
      return;
    }
    if (controller.companyNameError.value.isNotEmpty &&
        controller.companyNameFieldKey.currentContext != null) {
      scrollToField(controller.companyNameFieldKey);
      return;
    }
    if (controller.companyLicenseNumberError.value.isNotEmpty &&
        controller.companyLicenseNumberFieldKey.currentContext != null) {
      scrollToField(controller.companyLicenseNumberFieldKey);
      return;
    }
    if (controller.companyLicenseDateError.value.isNotEmpty &&
        controller.companyLicenseDateFieldKey.currentContext != null) {
      scrollToField(controller.companyLicenseDateFieldKey);
      return;
    }
  }

  void validateStep2Field(String fieldName, String value) {
    switch (fieldName) {
      case 'firstName':
        if (value.trim().isEmpty) {
          controller.firstNameError.value = 'يرجى إدخال الاسم الأول';
        } else if (value.trim().length <= 2) {
          controller.firstNameError.value = 'الاسم يجب أن يكون أكثر من حرفين';
        } else if (!FormValidator.isArabicName(value.trim())) {
          controller.firstNameError.value =
              'الاسم يجب أن يكون باللغة العربية حصراً';
        } else {
          controller.firstNameError.value = '';
        }
        if (controller.firstNameError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
        }
        break;
      case 'fatherName':
        if (controller.investorType.value == 'company') {
          controller.fatherNameError.value = '';
          return;
        }
        if (value.trim().isEmpty) {
          controller.fatherNameError.value = 'يرجى إدخال اسم الأب';
        } else if (value.trim().length <= 2) {
          controller.fatherNameError.value =
              'اسم الأب يجب أن يكون أكثر من حرفين';
        } else if (!FormValidator.isArabicName(value.trim())) {
          controller.fatherNameError.value =
              'اسم الأب يجب أن يكون باللغة العربية حصراً';
        } else {
          controller.fatherNameError.value = '';
        }
        if (controller.fatherNameError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
        }
        break;
      case 'motherName':
        if (controller.investorType.value == 'company') {
          controller.motherNameError.value = '';
          return;
        }
        if (value.trim().isEmpty) {
          controller.motherNameError.value = 'يرجى إدخال اسم الأم';
        } else if (value.trim().length <= 2) {
          controller.motherNameError.value =
              'اسم الأم يجب أن يكون أكثر من حرفين';
        } else if (!FormValidator.isArabicName(value.trim())) {
          controller.motherNameError.value =
              'اسم الأم يجب أن يكون باللغة العربية حصراً';
        } else {
          controller.motherNameError.value = '';
        }
        if (controller.motherNameError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
        }
        break;
      case 'nickname':
        if (value.trim().isEmpty) {
          controller.nicknameError.value = 'يرجى إدخال الكنية';
        } else if (value.trim().length <= 2) {
          controller.nicknameError.value = 'الكنية يجب أن تكون أكثر من حرفين';
        } else if (!FormValidator.isArabicName(value.trim())) {
          controller.nicknameError.value =
              'الكنية يجب أن تكون باللغة العربية حصراً';
        } else {
          controller.nicknameError.value = '';
        }
        if (controller.nicknameError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
        }
        break;
      case 'nationalId':
        if (value.trim().isEmpty) {
          controller.nationalIdError.value = 'يرجى إدخال الرقم الوطني';
        } else if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
          controller.nationalIdError.value =
              'الرقم الوطني يجب أن يحتوي على أرقام فقط';
        } else if (value.trim().length < 8 || value.trim().length > 12) {
          controller.nationalIdError.value =
              'الرقم الوطني يجب أن يكون بين 8 و12 رقماً';
        } else {
          controller.nationalIdError.value = '';
        }
        if (controller.nationalIdError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
        }
        break;
      case 'birthPlace':
        if (controller.investorType.value == 'company') {
          controller.birthPlaceError.value = '';
          return;
        }
        if (value.trim().isEmpty) {
          controller.birthPlaceError.value = 'يرجى إدخال مكان الولادة';
        } else if (value.trim().length <= 2) {
          controller.birthPlaceError.value =
              'مكان الولادة يجب أن يكون أكثر من حرفين';
        } else if (!FormValidator.isArabicName(value.trim())) {
          controller.birthPlaceError.value =
              'مكان الولادة يجب أن يكون باللغة العربية حصراً';
        } else {
          controller.birthPlaceError.value = '';
        }
        if (controller.birthPlaceError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
        }
        break;
      case 'birthDate':
        if (controller.investorType.value == 'company') {
          controller.birthDateError.value = '';
          return;
        }
        if (controller.birthDate.value == null) {
          controller.birthDateError.value = 'يرجى اختيار تاريخ الولادة';
        } else {
          final now = DateTime.now();
          var age = now.year - controller.birthDate.value!.year;
          if (now.month < controller.birthDate.value!.month ||
              (now.month == controller.birthDate.value!.month &&
                  now.day < controller.birthDate.value!.day)) {
            age--;
          }
          controller.birthDateError.value = age < 18
              ? 'يجب أن لا يقل عمر مقدم الطلب عن 18 سنة'
              : '';
        }
        if (controller.birthDateError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
        }
        break;
      case 'companyName':
        if (value.trim().isEmpty) {
          controller.companyNameError.value = 'يرجى إدخال اسم الشركة';
        } else if (value.trim().length <= 2) {
          controller.companyNameError.value =
              'اسم الشركة يجب أن يكون أكثر من حرفين';
        } else if (!FormValidator.isArabicName(value.trim())) {
          controller.companyNameError.value =
              'اسم الشركة يجب أن يكون باللغة العربية حصراً';
        } else {
          controller.companyNameError.value = '';
        }
        if (controller.companyNameError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
        }
        break;
      case 'companyLicenseNumber':
        if (value.trim().isEmpty) {
          controller.companyLicenseNumberError.value =
              'يرجى إدخال رقم ترخيص الشركة';
        } else if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(value.trim())) {
          controller.companyLicenseNumberError.value =
              'غير مسموح بإدخال مسافات أو رموز أو أحرف عربية. الرجاء استخدام أحرف إنكليزية وأرقام فقط.';
        } else {
          controller.companyLicenseNumberError.value = '';
        }
        if (controller.companyLicenseNumberError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
        }
        break;
      case 'previousLicenseNumber':
        if (value.trim().isEmpty) {
          controller.settlementPreviousLicenseError.value =
              'يرجى إدخال رقم الترخيص السابق';
        } else if (!RegExp(r'^[A-Za-z0-9-]+$').hasMatch(value.trim())) {
          controller.settlementPreviousLicenseError.value =
              'غير مسموح بإدخال مسافات أو رموز أو أحرف عربية. الرجاء استخدام أحرف إنكليزية وأرقام وواصلة (-) فقط.';
        } else {
          controller.settlementPreviousLicenseError.value = '';
        }
        if (controller.settlementPreviousLicenseError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
        }
        break;
      case 'companyLicenseDate':
        if (controller.companyLicenseDate.value == null) {
          controller.companyLicenseDateError.value =
              'يرجى اختيار تاريخ ترخيص الشركة';
        } else {
          final now = DateTime.now();
          final selectedDate = DateTime(
            controller.companyLicenseDate.value!.year,
            controller.companyLicenseDate.value!.month,
            controller.companyLicenseDate.value!.day,
          );
          final today = DateTime(now.year, now.month, now.day);
          if (!selectedDate.isBefore(today)) {
            controller.companyLicenseDateError.value =
                'يجب أن يكون التاريخ من أمس أو قبله';
          } else {
            controller.companyLicenseDateError.value = '';
          }
        }
        if (controller.companyLicenseDateError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
        }
        break;
    }
  }

  bool validateStep3() {
    controller.errorMessage.value = '';
    final oldLocationValid =
        controller.oldSelectedGovernorate.value != null &&
        controller.oldSelectedDistrict.value != null &&
        controller.oldSelectedSubdistrict.value != null &&
        controller.oldSelectedTown.value != null &&
        controller.oldLatitudeController.text.isNotEmpty &&
        controller.oldLongitudeController.text.isNotEmpty;
    if (controller.requestType.value == 'settlement' &&
        controller.settlementRelocation.value &&
        !oldLocationValid) {
      controller.errorMessage.value = 'يرجى إدخال بيانات الموقع القديم كاملة';
      return false;
    }
    if (controller.selectedGovernorate.value == null) {
      controller.errorMessage.value = 'يرجى اختيار المحافظة';
      return false;
    }
    if (controller.selectedDistrict.value == null) {
      controller.errorMessage.value = 'يرجى اختيار المنطقة';
      return false;
    }
    if (controller.selectedSubdistrict.value == null) {
      controller.errorMessage.value = 'يرجى اختيار الناحية';
      return false;
    }
    if (controller.selectedTown.value == null) {
      controller.errorMessage.value = 'يرجى اختيار البلدة';
      return false;
    }
    if (controller.latitudeController.text.isEmpty ||
        controller.longitudeController.text.isEmpty) {
      controller.errorMessage.value = 'يرجى تحديد موقع المحطة على الخريطة';
      return false;
    }
    return true;
  }
}
