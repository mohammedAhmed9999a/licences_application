import 'application_model.dart';

class LicenseDetailModel {
  final ApplicationModel application;
  final String applicantName;
  final String email;
  final String phone;
  final String nationalId;
  final String governorate;
  final String district;
  final String stationName;
  final String stationCategory;
  final String roadType;
  final String planningLocation;
  final String coordinates;
  final String statusNote;
  final List<AttachmentItem> attachments;
  final List<String> stepSummary;

  LicenseDetailModel({
    required this.application,
    required this.applicantName,
    required this.email,
    required this.phone,
    required this.nationalId,
    required this.governorate,
    required this.district,
    required this.stationName,
    required this.stationCategory,
    required this.roadType,
    required this.planningLocation,
    required this.coordinates,
    required this.statusNote,
    required this.attachments,
    required this.stepSummary,
  });

  String get requestTypeLabel => application.requestTypeLabel;
  String get investorTypeLabel => application.investorTypeLabel;
  List<AttachmentItem> get latest_attachments =>
      application.latest_attachments.isNotEmpty
      ? application.latest_attachments
      : attachments;

  static List<LicenseDetailModel> mockLicenses() {
    final base = ApplicationModel.mockApplications();

    return [
      LicenseDetailModel(
        application: base[0],
        applicantName: 'أحمد محمد علي',
        email: 'ahmad@example.com',
        phone: '0999123456',
        nationalId: '1001234567',
        governorate: 'دمشق',
        district: 'القنوات',
        stationName: 'محطة أحمد للوقود',
        stationCategory: 'A',
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
      LicenseDetailModel(
        application: base[1],
        applicantName: 'سارة خليل',
        email: 'sara@example.com',
        phone: '0955123456',
        nationalId: '1009876543',
        governorate: 'حلب',
        district: 'الحديثة',
        stationName: 'محطة سارة للطاقة',
        stationCategory: 'B',
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

  factory LicenseDetailModel.fromApplication(ApplicationModel app) {
    return LicenseDetailModel(
      application: app,
      applicantName: app.applicantName ?? 'غير متوفر',
      email: app.email.isNotEmpty ? app.email : 'غير متوفر',
      phone: app.phone.isNotEmpty ? app.phone : 'غير متوفر',
      nationalId: app.nationalId.isNotEmpty ? app.nationalId : 'غير متوفر',
      governorate: app.governorate ?? 'غير محدد',
      district: app.district.isNotEmpty ? app.district : 'غير محدد',
      stationName: app.stationName ?? app.stationCategory ?? 'غير محدد',
      stationCategory: app.stationCategory ?? 'غير محدد',
      roadType: app.roadType.isNotEmpty ? app.roadType : 'غير محدد',
      planningLocation: app.planningLocation.isNotEmpty
          ? app.planningLocation
          : 'غير محدد',
      coordinates: app.coordinates.isNotEmpty ? app.coordinates : 'غير محدد',
      statusNote: app.statusNote.isNotEmpty
          ? app.statusNote
          : 'لا توجد ملاحظات إضافية',
      attachments: app.attachments.isNotEmpty
          ? app.attachments.cast<dynamic>().map((item) {
              if (item is AttachmentItem) return item;
              return AttachmentItem(name: item.toString());
            }).toList()
          : [AttachmentItem(name: 'لا توجد مرفقات')],
      stepSummary: app.stepSummary.isNotEmpty
          ? app.stepSummary
          : ['تم تقديم الطلب', 'في انتظار المراجعة'],
    );
  }
}
