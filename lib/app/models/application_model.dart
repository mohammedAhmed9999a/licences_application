class AttachmentItem {
  final String name;
  final String? filePath;

  AttachmentItem({required this.name, this.filePath});

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
    final baseEndsWithStorage = baseWithoutSlash.toLowerCase().endsWith('/storage');
    if (trimmed.startsWith('storage/')) {
      final rel = trimmed.replaceFirst(RegExp(r'^storage/+'), '');
      return baseEndsWithStorage ? '$baseWithoutSlash/$rel' : '$baseWithoutSlash/$trimmed';
    }
    return baseEndsWithStorage ? '$baseWithoutSlash/$trimmed' : '$baseWithoutSlash/storage/$trimmed';
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
    final source = (normalizedFilePath.isNotEmpty ? normalizedFilePath : name).toLowerCase();
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
    if ((s.startsWith('"') && s.endsWith('"')) || (s.startsWith("'") && s.endsWith("'"))) {
      s = s.substring(1, s.length - 1).trim();
    }
    // Remove markdown-like wrapper [url](...) or [text](url)
    final md = RegExp(r'^\[(.*?)\]\((.*?)\)$');
    final m = md.firstMatch(s);
    if (m != null) {
      final insideParens = m.group(2)?.trim();
      final insideBrackets = m.group(1)?.trim();
      if (insideParens != null && insideParens.isNotEmpty) return insideParens;
      if (insideBrackets != null && insideBrackets.isNotEmpty) return insideBrackets;
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
  final String status;
  final String statusLabel;
  final String requestType;
  final String investorType;
  final String createdAt;
  final String? governorate;
  final String? stationCategory;
  final String? stationName;
  final String? applicantName;
  final String email;
  final String phone;
  final String nationalId;
  final String district;
  final String roadType;
  final String planningLocation;
  final String coordinates;
  final String statusNote;
  final List<AttachmentItem> attachments;
  final List<String> stepSummary;

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
    this.roadType = '',
    this.planningLocation = '',
    this.coordinates = '',
    this.statusNote = '',
    this.attachments = const [],
    this.stepSummary = const [],
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final governorateMap = location['governorate'] as Map<String, dynamic>?;
    final districtMap = location['district'] as Map<String, dynamic>?;
    final townMap = location['town'] as Map<String, dynamic>?;
    final allowedCategory = json['allowed_category'] as Map<String, dynamic>?;
    final licenseCategory =
        allowedCategory?['license_category'] as Map<String, dynamic>?;
    final roadTypeMap = allowedCategory?['road_type'] as Map<String, dynamic>?;
    final zoningMap = allowedCategory?['zoning'] as Map<String, dynamic>?;
    final applicantable = json['applicantable'] as Map<String, dynamic>?;
    final user = json['user'] as Map<String, dynamic>?;

    var applicantName = applicantable?['full_name']?.toString() ?? '';
    if (applicantName.isEmpty) {
      applicantName = applicantable?['company_name']?.toString() ?? '';
    }
    if (applicantName.isEmpty) {
      applicantName = user?['name']?.toString() ?? '';
    }

    final attachmentItems =
        (json['attachments'] as List?)
            ?.map((item) {
              if (item is Map<String, dynamic>) {
                final path =
                    item['file_path']?.toString() ??
                    item['file']?.toString() ??
                    item['url']?.toString();
                String name = item['file_name']?.toString() ?? '';
                if (name.isEmpty) {
                  final docType = item['doc_type'];
                  if (docType is Map<String, dynamic>) {
                    name = docType['name']?.toString() ?? '';
                  } else if (docType != null) {
                    name = docType.toString();
                  }
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

    final latitude = location['latitude']?.toString() ?? '';
    final longitude = location['longitude']?.toString() ?? '';
    final coordinates = [
      latitude,
      longitude,
    ].where((part) => part.isNotEmpty).join(', ');

    final status = json['status']?.toString() ?? 'PENDING';
    final adminMessage = json['admin_message']?.toString() ?? '';
    final statusNote = adminMessage.isNotEmpty
        ? adminMessage
        : correctionTargets.isNotEmpty
        ? 'مطلوب معلومات إضافية'
        : 'لا توجد ملاحظات إضافية';

    return ApplicationModel(
      id: json['id']?.toString() ?? '',
      applicationNumber: json['license_request_number']?.toString() ?? '',
      status: status,
      statusLabel: _statusLabel(status),
      requestType: json['operation_type']?['name']?.toString() ?? '',
      investorType: json['applicantable_type']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      governorate: governorateMap?['name']?.toString(),
      stationCategory:
          licenseCategory?['description']?.toString() ??
          licenseCategory?['code']?.toString(),
      stationName: townMap?['name']?.toString(),
      applicantName: applicantName.isNotEmpty ? applicantName : null,
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      nationalId: user?['national_id']?.toString() ?? '',
      district: districtMap?['name']?.toString() ?? '',
      roadType:
          roadTypeMap?['name']?.toString() ??
          zoningMap?['scope']?.toString() ??
          '',
      planningLocation: zoningMap?['scope']?.toString() ?? '',
      coordinates: coordinates,
      statusNote: statusNote,
      attachments: attachmentItems,
      stepSummary:
          (json['step_summary'] as List?)?.map((e) => e.toString()).toList() ??
          [],
    );
  }

  static List<ApplicationModel> mockApplications() {
    return [
      ApplicationModel(
        id: 'LIC-1001',
        applicationNumber: 'طلب رقم 1001',
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

  String get displayStationName => stationName ?? 'غير محددة';
  String get displayStatusNote =>
      statusNote.isNotEmpty ? statusNote : 'لا توجد ملاحظات إضافية';

  static String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'قيد المراجعة';
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'draft':
        return 'مسودة';
      case 'under_review':
        return 'قيد الدراسة';
      default:
        return 'غير معروف';
    }
  }
}
