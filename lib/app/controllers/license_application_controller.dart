import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart' as dio;
import 'package:licences_application/core/services/core_api_service.dart';
import '../routes/app_routes.dart';
import '../models/governorate_model.dart';
import '../models/application_model.dart';
import '../models/attachment_requirement.dart';
import 'parts/license_correction_mixin.dart';
import 'parts/license_form_state_mixin.dart';
import 'parts/license_validation_mixin.dart';

class LicenseApplicationController extends GetxController
    with LicenseValidationMixin, LicenseCorrectionMixin, LicenseFormStateMixin {
  static LicenseApplicationController get to => Get.find();

  String extractSubmissionErrorMessage(Object error) {
    if (error is dio.DioException) {
      final responseData = error.response?.data;

      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }

        final errors = responseData['errors'];
        if (errors is Map) {
          for (final entry in errors.entries) {
            final value = entry.value;
            if (value is List && value.isNotEmpty) {
              final firstMessage = value.first;
              if (firstMessage is String && firstMessage.trim().isNotEmpty) {
                return firstMessage;
              }
            }
          }
        }
      }

      if (responseData is Map) {
        final message = responseData['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
    }

    return 'حدث خطأ في إرسال الطلب';
  }

  // ─── Step tracking ───────────────────────────────────────────────
  final currentStep = 0.obs; // 0-based (0=Step1 … 3=Step4)
  final applicationId = ''.obs;
  final isLoading = false.obs;
  final step3CardsUnlocked = true.obs;
  final hasAttemptedStep1Submission = false.obs;
  final isGovernoratesLoading = false.obs;
  final isDistrictsLoading = false.obs;
  final isSubdistrictsLoading = false.obs;
  final isTownsLoading = false.obs;
  final isOldGovernoratesLoading = false.obs;
  final isOldDistrictsLoading = false.obs;
  final isOldSubdistrictsLoading = false.obs;
  final isOldTownsLoading = false.obs;
  final errorMessage = ''.obs;
  final step1ErrorField = ''.obs;

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
  final partnerTextControllers = <TextEditingController>[];
  final partnersKeys = <Key>[].obs;

  final companyNameError = ''.obs;
  final companyLicenseNumberError = ''.obs;
  final companyLicenseDateError = ''.obs;
  final phonenumberRequied = FocusNode();
  final phonenumberNotRequied = FocusNode();
  final emailRequied = FocusNode();

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
  final step1ScrollController = ScrollController();
  final phoneFieldKey = GlobalKey();
  final emailFieldKey = GlobalKey();
  final secondaryPhoneFieldKey = GlobalKey();
  final termsFieldKey = GlobalKey();
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

  // Scroll controller for step 2 form
  final ScrollController step2ScrollController = ScrollController();

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

  // Settlement relocation uses a second, independent location for the old site.
  final settlementRelocation = false.obs;
  final oldSelectedGovernorate = Rxn<GovernorateModel>();
  final oldSelectedDistrict = Rxn<GovernorateModel>();
  final oldSelectedSubdistrict = Rxn<GovernorateModel>();
  final oldSelectedTown = Rxn<GovernorateModel>();
  final oldGovernorates = <GovernorateModel>[].obs;
  final oldDistricts = <GovernorateModel>[].obs;
  final oldSubdistricts = <GovernorateModel>[].obs;
  final oldTowns = <GovernorateModel>[].obs;
  final oldLatitudeController = TextEditingController();
  final oldLongitudeController = TextEditingController();

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
  final valuationSataementUpdataStecte = false.obs;
  final valueMohammedAhmed = 'mohammed ahmed'.obs;
  // Success
  final submittedApplicationNumber = ''.obs;
  final isCorrectionMode = false.obs;
  final editApplicationId = ''.obs;
  final correctionTargets = <String>[].obs;
  ApplicationModel? _originalApplication;
  ApplicationModel? get originalApplication => _originalApplication;

  // Map local field keys to server correction target ids.
  // Add more mappings here as new fields are added.
  final Map<String, String> _fieldToCorrectionTarget = {
    'email': 'contactInfo',
    'phone': 'contactInfo',
    'phone2': 'contactInfo',
    'agreedToTerms': 'termsContact',
    'requestType': 'licenseDetails',
    'previousLicenseNumber': 'settlementDetails',
    'license_number': 'licenseDetails',
    'settledAgreed': 'settlementDetails',
    'firstName': 'licenseDetails',
    'fatherName': 'licenseDetails',
    'motherName': 'licenseDetails',
    'nickname': 'licenseDetails',
    'lastName': 'licenseDetails',
    'nationalId': 'licenseDetails',
    'birthPlace': 'licenseDetails',
    'birthDate': 'licenseDetails',
    'companyName': 'licenseDetails',
    'partners': 'licenseDetails',
    'companyLicenseNumber': 'licenseDetails',
    'companyLicenseDate': 'licenseDetails',
    'governorate': 'locationClassification',
    'district': 'locationClassification',
    'subdistrict': 'locationClassification',
    'town': 'locationClassification',
    'latitude': 'locationClassification',
    'longitude': 'locationClassification',
    'planningLocation': 'locationClassification',
    'roadType': 'locationClassification',
    'stationCategory': 'locationClassification',
    'id_card': 'identityDocument',
    'property_map': 'surveyPlan',
    'land_title': 'propertyRecord',
    'valid_license': 'validLicenseDocument',
    'lease_contract': 'leaseContract',
    'commercial_register': 'commercialRegister',
    'investment_contract': 'investmentContract',
  };

  final Set<String> _step1Fields = {
    'email',
    'phone',
    'phone2',
    'agreedToTerms',
  };

  final Set<String> _step2Fields = {
    'requestType',
    'previousLicenseNumber',
    'firstName',
    'fatherName',
    'motherName',
    'nickname',
    'lastName',
    'nationalId',
    'birthPlace',
    'birthDate',
    'companyName',
    'partners',
    'companyLicenseNumber',
    'companyLicenseDate',
  };

  final Set<String> _step3LocationFields = {
    'governorate',
    'district',
    'subdistrict',
    'town',
    'latitude',
    'longitude',
    'planningLocation',
    'roadType',
    'stationCategory',
  };

  /// Returns true if the given local field key should be editable.
  /// When not in correction mode all fields are editable.
  bool isFieldEditable(String fieldKey) {
    if (!isCorrectionMode.value) return true;
    if (correctionTargets.contains('termsContact') &&
        _step1Fields.contains(fieldKey)) {
      return true;
    }
    if (correctionTargets.contains('licenseDetails') &&
        _step2Fields.contains(fieldKey)) {
      return true;
    }
    if (correctionTargets.contains('locationClassification') &&
        _step3LocationFields.contains(fieldKey)) {
      return true;
    }
    final target = _fieldToCorrectionTarget[fieldKey];
    if (target == null) return true;
    return correctionTargets.contains(target);
  }

  bool isAttachmentEditable(String attachmentKey) {
    if (!isCorrectionMode.value) return true;
    final target = _fieldToCorrectionTarget[attachmentKey];
    if (target == null) return true;
    return correctionTargets.contains(target);
  }

  bool canEditOldSettlementLocation() {
    if (!isCorrectionMode.value) return true;
    return correctionTargets.contains('settlementDetails') ||
        correctionTargets.contains('locationClassification');
  }

  @override
  void onInit() {
    super.onInit();
    _loadGovernorates();
    // Ensure when switching to company, at least one partner field exists
    ever<String>(investorType, (val) {
      if (val == 'company' && partners.isEmpty) {
        partners.add('');
        partnerTextControllers.add(TextEditingController(text: ''));
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
    for (final ctrl in partnerTextControllers) {
      ctrl.dispose();
    }
    firstNameFocus.dispose();
    fatherNameFocus.dispose();
    motherNameFocus.dispose();
    nicknameFocus.dispose();
    nationalIdFocus.dispose();
    birthPlaceFocus.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    step1ScrollController.dispose();
    step2ScrollController.dispose();
    super.onClose();
  }

  Future<dio.Response> _post(
    String path, {
    dynamic data,
    dio.Options? options,
  }) async {
    return CoreApiService.post(path, data: data, options: options);
  }

  Future<dio.Response> _patch(
    String path, {
    dynamic data,
    dio.Options? options,
  }) async {
    return CoreApiService.patch(path, data: data, options: options);
  }

  Future<dio.Response> _patch_att(
    String path, {
    dynamic data,
    dio.Options? options,
  }) async {
    return CoreApiService.post(path, data: data, options: options);
  }

  Future<dio.Response> updateLicenseApplication(
    String applicationId, {
    required dynamic data,
    // dio.Options? options,
  }) async {
    // ةخشااثةmohammed ahed
    return _patch(
      '/v1/license-applications/$applicationId',
      data: data,
      // options: options,
    );
  }

  Future<dio.Response> updateLicenseApplication_att(
    String applicationId, {
    required dynamic data,
    // dio.Options? options,
  }) async {
    return _patch_att(
      '/v1/license-applications/$applicationId',
      data: data,
      // options: options,
    );
  }

  void resetForm() {
    currentStep.value = 0;
    applicationId.value = '';
    isCorrectionMode.value = false;
    editApplicationId.value = '';
    correctionTargets.clear();
    _originalApplication = null;
    emailController.clear();
    phoneController.clear();
    phone2Controller.clear();
    agreedToTerms.value = false;
    requestType.value = 'new';
    previousLicenseNumber.clear();
    settledAgreed.value = false;
    investorType.value = 'individual';
    firstNameController.clear();
    lastNameController.clear();
    fatherNameController.clear();
    motherNameController.clear();
    nicknameController.clear();
    nationalIdController.clear();
    birthPlaceController.clear();
    birthDate.value = null;
    companyNameController.clear();
    companyLicenseNumberController.clear();
    companyLicenseDate.value = null;
    partners.clear();
    for (final controller in partnerTextControllers) {
      controller.dispose();
    }
    partnerTextControllers.clear();
    partnersKeys.clear();
    selectedGovernorate.value = null;
    selectedDistrict.value = null;
    selectedSubdistrict.value = null;
    selectedTown.value = null;
    latitudeController.clear();
    longitudeController.clear();
    selectedLocation.value = null;
    locationStatus.value = 'not_set';
    planningLocation.value = 'inside';
    roadType.value = 'international';
    stationCategory.value = 'A';
    idCardFile = null;
    propertyMapFile = null;
    landTitleFile = null;
    validLicenseFile = null;
    leaseContractFile = null;
    commercialRegisterFile = null;
    investmentContractFile = null;
    valuationStatementFile = null;
    idCardUploaded.value = false;
    propertyMapUploaded.value = false;
    landTitleUploaded.value = false;
    validLicenseUploaded.value = false;
    leaseContractUploaded.value = false;
    commercialRegisterUploaded.value = false;
    investmentContractUploaded.value = false;
    valuationStatementUploaded.value = false;
    errorMessage.value = '';
    step1ErrorField.value = '';
    hasAttemptedStep1Submission.value = false;
    submittedApplicationNumber.value = '';
  }

  Future<void> applyLocationSelectionFromIds({
    String? governorateId,
    String? districtId,
    String? subDistrictId,
    String? townId,
  }) async {
    selectedGovernorate.value = null;
    selectedDistrict.value = null;
    selectedSubdistrict.value = null;
    selectedTown.value = null;

    if (governorates.isEmpty) {
      await _loadGovernorates();
    }

    if (governorateId?.isNotEmpty == true) {
      final match = governorates.firstWhere(
        (item) => item.id.toString() == governorateId,
        orElse: () => GovernorateModel(id: 0, name: ''),
      );
      if (match.id != 0) {
        selectedGovernorate.value = match;
        await onGovernorateChanged(match);
      }
    }

    if (districtId?.isNotEmpty == true) {
      final match = districts.firstWhere(
        (item) => item.id.toString() == districtId,
        orElse: () => GovernorateModel(id: 0, name: ''),
      );
      if (match.id != 0) {
        selectedDistrict.value = match;
        await onDistrictChanged(match);
      }
    }

    if (subDistrictId?.isNotEmpty == true) {
      final match = subdistricts.firstWhere(
        (item) => item.id.toString() == subDistrictId,
        orElse: () => GovernorateModel(id: 0, name: ''),
      );
      if (match.id != 0) {
        selectedSubdistrict.value = match;
        await onSubdistrictChanged(match);
      }
    }

    if (townId?.isNotEmpty == true) {
      final match = towns.firstWhere(
        (item) => item.id.toString() == townId,
        orElse: () => GovernorateModel(id: 0, name: ''),
      );
      if (match.id != 0) {
        selectedTown.value = match;
        if (latitudeController.text.isEmpty &&
            longitudeController.text.isEmpty &&
            match.latitude != null &&
            match.longitude != null) {
          setLocation(match.latitude!, match.longitude!);
        }
      }
    }
  }

  Future<void> prepareForCorrection(ApplicationModel application) async {
    resetForm();
    isCorrectionMode.value = true;
    editApplicationId.value = application.id;
    correctionTargets.assignAll(application.correctionTargets);
    emailController.text = application.email;
    phoneController.text = application.phone;
    phone2Controller.text = application.secondaryPhone ?? '';
    agreedToTerms.value = true; // Activate terms checkbox in edit mode
    final isSettlement = application.requestType.toLowerCase().contains(
      'settlement',
    );
    requestType.value = isSettlement ? 'settlement' : 'new';
    if (isSettlement) {
      settledAgreed.value = true; // Activate settlement checkbox in edit mode
      settlementAgreementError.value = '';
    }
    previousLicenseNumber.text = isSettlement
        ? (application.licensenumberOld.trim().isNotEmpty
              ? application.licensenumberOld.trim()
              : (application.applicationNumber.isNotEmpty
                    ? application.applicationNumber
                    : ''))
        : '';
    investorType.value =
        application.applicantType?.toLowerCase().contains('company') == true
        ? 'company'
        : 'individual';
    firstNameController.text = application.firstName ?? '';
    lastNameController.text = application.lastName ?? '';
    fatherNameController.text = application.fatherName ?? '';
    motherNameController.text = application.motherName ?? '';
    nicknameController.text = application.lastName ?? '';
    nationalIdController.text = application.nationalId;
    birthPlaceController.text = application.placeOfBirth ?? '';
    if (application.dateOfBirth != null &&
        application.dateOfBirth!.isNotEmpty) {
      final parsed = DateTime.tryParse(application.dateOfBirth!);
      if (parsed != null) {
        birthDate.value = parsed;
      }
    }
    companyNameController.text = application.companyName ?? '';
    companyLicenseNumberController.text =
        application.companyLicenseNumber ?? '';
    if (application.companyLicenseDate != null &&
        application.companyLicenseDate!.isNotEmpty) {
      final parsed = DateTime.tryParse(application.companyLicenseDate!);
      if (parsed != null) {
        companyLicenseDate.value = parsed;
      }
    }

    partners.clear();
    for (final controller in partnerTextControllers) {
      controller.dispose();
    }
    partnerTextControllers.clear();
    partnersKeys.clear();
    if (application.partners.isNotEmpty) {
      for (final partner in application.partners) {
        final trimmed = partner.trim();
        partners.add(trimmed);
        partnerTextControllers.add(TextEditingController(text: trimmed));
        partnersKeys.add(ValueKey(DateTime.now().microsecondsSinceEpoch));
      }
    } else if (investorType.value == 'company' && partners.isEmpty) {
      partners.add('');
      partnerTextControllers.add(TextEditingController(text: ''));
      partnersKeys.add(ValueKey(DateTime.now().microsecondsSinceEpoch));
    }

    final planningRaw = application.planningLocation.toLowerCase();
    if (planningRaw.contains('outside') || planningRaw.contains('خارج')) {
      planningLocation.value = 'outside';
    } else {
      planningLocation.value = 'inside';
    }

    // Normalize road type
    final roadRaw = application.roadType.toLowerCase();
    if (roadRaw.contains('local') || roadRaw.contains('محلي')) {
      roadType.value = 'local';
    } else if (roadRaw.contains('central') ||
        roadRaw.contains('مركز') ||
        roadRaw.contains('مركزية')) {
      roadType.value = 'central';
    } else {
      roadType.value = 'international';
    }

    // Normalize station category (A/B/C) from Arabic or latin representations
    final catRaw = application.stationCategory?.trim() ?? '';
    final catLower = catRaw.toLowerCase();
    if (catLower.contains('أ') || catLower.contains('a')) {
      stationCategory.value = 'A';
    } else if (catLower.contains('ب') || catLower.contains('b')) {
      stationCategory.value = 'B';
    } else if (catLower.contains('ج') || catLower.contains('c')) {
      stationCategory.value = 'C';
    } else if (catRaw.trim().isNotEmpty) {
      stationCategory.value = catRaw.trim().toUpperCase();
    } else {
      stationCategory.value = 'A';
    }
    latitudeController.text = application.latitude ?? '';
    longitudeController.text = application.longitude ?? '';
    if (application.latitude?.isNotEmpty == true &&
        application.longitude?.isNotEmpty == true) {
      final lat = double.tryParse(application.latitude!);
      final lng = double.tryParse(application.longitude!);
      if (lat != null && lng != null) {
        selectedLocation.value = LatLng(lat, lng);
        locationStatus.value = 'set';
      }
    }

    await applyLocationSelectionFromIds(
      governorateId: application.governorateId,
      districtId: application.districtId,
      subDistrictId: application.subDistrictId,
      townId: application.townId,
    );

    final settlementDetails = application.settlementDetails;
    if (requestType.value == 'settlement') {
      final isRelocation = settlementDetails?.isRelocation == true;
      settlementRelocation.value = isRelocation;

      if (isRelocation) {
        final oldLocation = settlementDetails?.oldLocation;
        if (oldLocation != null) {
          final oldGovernorateId = oldLocation.governorateId;
          if (oldGovernorateId?.isNotEmpty == true) {
            final match = oldGovernorates.firstWhereOrNull(
              (item) => item.id.toString() == oldGovernorateId,
            );
            if (match != null) {
              oldSelectedGovernorate.value = match;
              await onOldGovernorateChanged(match);
            }
          }
          if (oldLocation.districtId?.isNotEmpty == true) {
            final match = oldDistricts.firstWhereOrNull(
              (item) => item.id.toString() == oldLocation.districtId,
            );
            if (match != null) {
              oldSelectedDistrict.value = match;
              await onOldDistrictChanged(match);
            }
          }
          if (oldLocation.subDistrictId?.isNotEmpty == true) {
            final match = oldSubdistricts.firstWhereOrNull(
              (item) => item.id.toString() == oldLocation.subDistrictId,
            );
            if (match != null) {
              oldSelectedSubdistrict.value = match;
              await onOldSubdistrictChanged(match);
            }
          }
          if (oldLocation.townId?.isNotEmpty == true) {
            final match = oldTowns.firstWhereOrNull(
              (item) => item.id.toString() == oldLocation.townId,
            );
            if (match != null) {
              oldSelectedTown.value = match;
            }
          }
          if (oldLocation.latitude?.isNotEmpty == true) {
            oldLatitudeController.text = oldLocation.latitude!;
          }
          if (oldLocation.longitude?.isNotEmpty == true) {
            oldLongitudeController.text = oldLocation.longitude!;
          }
        }
      }
    }

    _originalApplication = application;
    if (application.needsCorrection) {
      errorMessage.value = 'تم تهيئة الطلب للتعديل وفقًا للملاحظات';
    }
  }

  bool _hasChangedString(String? originalValue, String currentValue) {
    return (originalValue ?? '').trim() != currentValue.trim();
  }

  bool _hasChangedBool(bool? originalValue, bool currentValue) {
    return (originalValue ?? false) != currentValue;
  }

  Map<String, dynamic> buildCorrectionFormDataFields() {
    final payload = buildCorrectionPayload();
    final flattened = <String, dynamic>{};

    void flatten(String prefix, dynamic value) {
      if (value is Map) {
        value.forEach((key, child) {
          final nextPrefix = prefix.isEmpty ? key.toString() : '$prefix[$key]';
          flatten(nextPrefix, child);
        });
      } else if (value is List) {
        for (var i = 0; i < value.length; i++) {
          flatten('$prefix[$i]', value[i]);
        }
      } else {
        flattened[prefix] = value;
      }
    }

    payload.forEach((key, value) {
      flatten(key, value);
    });

    return flattened;
  }

  Map<String, dynamic> buildCorrectionPayload() {
    final payload = <String, dynamic>{};

    if (!isCorrectionMode.value || editApplicationId.value.isEmpty) {
      return payload;
    }

    final original = _originalApplication;

    if (correctionTargets.contains('contactInfo') ||
        correctionTargets.contains('termsContact')) {
      final email = emailController.text.trim();
      if (original == null || _hasChangedString(original.email, email)) {
        payload['email'] = email;
      }

      final phone = phoneController.text.trim();
      if (original == null || _hasChangedString(original.phone, phone)) {
        payload['phone'] = phone;
      }

      final secondaryPhone = phone2Controller.text.trim();
      if (original == null ||
          _hasChangedString(original.secondaryPhone, secondaryPhone)) {
        payload['secondary_phone'] = secondaryPhone;
      }
    }

    if (correctionTargets.contains('termsContact')) {
      final termsAccepted = agreedToTerms.value ? 1 : 0;
      if (original == null ||
          _hasChangedBool(original.termsAccepted, agreedToTerms.value)) {
        payload['terms_accepted'] = termsAccepted;
      }
    }

    final shouldSendUserInfo =
        correctionTargets.contains('licenseDetails') ||
        correctionTargets.contains('applicantInfo') ||
        correctionTargets.contains('identityDocument');
    final shouldSendCompanyInfo =
        correctionTargets.contains('licenseDetails') ||
        correctionTargets.contains('companyInfo');

    if (shouldSendUserInfo || shouldSendCompanyInfo) {
      final firstName = firstNameController.text.trim();
      final fatherName = fatherNameController.text.trim();
      final lastName = nicknameController.text.trim().isNotEmpty
          ? nicknameController.text.trim()
          : nicknameController.text.trim();
      final motherName = motherNameController.text.trim();
      final nationalId = nationalIdController.text.trim();
      final placeOfBirth = birthPlaceController.text.trim();
      final dateOfBirth = birthDate.value != null
          ? '${birthDate.value!.year.toString().padLeft(4, '0')}-${birthDate.value!.month.toString().padLeft(2, '0')}-${birthDate.value!.day.toString().padLeft(2, '0')}'
          : '';

      if (shouldSendUserInfo) {
        final userInfo = <String, dynamic>{
          'first_name': firstName,
          'father_name': fatherName,
          'last_name': lastName,
          'mother_name': motherName,
          'national_id': nationalId,
          'place_of_birth': placeOfBirth,
          'date_of_birth': dateOfBirth,
        };
        payload['user_info'] = userInfo;
      }

      if (shouldSendCompanyInfo && investorType.value == 'company') {
        final companyName = companyNameController.text.trim();
        final companyLicenseNumber = companyLicenseNumberController.text.trim();
        final companyLicenseDateValue = companyLicenseDate.value != null
            ? '${companyLicenseDate.value!.year.toString().padLeft(4, '0')}-${companyLicenseDate.value!.month.toString().padLeft(2, '0')}-${companyLicenseDate.value!.day.toString().padLeft(2, '0')}'
            : '';
        final partnerNames = partners
            .map((name) => name.trim())
            .where((name) => name.isNotEmpty)
            .toList();

        final applicant = <String, dynamic>{
          'company_name': companyName,
          'company_license_number': companyLicenseNumber,
          'company_license_date': companyLicenseDateValue,
        };

        if (partnerNames.isNotEmpty ||
            _originalApplication?.partners.isNotEmpty == true) {
          applicant['partners'] = partnerNames;
        }

        payload['applicant'] = applicant;
      }

      if (correctionTargets.contains('licenseDetails')) {
        payload['applicant_type'] = investorType.value == 'individual'
            ? 'INDIVIDUAL'
            : 'COMPANY';
      }
    }

    if (correctionTargets.contains('locationClassification')) {
      final location = <String, dynamic>{};
      final originalGovernorateId = original?.governorateId;
      final originalDistrictId = original?.districtId;
      final originalSubDistrictId = original?.subDistrictId;
      final originalTownId = original?.townId;
      final originalLatitude = original?.latitude ?? '';
      final originalLongitude = original?.longitude ?? '';

      final governorateId = selectedGovernorate.value?.id.toString();
      final districtId = selectedDistrict.value?.id.toString();
      final subDistrictId = selectedSubdistrict.value?.id.toString();
      final townId = selectedTown.value?.id.toString();
      final latitude = latitudeController.text.trim();
      final longitude = longitudeController.text.trim();

      location['governorate_id'] = governorateId ?? originalGovernorateId ?? '';
      location['district_id'] = districtId ?? originalDistrictId ?? '';
      location['sub_district_id'] =
          subDistrictId ?? originalSubDistrictId ?? '';
      location['town_id'] = townId ?? originalTownId ?? '';
      location['latitude'] = latitude.isNotEmpty ? latitude : originalLatitude;
      location['longitude'] = longitude.isNotEmpty
          ? longitude
          : originalLongitude;

      if (requestType.value == 'settlement' && settlementRelocation.value) {
        payload['settlement'] = {
          'is_relocation': 1,
          'license_number': previousLicenseNumber.text.trim(),
          'old_location': buildOldLocationPayload(),
          'new_location': location,
        };
      } else {
        payload['location'] = location;
      }
    }

    if (correctionTargets.contains('locationClassification')) {
      final category = <String, dynamic>{};
      final zoning = planningLocation.value == 'inside' ? 'INSIDE' : 'OUTSIDE';
      if (original == null ||
          original.planningLocation.toLowerCase() != planningLocation.value) {
        category['zoning'] = zoning;
      }
      if (planningLocation.value != 'inside') {
        final roadTypeValue = roadType.value.toUpperCase();
        if (original == null ||
            original.roadType.toLowerCase() != roadType.value) {
          category['road_type'] = roadTypeValue;
        }
      }
      if (original == null ||
          original.stationCategory != stationCategory.value) {
        category['license_category'] = stationCategory.value;
      }
      if (category.isNotEmpty) {
        payload['category'] = category;
      }
    }

    if (correctionTargets.contains('licenseDetails')) {
      final operationType = requestType.value.toUpperCase();
      if (original == null ||
          original.requestType.toUpperCase() != operationType) {
        payload['operation_type'] = operationType;
      }

      if (requestType.value == 'settlement') {
        final settlement = payload['settlement'] is Map
            ? Map<String, dynamic>.from(payload['settlement'] as Map)
            : <String, dynamic>{};
        settlement['is_relocation'] = settlementRelocation.value ? 1 : 0;
        settlement['license_number'] = previousLicenseNumber.text.trim();
        payload['settlement'] = settlement;
      }
    }
    //
    //
    //

    if (correctionTargets.contains('settlementDetails')) {
      final settlement = payload['settlement'] is Map
          ? Map<String, dynamic>.from(payload['settlement'] as Map)
          : <String, dynamic>{};
      settlement['is_relocation'] = settlementRelocation.value ? 1 : 0;
      settlement['license_number'] = previousLicenseNumber.text.trim();
      payload['settlement'] = settlement;
    }

    return payload;
  }

  // ─── Submit Step 1 ────────────────────────────────────────────────
  void goToNextStep() => super.goToNextStep();

  void goToPreviousStep() => super.goToPreviousStep();

  // ─── Validation ───────────────────────────────────────────────────
  void scrollToStep1Field(GlobalKey key) => super.scrollToStep1Field(key);

  void scrollToStep1Error() => super.scrollToStep1Error();

  bool validateStep1() => super.validateStep1();

  bool validateStep2() => super.validateStep2();

  void clearStep2FieldErrors() => super.clearStep2FieldErrors();

  void scrollToField(GlobalKey key) => super.scrollToField(key);

  void scrollToFirstError() => super.scrollToFirstError();

  void validateStep2Field(String fieldName, String value) =>
      super.validateStep2Field(fieldName, value);

  void requestFocus(FocusNode nextFocus) => super.requestFocus(nextFocus);

  bool validateStep3() => super.validateStep3();

  List<AttachmentRequirement> getRequiredAttachments() {
    final isSettlement = requestType.value == 'settlement';
    final isCompany = investorType.value == 'company';

    final landTitleTitle =
        requestType.value == 'new' && investorType.value == 'individual'
        ? 'بيان قيد فردي (حديث)'
        : 'بيان قيد عقاري (حديث)';

    final attachments = <AttachmentRequirement>[
      AttachmentRequirement(
        key: 'id_card',
        title: isCompany
            ? 'صورة عن الهوية (وجه أمامي وخلفي معاً) / صورة شعار الشركة'
            : 'صورة عن الهوية (وجه أمامي وخلفي معاً)',
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
          isRequired: false,
        ),
      );
    }

    if (isCompany) {
      attachments.add(
        const AttachmentRequirement(
          key: 'commercial_register',
          title: 'السجل التجاري',
          docType: 'COMMERCIAL_REGISTER',
          isRequired: false,
        ),
      );
    } else if (isSettlement) {
      attachments.add(
        const AttachmentRequirement(
          key: 'investment_contract',
          title: 'عقد استثمار',
          docType: 'INVESTMENT_CONTRACT',
          isRequired: true,
        ),
      );
    }

    return attachments;
  }

  List<AttachmentRequirement> getAttachmentsForSubmission() {
    final attachments = getRequiredAttachments();
    if (!isCorrectionMode.value || editApplicationId.value.isEmpty) {
      return attachments;
    }

    return attachments.where((attachment) {
      final target = _fieldToCorrectionTarget[attachment.key];
      return target != null && correctionTargets.contains(target);
    }).toList();
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

  int? getAttachmentFileSize(String key) {
    final file = getAttachmentFile(key);
    if (file != null && file.existsSync()) {
      return file.lengthSync();
    }
    return null;
  }

  bool validateStep4() {
    errorMessage.value = '';
    final allAttachments = getAttachmentsForSubmission();
    if (allAttachments.isEmpty) {
      return true;
    }

    // Filter only required attachments
    final requiredAttachments = allAttachments
        .where((attachment) => attachment.isRequired)
        .toList();

    if (requiredAttachments.isEmpty) {
      return true;
    }

    final hasAllUploads = requiredAttachments.every(
      (attachment) => isAttachmentUploaded(attachment.key),
    );

    if (!hasAllUploads) {
      errorMessage.value = 'يرجى رفع جميع المرفقات المطلوبة';
      return false;
    }
    return true;
  }

  String getApplicantFullName() {
    if (investorType.value == 'individual') {
      final parts = <String>[
        firstNameController.text.trim(),
        fatherNameController.text.trim(),
        lastNameController.text.trim().isNotEmpty
            ? lastNameController.text.trim()
            : nicknameController.text.trim(),
      ].where((part) => part.isNotEmpty).toList();
      return parts.join(' ');
    }
    return companyNameController.text.trim();
  }

  Map<String, dynamic> buildUserInfoPayload() {
    // All applicants must provide personal information
    final userInfoMap = {
      'user_info[first_name]': firstNameController.text.trim(),
      'user_info[father_name]': fatherNameController.text.trim(),
      'user_info[last_name]': lastNameController.text.trim().isNotEmpty
          ? lastNameController.text.trim()
          : nicknameController.text.trim(),
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
    if (!validateStep2()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToFirstError();
      });
      return;
    }
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

    final requiredAttachments = getAttachmentsForSubmission();
    final onlyRequiredAttachments = requiredAttachments
        .where((attachment) => attachment.isRequired)
        .toList();
    final missingFiles = onlyRequiredAttachments.where(
      (attachment) => getAttachmentFile(attachment.key) == null,
    );
    if (missingFiles.isNotEmpty) {
      errorMessage.value = 'يرجى رفع جميع المرفقات المطلوبة قبل الإرسال';
      currentStep.value = 3;
      return;
    }

    try {
      isLoading.value = true;
      if (isCorrectionMode.value && editApplicationId.value.isNotEmpty) {
        final correctionPayload = buildCorrectionPayload();
        final rawPayload = <String, dynamic>{}..addAll(correctionPayload);

        if (requiredAttachments.isEmpty) {
          final response = await updateLicenseApplication(
            editApplicationId.value,
            data: rawPayload,
            // options: dio.Options(contentType: 'application/json'),
          );

          final payload = response.data is Map
              ? (response.data['data'] ?? response.data)
              : response.data;
          final serverNumber = payload is Map
              ? payload['license_request_number']?.toString()
              : null;

          submittedApplicationNumber.value = serverNumber?.isNotEmpty == true
              ? serverNumber!
              : 'SY-LR-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-000';
          Get.offAllNamed(AppRoutes.applicationSuccess);
          return;
        }

        final formData = dio.FormData.fromMap(buildCorrectionFormDataFields());
        final uploadAttachments = requiredAttachments
            .where((attachment) => getAttachmentFile(attachment.key) != null)
            .toList();
        for (var i = 0; i < uploadAttachments.length; i++) {
          final attachment = uploadAttachments[i];
          final file = getAttachmentFile(attachment.key);
          if (file == null) {
            continue;
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
        formData.fields.add(const MapEntry('_method', 'PATCH'));

        final response = await updateLicenseApplication_att(
          editApplicationId.value,
          data: formData,
          // options: dio.Options(contentType: 'multipart/form-data'),
        );
        final payload = response.data is Map
            ? (response.data['data'] ?? response.data)
            : response.data;
        final serverNumber = payload is Map
            ? payload['license_request_number']?.toString()
            : null;

        submittedApplicationNumber.value = serverNumber?.isNotEmpty == true
            ? serverNumber!
            : 'SY-LR-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-000';
        Get.offAllNamed(AppRoutes.applicationSuccess);
        return;
      }

      final applicantFullName = getApplicantFullName();
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
          'settlement[is_relocation]': settlementRelocation.value ? 1 : 0,
          'settlement[license_number]': previousLicenseNumber.text.trim(),
        },
        if (requestType.value != 'settlement' ||
            !settlementRelocation.value) ...{
          'location[governorate_id]': selectedGovernorate.value?.id,
          'location[district_id]': selectedDistrict.value?.id,
          'location[sub_district_id]': selectedSubdistrict.value?.id,
          'location[town_id]': selectedTown.value?.id,
          'location[latitude]': latitudeController.text.trim(),
          'location[longitude]': longitudeController.text.trim(),
        } else ...{
          'settlement[old_location][governorate_id]':
              oldSelectedGovernorate.value?.id,
          'settlement[old_location][district_id]':
              oldSelectedDistrict.value?.id,
          'settlement[old_location][sub_district_id]':
              oldSelectedSubdistrict.value?.id,
          'settlement[old_location][town_id]': oldSelectedTown.value?.id,
          'settlement[old_location][latitude]': oldLatitudeController.text
              .trim(),
          'settlement[old_location][longitude]': oldLongitudeController.text
              .trim(),
          'settlement[new_location][governorate_id]':
              selectedGovernorate.value?.id,
          'settlement[new_location][district_id]': selectedDistrict.value?.id,
          'settlement[new_location][sub_district_id]':
              selectedSubdistrict.value?.id,
          'settlement[new_location][town_id]': selectedTown.value?.id,
          'settlement[new_location][latitude]': latitudeController.text.trim(),
          'settlement[new_location][longitude]': longitudeController.text
              .trim(),
        },
        ...buildUserInfoPayload(),
      });
      final uploadAttachments = requiredAttachments
          .where((attachment) => getAttachmentFile(attachment.key) != null)
          .toList();
      for (var i = 0; i < uploadAttachments.length; i++) {
        final attachment = uploadAttachments[i];
        final file = getAttachmentFile(attachment.key);
        if (file == null) {
          continue;
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

      final response = await _post(
        '/v1/license-applications',
        data: formData,
        options: dio.Options(contentType: 'multipart/form-data'),
      );

      final payload = response.data is Map
          ? (response.data['data'] ?? response.data)
          : response.data;
      final serverNumber = payload is Map
          ? payload['license_request_number']?.toString()
          : null;

      submittedApplicationNumber.value = serverNumber?.isNotEmpty == true
          ? serverNumber!
          : 'SY-LR-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-000';
      Get.offAllNamed(AppRoutes.applicationSuccess);
    } catch (error) {
      errorMessage.value = extractSubmissionErrorMessage(error);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Lookups ─────────────────────────────────────────────────────
  Map<String, dynamic> buildOldLocationPayload() {
    return {
      'governorate_id': oldSelectedGovernorate.value?.id,
      'district_id': oldSelectedDistrict.value?.id,
      'sub_district_id': oldSelectedSubdistrict.value?.id,
      'town_id': oldSelectedTown.value?.id,
      'latitude': oldLatitudeController.text.trim(),
      'longitude': oldLongitudeController.text.trim(),
    };
  }

  Future<void> _loadGovernorates() async {
    isGovernoratesLoading.value = true;
    try {
      final res = await CoreApiService.get('/v1/governorates');
      final data = res.data is Map ? res.data['data'] : res.data;
      final values = (data as List)
          .map((e) => GovernorateModel.fromJson(e))
          .toList();
      governorates.value = values;
      oldGovernorates.value = values;
    } catch (_) {
      governorates.value = [];
    } finally {
      isGovernoratesLoading.value = false;
    }
  }

  //
  // Future<void> onUpdata(GovernorateModel? gov) {
  //   selectedDistrict.value = gov;
  //   selectedSubdistrict.value = null;
  //   selectedDistrict.value = null;
  // }

  Future<void> onGovernorateChanged(GovernorateModel? gov) async {
    // print("test api gov gov ${gov!.name.toString()}");
    // print("test On GovernorateChanged ${gov.toExternalReference} ");
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

  Future<void> refreshGovernorates() async {
    isGovernoratesLoading.value = true;
    try {
      await _loadGovernorates();
      if (selectedGovernorate.value != null) {
        await onGovernorateChanged(selectedGovernorate.value);
      }
    } finally {
      isGovernoratesLoading.value = false;
    }
  }

  Future<void> refreshDistricts() async {
    isDistrictsLoading.value = true;
    try {
      await onGovernorateChanged(selectedGovernorate.value);
    } finally {
      isDistrictsLoading.value = false;
    }
  }

  Future<void> refreshSubdistricts() async {
    isSubdistrictsLoading.value = true;
    try {
      await onDistrictChanged(selectedDistrict.value);
    } finally {
      isSubdistrictsLoading.value = false;
    }
  }

  Future<void> refreshTowns() async {
    isTownsLoading.value = true;
    try {
      await onSubdistrictChanged(selectedSubdistrict.value);
    } finally {
      isTownsLoading.value = false;
    }
  }

  Future<void> refreshOldDistricts() async {
    isOldDistrictsLoading.value = true;
    try {
      await onOldGovernorateChanged(oldSelectedGovernorate.value);
    } finally {
      isOldDistrictsLoading.value = false;
    }
  }

  Future<void> refreshOldSubdistricts() async {
    isOldSubdistrictsLoading.value = true;
    try {
      await onOldDistrictChanged(oldSelectedDistrict.value);
    } finally {
      isOldSubdistrictsLoading.value = false;
    }
  }

  Future<void> refreshOldTowns() async {
    isOldTownsLoading.value = true;
    try {
      await onOldSubdistrictChanged(oldSelectedSubdistrict.value);
    } finally {
      isOldTownsLoading.value = false;
    }
  }

  Future<void> onOldGovernorateChanged(GovernorateModel? gov) async {
    oldSelectedGovernorate.value = gov;
    oldSelectedDistrict.value = null;
    oldSelectedSubdistrict.value = null;
    oldSelectedTown.value = null;
    oldDistricts.clear();
    oldSubdistricts.clear();
    oldTowns.clear();
    if (gov == null) return;
    isOldDistrictsLoading.value = true;
    try {
      final res = await CoreApiService.get(
        '/v1/governorates/${gov.id}/districts',
      );
      final data = res.data is Map ? res.data['data'] : res.data;
      oldDistricts.value = (data as List)
          .map((e) => GovernorateModel.fromJson(e))
          .toList();
    } catch (_) {
    } finally {
      isOldDistrictsLoading.value = false;
    }
  }

  Future<void> onOldDistrictChanged(GovernorateModel? dist) async {
    oldSelectedDistrict.value = dist;
    oldSelectedSubdistrict.value = null;
    oldSelectedTown.value = null;
    oldSubdistricts.clear();
    oldTowns.clear();
    if (dist == null) return;
    isOldSubdistrictsLoading.value = true;
    try {
      final res = await CoreApiService.get(
        '/v1/districts/${dist.id}/sub-districts',
      );
      final data = res.data is Map ? res.data['data'] : res.data;
      oldSubdistricts.value = (data as List)
          .map((e) => GovernorateModel.fromJson(e))
          .toList();
    } catch (_) {
    } finally {
      isOldSubdistrictsLoading.value = false;
    }
  }

  Future<void> onOldSubdistrictChanged(GovernorateModel? sub) async {
    oldSelectedSubdistrict.value = sub;
    oldSelectedTown.value = null;
    oldTowns.clear();
    if (sub == null) return;
    isOldTownsLoading.value = true;
    try {
      final res = await CoreApiService.get('/v1/sub-districts/${sub.id}/towns');
      final data = res.data is Map ? res.data['data'] : res.data;
      oldTowns.value = (data as List)
          .map((e) => GovernorateModel.fromJson(e))
          .toList();
    } catch (_) {
    } finally {
      isOldTownsLoading.value = false;
    }
  }

  static const int maxPartners = 30;

  void addPartner() {
    if (partners.length >= maxPartners) {
      errorMessage.value = 'لا يمكن إضافة أكثر من $maxPartners شركاء';
      return;
    }
    partners.add('');
    partnerTextControllers.add(TextEditingController(text: ''));
    partnersKeys.add(ValueKey(DateTime.now().microsecondsSinceEpoch));
  }

  void removePartner(int index) {
    if (index < 0 || index >= partners.length) return;
    partners.removeAt(index);
    if (index >= 0 && index < partnersKeys.length) partnersKeys.removeAt(index);
    if (index >= 0 && index < partnerTextControllers.length) {
      partnerTextControllers[index].dispose();
      partnerTextControllers.removeAt(index);
    }
  }

  void updatePartner(int index, String name) => partners[index] = name;
}
