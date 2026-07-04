import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart' as dio;
import 'package:licences_application/core/services/core_api_service.dart';
import '../routes/app_routes.dart';
import '../models/governorate_model.dart';
import '../../core/validators/form_validator.dart';

class AttachmentRequirement {
  final String key;
  final String title;
  final String docType;

  const AttachmentRequirement({
    required this.key,
    required this.title,
    required this.docType,
  });
}

class LicenseApplicationController extends GetxController {
  static LicenseApplicationController get to => Get.find();

  // ─── Step tracking ───────────────────────────────────────────────
  final currentStep = 0.obs; // 0-based (0=Step1 … 3=Step4)
  final applicationId = ''.obs;
  final isLoading = false.obs;
  final isGovernoratesLoading = false.obs;
  final isDistrictsLoading = false.obs;
  final isSubdistrictsLoading = false.obs;
  final isTownsLoading = false.obs;
  final errorMessage = ''.obs;

  // ─── STEP 1: Conditions & Contact ────────────────────────────────
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final phone2Controller = TextEditingController();
  final agreedToTerms = false.obs;
  bool termsFileViewed = false;

  // ─── STEP 2: License Info ─────────────────────────────────────────
  // Request type
  final requestType = 'new'.obs; // 'new' | 'settlement'
  final previousLicenseNumber = TextEditingController();
  final settledAgreed = false.obs;

  // Investor type
  final investorType = 'individual'.obs; // 'individual' | 'company'

  // Individual fields
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final fatherNameController = TextEditingController();
  final motherNameController = TextEditingController();
  final nicknameController = TextEditingController();
  final nationalIdController = TextEditingController();
  final birthPlaceController = TextEditingController();
  final birthDate = Rxn<DateTime>();

  final firstNameError = ''.obs;
  final birthPlaceError = ''.obs;
  final fatherNameError = ''.obs;
  final motherNameError = ''.obs;
  final nicknameError = ''.obs;
  final nationalIdError = ''.obs;
  final birthDateError = ''.obs;
  final settlementPreviousLicenseError = ''.obs;
  final settlementAgreementError = ''.obs;

  // Company fields
  final companyNameController = TextEditingController();
  final companyLicenseNumberController = TextEditingController();
  final companyLicenseDate = Rxn<DateTime>();
  final partners = <String>[].obs; // list of partner names
  final partnersKeys = <Key>[].obs;

  final companyNameError = ''.obs;
  final companyLicenseNumberError = ''.obs;
  final companyLicenseDateError = ''.obs;

  final firstNameFocus = FocusNode();
  final fatherNameFocus = FocusNode();
  final motherNameFocus = FocusNode();
  final nicknameFocus = FocusNode();
  final nationalIdFocus = FocusNode();
  final birthPlaceFocus = FocusNode();
  final birthDateFocus = FocusNode();
  final companyNameFocus = FocusNode();
  final companyLicenseNumberFocus = FocusNode();

  // Keys for scrolling to fields with errors
  final firstNameFieldKey = GlobalKey();
  final fatherNameFieldKey = GlobalKey();
  final motherNameFieldKey = GlobalKey();
  final nicknameFieldKey = GlobalKey();
  final nationalIdFieldKey = GlobalKey();
  final birthPlaceFieldKey = GlobalKey();
  final birthDateFieldKey = GlobalKey();
  final previousLicenseNumberFieldKey = GlobalKey();
  final settlementAgreementFieldKey = GlobalKey();
  final companyNameFieldKey = GlobalKey();
  final companyLicenseNumberFieldKey = GlobalKey();
  final companyLicenseDateFieldKey = GlobalKey();

  // ─── STEP 3: Location & Classification ───────────────────────────
  final governorates = <GovernorateModel>[].obs;
  final districts = <GovernorateModel>[].obs;
  final subdistricts = <GovernorateModel>[].obs;
  final towns = <GovernorateModel>[].obs;

  final selectedGovernorate = Rxn<GovernorateModel>();
  final selectedDistrict = Rxn<GovernorateModel>();
  final selectedSubdistrict = Rxn<GovernorateModel>();
  final selectedTown = Rxn<GovernorateModel>();

  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final selectedLocation = Rxn<LatLng>();
  final locationStatus = 'not_set'.obs; // 'not_set' | 'set' | 'denied'

  // Planning
  final planningLocation = 'inside'.obs; // 'inside' | 'outside'

  void setLocation(double latitude, double longitude) {
    latitudeController.text = latitude.toStringAsFixed(6);
    longitudeController.text = longitude.toStringAsFixed(6);
    selectedLocation.value = LatLng(latitude, longitude);
    locationStatus.value = 'set';
  }

  final roadType = 'international'.obs; // 'international' | 'central' | 'local'
  final stationCategory = 'A'.obs; // 'A' | 'B' | 'C'

  // ─── STEP 4: Attachments ─────────────────────────────────────────
  // Required files
  File? idCardFile;
  File? propertyMapFile;
  File? landTitleFile;
  File? validLicenseFile;
  File? leaseContractFile;
  File? commercialRegisterFile;
  File? investmentContractFile;
  File? valuationStatementFile;

  final idCardUploaded = false.obs;
  final propertyMapUploaded = false.obs;
  final landTitleUploaded = false.obs;
  final validLicenseUploaded = false.obs;
  final leaseContractUploaded = false.obs;
  final commercialRegisterUploaded = false.obs;
  final investmentContractUploaded = false.obs;
  final valuationStatementUploaded = false.obs;

  // ─── Success ──────────────────────────────────────────────────────
  final submittedApplicationNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadGovernorates();
    // Ensure when switching to company, at least one partner field exists
    ever<String>(investorType, (val) {
      if (val == 'company' && partners.isEmpty) {
        partners.add('');
        partnersKeys.add(ValueKey(DateTime.now().microsecondsSinceEpoch));
      }
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    phone2Controller.dispose();
    previousLicenseNumber.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    fatherNameController.dispose();
    motherNameController.dispose();
    nicknameController.dispose();
    nationalIdController.dispose();
    birthPlaceController.dispose();
    companyNameController.dispose();
    companyLicenseNumberController.dispose();
    firstNameFocus.dispose();
    fatherNameFocus.dispose();
    motherNameFocus.dispose();
    nicknameFocus.dispose();
    nationalIdFocus.dispose();
    birthPlaceFocus.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.onClose();
  }

  Future<dio.Response> _get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return CoreApiService.get(path, queryParameters: queryParameters);
  }

  Future<dio.Response> _post(
    String path, {
    dynamic data,
    dio.Options? options,
  }) async {
    return CoreApiService.post(path, data: data, options: options);
  }

  // ─── Step navigation ─────────────────────────────────────────────
  void goToNextStep() {
    if (currentStep.value < 3) {
      currentStep.value++;
    }
  }

  void goToPreviousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  // ─── Validation ───────────────────────────────────────────────────
  bool validateStep1() {
    errorMessage.value = '';

    final emailError = FormValidator.validateEmailField(emailController.text);
    if (emailError != null) {
      errorMessage.value = emailError;
      return false;
    }

    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      errorMessage.value = 'يرجى إدخال رقم التواصل';
      return false;
    }
    if (!RegExp(r'^09\d{8}$').hasMatch(phone)) {
      errorMessage.value = 'رقم التواصل يجب أن يبدأ بـ 09 وأن يكون 10 أرقام';
      return false;
    }

    final secondaryPhone = phone2Controller.text.trim();
    if (secondaryPhone.isNotEmpty &&
        !RegExp(r'^09\d{8}$').hasMatch(secondaryPhone)) {
      errorMessage.value =
          'رقم التواصل الثانوي يجب أن يبدأ بـ 09 وأن يكون 10 أرقام';
      return false;
    }

    if (!agreedToTerms.value) {
      errorMessage.value = 'يجب الموافقة على الشروط والأحكام للمتابعة';
      return false;
    }
    return true;
  }

  bool validateStep2() {
    errorMessage.value = '';
    clearStep2FieldErrors();

    if (requestType.value == 'settlement') {
      final hasPreviousLicenseNumber = previousLicenseNumber.text
          .trim()
          .isNotEmpty;
      final hasSettlementAgreement = settledAgreed.value;

      if (!hasPreviousLicenseNumber) {
        settlementPreviousLicenseError.value = 'يرجى إدخال رقم الترخيص السابق';
      } else {
        settlementPreviousLicenseError.value = '';
      }

      if (!hasSettlementAgreement) {
        settlementAgreementError.value =
            'يجب الموافقة على المراحل الإلزامية للتسوية';
      } else {
        settlementAgreementError.value = '';
      }

      if (!hasPreviousLicenseNumber || !hasSettlementAgreement) {
        errorMessage.value = 'يرجى إكمال بيانات التسوية المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
    }

    if (investorType.value == 'individual' || investorType.value == 'company') {
      final firstName = firstNameController.text.trim();
      if (firstName.isEmpty) {
        firstNameError.value = 'يرجى إدخال الاسم الأول';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
      if (firstName.length <= 2) {
        firstNameError.value = 'الاسم يجب أن يكون أكثر من حرفين';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }
      if (!FormValidator.isArabicName(firstName)) {
        firstNameError.value = 'الاسم يجب أن يكون باللغة العربية حصراً';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }

      final fatherName = fatherNameController.text.trim();
      if (fatherName.isEmpty) {
        fatherNameError.value = 'يرجى إدخال اسم الأب';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
      if (fatherName.length <= 2) {
        fatherNameError.value = 'اسم الأب يجب أن يكون أكثر من حرفين';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }
      if (!FormValidator.isArabicName(fatherName)) {
        fatherNameError.value = 'اسم الأب يجب أن يكون باللغة العربية حصراً';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }

      final motherName = motherNameController.text.trim();
      if (motherName.isEmpty) {
        motherNameError.value = 'يرجى إدخال اسم الأم';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
      if (motherName.length <= 2) {
        motherNameError.value = 'اسم الأم يجب أن يكون أكثر من حرفين';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }
      if (!FormValidator.isArabicName(motherName)) {
        motherNameError.value = 'اسم الأم يجب أن يكون باللغة العربية حصراً';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }

      final nickname = nicknameController.text.trim();
      if (nickname.isEmpty) {
        nicknameError.value = 'يرجى إدخال الكنية';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
      if (nickname.length <= 2) {
        nicknameError.value = 'الكنية يجب أن تكون أكثر من حرفين';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }
      if (!FormValidator.isArabicName(nickname)) {
        nicknameError.value = 'الكنية يجب أن تكون باللغة العربية حصراً';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }

      final nationalId = nationalIdController.text.trim();
      if (nationalId.isEmpty) {
        nationalIdError.value = 'يرجى إدخال الرقم الوطني';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
      if (!RegExp(r'^\d+$').hasMatch(nationalId)) {
        nationalIdError.value = 'الرقم الوطني يجب أن يحتوي على أرقام فقط';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }
      if (nationalId.length < 9 || nationalId.length > 12) {
        nationalIdError.value = 'الرقم الوطني يجب أن يكون بين 9 و12 رقماً';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }

      final birthPlace = birthPlaceController.text.trim();
      if (birthPlace.isEmpty) {
        birthPlaceError.value = 'يرجى إدخال مكان الولادة';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
      if (birthPlace.length <= 2) {
        birthPlaceError.value = 'مكان الولادة يجب أن يكون أكثر من حرفين';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }
      if (!FormValidator.isArabicName(birthPlace)) {
        birthPlaceError.value = 'مكان الولادة يجب أن يكون باللغة العربية حصراً';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        return false;
      }

      final selectedBirthDate = birthDate.value;
      if (selectedBirthDate == null) {
        birthDateError.value = 'يرجى اختيار تاريخ الولادة';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
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
        birthDateError.value = 'يجب أن لا يقل عمر مقدم الطلب عن 18 سنة';
        errorMessage.value = 'يرجى إدخال البيانات الشخصية المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
    } else {
      final companyName = companyNameController.text.trim();
      if (companyName.isEmpty) {
        companyNameError.value = 'يرجى إدخال اسم الشركة';
        errorMessage.value = 'يرجى إدخال بيانات الشركة المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
      if (companyName.length <= 2) {
        companyNameError.value = 'اسم الشركة يجب أن يكون أكثر من حرفين';
        errorMessage.value = 'يرجى إدخال بيانات الشركة المطلوبة';
        return false;
      }
      if (!FormValidator.isArabicName(companyName)) {
        companyNameError.value = 'اسم الشركة يجب أن يكون باللغة العربية حصراً';
        errorMessage.value = 'يرجى إدخال بيانات الشركة المطلوبة';
        return false;
      }

      final licenseNum = companyLicenseNumberController.text.trim();
      if (licenseNum.isEmpty) {
        companyLicenseNumberError.value = 'يرجى إدخال رقم ترخيص الشركة';
        errorMessage.value = 'يرجى إدخال بيانات الشركة المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
      if (!RegExp(r'^\d+$').hasMatch(licenseNum)) {
        companyLicenseNumberError.value =
            'رقم الترخيص يجب أن يحتوي على أرقام فقط';
        errorMessage.value = 'يرجى إدخال بيانات الشركة المطلوبة';
        return false;
      }

      if (companyLicenseDate.value == null) {
        companyLicenseDateError.value = 'يرجى اختيار تاريخ ترخيص الشركة';
        errorMessage.value = 'يرجى إدخال بيانات الشركة المطلوبة';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToFirstError();
        });
        return false;
      }
    }
    return true;
  }

  void clearStep2FieldErrors() {
    firstNameError.value = '';
    fatherNameError.value = '';
    motherNameError.value = '';
    nicknameError.value = '';
    nationalIdError.value = '';
    birthPlaceError.value = '';
    birthDateError.value = '';
    settlementPreviousLicenseError.value = '';
    settlementAgreementError.value = '';
    companyNameError.value = '';
    companyLicenseNumberError.value = '';
    companyLicenseDateError.value = '';
  }

  void scrollToField(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  void scrollToFirstError() {
    if (firstNameError.value.isNotEmpty &&
        firstNameFieldKey.currentContext != null) {
      scrollToField(firstNameFieldKey);
      return;
    }
    if (fatherNameError.value.isNotEmpty &&
        fatherNameFieldKey.currentContext != null) {
      scrollToField(fatherNameFieldKey);
      return;
    }
    if (motherNameError.value.isNotEmpty &&
        motherNameFieldKey.currentContext != null) {
      scrollToField(motherNameFieldKey);
      return;
    }
    if (nicknameError.value.isNotEmpty &&
        nicknameFieldKey.currentContext != null) {
      scrollToField(nicknameFieldKey);
      return;
    }
    if (nationalIdError.value.isNotEmpty &&
        nationalIdFieldKey.currentContext != null) {
      scrollToField(nationalIdFieldKey);
      return;
    }
    if (birthPlaceError.value.isNotEmpty &&
        birthPlaceFieldKey.currentContext != null) {
      scrollToField(birthPlaceFieldKey);
      return;
    }
    if (birthDateError.value.isNotEmpty &&
        birthDateFieldKey.currentContext != null) {
      scrollToField(birthDateFieldKey);
      return;
    }
    if (settlementPreviousLicenseError.value.isNotEmpty &&
        previousLicenseNumberFieldKey.currentContext != null) {
      scrollToField(previousLicenseNumberFieldKey);
      return;
    }
    if (settlementAgreementError.value.isNotEmpty &&
        settlementAgreementFieldKey.currentContext != null) {
      scrollToField(settlementAgreementFieldKey);
      return;
    }
    if (companyNameError.value.isNotEmpty &&
        companyNameFieldKey.currentContext != null) {
      scrollToField(companyNameFieldKey);
      return;
    }
    if (companyLicenseNumberError.value.isNotEmpty &&
        companyLicenseNumberFieldKey.currentContext != null) {
      scrollToField(companyLicenseNumberFieldKey);
      return;
    }
    if (companyLicenseDateError.value.isNotEmpty &&
        companyLicenseDateFieldKey.currentContext != null) {
      scrollToField(companyLicenseDateFieldKey);
      return;
    }
  }

  void validateStep2Field(String fieldName, String value) {
    switch (fieldName) {
      case 'firstName':
        if (value.trim().isEmpty) {
          firstNameError.value = 'يرجى إدخال الاسم الأول';
        } else if (value.trim().length <= 2) {
          firstNameError.value = 'الاسم يجب أن يكون أكثر من حرفين';
        } else if (!FormValidator.isArabicName(value.trim())) {
          firstNameError.value = 'الاسم يجب أن يكون باللغة العربية حصراً';
        } else {
          firstNameError.value = '';
        }
        break;
      case 'fatherName':
        if (value.trim().isEmpty) {
          fatherNameError.value = 'يرجى إدخال اسم الأب';
        } else if (value.trim().length <= 2) {
          fatherNameError.value = 'اسم الأب يجب أن يكون أكثر من حرفين';
        } else if (!FormValidator.isArabicName(value.trim())) {
          fatherNameError.value = 'اسم الأب يجب أن يكون باللغة العربية حصراً';
        } else {
          fatherNameError.value = '';
        }
        break;
      case 'motherName':
        if (value.trim().isEmpty) {
          motherNameError.value = 'يرجى إدخال اسم الأم';
        } else if (value.trim().length <= 2) {
          motherNameError.value = 'اسم الأم يجب أن يكون أكثر من حرفين';
        } else if (!FormValidator.isArabicName(value.trim())) {
          motherNameError.value = 'اسم الأم يجب أن يكون باللغة العربية حصراً';
        } else {
          motherNameError.value = '';
        }
        break;
      case 'nickname':
        if (value.trim().isEmpty) {
          nicknameError.value = 'يرجى إدخال الكنية';
        } else if (value.trim().length <= 2) {
          nicknameError.value = 'الكنية يجب أن تكون أكثر من حرفين';
        } else if (!FormValidator.isArabicName(value.trim())) {
          nicknameError.value = 'الكنية يجب أن تكون باللغة العربية حصراً';
        } else {
          nicknameError.value = '';
        }
        break;
      case 'nationalId':
        if (value.trim().isEmpty) {
          nationalIdError.value = 'يرجى إدخال الرقم الوطني';
        } else if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
          nationalIdError.value = 'الرقم الوطني يجب أن يحتوي على أرقام فقط';
        } else if (value.trim().length < 9 || value.trim().length > 12) {
          nationalIdError.value = 'الرقم الوطني يجب أن يكون بين 9 و12 رقماً';
        } else {
          nationalIdError.value = '';
        }
        break;
      case 'birthPlace':
        if (value.trim().isEmpty) {
          birthPlaceError.value = 'يرجى إدخال مكان الولادة';
        } else if (value.trim().length <= 2) {
          birthPlaceError.value = 'مكان الولادة يجب أن يكون أكثر من حرفين';
        } else if (!FormValidator.isArabicName(value.trim())) {
          birthPlaceError.value =
              'مكان الولادة يجب أن يكون باللغة العربية حصراً';
        } else {
          birthPlaceError.value = '';
        }
        break;
      case 'birthDate':
        if (birthDate.value == null) {
          birthDateError.value = 'يرجى اختيار تاريخ الولادة';
        } else {
          final now = DateTime.now();
          var age = now.year - birthDate.value!.year;
          if (now.month < birthDate.value!.month ||
              (now.month == birthDate.value!.month &&
                  now.day < birthDate.value!.day)) {
            age--;
          }
          birthDateError.value = age < 18
              ? 'يجب أن لا يقل عمر مقدم الطلب عن 18 سنة'
              : '';
        }
        break;
      case 'companyName':
        if (value.trim().isEmpty) {
          companyNameError.value = 'يرجى إدخال اسم الشركة';
        } else if (value.trim().length <= 2) {
          companyNameError.value = 'اسم الشركة يجب أن يكون أكثر من حرفين';
        } else if (!FormValidator.isArabicName(value.trim())) {
          companyNameError.value =
              'اسم الشركة يجب أن يكون باللغة العربية حصراً';
        } else {
          companyNameError.value = '';
        }
        break;
      case 'companyLicenseNumber':
        if (value.trim().isEmpty) {
          companyLicenseNumberError.value = 'يرجى إدخال رقم ترخيص الشركة';
        } else if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
          companyLicenseNumberError.value =
              'رقم الترخيص يجب أن يحتوي على أرقام فقط';
        } else {
          companyLicenseNumberError.value = '';
        }
        break;
      case 'companyLicenseDate':
        if (companyLicenseDate.value == null) {
          companyLicenseDateError.value = 'يرجى اختيار تاريخ ترخيص الشركة';
        } else {
          companyLicenseDateError.value = '';
        }
        break;
    }
  }

  void requestFocus(FocusNode nextFocus) {
    FocusScope.of(Get.context!).requestFocus(nextFocus);
  }

  bool validateStep3() {
    errorMessage.value = '';
    if (selectedGovernorate.value == null) {
      errorMessage.value = 'يرجى اختيار المحافظة';
      return false;
    }
    if (latitudeController.text.isEmpty || longitudeController.text.isEmpty) {
      errorMessage.value = 'يرجى تحديد موقع المحطة على الخريطة';
      return false;
    }
    return true;
  }

  List<AttachmentRequirement> getRequiredAttachments() {
    final isSettlement = requestType.value == 'settlement';
    final isCompany = investorType.value == 'company';

    final landTitleTitle =
        requestType.value == 'new' && investorType.value == 'individual'
        ? 'بيان قيد فردي (حديث)'
        : 'بيان قيد عقاري (حديث)';

    final attachments = <AttachmentRequirement>[
      const AttachmentRequirement(
        key: 'id_card',
        title: 'صورة عن الهوية (وجه أمامي وخلفي معاً)',
        docType: 'NATIONAL_ID',
      ),
      AttachmentRequirement(
        key: 'land_title',
        title: landTitleTitle,
        docType: 'REGISTRATION_STATEMENT',
      ),
      const AttachmentRequirement(
        key: 'property_map',
        title: 'مخطط مساحي مصدق من المصالح العقارية بمقياس رسم',
        docType: 'SURVEY_MAP',
      ),
    ];

    if (isSettlement) {
      attachments.add(
        const AttachmentRequirement(
          key: 'valid_license',
          title: 'صورة عن الرخصة سارية المفعول',
          docType: 'VALID_LICENSE',
        ),
      );
      attachments.add(
        const AttachmentRequirement(
          key: 'lease_contract',
          title: 'عقد إيجار لا يقل عن 15 عاماً',
          docType: 'LEASE_CONTRACT',
        ),
      );
    }

    if (isCompany) {
      attachments.add(
        const AttachmentRequirement(
          key: 'commercial_register',
          title: 'السجل التجاري',
          docType: 'COMMERCIAL_REGISTER',
        ),
      );
    } else if (isSettlement) {
      attachments.add(
        const AttachmentRequirement(
          key: 'investment_contract',
          title: 'عقد استثمار',
          docType: 'INVESTMENT_CONTRACT',
        ),
      );
    }

    return attachments;
  }

  File? getAttachmentFile(String key) {
    switch (key) {
      case 'id_card':
        return idCardFile;
      case 'property_map':
        return propertyMapFile;
      case 'land_title':
        return landTitleFile;
      case 'valid_license':
        return validLicenseFile;
      case 'lease_contract':
        return leaseContractFile;
      case 'commercial_register':
        return commercialRegisterFile;
      case 'investment_contract':
        return investmentContractFile;
      default:
        return null;
    }
  }

  bool isAttachmentUploaded(String key) {
    switch (key) {
      case 'id_card':
        return idCardUploaded.value;
      case 'property_map':
        return propertyMapUploaded.value;
      case 'land_title':
        return landTitleUploaded.value;
      case 'valid_license':
        return validLicenseUploaded.value;
      case 'lease_contract':
        return leaseContractUploaded.value;
      case 'commercial_register':
        return commercialRegisterUploaded.value;
      case 'investment_contract':
        return investmentContractUploaded.value;
      default:
        return false;
    }
  }

  void setAttachmentFile(String key, File? file) {
    switch (key) {
      case 'id_card':
        idCardFile = file;
        idCardUploaded.value = file != null;
        break;
      case 'property_map':
        propertyMapFile = file;
        propertyMapUploaded.value = file != null;
        break;
      case 'land_title':
        landTitleFile = file;
        landTitleUploaded.value = file != null;
        break;
      case 'valid_license':
        validLicenseFile = file;
        validLicenseUploaded.value = file != null;
        break;
      case 'lease_contract':
        leaseContractFile = file;
        leaseContractUploaded.value = file != null;
        break;
      case 'commercial_register':
        commercialRegisterFile = file;
        commercialRegisterUploaded.value = file != null;
        break;
      case 'investment_contract':
        investmentContractFile = file;
        investmentContractUploaded.value = file != null;
        break;
    }
  }

  void clearAttachment(String key) {
    setAttachmentFile(key, null);
  }

  String? getAttachmentFileName(String key) {
    final file = getAttachmentFile(key);
    return file?.path.split(Platform.pathSeparator).last;
  }

  bool validateStep4() {
    errorMessage.value = '';
    final requiredAttachments = getRequiredAttachments();
    final hasAllUploads = requiredAttachments.every(
      (attachment) => isAttachmentUploaded(attachment.key),
    );

    if (!hasAllUploads) {
      errorMessage.value = 'يرجى رفع جميع المرفقات المطلوبة';
      return false;
    }
    return true;
  }

  Map<String, dynamic> buildUserInfoPayload() {
    // All applicants must provide personal information
    final userInfoMap = {
      'user_info[first_name]': firstNameController.text.trim(),
      'user_info[father_name]': fatherNameController.text.trim(),
      'user_info[last_name]': nicknameController.text.trim(),
      'user_info[mother_name]': motherNameController.text.trim(),
      'user_info[national_id]': nationalIdController.text.trim(),
      'user_info[place_of_birth]': birthPlaceController.text.trim(),
      'user_info[date_of_birth]': birthDate.value != null
          ? '${birthDate.value!.year.toString().padLeft(4, '0')}-${birthDate.value!.month.toString().padLeft(2, '0')}-${birthDate.value!.day.toString().padLeft(2, '0')}'
          : '',
    };

    // For company applicants, add company info to applicant section
    if (investorType.value == 'company') {
      userInfoMap['applicant[company_name]'] = companyNameController.text
          .trim();
      userInfoMap['applicant[company_license_number]'] =
          companyLicenseNumberController.text.trim();
      userInfoMap['applicant[company_license_date]'] =
          companyLicenseDate.value != null
          ? '${companyLicenseDate.value!.year.toString().padLeft(4, '0')}-${companyLicenseDate.value!.month.toString().padLeft(2, '0')}-${companyLicenseDate.value!.day.toString().padLeft(2, '0')}'
          : '';
    }

    return userInfoMap;
  }

  // ─── Submit Step 1 ────────────────────────────────────────────────
  Future<void> submitStep1() async {
    if (!validateStep1()) return;
    goToNextStep();
  }

  // ─── Submit Step 2 ────────────────────────────────────────────────
  Future<void> submitStep2() async {
    if (!validateStep2()) return;
    goToNextStep();
  }

  // ─── Submit Step 3 ────────────────────────────────────────────────
  Future<void> submitStep3() async {
    if (!validateStep3()) return;
    goToNextStep();
  }

  // ─── Submit Step 4 (final) ────────────────────────────────────────
  Future<void> submitFinal() async {
    if (!validateStep1()) {
      currentStep.value = 0;
      return;
    }
    if (!validateStep2()) {
      currentStep.value = 1;
      return;
    }
    if (!validateStep3()) {
      currentStep.value = 2;
      return;
    }
    if (!validateStep4()) {
      currentStep.value = 3;
      return;
    }

    final requiredAttachments = getRequiredAttachments();
    final missingFiles = requiredAttachments.where(
      (attachment) => getAttachmentFile(attachment.key) == null,
    );
    if (missingFiles.isNotEmpty) {
      errorMessage.value = 'يرجى رفع جميع المرفقات المطلوبة قبل الإرسال';
      currentStep.value = 3;
      return;
    }

    try {
      isLoading.value = true;
      final applicantFullName = investorType.value == 'individual'
          ? '${firstNameController.text.trim()} ${fatherNameController.text.trim()} ${lastNameController.text.trim()}'
          : companyNameController.text.trim();
      final formData = dio.FormData.fromMap({
        'operation_type': requestType.value.toUpperCase(),
        'terms_accepted': agreedToTerms.value ? 1 : 0,
        'category[zoning]': planningLocation.value == 'inside'
            ? 'INSIDE'
            : 'OUTSIDE',
        if (planningLocation.value != 'inside')
          'category[road_type]': roadType.value.toUpperCase(),
        'category[license_category]': stationCategory.value,
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'applicant_type': investorType.value == 'individual'
            ? 'INDIVIDUAL'
            : 'COMPANY',
        if (investorType.value == 'individual') ...{
          'applicant[full_name]': applicantFullName,
        } else ...{
          // Company applicant info is now included in buildUserInfoPayload()
          for (var i = 0; i < partners.length; i++)
            if (partners[i].trim().isNotEmpty)
              'applicant[partners][$i]': partners[i].trim(),
        },
        if (requestType.value == 'settlement') ...{
          'settlement[is_relocation]': 0,
          'settlement[license_number]': previousLicenseNumber.text.trim(),
        },
        'location[governorate_id]': selectedGovernorate.value?.id,
        'location[district_id]': selectedDistrict.value?.id,
        'location[sub_district_id]': selectedSubdistrict.value?.id,
        'location[town_id]': selectedTown.value?.id,
        'location[latitude]': latitudeController.text.trim(),
        'location[longitude]': longitudeController.text.trim(),
        ...buildUserInfoPayload(),
      });
      for (var i = 0; i < requiredAttachments.length; i++) {
        final attachment = requiredAttachments[i];
        final file = getAttachmentFile(attachment.key);
        if (file == null) {
          errorMessage.value = 'يرجى رفع جميع المرفقات المطلوبة قبل الإرسال';
          currentStep.value = 3;
          return;
        }
        formData.fields.add(
          MapEntry('attachments[$i][doc_type]', attachment.docType),
        );
        formData.files.add(
          MapEntry(
            'attachments[$i][file]',
            await dio.MultipartFile.fromFile(
              file.path,
              filename: file.path.split(Platform.pathSeparator).last,
            ),
          ),
        );
      }

      await _post(
        '/v1/license-applications',
        data: formData,
        options: dio.Options(contentType: 'multipart/form-data'),
      );

      final now = DateTime.now();
      submittedApplicationNumber.value =
          'SY-LR-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-000';
      Get.offAllNamed(AppRoutes.applicationSuccess);
    } catch (_) {
      errorMessage.value = 'حدث خطأ في إرسال الطلب';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Lookups ─────────────────────────────────────────────────────
  Future<void> _loadGovernorates() async {
    isGovernoratesLoading.value = true;
    try {
      final res = await CoreApiService.get('/v1/governorates');
      final data = res.data is Map ? res.data['data'] : res.data;
      governorates.value = (data as List)
          .map((e) => GovernorateModel.fromJson(e))
          .toList();
    } catch (_) {
      governorates.value = [];
    } finally {
      isGovernoratesLoading.value = false;
    }
  }

  Future<void> onGovernorateChanged(GovernorateModel? gov) async {
    selectedGovernorate.value = gov;
    selectedDistrict.value = null;
    selectedSubdistrict.value = null;
    selectedTown.value = null;
    districts.clear();
    subdistricts.clear();
    towns.clear();
    if (gov == null) return;
    isDistrictsLoading.value = true;
    try {
      final res = await CoreApiService.get(
        '/v1/governorates/${gov.id}/districts',
      );
      final data = res.data is Map ? res.data['data'] : res.data;
      districts.value = (data as List)
          .map((e) => GovernorateModel.fromJson(e))
          .toList();
    } catch (_) {
    } finally {
      isDistrictsLoading.value = false;
    }
  }

  Future<void> onDistrictChanged(GovernorateModel? dist) async {
    selectedDistrict.value = dist;
    selectedSubdistrict.value = null;
    selectedTown.value = null;
    subdistricts.clear();
    towns.clear();
    if (dist == null) return;
    isSubdistrictsLoading.value = true;
    try {
      final res = await CoreApiService.get(
        '/v1/districts/${dist.id}/sub-districts',
      );
      final data = res.data is Map ? res.data['data'] : res.data;
      subdistricts.value = (data as List)
          .map((e) => GovernorateModel.fromJson(e))
          .toList();
    } catch (_) {
    } finally {
      isSubdistrictsLoading.value = false;
    }
  }

  Future<void> onSubdistrictChanged(GovernorateModel? sub) async {
    selectedSubdistrict.value = sub;
    selectedTown.value = null;
    towns.clear();
    if (sub == null) return;
    isTownsLoading.value = true;
    try {
      final res = await CoreApiService.get('/v1/sub-districts/${sub.id}/towns');
      final data = res.data is Map ? res.data['data'] : res.data;
      towns.value = (data as List)
          .map((e) => GovernorateModel.fromJson(e))
          .toList();
    } catch (_) {
    } finally {
      isTownsLoading.value = false;
    }
  }

  void addPartner() {
    partners.add('');
    partnersKeys.add(ValueKey(DateTime.now().microsecondsSinceEpoch));
  }

  void removePartner(int index) {
    if (index < 0 || index >= partners.length) return;
    partners.removeAt(index);
    if (index >= 0 && index < partnersKeys.length) partnersKeys.removeAt(index);
  }

  void updatePartner(int index, String name) => partners[index] = name;
}
