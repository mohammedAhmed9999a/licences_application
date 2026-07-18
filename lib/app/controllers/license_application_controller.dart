import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart' as dio;
import 'package:licences_application/core/services/core_api_service.dart';
import '../routes/app_routes.dart';
import '../models/governorate_model.dart';
import '../models/application_model.dart';
import '../../core/validators/form_validator.dart';

class AttachmentRequirement {
  final String key;
  final String title;
  final String docType;
  final bool isRequired;

  const AttachmentRequirement({
    required this.key,
    required this.title,
    required this.docType,
    this.isRequired = true,
  });
}

class LicenseApplicationController extends GetxController {
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
  final isGovernoratesLoading = false.obs;
  final isDistrictsLoading = false.obs;
  final isSubdistrictsLoading = false.obs;
  final isTownsLoading = false.obs;
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
  // ─── Success ──────────────────────────────────────────────────────
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
    agreedToTerms.value = application.termsAccepted;
    requestType.value =
        application.requestType.toLowerCase().contains('settlement')
        ? 'settlement'
        : 'new';
    previousLicenseNumber.text =
        application.requestType.toLowerCase().contains('settlement')
        ? (application.applicationNumber.isNotEmpty
              ? application.applicationNumber
              : '')
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
    // Normalize planning location (handle Arabic and English responses)
    final planningRaw = application.planningLocation?.toLowerCase() ?? '';
    if (planningRaw.contains('outside') || planningRaw.contains('خارج')) {
      planningLocation.value = 'outside';
    } else {
      planningLocation.value = 'inside';
    }

    // Normalize road type
    final roadRaw = application.roadType?.toLowerCase() ?? '';
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

        final applicant = <String, dynamic>{
          'company_name': companyName,
          'company_license_number': companyLicenseNumber,
          'company_license_date': companyLicenseDateValue,
        };

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
      if (selectedGovernorate.value?.id != null &&
          (original == null ||
              original.governorateId !=
                  selectedGovernorate.value?.id.toString())) {
        location['governorate_id'] = selectedGovernorate.value?.id;
      }
      if (selectedDistrict.value?.id != null &&
          (original == null ||
              original.districtId != selectedDistrict.value?.id.toString())) {
        location['district_id'] = selectedDistrict.value?.id;
      }
      if (selectedSubdistrict.value?.id != null &&
          (original == null ||
              original.subDistrictId !=
                  selectedSubdistrict.value?.id.toString())) {
        location['sub_district_id'] = selectedSubdistrict.value?.id;
      }
      if (selectedTown.value?.id != null &&
          (original == null ||
              original.townId != selectedTown.value?.id.toString())) {
        location['town_id'] = selectedTown.value?.id;
      }
      final latitude = latitudeController.text.trim();
      if (latitude.isNotEmpty &&
          (original == null ||
              _hasChangedString(original.latitude, latitude))) {
        location['latitude'] = latitude;
      }
      final longitude = longitudeController.text.trim();
      if (longitude.isNotEmpty &&
          (original == null ||
              _hasChangedString(original.longitude, longitude))) {
        location['longitude'] = longitude;
      }
      if (location.isNotEmpty) {
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
        payload['settlement'] = {
          'is_relocation': 0,
          'license_number': previousLicenseNumber.text.trim(),
        };
      }
    }

    if (correctionTargets.contains('settlementDetails')) {
      payload['settlement'] = {
        'is_relocation': 0,
        'license_number': previousLicenseNumber.text.trim(),
      };
    }

    return payload;
  }

  // ─── Submit Step 1 ────────────────────────────────────────────────
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
    if (step1ErrorField.value == 'phone' &&
        phoneFieldKey.currentContext != null) {
      scrollToStep1Field(phoneFieldKey);
      return;
    }
    if (step1ErrorField.value == 'email' &&
        emailFieldKey.currentContext != null) {
      scrollToStep1Field(emailFieldKey);
      return;
    }
    if (step1ErrorField.value == 'phone2' &&
        secondaryPhoneFieldKey.currentContext != null) {
      scrollToStep1Field(secondaryPhoneFieldKey);
      return;
    }
    if (step1ErrorField.value == 'terms' &&
        termsFieldKey.currentContext != null) {
      scrollToStep1Field(termsFieldKey);
      return;
    }

    if (phoneController.text.trim().isEmpty &&
        phoneFieldKey.currentContext != null) {
      scrollToStep1Field(phoneFieldKey);
      return;
    }
    if (emailController.text.trim().isEmpty &&
        emailFieldKey.currentContext != null) {
      scrollToStep1Field(emailFieldKey);
      return;
    }
    if (!agreedToTerms.value && termsFieldKey.currentContext != null) {
      scrollToStep1Field(termsFieldKey);
      return;
    }
  }

  bool validateStep1() {
    errorMessage.value = '';
    step1ErrorField.value = '';

    final emailError = FormValidator.validateEmailField(emailController.text);
    if (emailError != null) {
      errorMessage.value = emailError;
      step1ErrorField.value = 'email';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToStep1Error();
      });
      return false;
    }

    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      errorMessage.value = 'يرجى إدخال رقم التواصل';
      step1ErrorField.value = 'phone';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToStep1Error();
      });
      return false;
    }
    if (!RegExp(r'^09\d{8}$').hasMatch(phone)) {
      errorMessage.value = 'رقم التواصل يجب أن يبدأ بـ 09 وأن يكون 10 أرقام';
      step1ErrorField.value = 'phone';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToStep1Error();
      });
      return false;
    }

    final secondaryPhone = phone2Controller.text.trim();
    if (secondaryPhone.isNotEmpty &&
        !RegExp(r'^09\d{8}$').hasMatch(secondaryPhone)) {
      errorMessage.value =
          'رقم التواصل الثانوي يجب أن يبدأ بـ 09 وأن يكون 10 أرقام';
      step1ErrorField.value = 'phone2';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToStep1Error();
      });
      return false;
    }

    if (!agreedToTerms.value) {
      errorMessage.value = 'يجب الموافقة على الشروط والأحكام للمتابعة';
      step1ErrorField.value = 'terms';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToStep1Error();
      });
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
      } else if (!RegExp(
        r'^[A-Za-z0-9]+$',
      ).hasMatch(previousLicenseNumber.text.trim())) {
        settlementPreviousLicenseError.value =
            'رقم الترخيص يجب أن يحتوي على حروف إنكليزية وأرقام فقط وبدون مسافات أو رموز';
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

    if (investorType.value == 'individual') {
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
      if (nationalId.length < 8 || nationalId.length > 12) {
        nationalIdError.value = 'الرقم الوطني يجب أن يكون بين 8 و12 رقماً';
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
    } else if (investorType.value == 'company') {
      var hasPersonalErrors = false;
      var hasCompanyErrors = false;

      final firstName = firstNameController.text.trim();
      if (firstName.isEmpty) {
        firstNameError.value = 'يرجى إدخال الاسم الأول';
        hasPersonalErrors = true;
      } else if (firstName.length <= 2) {
        firstNameError.value = 'الاسم يجب أن يكون أكثر من حرفين';
        hasPersonalErrors = true;
      } else if (!FormValidator.isArabicName(firstName)) {
        firstNameError.value = 'الاسم يجب أن يكون باللغة العربية حصراً';
        hasPersonalErrors = true;
      } else {
        firstNameError.value = '';
      }

      final fatherName = fatherNameController.text.trim();
      if (fatherName.isEmpty) {
        fatherNameError.value = 'يرجى إدخال اسم الأب';
        hasPersonalErrors = true;
      } else if (fatherName.length <= 2) {
        fatherNameError.value = 'اسم الأب يجب أن يكون أكثر من حرفين';
        hasPersonalErrors = true;
      } else if (!FormValidator.isArabicName(fatherName)) {
        fatherNameError.value = 'اسم الأب يجب أن يكون باللغة العربية حصراً';
        hasPersonalErrors = true;
      } else {
        fatherNameError.value = '';
      }

      final motherName = motherNameController.text.trim();
      if (motherName.isEmpty) {
        motherNameError.value = 'يرجى إدخال اسم الأم';
        hasPersonalErrors = true;
      } else if (motherName.length <= 2) {
        motherNameError.value = 'اسم الأم يجب أن يكون أكثر من حرفين';
        hasPersonalErrors = true;
      } else if (!FormValidator.isArabicName(motherName)) {
        motherNameError.value = 'اسم الأم يجب أن يكون باللغة العربية حصراً';
        hasPersonalErrors = true;
      } else {
        motherNameError.value = '';
      }

      final nickname = nicknameController.text.trim();
      if (nickname.isEmpty) {
        nicknameError.value = 'يرجى إدخال الكنية';
        hasPersonalErrors = true;
      } else if (nickname.length <= 2) {
        nicknameError.value = 'الكنية يجب أن تكون أكثر من حرفين';
        hasPersonalErrors = true;
      } else if (!FormValidator.isArabicName(nickname)) {
        nicknameError.value = 'الكنية يجب أن تكون باللغة العربية حصراً';
        hasPersonalErrors = true;
      } else {
        nicknameError.value = '';
      }

      final nationalId = nationalIdController.text.trim();
      if (nationalId.isEmpty) {
        nationalIdError.value = 'يرجى إدخال الرقم الوطني';
        hasPersonalErrors = true;
      } else if (!RegExp(r'^\d+$').hasMatch(nationalId)) {
        nationalIdError.value = 'الرقم الوطني يجب أن يحتوي على أرقام فقط';
        hasPersonalErrors = true;
      } else if (nationalId.length < 8 || nationalId.length > 12) {
        nationalIdError.value = 'الرقم الوطني يجب أن يكون بين 8 و12 رقماً';
        hasPersonalErrors = true;
      } else {
        nationalIdError.value = '';
      }

      final birthPlace = birthPlaceController.text.trim();
      if (birthPlace.isEmpty) {
        birthPlaceError.value = 'يرجى إدخال مكان الولادة';
        hasPersonalErrors = true;
      } else if (birthPlace.length <= 2) {
        birthPlaceError.value = 'مكان الولادة يجب أن يكون أكثر من حرفين';
        hasPersonalErrors = true;
      } else if (!FormValidator.isArabicName(birthPlace)) {
        birthPlaceError.value = 'مكان الولادة يجب أن يكون باللغة العربية حصراً';
        hasPersonalErrors = true;
      } else {
        birthPlaceError.value = '';
      }

      final selectedBirthDate = birthDate.value;
      if (selectedBirthDate == null) {
        birthDateError.value = 'يرجى اختيار تاريخ الولادة';
        hasPersonalErrors = true;
      } else {
        final now = DateTime.now();
        var age = now.year - selectedBirthDate.year;
        if (now.month < selectedBirthDate.month ||
            (now.month == selectedBirthDate.month &&
                now.day < selectedBirthDate.day)) {
          age--;
        }
        birthDateError.value = age < 18
            ? 'يجب أن لا يقل عمر مقدم الطلب عن 18 سنة'
            : '';
        if (age < 18) {
          hasPersonalErrors = true;
        }
      }

      final companyName = companyNameController.text.trim();
      if (companyName.isEmpty) {
        companyNameError.value = 'يرجى إدخال اسم الشركة';
        hasCompanyErrors = true;
      } else if (companyName.length <= 2) {
        companyNameError.value = 'اسم الشركة يجب أن يكون أكثر من حرفين';
        hasCompanyErrors = true;
      } else if (!FormValidator.isArabicName(companyName)) {
        companyNameError.value = 'اسم الشركة يجب أن يكون باللغة العربية حصراً';
        hasCompanyErrors = true;
      } else {
        companyNameError.value = '';
      }

      final licenseNum = companyLicenseNumberController.text.trim();
      if (licenseNum.isEmpty) {
        companyLicenseNumberError.value = 'يرجى إدخال رقم ترخيص الشركة';
        hasCompanyErrors = true;
      } else if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(licenseNum)) {
        companyLicenseNumberError.value =
            'غير مسموح بإدخال مسافات أو رموز أو أحرف عربية. الرجاء استخدام أحرف إنكليزية وأرقام فقط.';
        hasCompanyErrors = true;
      } else {
        companyLicenseNumberError.value = '';
      }

      if (companyLicenseDate.value == null) {
        companyLicenseDateError.value = 'يرجى اختيار تاريخ ترخيص الشركة';
        hasCompanyErrors = true;
      } else {
        companyLicenseDateError.value = '';
      }

      if (hasPersonalErrors || hasCompanyErrors) {
        errorMessage.value = 'يرجى إدخال البيانات الشخصية والشركة المطلوبة';
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

    // Try the standard ensureVisible first. If it fails or has no effect,
    // fall back to computing an offset and animating the step2 scroll controller.
    try {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
      return;
    } catch (_) {}

    // Fallback: compute widget position relative to the viewport and animate.
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
        step2ScrollController.offset + (widgetOffset - scrollTop) - 24.0;
    final clamped = targetOffset < 0
        ? 0.0
        : (step2ScrollController.hasClients
              ? targetOffset.clamp(
                  0.0,
                  step2ScrollController.position.maxScrollExtent,
                )
              : targetOffset);
    if (step2ScrollController.hasClients) {
      step2ScrollController.animateTo(
        clamped,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
        if (firstNameError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
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
        if (fatherNameError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
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
        if (motherNameError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
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
        if (nicknameError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
        }
        break;
      case 'nationalId':
        if (value.trim().isEmpty) {
          nationalIdError.value = 'يرجى إدخال الرقم الوطني';
        } else if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
          nationalIdError.value = 'الرقم الوطني يجب أن يحتوي على أرقام فقط';
        } else if (value.trim().length < 8 || value.trim().length > 12) {
          nationalIdError.value = 'الرقم الوطني يجب أن يكون بين 8 و12 رقماً';
        } else {
          nationalIdError.value = '';
        }
        if (nationalIdError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
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
        if (birthPlaceError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
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
        if (birthDateError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
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
        if (companyNameError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
        }
        break;
      case 'companyLicenseNumber':
        if (value.trim().isEmpty) {
          companyLicenseNumberError.value = 'يرجى إدخال رقم ترخيص الشركة';
        } else if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(value.trim())) {
          companyLicenseNumberError.value =
              'غير مسموح بإدخال مسافات أو رموز أو أحرف عربية. الرجاء استخدام أحرف إنكليزية وأرقام فقط.';
        } else {
          companyLicenseNumberError.value = '';
        }
        if (companyLicenseNumberError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
        }
        break;
      case 'previousLicenseNumber':
        if (value.trim().isEmpty) {
          settlementPreviousLicenseError.value =
              'يرجى إدخال رقم الترخيص السابق';
        }
        // else if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(value.trim())) {
        //   settlementPreviousLicenseError.value =
        //       'غير مسموح بإدخال مسافات أو رموز أو أحرف عربية. الرجاء استخدام أحرف إنكليزية وأرقام فقط.';
        // }
        else {
          settlementPreviousLicenseError.value = '';
        }
        if (settlementPreviousLicenseError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
        }
        break;
      case 'companyLicenseDate':
        if (companyLicenseDate.value == null) {
          companyLicenseDateError.value = 'يرجى اختيار تاريخ ترخيص الشركة';
        } else {
          final now = DateTime.now();
          final selectedDate = DateTime(
            companyLicenseDate.value!.year,
            companyLicenseDate.value!.month,
            companyLicenseDate.value!.day,
          );
          final today = DateTime(now.year, now.month, now.day);
          if (!selectedDate.isBefore(today)) {
            companyLicenseDateError.value =
                'يجب أن يكون التاريخ من أمس أو قبله';
          } else {
            companyLicenseDateError.value = '';
          }
        }
        if (companyLicenseDateError.value.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstError();
          });
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
    if (selectedDistrict.value == null) {
      errorMessage.value = 'يرجى اختيار المنطقة';
      return false;
    }
    if (selectedSubdistrict.value == null) {
      errorMessage.value = 'يرجى اختيار الناحية';
      return false;
    }
    if (selectedTown.value == null) {
      errorMessage.value = 'يرجى اختيار البلدة';
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

        final formData = dio.FormData.fromMap(rawPayload);
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
    await _loadGovernorates();
    if (selectedGovernorate.value != null) {
      await onGovernorateChanged(selectedGovernorate.value);
    }
  }

  Future<void> refreshDistricts() async {
    await onGovernorateChanged(selectedGovernorate.value);
  }

  Future<void> refreshSubdistricts() async {
    await onDistrictChanged(selectedDistrict.value);
  }

  Future<void> refreshTowns() async {
    await onSubdistrictChanged(selectedSubdistrict.value);
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
