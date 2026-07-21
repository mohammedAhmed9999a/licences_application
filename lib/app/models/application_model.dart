class AttachmentItem {
  final String name;
  final String? filePath;
  final String? docTypeName;

  AttachmentItem({required this.name, this.filePath, this.docTypeName});

  String? resolveUrl({required String baseUrl}) {
    if (filePath == null || filePath!.trim().isEmpty) return null;

    final trimmed = normalizedFilePath;
    // If it's already an absolute http(s) url, return as-is
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    // absolute path starting with '/'
    if (trimmed.startsWith('/')) {
      final uri = Uri.tryParse(baseUrl);
      if (uri == null) return trimmed;
      return Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.port,
        path: '${uri.path.replaceAll(RegExp(r'/+$'), '')}$trimmed',
      ).toString();
    }

    // relative file path (e.g. "license-applications/31/...")
    // Use conventional storage path if the server serves files under /storage
    final baseWithoutSlash = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final baseEndsWithStorage = baseWithoutSlash.toLowerCase().endsWith(
      '/storage',
    );
    if (trimmed.startsWith('storage/')) {
      final rel = trimmed.replaceFirst(RegExp(r'^storage/+'), '');
      return baseEndsWithStorage
          ? '$baseWithoutSlash/$rel'
          : '$baseWithoutSlash/$trimmed';
    }
    return baseEndsWithStorage
        ? '$baseWithoutSlash/$trimmed'
        : '$baseWithoutSlash/storage/$trimmed';
  }

  String get displayName {
    final value = (docTypeName ?? name).toString().trim();
    return value.isNotEmpty
        ? value
        : name.isNotEmpty
        ? name
        : 'مرفق';
  }

  String get fileName {
    if (name.isNotEmpty) return name;
    if (filePath != null) {
      final uri = Uri.tryParse(normalizedFilePath);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last;
      }
      final parts = normalizedFilePath.split(RegExp(r'[\\/]'));
      if (parts.isNotEmpty) return parts.last;
    }
    return 'مرفق';
  }

  String get extension {
    final source = (normalizedFilePath.isNotEmpty ? normalizedFilePath : name)
        .toLowerCase();
    final dotIndex = source.lastIndexOf('.');
    if (dotIndex >= 0 && dotIndex < source.length - 1) {
      return source.substring(dotIndex);
    }
    return '';
  }

  bool get isPdf => extension == '.pdf';
  bool get isImage =>
      ['.png', '.jpg', '.jpeg', '.webp', '.gif', '.bmp'].contains(extension);
  String get normalizedFilePath {
    if (filePath == null) return '';
    var s = filePath!.trim();
    // Trim surrounding quotes
    if ((s.startsWith('"') && s.endsWith('"')) ||
        (s.startsWith("'") && s.endsWith("'"))) {
      s = s.substring(1, s.length - 1).trim();
    }
    // Remove markdown-like wrapper [url](...) or [text](url)
    final md = RegExp(r'^\[(.*?)\]\((.*?)\)$');
    final m = md.firstMatch(s);
    if (m != null) {
      final insideParens = m.group(2)?.trim();
      final insideBrackets = m.group(1)?.trim();
      if (insideParens != null && insideParens.isNotEmpty) return insideParens;
      if (insideBrackets != null && insideBrackets.isNotEmpty)
        return insideBrackets;
    }
    // Remove angle brackets
    if (s.startsWith('<') && s.endsWith('>')) {
      s = s.substring(1, s.length - 1).trim();
    }
    return s;
  }

  bool get hasFilePath => normalizedFilePath.isNotEmpty;

  bool get isRemoteUrl {
    if (!hasFilePath) return false;
    final uri = Uri.tryParse(normalizedFilePath);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  bool get isLocalPath {
    if (!hasFilePath) return false;
    final s = normalizedFilePath;
    if (s.startsWith('file://')) return true;
    if (RegExp(r'^[A-Za-z]:[\\/]').hasMatch(s)) return true; // Windows drive
    if (s.startsWith('/')) return true; // absolute POSIX path
    return false;
  }
}

class ApplicationModel {
  final String id;
  final String applicationNumber;
  final String licensenumberOld;
  final String status;
  final String statusLabel;
  final String requestType;
  final String investorType;
  final String createdAt;
  final String? governorate;

  static String _normalizeRequestType(String value) {
    final lowerValue = value.trim().toLowerCase();
    if (lowerValue.contains('settlement') || lowerValue.contains('تسوية')) {
      return 'settlement';
    }
    if (lowerValue.contains('new') || lowerValue.contains('جديد')) {
      return 'new';
    }
    if (lowerValue.contains('renewal') || lowerValue.contains('تجديد')) {
      return 'renewal';
    }
    return value.trim();
  }

  static String getInvestorTypeLabel(String? value) {
    if (value == null || value.trim().isEmpty) return 'نوع المستثمر';
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'applicant_individual':
      case 'individual':
        return 'مستثمر فردي';
      case 'applicant_company':
      case 'company':
        return 'شركة';
      case 'public':
        return 'جهة عامة';
      default:
        return value;
    }
  }
  final String? stationCategory;
  final String? stationName;
  final String? applicantName;
  final String email;
  final String phone;
  final String nationalId;
  final String district;
  final String? subDistrict;
  final String roadType;
  final String planningLocation;
  final String coordinates;
  final String statusNote;
  final List<AttachmentItem> attachments;
  final List<AttachmentItem> latest_attachments;
  final List<String> stepSummary;
  final List<String> correctionTargets;
  final bool needsCorrection;
  final String? firstName;
  final String? fatherName;
  final String? lastName;
  final String? motherName;
  final String? nickname;
  final String? placeOfBirth;
  final String? dateOfBirth;
  final String? companyName;
  final String? companyLicenseNumber;
  final String? companyLicenseDate;
  final List<String> partners;
  final String? secondaryPhone;
  final String? governorateId;
  final String? districtId;
  final String? subDistrictId;
  final String? townId;
  final String? latitude;
  final String? longitude;
  final String? applicantType;
  final bool termsAccepted;

  ApplicationModel({
    required this.id,
    required this.applicationNumber,
    required this.status,
    required this.statusLabel,
    required this.requestType,
    required this.investorType,
    required this.createdAt,
    this.governorate,
    this.stationCategory,
    this.stationName,
    this.applicantName,
    this.email = '',
    this.phone = '',
    this.nationalId = '',
    this.district = '',
    this.subDistrict,
    this.roadType = '',
    this.planningLocation = '',
    this.coordinates = '',
    this.statusNote = '',
    this.attachments = const [],
    this.latest_attachments = const [],
    this.stepSummary = const [],
    this.correctionTargets = const [],
    this.needsCorrection = false,
    this.firstName,
    this.fatherName,
    this.lastName,
    this.motherName,
    this.nickname,
    this.placeOfBirth,
    this.dateOfBirth,
    this.companyName,
    this.companyLicenseNumber,
    this.companyLicenseDate,
    this.partners = const [],
    this.secondaryPhone,
    this.governorateId,
    this.districtId,
    this.subDistrictId,
    this.townId,
    this.latitude,
    this.longitude,
    this.applicantType,
    this.termsAccepted = false, required this.licensenumberOld,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    final location = _asStringKeyedMap(json['location']) ?? <String, dynamic>{};
    final governorateMap = _asStringKeyedMap(location['governorate']);
    final districtMap = _asStringKeyedMap(location['district']);
    final subDistrictMap = _asStringKeyedMap(location['sub_district']);
    final townMap = _asStringKeyedMap(location['town']);
    final allowedCategory = _asStringKeyedMap(json['allowed_category']);
    final licenseCategory = _asStringKeyedMap(
      allowedCategory?['license_category'],
    );
    final roadTypeMap = _asStringKeyedMap(allowedCategory?['road_type']);
    final zoningMap = _asStringKeyedMap(allowedCategory?['zoning']);
    final applicantable =
        _asStringKeyedMap(json['applicantable']) ?? <String, dynamic>{};
    final user = _asStringKeyedMap(json['user']) ?? <String, dynamic>{};

    final applicantTypeRaw = json['applicantable_type']?.toString() ?? '';
    final applicantTypeNormalized = _normalizeApplicantType(applicantTypeRaw);

    final personalName = [
      user['first_name']?.toString() ?? '',
      user['father_name']?.toString() ?? '',
      user['last_name']?.toString() ?? '',
    ].where((value) => value.trim().isNotEmpty).join(' ');

    var applicantName = personalName;
    if (applicantName.isEmpty) {
      applicantName = applicantable['full_name']?.toString() ?? '';
    }
    if (applicantName.isEmpty) {
      applicantName = applicantable['company_name']?.toString() ?? '';
    }
    if (applicantName.isEmpty) {
      applicantName = user['name']?.toString() ?? '';
    }

    final attachmentItems =
        (json['attachments'] as List?)
            ?.map((item) {
              if (item is Map) {
                final itemMap = _asStringKeyedMap(item) ?? <String, dynamic>{};
                final path =
                    itemMap['file_path']?.toString() ??
                    itemMap['file']?.toString() ??
                    itemMap['url']?.toString();
                String name = itemMap['file_name']?.toString() ?? '';
                final docTypeName = _readAttachmentDocTypeName(itemMap);

                if (docTypeName != null && docTypeName.trim().isNotEmpty) {
                  name = docTypeName;
                } else if (name.isEmpty) {
                  name = docTypeName ?? '';
                }
                if (name.isEmpty && path != null) {
                  final uri = Uri.tryParse(path);
                  if (uri != null && uri.pathSegments.isNotEmpty) {
                    name = uri.pathSegments.last;
                  } else {
                    name = path;
                  }
                }
                return AttachmentItem(
                  name: name.isNotEmpty ? name : 'مرفق',
                  filePath: path,
                  docTypeName: docTypeName,
                );
              }
              final text = item?.toString() ?? '';
              return AttachmentItem(name: text, filePath: null);
            })
            .where((attachment) => attachment.name.trim().isNotEmpty)
            .toList() ??
        [];

    final correctionTargets =
        (json['correction_targets'] as List?)
            ?.map((item) => item?.toString() ?? '')
            .where((value) => value.isNotEmpty)
            .toList() ??
        [];

    final statusValue = json['status']?.toString() ?? 'PENDING';
    final normalizedStatus = statusValue.toLowerCase();
    final needsCorrection =
        normalizedStatus.contains('additionalinforequired') ||
        normalizedStatus.contains('correction') ||
        correctionTargets.isNotEmpty;

    final latitude = location['latitude']?.toString() ?? '';
    final longitude = location['longitude']?.toString() ?? '';
    final coordinates = [
      latitude,
      longitude,
    ].where((part) => part.isNotEmpty).join(', ');

    final firstName = user['first_name']?.toString() ?? '';
    final fatherName = user['father_name']?.toString() ?? '';
    final lastName = user['last_name']?.toString() ?? '';
    final motherName = user['mother_name']?.toString() ?? '';
    final nickName = user['nickname']?.toString() ?? '';
    final placeOfBirth = user['place_of_birth']?.toString() ?? '';
    final dateOfBirth = user['date_of_birth']?.toString() ?? '';
    final companyName = applicantable['company_name']?.toString() ?? '';
    final companyLicenseNumber =
        applicantable['company_license_number']?.toString() ?? '';
    final subDistrictName =
        (location['sub_district_name']?.toString() ?? '').trim().isNotEmpty
            ? location['sub_district_name']!.toString()
            : subDistrictMap?['name']?.toString() ?? '';
    final companyLicenseDate =
        applicantable['company_license_date']?.toString() ?? '';
    final partners =
        (applicantable['partners'] is List)
            ? (applicantable['partners'] as List)
                .map((partner) => partner?.toString() ?? '')
                .where((partner) => partner.trim().isNotEmpty)
                .toList()
            : <String>[];

    final latestAttachmentItems =
        (json['latest_attachments'] as List?)
            ?.map((item) {
              if (item is Map) {
                final itemMap = _asStringKeyedMap(item) ?? <String, dynamic>{};
                final path =
                    itemMap['file_path']?.toString() ??
                    itemMap['file']?.toString() ??
                    itemMap['url']?.toString();
                String name = itemMap['file_name']?.toString() ?? '';
                final docTypeName = _readAttachmentDocTypeName(itemMap);

                if (docTypeName != null && docTypeName.trim().isNotEmpty) {
                  name = docTypeName;
                } else if (name.isEmpty) {
                  name = docTypeName ?? '';
                }
                if (name.isEmpty && path != null) {
                  final uri = Uri.tryParse(path);
                  if (uri != null && uri.pathSegments.isNotEmpty) {
                    name = uri.pathSegments.last;
                  } else {
                    name = path;
                  }
                }
                return AttachmentItem(
                  name: name.isNotEmpty ? name : 'مرفق',
                  filePath: path,
                  docTypeName: docTypeName,
                );
              }
              final text = item?.toString() ?? '';
              return AttachmentItem(name: text, filePath: null);
            })
            .where((attachment) => attachment.name.trim().isNotEmpty)
            .toList() ??
        [];

    final adminMessage = json['admin_message']?.toString() ?? '';
    final statusNote = adminMessage.isNotEmpty
        ? adminMessage
        : correctionTargets.isNotEmpty
        ? 'مطلوب معلومات إضافية'
        : 'لا توجد ملاحظات إضافية';

    final rawRequestType = json['operation_type']?['name']?.toString() ?? '';

    return ApplicationModel(
      id: json['id']?.toString() ?? '',
      applicationNumber: json['license_request_number']?.toString() ?? '',
      licensenumberOld: json['license_number']?.toString()??'',
      status: statusValue,
      statusLabel: _statusLabel(statusValue),
      requestType: _normalizeRequestType(rawRequestType),
      investorType: applicantTypeNormalized,
      correctionTargets: correctionTargets,
      needsCorrection: needsCorrection,
      firstName: firstName.isNotEmpty ? firstName : null,
      fatherName: fatherName.isNotEmpty ? fatherName : null,
      lastName: lastName.isNotEmpty ? lastName : null,
      motherName: motherName.isNotEmpty ? motherName : null,
      nickname: nickName.isNotEmpty ? nickName : null,
      placeOfBirth: placeOfBirth.isNotEmpty ? placeOfBirth : null,
      dateOfBirth: dateOfBirth.isNotEmpty ? dateOfBirth : null,
      companyName: companyName.isNotEmpty ? companyName : null,
      companyLicenseNumber: companyLicenseNumber.isNotEmpty
          ? companyLicenseNumber
          : null,
      companyLicenseDate: companyLicenseDate.isNotEmpty
          ? companyLicenseDate
          : null,
      partners: partners,
      secondaryPhone: json['secondary_phone']?.toString(),
      governorateId:
          location['governorate_id']?.toString() ??
          governorateMap?['id']?.toString(),
      districtId:
          location['district_id']?.toString() ?? districtMap?['id']?.toString(),
      subDistrictId:
          location['sub_district_id']?.toString() ??
          (location['sub_district'] as Map<String, dynamic>?)?['id']
              ?.toString(),
      townId: location['town_id']?.toString() ?? townMap?['id']?.toString(),
      latitude: latitude,
      longitude: longitude,
      applicantType: applicantTypeNormalized,
      termsAccepted:
          json['terms_accepted'] == true || json['terms_accepted'] == 1,
      createdAt: json['created_at']?.toString() ?? '',
      governorate: governorateMap?['name']?.toString(),
      stationCategory:
          licenseCategory?['description']?.toString() ??
          licenseCategory?['code']?.toString(),
      stationName: townMap?['name']?.toString(),
      applicantName: applicantName.isNotEmpty ? applicantName : null,
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      nationalId: user['national_id']?.toString() ?? '',
      district: districtMap?['name']?.toString() ?? '',
      subDistrict: subDistrictName.isNotEmpty ? subDistrictName : null,
      roadType:
          roadTypeMap?['name']?.toString() ??
          zoningMap?['scope']?.toString() ??
          '',
      planningLocation: zoningMap?['scope']?.toString() ?? '',
      coordinates: coordinates,
      statusNote: statusNote,
      attachments: attachmentItems,
      latest_attachments: latestAttachmentItems.isNotEmpty
          ? latestAttachmentItems
          : attachmentItems,
      stepSummary:
          (json['step_summary'] as List?)?.map((e) => e.toString()).toList() ??
          [],
    );
  }

  static Map<String, dynamic>? _asStringKeyedMap(dynamic value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  static String? _readAttachmentDocTypeName(Map<String, dynamic> item) {
    final docType = item['doc_type'];
    final docTypeMap = _asStringKeyedMap(docType);
    final docTypeName = docTypeMap?['name']?.toString();

    final values = [
      item['doc_name']?.toString(),
      item['doc_type_name']?.toString(),
      item['document_type']?.toString(),
      docTypeName,
    ];

    return values.firstWhere(
      (value) => value != null && value.trim().isNotEmpty,
      orElse: () => null,
    );
  }

  static List<ApplicationModel> mockApplications() {
    return [
      ApplicationModel(
        id: 'LIC-1001',
        applicationNumber: 'طلب رقم 1001',
        licensenumberOld: 'test',
        status: 'pending',
        statusLabel: 'قيد المراجعة',
        requestType: 'new',
        investorType: 'individual',
        createdAt: '2026-06-20',
        governorate: 'دمشق',
        stationCategory: 'A',
        stationName: 'محطة أحمد للوقود',
        applicantName: 'أحمد محمد علي',
        email: 'ahmad@example.com',
        phone: '0999123456',
        nationalId: '1001234567',
        district: 'القنوات',
        roadType: 'دولي',
        planningLocation: 'داخل المنطقة',
        coordinates: '33.5138, 36.2765',
        statusNote: 'الطلب قيد المراجعة من قبل لجنة التراخيص',
        attachments: [
          AttachmentItem(name: 'صورة الهوية'),
          AttachmentItem(name: 'خريطة الملكية'),
          AttachmentItem(name: 'وثيقة الملكية'),
        ],
        stepSummary: [
          'تم استلام بيانات التواصل بنجاح',
          'تم تعبئة بيانات المالك والموقع',
          'تم اختيار الموقع والتصنيف',
          'تم رفع جميع المرفقات المطلوبة',
        ],
      ),
      ApplicationModel(
        id: 'LIC-1002',
        applicationNumber: 'طلب رقم 1002',
        licensenumberOld: 'test old ',
        status: 'approved',
        statusLabel: 'مقبول',
        requestType: 'settlement',
        investorType: 'company',
        createdAt: '2026-06-22',
        governorate: 'حلب',
        stationCategory: 'B',
        stationName: 'محطة سارة للطاقة',
        applicantName: 'سارة خليل',
        email: 'sara@example.com',
        phone: '0955123456',
        nationalId: '1009876543',
        district: 'الحديثة',
        roadType: 'محلي',
        planningLocation: 'خارج المنطقة',
        coordinates: '36.2021, 37.1343',
        statusNote: 'تم قبول الطلب ومراجعته من قبل الإدارة',
        attachments: [
          AttachmentItem(name: 'هوية المالك'),
          AttachmentItem(name: 'خريطة الموقع'),
          AttachmentItem(name: 'إقرار ملكية'),
        ],
        stepSummary: [
          'تمت مراجعة البيانات الأولية',
          'تمت مراجعة بيانات المالك',
          'تمت مراجعة الموقع والتصنيف',
          'تمت الموافقة على المرفقات',
        ],
      ),
    ];
  }

  String get displayApplicantName {
    final personalName = [
      firstName,
      fatherName,
      lastName,
    ].where((value) => (value ?? '').trim().isNotEmpty).join(' ');

    if (personalName.isNotEmpty) {
      return personalName;
    }

    final fallback = (applicantName ?? '').trim();
    return fallback.isNotEmpty ? fallback : '';
  }

  String get requestTypeLabel {
    final type = requestType.toLowerCase();
    switch (type) {
      case 'new':
      case 'جديد':
        return 'طلب جديد';
      case 'settlement':
      case 'تسوية':
        return 'تسوية';
      case 'renewal':
      case 'تجديد':
        return 'تجديد';
      default:
        return requestType.isNotEmpty ? requestType : 'نوع الطلب';
    }
  }

  String get investorTypeLabel {
    switch (investorType) {
      case 'applicant_individual':
      case 'individual':
        return 'مستثمر فردي';
      case 'applicant_company':
      case 'company':
        return 'شركة';
      case 'public':
        return 'جهة عامة';
      default:
        return investorType.isNotEmpty ? investorType : 'نوع المستثمر';
    }
  }

  static String _normalizeApplicantType(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.contains('company') || normalized.contains('شركة')) {
      return 'applicant_company';
    }
    if (normalized.contains('individual') || normalized.contains('فرد')) {
      return 'applicant_individual';
    }
    return normalized.isNotEmpty ? normalized : 'applicant_individual';
  }

  String get displayStationName => stationName ?? 'غير محددة';
  String get displayStatusNote =>
      statusNote.isNotEmpty ? statusNote : 'لا توجد ملاحظات إضافية';

  static String _statusLabel(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized.isEmpty) return 'غير معروف';

    if (normalized.contains('under_committee_review') ||
        normalized.contains('under committee') ||
        normalized.contains('committee review') ||
        (normalized.contains('committee') &&
            (normalized.contains('under') || normalized.contains('review')))) {
      return 'إحالة للجنة الفنية';
    }

    if (normalized.contains('pending') ||
        normalized.contains('in_review') ||
        normalized.contains('under_review') ||
        normalized.contains('review') ||
        normalized.contains('in progress') ||
        normalized.contains('processing')) {
      return 'قيد المراجعة';
    }

    if (normalized.contains('approved') || normalized.contains('accepted')) {
      return 'مقبول';
    }

    if (normalized.contains('rejected') || normalized.contains('declined')) {
      return 'مرفوض';
    }

    if (normalized.contains('draft')) {
      return 'مسودة';
    }

    if (normalized.contains('additional') ||
        normalized.contains('additional_info') ||
        normalized.contains('additionalinfo') ||
        normalized.contains('additional_info_required') ||
        normalized.contains('correction') ||
        normalized.contains('correction_targets')) {
      return 'مطلوب معلومات إضافية';
    }

    if (normalized.contains('completed') || normalized.contains('finished')) {
      return 'مكتمل';
    }

    if (normalized.contains('canceled') || normalized.contains('cancelled')) {
      return 'ملغى';
    }
    return status;
  }
}
