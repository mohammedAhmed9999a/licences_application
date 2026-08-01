import 'package:get/get.dart';
import '../license_application_controller.dart';

mixin LicenseCorrectionMixin on GetxController {
  LicenseApplicationController get controller =>
      Get.find<LicenseApplicationController>();

  bool _hasChangedString(String? originalValue, String currentValue) {
    return (originalValue ?? '').trim() != currentValue.trim();
  }

  bool _hasChangedBool(bool? originalValue, bool currentValue) {
    return (originalValue ?? false) != currentValue;
  }

  Map<String, dynamic> buildCorrectionPayload() {
    final payload = <String, dynamic>{};
    final original = controller.originalApplication;

    if (!controller.isCorrectionMode.value ||
        controller.editApplicationId.value.isEmpty) {
      return payload;
    }

    if (controller.correctionTargets.contains('contactInfo') ||
        controller.correctionTargets.contains('termsContact')) {
      final email = controller.emailController.text.trim();
      if (original == null || _hasChangedString(original.email, email)) {
        payload['email'] = email;
      }

      final phone = controller.phoneController.text.trim();
      if (original == null || _hasChangedString(original.phone, phone)) {
        payload['phone'] = phone;
      }

      final secondaryPhone = controller.phone2Controller.text.trim();
      if (original == null ||
          _hasChangedString(original.secondaryPhone, secondaryPhone)) {
        payload['secondary_phone'] = secondaryPhone;
      }
    }

    if (controller.correctionTargets.contains('termsContact')) {
      final termsAccepted = controller.agreedToTerms.value ? 1 : 0;
      if (original == null ||
          _hasChangedBool(
            original.termsAccepted,
            controller.agreedToTerms.value,
          )) {
        payload['terms_accepted'] = termsAccepted;
      }
    }

    final shouldSendUserInfo =
        controller.correctionTargets.contains('licenseDetails') ||
        controller.correctionTargets.contains('applicantInfo') ||
        controller.correctionTargets.contains('identityDocument');
    final shouldSendCompanyInfo =
        controller.correctionTargets.contains('licenseDetails') ||
        controller.correctionTargets.contains('companyInfo');

    if (shouldSendUserInfo || shouldSendCompanyInfo) {
      final firstName = controller.firstNameController.text.trim();
      final fatherName = controller.fatherNameController.text.trim();
      final lastName = controller.nicknameController.text.trim().isNotEmpty
          ? controller.nicknameController.text.trim()
          : controller.nicknameController.text.trim();
      final motherName = controller.motherNameController.text.trim();
      final nationalId = controller.nationalIdController.text.trim();
      final placeOfBirth = controller.birthPlaceController.text.trim();
      final dateOfBirth = controller.birthDate.value != null
          ? '${controller.birthDate.value!.year.toString().padLeft(4, '0')}-${controller.birthDate.value!.month.toString().padLeft(2, '0')}-${controller.birthDate.value!.day.toString().padLeft(2, '0')}'
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

      if (shouldSendCompanyInfo && controller.investorType.value == 'company') {
        final companyName = controller.companyNameController.text.trim();
        final companyLicenseNumber = controller
            .companyLicenseNumberController
            .text
            .trim();
        final companyLicenseDateValue =
            controller.companyLicenseDate.value != null
            ? '${controller.companyLicenseDate.value!.year.toString().padLeft(4, '0')}-${controller.companyLicenseDate.value!.month.toString().padLeft(2, '0')}-${controller.companyLicenseDate.value!.day.toString().padLeft(2, '0')}'
            : '';
        final partnerNames = controller.partners
            .map((name) => name.trim())
            .where((name) => name.isNotEmpty)
            .toList();

        final applicant = <String, dynamic>{
          'company_name': companyName,
          'company_license_number': companyLicenseNumber,
          'company_license_date': companyLicenseDateValue,
        };

        if (partnerNames.isNotEmpty ||
            controller.originalApplication?.partners.isNotEmpty == true) {
          applicant['partners'] = partnerNames;
        }

        payload['applicant'] = applicant;
      }

      if (controller.correctionTargets.contains('licenseDetails')) {
        payload['applicant_type'] =
            controller.investorType.value == 'individual'
            ? 'INDIVIDUAL'
            : 'COMPANY';
      }
    }

    if (controller.correctionTargets.contains('locationClassification')) {
      final location = <String, dynamic>{};
      final originalGovernorateId = original?.governorateId;
      final originalDistrictId = original?.districtId;
      final originalSubDistrictId = original?.subDistrictId;
      final originalTownId = original?.townId;
      final originalLatitude = original?.latitude ?? '';
      final originalLongitude = original?.longitude ?? '';

      final governorateId = controller.selectedGovernorate.value?.id.toString();
      final districtId = controller.selectedDistrict.value?.id.toString();
      final subDistrictId = controller.selectedSubdistrict.value?.id.toString();
      final townId = controller.selectedTown.value?.id.toString();
      final latitude = controller.latitudeController.text.trim();
      final longitude = controller.longitudeController.text.trim();

      location['governorate_id'] = governorateId ?? originalGovernorateId ?? '';
      location['district_id'] = districtId ?? originalDistrictId ?? '';
      location['sub_district_id'] =
          subDistrictId ?? originalSubDistrictId ?? '';
      location['town_id'] = townId ?? originalTownId ?? '';
      location['latitude'] = latitude.isNotEmpty ? latitude : originalLatitude;
      location['longitude'] = longitude.isNotEmpty
          ? longitude
          : originalLongitude;

      if (controller.requestType.value == 'settlement' &&
          controller.settlementRelocation.value) {
        payload['settlement'] = {
          'is_relocation': 1,
          'license_number': controller.previousLicenseNumber.text.trim(),
          'old_location': controller.buildOldLocationPayload(),
          'new_location': location,
        };
      } else {
        payload['location'] = location;
      }
    }

    if (controller.correctionTargets.contains('locationClassification')) {
      final category = <String, dynamic>{};
      final zoning = controller.planningLocation.value == 'inside'
          ? 'INSIDE'
          : 'OUTSIDE';
      if (original == null ||
          original.planningLocation.toLowerCase() !=
              controller.planningLocation.value) {
        category['zoning'] = zoning;
      }
      if (controller.planningLocation.value != 'inside') {
        final roadTypeValue = controller.roadType.value.toUpperCase();
        if (original == null ||
            original.roadType.toLowerCase() != controller.roadType.value) {
          category['road_type'] = roadTypeValue;
        }
      }
      if (original == null ||
          original.stationCategory != controller.stationCategory.value) {
        category['license_category'] = controller.stationCategory.value;
      }
      if (category.isNotEmpty) {
        payload['category'] = category;
      }
    }

    if (controller.correctionTargets.contains('licenseDetails')) {
      final operationType = controller.requestType.value.toUpperCase();
      if (original == null ||
          original.requestType.toUpperCase() != operationType) {
        payload['operation_type'] = operationType;
      }

      if (controller.requestType.value == 'settlement') {
        final settlement = payload['settlement'] is Map
            ? Map<String, dynamic>.from(payload['settlement'] as Map)
            : <String, dynamic>{};
        settlement['is_relocation'] = controller.settlementRelocation.value
            ? 1
            : 0;
        settlement['license_number'] = controller.previousLicenseNumber.text
            .trim();
        payload['settlement'] = settlement;
      }
    }

    if (controller.correctionTargets.contains('settlementDetails')) {
      final settlement = payload['settlement'] is Map
          ? Map<String, dynamic>.from(payload['settlement'] as Map)
          : <String, dynamic>{};
      settlement['is_relocation'] = controller.settlementRelocation.value
          ? 1
          : 0;
      settlement['license_number'] = controller.previousLicenseNumber.text
          .trim();
      payload['settlement'] = settlement;
    }

    return payload;
  }
}
