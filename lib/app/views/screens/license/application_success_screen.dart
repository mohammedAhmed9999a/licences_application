import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:licences_application/app/controllers/auth_controller.dart';
import 'package:licences_application/app/views/screens/terms_pdf_viewer_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../theme/app_theme.dart';
import '../../../controllers/license_application_controller.dart';
import '../../../routes/app_routes.dart';

class ApplicationSuccessScreen extends StatefulWidget {
  const ApplicationSuccessScreen({super.key});

  @override
  State<ApplicationSuccessScreen> createState() =>
      _ApplicationSuccessScreenState();
}

class _ApplicationSuccessScreenState extends State<ApplicationSuccessScreen> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LicenseApplicationController>();
    final ctrlAuth = Get.find<AuthController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final accentColor = isDark ? AppColors.accentLight : AppColors.accent;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final surfaceVariantColor = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.surfaceVariant;
    final cardColor = isDark ? AppColors.darkSurfaceVariant : AppColors.golden3;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textColor = isDark ? AppColors.darkText : AppColors.textPrimary;
    final secondaryTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final mutedTextColor = isDark ? AppColors.darkTextHint : AppColors.textHint;
    final shadowColor = isDark
        ? AppColors.primaryDark.withOpacity(0.28)
        : AppColors.primaryDark.withOpacity(0.08);

    Future<void> exportApplicationPdf() async {
      if (!mounted) return;
      setState(() => _isExporting = true);
      final now = DateTime.now();
      final submissionDateLabel = DateFormat(
        'dd/MM/yyyy - hh:mm a',
        'ar',
      ).format(now);
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
      final partnersText = partners.isNotEmpty
          ? partners.map((p) => p.trim()).where((p) => p.isNotEmpty).join('، ')
          : 'غير محدد';
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
      pw.Widget buildFourColumnRow(
        String label1,
        String value1,
        String label2,
        String value2, {
        bool alternate = false,
        bool allowWrap = false,
      }) {
        final rowColor = alternate
            ? PdfColor.fromHex('#f8f7f0')
            : PdfColors.white;
        final shouldWrap =
            allowWrap && (value1.length > 30 || value2.length > 30);
        final rowHeight = shouldWrap ? 30.h : 20.h;

        return pw.Table(
          border: pw.TableBorder.symmetric(
            inside: pw.BorderSide(
              color: PdfColor.fromHex('#b9a779'),
              width: 0.5,
            ),
            outside: pw.BorderSide(
              color: PdfColor.fromHex('#b9a779'),
              width: 0.5,
            ),
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(4),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(4),
            3: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: rowColor),
              children: [
                pw.Container(
                  height: rowHeight,
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 4,
                  ),
                  alignment: pw.Alignment.centerRight,
                  color: PdfColor.fromHex('#ffffff'),
                  child: pw.Text(
                    value2.isEmpty ? '-' : value2,
                    textAlign: pw.TextAlign.right,
                    softWrap: shouldWrap,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Container(
                  height: rowHeight,
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 4,
                  ),
                  alignment: pw.Alignment.centerRight,
                  color: PdfColor.fromHex('#edebe0'),
                  child: pw.Text(
                    label2,
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                ),
                pw.Container(
                  height: rowHeight,
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 4,
                  ),
                  alignment: pw.Alignment.centerRight,
                  color: PdfColor.fromHex('#ffffff'),
                  child: pw.Text(
                    value1.isEmpty ? '-' : value1,
                    textAlign: pw.TextAlign.right,
                    softWrap: shouldWrap,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Container(
                  height: rowHeight,
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 4,
                  ),
                  alignment: pw.Alignment.centerRight,
                  color: PdfColor.fromHex('#edebe0'),
                  child: pw.Text(
                    label1,
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }

      pw.Widget buildTwoColumnRow(
        String label,
        String value, {
        bool alternate = false,
      }) {
        final rowColor = alternate
            ? PdfColor.fromHex('#f8f7f0')
            : PdfColors.white;

        return pw.Table(
          border: pw.TableBorder.symmetric(
            inside: pw.BorderSide(
              color: PdfColor.fromHex('#b9a779'),
              width: 0.5,
            ),
            outside: pw.BorderSide(
              color: PdfColor.fromHex('#b9a779'),
              width: 0.5,
            ),
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(5),
            1: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: rowColor),
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 4,
                  ),
                  alignment: pw.Alignment.topRight,
                  color: PdfColor.fromHex('#ffffff'),
                  child: pw.Text(
                    value.isEmpty ? '-' : value,
                    textAlign: pw.TextAlign.right,
                    softWrap: true,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Container(
                  height: 20.h,
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 4,
                  ),
                  alignment: pw.Alignment.centerRight,
                  color: PdfColor.fromHex('#edebe0'),
                  child: pw.Text(
                    label,
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }

      // pw.TableRow buildFourColumnRow(
      //   String label1,
      //   String value1,
      //   String label2,
      //   String value2, {
      //   bool alternate = false,
      // }) {
      //   return pw.TableRow(

      //     decoration: pw.BoxDecoration(
      //       color: alternate ? PdfColors.grey100 : PdfColors.white,
      //     ),
      //     children: [
      //       pw.Container(
      //         padding: const pw.EdgeInsets.symmetric(
      //           vertical: 10,
      //           horizontal: 8,
      //         ),
      //         alignment: pw.Alignment.centerRight,
      //         child: pw.Text(
      //           label1,
      //           textAlign: pw.TextAlign.right,
      //           style: pw.TextStyle(
      //             fontSize: 10,
      //             fontWeight: pw.FontWeight.bold,
      //             color: PdfColors.green800,
      //           ),
      //         ),
      //       ),
      //       pw.Container(
      //         padding: const pw.EdgeInsets.symmetric(
      //           vertical: 10,
      //           horizontal: 8,
      //         ),
      //         alignment: pw.Alignment.centerRight,
      //         child: pw.Text(
      //           value1.isEmpty ? '-' : value1,
      //           textAlign: pw.TextAlign.right,
      //           style: pw.TextStyle(fontSize: 10),
      //         ),
      //       ),
      //       pw.Container(
      //         padding: const pw.EdgeInsets.symmetric(
      //           vertical: 10,
      //           horizontal: 8,
      //         ),
      //         alignment: pw.Alignment.centerRight,
      //         child: pw.Text(
      //           label2,
      //           textAlign: pw.TextAlign.right,
      //           style: pw.TextStyle(
      //             fontSize: 10,
      //             fontWeight: pw.FontWeight.bold,
      //             color: PdfColors.green800,
      //           ),
      //         ),
      //       ),
      //       pw.Container(
      //         padding: const pw.EdgeInsets.symmetric(
      //           vertical: 10,
      //           horizontal: 8,
      //         ),
      //         alignment: pw.Alignment.centerRight,
      //         child: pw.Text(
      //           value2.isEmpty ? '-' : value2,
      //           textAlign: pw.TextAlign.right,
      //           style: pw.TextStyle(fontSize: 10),
      //         ),
      //       ),
      //     ],
      //   );
      // }

      pw.Widget buildSection(String title, List<pw.Widget> rows) {
        return pw.Container(
          margin: pw.EdgeInsets.only(bottom: 6.h, top: 6.h),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4.h),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: rows,
              ),
            ],
          ),
        );
      }

      final bgData = await rootBundle.load(
        'assets/images/pattern-tiled-smooth.png',
      );
      debugPrint('حجم البيانات: ${bgData.lengthInBytes}');
      final bgImage = pw.MemoryImage(bgData.buffer.asUint8List());
      debugPrint('عرض الصورة: ${bgImage.width}, ارتفاعها: ${bgImage.height}');
      document.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            theme: pw.ThemeData.withFont(
              base: font,
              bold: font,
              italic: font,
              boldItalic: font,
            ),
            margin: pw.EdgeInsets.all(8.sp),
            buildBackground: (context) {
              return pw.Container(
                width: PdfPageFormat.a4.width,
                height: PdfPageFormat.a4.height,
                child: pw.Opacity(
                  opacity: 0.18,
                  child: pw.Image(
                    bgImage,
                    width: PdfPageFormat.a4.width,
                    height: PdfPageFormat.a4.height,
                    fit: pw.BoxFit.fill,
                  ),
                ),
              );
            },
          ),
          footer: (context) => pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Container(
              margin: pw.EdgeInsets.only(top: 4.h),
              padding: pw.EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Container(height: 0.5, color: PdfColors.grey300),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          'تم إنشاء هذا المستند إلكترونياً لغرض متابعة طلب الترخيص.',
                          style: pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey600,
                          ),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Container(
                        width: 130.w,
                        child: pw.Text(
                          'تاريخ الإنشاء: ${DateFormat('yyyy/MM/dd - hh:mm', 'ar').format(DateTime.now())}',
                          style: pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey600,
                          ),
                          textAlign: pw.TextAlign.left,
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Container(
                        width: 60.w,
                        child: pw.Text(
                          '${context.pageNumber}/${context.pagesCount}',
                          style: pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey600,
                          ),
                          textAlign: pw.TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          build: (context) => [
            // pw.SvgImage(svg: svg, fit: pw.BoxFit.cover),
            // pw.Positioned.fill(
            //   child: pw.Image(bgImage, fit: pw.BoxFit.cover),
            // ),
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Table(
                    columnWidths: {
                      0: pw.FixedColumnWidth(130.w),
                      1: pw.FixedColumnWidth(10.w),
                      2: const pw.FlexColumnWidth(1),
                      3: pw.FixedColumnWidth(10.w),
                      4: pw.FixedColumnWidth(130.w),
                    },
                    defaultVerticalAlignment:
                        pw.TableCellVerticalAlignment.middle,
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.BarcodeWidget(
                              data: applicationNumber,
                              barcode: pw.Barcode.qrCode(),
                              width: 64.w,
                              height: 64.h,
                            ),
                          ),
                          pw.Container(),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                'إدارة خدمات الطاقة',
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  color: PdfColor.fromHex('#002623'),
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'طلب ترخيص محطة وقود',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  color: PdfColors.grey700,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ],
                          ),
                          pw.Container(),
                          pw.Container(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Image(
                              logoImage,
                              width: 145.w,
                              height: 64.h,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Container(height: 1, color: PdfColors.green800),
                  pw.SizedBox(height: 10),
                  pw.SizedBox(height: 18),

                  buildSection('بيانات الطلب', [
                    buildFourColumnRow(
                      'رقم الطلب',
                      applicationNumber,
                      'حالة الطلب',
                      'قيد الدراسة',
                    ),
                    buildFourColumnRow(
                      'نوع العملية',
                      requestTypeLabel,
                      'تاريخ التقديم',
                      submissionDateLabel,
                      alternate: true,
                    ),
                    buildFourColumnRow(
                      'نوع مقدم الطلب',
                      ctrl.investorType.value == 'company' ? 'شركة' : 'فرد',
                      'نسخة الشروط المعتمدة',
                      '1.0',
                    ),
                  ]),
                  buildSection('بيانات مقدم الطلب', [
                    buildFourColumnRow(
                      'الاسم الكامل',
                      applicantFullName,
                      'الرقم الوطني',
                      ctrl.nationalIdController.text.trim(),
                    ),
                    buildFourColumnRow(
                      'اسم الام',
                      ctrl.motherNameController.text.trim(),
                      'مكان الولادة',
                      ctrl.birthPlaceController.text.trim().isNotEmpty
                          ? ctrl.birthPlaceController.text.trim()
                          : 'غير محدد',
                      alternate: true,
                    ),
                    buildFourColumnRow(
                      'تاريخ الولدة',
                      birthDate,
                      'بريد حساب المستخدم',
                      ctrlAuth.userEmail.isNotEmpty
                          ? ctrlAuth.userEmail
                          : 'غير متوفر',
                      allowWrap: true,
                      // ctrl.emailController.text.trim().isNotEmpty
                      //     ? ctrl.emailController.text.trim()
                      //     : 'غير متوفر',
                    ),
                  ]),
                  if (ctrl.investorType.value == 'company')
                    buildSection('بيانات الشركة  والشركاء', [
                      buildFourColumnRow(
                        'اسم الشركة',
                        ctrl.companyNameController.text.trim(),
                        'رقم ترخيص الشركة',
                        companyLicenseNumber,
                      ),
                      buildFourColumnRow(
                        'تاريخ ترخيص الشركة',
                        companyLicenseDateLabel,
                        '',
                        '',
                        alternate: true,
                      ),
                      buildTwoColumnRow(
                        'أسماء الشركاء',
                        partnersText,
                        alternate: true,
                      ),
                    ]),
                  buildSection('بيانات التواصل', [
                    buildFourColumnRow(
                      'البريد الإلكتروني',
                      ctrl.emailController.text.trim(),
                      'رقم التواصل',
                      ctrl.phoneController.text.trim(),
                      allowWrap: true,
                    ),
                    if (ctrl.phone2Controller.text.trim().isNotEmpty)
                      buildFourColumnRow(
                        'رقم التواصل الثانوي',
                        ctrl.phone2Controller.text.trim(),
                        '',
                        '',
                        alternate: true,
                      ),
                  ]),
                  if (ctrl.requestType.value == 'settlement' &&
                      (ctrl.previousLicenseNumber.text.trim().isNotEmpty ||
                          ctrl.settlementRelocation.value))
                    buildSection('بيانات التسوية', [
                      if (ctrl.previousLicenseNumber.text.trim().isNotEmpty)
                        buildFourColumnRow(
                          'رقم الترخيص السابق',
                          settlementLicenseNumber,
                          'نقل المحطة',
                          ctrl.settlementRelocation.value ? 'نعم' : 'لا',
                        ),
                      if (ctrl.settlementRelocation.value)
                        buildFourColumnRow(
                          'الموقع الفديم',
                          (ctrl.oldSelectedGovernorate.value?.name.toString() ??
                                  '/') +
                              ' / ' +
                              (ctrl.oldSelectedDistrict.value?.name
                                      .toString() ??
                                  '/') +
                              ' / ' +
                              (ctrl.oldSelectedSubdistrict.value?.name
                                      .toString() ??
                                  '/') +
                              ' / ' +
                              (ctrl.oldSelectedTown.value?.name.toString() ??
                                  'غير محدد'),
                          'إحداثيات الموقع  القديم',
                          (ctrl.oldLatitudeController.text.trim().isNotEmpty
                                  ? ctrl.oldLatitudeController.text.trim()
                                  : '-') +
                              ' , ' +
                              (ctrl.oldLongitudeController.text
                                      .trim()
                                      .isNotEmpty
                                  ? ctrl.oldLongitudeController.text.trim()
                                  : '-'),
                        ),
                      if (ctrl.settlementRelocation.value)
                        buildFourColumnRow(
                          'لموقع الجديد',
                          (ctrl.selectedGovernorate.value?.name.toString() ??
                                  '/') +
                              ' / ' +
                              (ctrl.selectedDistrict.value?.name.toString() ??
                                  '/') +
                              ' / ' +
                              (ctrl.selectedSubdistrict.value?.name
                                      .toString() ??
                                  '/') +
                              ' / ' +
                              (ctrl.selectedTown.value?.name.toString() ??
                                  'غير محدد'),
                          'إحداثيات الموقع الجديد',
                          (ctrl.latitudeController.text.trim().isNotEmpty
                                  ? ctrl.latitudeController.text.trim()
                                  : '-') +
                              ' , ' +
                              (ctrl.longitudeController.text.trim().isNotEmpty
                                  ? ctrl.longitudeController.text.trim()
                                  : '-'),
                        ),
                    ]),
                  buildSection('بيانات الموقع والتصنيف', [
                    buildFourColumnRow(
                      'المحافظة',
                      governorate,
                      'المنطقة',
                      district,
                    ),
                    buildFourColumnRow(
                      'القضاء',
                      subdistrict,
                      'الناحية',
                      town,
                      alternate: true,
                    ),
                    buildFourColumnRow(
                      'خط العرض',
                      latitude,
                      'خط الطول',
                      longitude,
                    ),
                    buildFourColumnRow(
                      'التصنيف',
                      stationCategoryLabel,
                      'النطاق التنظيمي',
                      planningLocationLabel,
                      alternate: true,
                    ),
                    buildFourColumnRow('نوع الطريق', roadTypeLabel, ' ', ''),
                  ]),
                  // pw.SizedBox(height: 12),
                  // pw.Divider(color: PdfColors.grey300),
                  // pw.SizedBox(height: 10),
                  // pw.Row(
                  //   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     pw.Text(
                  //       'تم إنشاء الملف آلياً بواسطة نظام إدارة خدمات الطاقة',
                  //       style: pw.TextStyle(
                  //         fontSize: 9,
                  //         color: PdfColors.grey600,
                  //       ),
                  //     ),
                  //     pw.Text(
                  //       'وزارة الطاقة © ${DateTime.now().year}',
                  //       style: pw.TextStyle(
                  //         fontSize: 9,
                  //         color: PdfColors.grey600,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      );

      try {
        final dir = await getApplicationDocumentsDirectory();
        final safeApplicationNumber = applicationNumber.replaceAll(
          RegExp(r'[^A-Za-z0-9\u0600-\u06FF._-]'),
          '_',
        );
        final file = File('${dir.path}/طلب_ترخيص_$safeApplicationNumber.pdf');
        await file.writeAsBytes(await document.save());

        if (!await file.exists()) {
          throw Exception('لم يتم إنشاء ملف PDF');
        }

        Get.snackbar(
          'تم التصدير',
          'تم فتح ملف PDF بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 2),
        );

        await Get.to(() => TermsPdfViewerScreen(pdfPath: file.path));
      } catch (e) {
        debugPrint('PDF export failed: $e');
        Get.snackbar(
          'خطأ',
          'تعذر فتح ملف PDF. يرجى المحاولة مرة أخرى.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 3),
        );
      } finally {
        if (mounted) {
          setState(() => _isExporting = false);
        }
      }
    }

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceVariantColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1.h,
            color: isDark ? AppColors.darkDivider : borderColor,
          ),
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
                    color: primaryColor,
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
            Container(
              width: 200.w,
              height: 100.h,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/h-logo.webp'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Shimmer.fromColors(
            //   baseColor: AppColors.gold.withOpacity(0.6),
            //   highlightColor: Colors.white,
            //   period: const Duration(seconds: 2),
            //   child: Container(
            //     width: 200.w,
            //     height: 100.h,
            //     decoration: const BoxDecoration(
            //       image: DecorationImage(
            //         image: AssetImage('assets/images/h-logo.webp'),
            //         fit: BoxFit.contain,
            //       ),
            //     ),
            //   ),
            // ),

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
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
                child: Column(
                  children: [
                    SizedBox(height: 8.h),

                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  AppColors.darkSurfaceVariant,
                                  AppColors.darkSurfaceAlt,
                                ]
                              : [AppColors.golden3, AppColors.surface],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 16.sp,
                                      color: primaryColor,
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      'تم الاستلام بنجاح',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 48.w,
                                height: 48.h,
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                child: Icon(
                                  Icons.verified_outlined,
                                  color: primaryColor,
                                  size: 24.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              'لقد استلمنا طلبك',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              textDirection: ui.TextDirection.rtl,
                            ),
                          ),
                          SizedBox(height: 8.h),

                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(
                              'بمكنك إغلاق هذه الصفحة الآن. سيتم التواصل معك قريباً عبر رقم الهاتف أو البريد الإلكتروني. احتفظ بـرمز الاستجابة السريعة ورقم الطلب لمتابعة معاملة الترخيص.',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                                color: secondaryTextColor,
                                height: 1.6,
                              ),
                              textDirection: ui.TextDirection.rtl,
                            ),
                          ),
                          SizedBox(height: 22.h),

                          Obx(
                            () => Container(
                              padding: EdgeInsets.all(14.sp),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(18.r),
                                border: Border.all(color: borderColor),
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
                                    size: 140.sp,
                                    backgroundColor: cardColor,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: QrEyeShape.square,
                                      color: primaryColor,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape: QrDataModuleShape.square,
                                      color: primaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    'رقم طلب الترخيص',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11.sp,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Obx(
                                    () => Text(
                                      ctrl
                                              .submittedApplicationNumber
                                              .value
                                              .isNotEmpty
                                          ? ctrl
                                                .submittedApplicationNumber
                                                .value
                                          : 'SY-LR-20260623-0001',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 22.h),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              final useColumn = constraints.maxWidth < 360;
                              if (useColumn) {
                                return Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: primaryColor),
                                          foregroundColor: primaryColor,
                                          backgroundColor: isDark
                                              ? AppColors.darkSurfaceVariant
                                              : AppColors.surface,
                                        ),
                                        onPressed: () => Get.offAllNamed(
                                          AppRoutes.dashboard,
                                        ),
                                        icon: Icon(
                                          Icons.home_outlined,
                                          size: 18.sp,
                                        ),
                                        label: Text(
                                          'العودة إلى الصفحة الرئيسية',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                        ),
                                        onPressed: () async {
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
                                );
                              }
                              return Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: primaryColor),
                                        foregroundColor: primaryColor,
                                        backgroundColor: isDark
                                            ? AppColors.darkSurfaceVariant
                                            : AppColors.surface,
                                      ),
                                      onPressed: () =>
                                          Get.offAllNamed(AppRoutes.dashboard),
                                      icon: Icon(
                                        Icons.home_outlined,
                                        size: 18.sp,
                                      ),
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
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                      ),
                                      onPressed: () async {
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
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 28.h),
                    Text(
                      'وزارة الطاقة © 2026',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        color: mutedTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isExporting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.25),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 22.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : cardColor,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LoadingAnimationWidget.threeArchedCircle(
                          color: primaryColor,
                          size: 42.sp,
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          'جاري تجهيز ملف PDF...',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'قد يستغرق ذلك بضع ثوانٍ',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
