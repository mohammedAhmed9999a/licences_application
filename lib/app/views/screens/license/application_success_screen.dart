import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:licences_application/app/views/screens/terms_pdf_viewer_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../theme/app_theme.dart';
import '../../../controllers/license_application_controller.dart';
import '../../../routes/app_routes.dart';

class ApplicationSuccessScreen extends StatelessWidget {
  const ApplicationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LicenseApplicationController>();

    Future<void> exportApplicationPdf() async {
      final applicationNumber = ctrl.submittedApplicationNumber.value.isNotEmpty
          ? ctrl.submittedApplicationNumber.value
          : 'غير محدد';
      final fontData = await rootBundle.load('assets/fonts/arial.ttf');
      final font = pw.Font.ttf(fontData);
      final document = pw.Document();
      final applicantName = ctrl.getApplicantFullName();
      final applicantPersonName = <String>[
        ctrl.firstNameController.text.trim(),
        ctrl.fatherNameController.text.trim(),
        ctrl.lastNameController.text.trim().isNotEmpty
            ? ctrl.lastNameController.text.trim()
            : ctrl.nicknameController.text.trim(),
      ].where((part) => part.isNotEmpty).join(' ');
      final applicantFullName = applicantPersonName.isNotEmpty
          ? applicantPersonName
          : applicantName;
      final requestTypeLabel = ctrl.requestType.value == 'settlement'
          ? 'تسوية'
          : 'جديد';
      final birthDate = ctrl.birthDate.value != null
          ? DateFormat('dd/MM/yyyy').format(ctrl.birthDate.value!)
          : 'غير محدد';
      final governorate = ctrl.selectedGovernorate.value?.name ?? 'غير محدد';
      final district = ctrl.selectedDistrict.value?.name ?? 'غير محدد';
      final subdistrict = ctrl.selectedSubdistrict.value?.name ?? 'غير محدد';
      final town = ctrl.selectedTown.value?.name ?? 'غير محدد';
      final planningLocationLabel = ctrl.planningLocation.value == 'inside'
          ? 'داخل التنظيم'
          : 'خارج التنظيم';
      final roadTypeLabel = ctrl.planningLocation.value == 'inside'
          ? '-'
          : ctrl.roadType.value == 'international'
          ? 'دولي'
          : ctrl.roadType.value == 'central'
          ? 'محوري'
          : 'محلي';
      final latitude = ctrl.latitudeController.text.trim().isNotEmpty
          ? ctrl.latitudeController.text.trim()
          : 'غير محدد';
      final longitude = ctrl.longitudeController.text.trim().isNotEmpty
          ? ctrl.longitudeController.text.trim()
          : 'غير محدد';
      final partners = ctrl.investorType.value == 'company'
          ? ctrl.partners.where((p) => p.trim().isNotEmpty).toList()
          : <String>[];
      final stationCategoryLabel = 'الفئة ${ctrl.stationCategory.value}';
      final companyLicenseNumber =
          ctrl.companyLicenseNumberController.text.trim().isNotEmpty
          ? ctrl.companyLicenseNumberController.text.trim()
          : 'غير مطبق';
      final companyLicenseDateLabel = ctrl.companyLicenseDate.value != null
          ? '${ctrl.companyLicenseDate.value!.day}/${ctrl.companyLicenseDate.value!.month}/${ctrl.companyLicenseDate.value!.year}'
          : 'غير مطبق';
      final settlementLicenseNumber = ctrl.requestType.value == 'settlement'
          ? ctrl.previousLicenseNumber.text.trim().isNotEmpty
                ? ctrl.previousLicenseNumber.text.trim()
                : 'غير محدد'
          : 'غير مطبق';
      final logoData = await rootBundle.load('assets/images/h-logo.webp');

      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
      pw.Widget buildLabelValue(String label, String value) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 9.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value.isEmpty ? '-' : value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontSize: 10),
            ),
          ],
        );
      }

      pw.Widget buildTripleRow(
        String label1,
        String value1, {
        String? label2,
        String? value2,
        String? label3,
        String? value3,
        bool alternate = false,
      }) {
        final cells = <pw.Widget>[
          pw.Expanded(child: buildLabelValue(label1, value1)),
        ];
        if (label2 != null && value2 != null) {
          cells.add(pw.SizedBox(width: 8));
          cells.add(pw.Expanded(child: buildLabelValue(label2, value2)));
        }
        if (label3 != null && value3 != null) {
          cells.add(pw.SizedBox(width: 8));
          cells.add(pw.Expanded(child: buildLabelValue(label3, value3)));
        }

        return pw.Container(
          color: alternate ? PdfColors.grey100 : PdfColors.white,
          padding: const pw.EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,

            // textDirection: pw.TextDirection.rtl,
            children: cells,
          ),
        );
      }

      pw.Widget buildSection(String title, List<pw.Widget> rows) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 10,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: const pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(8),
                    topRight: pw.Radius.circular(8),
                  ),
                ),
                child: pw.Text(
                  title,
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Divider(color: PdfColors.grey300, height: 1),
              ...rows,
            ],
          ),
        );
      }

      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: font,
            bold: font,
            italic: font,
            boldItalic: font,
          ),
          margin: const pw.EdgeInsets.all(24),
          build: (context) => [
            // pw.SvgImage(svg: svg, fit: pw.BoxFit.cover),
            // pw.Positioned.fill(
            //   child: pw.Image(bgImage, fit: pw.BoxFit.cover),
            // ),
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Image(logoImage, width: 150.w, height: 100.h),

                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'إدارة خدمات الطاقة',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'طلب ترخيص محطة وقود',
                            style: pw.TextStyle(
                              fontSize: 14,
                              color: PdfColors.grey700,
                            ),
                          ),
                          // pw.SizedBox(height: 2),
                          // pw.Text(
                          //   'طلب ترخيص محطة وقود',
                          //   style: pw.TextStyle(
                          //     fontSize: 12,
                          //     color: PdfColors.grey700,
                          //   ),
                          // ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: pw.BorderRadius.circular(8),
                          color: PdfColors.white,
                        ),
                        child: pw.BarcodeWidget(
                          data: applicationNumber,
                          barcode: pw.Barcode.qrCode(),
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 18),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'رقم الطلب: $applicationNumber',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'تاريخ التقديم: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  buildSection('بيانات الطلب', [
                    buildTripleRow(
                      'رقم الطلب',
                      applicationNumber,
                      label2: 'نوع الطلب',
                      value2: requestTypeLabel,
                      label3: 'حالة الطلب',
                      value3: 'قيد الدراسة',
                    ),
                    buildTripleRow(
                      'تاريخ التقديم',
                      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      label2: 'مدة الدراسة',
                      value2: '1.0',
                      label3: 'فئة المحطة',
                      value3: stationCategoryLabel,
                      alternate: true,
                    ),
                    buildTripleRow(
                      'رقم الترخيص السابق',
                      settlementLicenseNumber,
                      label2: 'اسم مقدم الطلب',
                      value2: applicantFullName,
                      alternate: false,
                    ),
                    if (ctrl.investorType.value == 'company')
                      buildTripleRow(
                        'اسم الشركة',
                        ctrl.companyNameController.text.trim(),
                        label2: 'رقم ترخيص الشركة',
                        value2: companyLicenseNumber,
                        label3: 'تاريخ ترخيص الشركة',
                        value3: companyLicenseDateLabel,
                        alternate: true,
                      ),
                  ]),
                  buildSection('بيانات مقدم الطلب', [
                    buildTripleRow(
                      'الاسم الكامل',
                      applicantFullName,
                      label2: 'الرقم الوطني',
                      value2: ctrl.nationalIdController.text.trim(),
                      label3: 'مكان الولادة',
                      value3: ctrl.birthPlaceController.text.trim(),
                    ),
                    buildTripleRow(
                      'تاريخ الولادة',
                      birthDate,
                      label2: 'البريد الإلكتروني',
                      value2: ctrl.emailController.text.trim(),
                      label3: 'رقم التواصل',
                      value3: ctrl.phoneController.text.trim(),
                      alternate: true,
                    ),
                    if (ctrl.phone2Controller.text.trim().isNotEmpty)
                      buildTripleRow(
                        'الهاتف الثانوي',
                        ctrl.phone2Controller.text.trim(),
                        alternate: false,
                      ),
                    if (ctrl.investorType.value == 'company')
                      buildTripleRow(
                        'اسم الشركة',
                        ctrl.companyNameController.text.trim(),
                        label2: 'الشركاء',
                        value2: partners.isNotEmpty
                            ? partners.join('، ')
                            : 'غير محدد',
                        alternate: true,
                      ),
                  ]),
                  buildSection('بيانات الموقع والتصنيف', [
                    buildTripleRow(
                      'المحافظة',
                      governorate,
                      label2: 'المنطقة',
                      value2: district,
                      label3: 'القضاء',
                      value3: subdistrict,
                    ),
                    buildTripleRow(
                      'الناحية',
                      town,
                      label2: 'نوع الطريق',
                      value2: roadTypeLabel,
                      label3: 'فئة المحطة',
                      value3: stationCategoryLabel,
                      alternate: true,
                    ),
                    buildTripleRow(
                      'خط الطول',
                      longitude,
                      label2: 'دائرة العرض',
                      value2: latitude,
                      label3: 'حالة التنظيم',
                      value3: planningLocationLabel,
                    ),
                  ]),
                  pw.SizedBox(height: 22),
                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'تم إنشاء الملف آلياً بواسطة نظام إدارة خدمات الطاقة',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        'وزارة الطاقة © ${DateTime.now().year}',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/طلب_ترخيص_$applicationNumber.pdf');
      await file.writeAsBytes(await document.save());

      Get.to(() => TermsPdfViewerScreen(pdfPath: file.path));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1.h, color: AppColors.borderLight),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: ui.TextDirection.ltr,
          children: [
            // Logout button
            GestureDetector(
              onTap: () => Get.offAllNamed(AppRoutes.dashboard),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios_new_outlined,
                    size: 18.sp,
                    textDirection: ui.TextDirection.ltr,
                    color: AppColors.textSecondary,
                  ),
                  // SizedBox(width: 4.w),
                  // Text(
                  //   'تسجيل الخروج',
                  //   style: TextStyle(
                  //     fontSize: 13.sp,
                  //     color: AppColors.textSecondary,
                  //     fontFamily: 'Cairo',
                  //   ),
                  // ),
                ],
              ),
            ),
            Shimmer.fromColors(
              baseColor: AppColors.gold.withOpacity(0.6),
              highlightColor: Colors.white,
              period: const Duration(seconds: 2),
              child: Container(
                width: 200.w,
                height: 100.h,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/h-logo.webp'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Ministry branding
            // Row(
            //   children: [
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.end,
            //       children: [
            //         Text(
            //           'إدارة خدمات الطاقة',
            //           style: TextStyle(
            //             fontSize: 11.sp,
            //             color: AppColors.textSecondary,
            //             fontFamily: 'Cairo',
            //           ),
            //         ),
            //         Text(
            //           'Energy Services Management',
            //           style: TextStyle(
            //             fontSize: 9.sp,
            //             color: AppColors.textHint,
            //             fontFamily: 'Cairo',
            //           ),
            //         ),
            //       ],
            //     ),
            //     SizedBox(width: 8.w),
            //     const MinistryLogoWidget(size: 36, showText: false),
            //   ],
            // ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // Main success card
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Success icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 26.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Title
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'لقد استلمنا طلبك',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textDirection: ui.TextDirection.rtl,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Description
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        'بمكنك إغلاق هذه الصفحة الآن. سيتم التواصل معك قريباً عبر رقم الهاتف أو البريد الإلكتروني. احتفظ بـرمز الاستجابة السريعة ورقم الطلب لمتابعة معاملة الترخيص.',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                        textDirection: ui.TextDirection.rtl,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // QR Code
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          children: [
                            QrImageView(
                              data:
                                  ctrl
                                      .submittedApplicationNumber
                                      .value
                                      .isNotEmpty
                                  ? ctrl.submittedApplicationNumber.value
                                  : 'SY-LR-20260623-0001',
                              version: QrVersions.auto,
                              size: 180,
                              backgroundColor: Colors.white,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: AppColors.textPrimary,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            // Application number
                            Text(
                              'رقم طلب الترخيص',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Obx(
                              () => Text(
                                ctrl.submittedApplicationNumber.value.isNotEmpty
                                    ? ctrl.submittedApplicationNumber.value
                                    : 'SY-LR-20260623-0001',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Action buttons
                    Row(
                      children: [
                        // Go to home
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                Get.offAllNamed(AppRoutes.dashboard),
                            icon: Icon(Icons.home_outlined, size: 18.sp),
                            label: Text(
                              'العودة إلى الصفحة الرئيسية',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Export PDF
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              Get.snackbar(
                                'تحميل',
                                'جاري تحضير ملف PDF...',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.primary,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 8,
                                duration: const Duration(seconds: 2),
                              );
                              await exportApplicationPdf();
                            },
                            icon: Icon(
                              Icons.picture_as_pdf_outlined,
                              size: 18.sp,
                            ),
                            label: Text(
                              'تصدير الطلب بصيغة PDF',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),
              // Footer
              Text(
                'وزارة الطاقة © 2026',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  color: AppColors.textHint,
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
