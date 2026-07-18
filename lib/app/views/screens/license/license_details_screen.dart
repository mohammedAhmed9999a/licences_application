import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

import 'package:intl/intl.dart';
import 'package:licences_application/app/views/screens/terms_pdf_viewer_screen.dart';
import 'package:licences_application/core/services/core_api_service.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_theme.dart';
import '../../../models/application_model.dart';
import '../../../models/license_detail_model.dart';
import '../../../controllers/license_application_controller.dart';
import '../../../routes/app_routes.dart';

class LicenseDetailsScreen extends StatefulWidget {
  const LicenseDetailsScreen({super.key});

  @override
  State<LicenseDetailsScreen> createState() => _LicenseDetailsScreenState();
}

class FullscreenImageViewer extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isLocal;
  final String? localPath;

  const FullscreenImageViewer({
    super.key,
    required this.title,
    required this.imageUrl,
    this.isLocal = false,
    this.localPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(title, style: TextStyle(fontSize: 14.sp)),
        actions: [
          IconButton(
            onPressed: () async {
              // try to download/open the image in browser
              final uri = Uri.tryParse(imageUrl);
              if (uri != null &&
                  (uri.scheme == 'http' || uri.scheme == 'https')) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            icon: Icon(Icons.open_in_new, color: theme.colorScheme.onPrimary),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: InteractiveViewer(
            maxScale: 4.0,
            minScale: 1.0,
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: isLocal && localPath != null
                  ? Image.file(File(localPath!), fit: BoxFit.contain)
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      headers: {'Accept': 'image/*'},
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              size: 64.sp,
                              color: theme.colorScheme.error,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'تعذر تحميل الصورة',
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LicenseDetailsScreenState extends State<LicenseDetailsScreen> {
  LicenseDetailModel? detail;
  final Map<String, bool> _expandedSections = {
    'summary': false,
    'applicant': false,
    'location': false,
    'latest_attachments': false,
    'timeline': false,
  };

  @override
  void initState() {
    super.initState();
    detail = Get.arguments as LicenseDetailModel?;
  }

  Future<void> _exportApplicationPdf() async {
    if (detail == null) return;

    final applicationNumber = detail!.application.applicationNumber.isNotEmpty
        ? detail!.application.applicationNumber
        : 'غير محدد';
    final fontData = await rootBundle.load('assets/fonts/arial.ttf');
    final font = pw.Font.ttf(fontData);
    final document = pw.Document();

    final applicantFullName = detail!.applicantName.trim().isNotEmpty
        ? detail!.applicantName
        : [
            detail!.application.firstName,
            detail!.application.fatherName,
            detail!.application.lastName,
          ].where((value) => (value ?? '').trim().isNotEmpty).join(' ');

    final requestTypeLabel = detail!.requestTypeLabel;
    final birthDate = detail!.application.dateOfBirth?.trim().isNotEmpty == true
        ? detail!.application.dateOfBirth!
        : 'غير محدد';
    final governorate = detail!.governorate;
    final district = detail!.district;
    final stationCategoryLabel = 'الفئة ${detail!.stationCategory}';
    final roadTypeLabel = detail!.roadType;
    final planningLocationLabel = detail!.planningLocation;
    final coordinates = detail!.coordinates;
    final companyName =
        detail!.application.companyName?.trim().isNotEmpty == true
        ? detail!.application.companyName!
        : 'غير محدد';
    final companyLicenseNumber =
        detail!.application.companyLicenseNumber?.trim().isNotEmpty == true
        ? detail!.application.companyLicenseNumber!
        : 'غير مطبق';
    final companyLicenseDateLabel =
        detail!.application.companyLicenseDate?.trim().isNotEmpty == true
        ? detail!.application.companyLicenseDate!
        : 'غير مطبق';
    final logoData = await rootBundle.load('assets/images/h-logo.webp');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    pw.TableRow buildFourColumnRow(
      String label1,
      String value1,
      String label2,
      String value2, {
      bool alternate = false,
    }) {
      return pw.TableRow(
        children: [
          pw.Container(
            height: 20.h,
            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            alignment: pw.Alignment.centerRight,
            decoration: pw.BoxDecoration(color: PdfColors.white),
            child: pw.Text(
              value2.isEmpty ? '-' : value2,
              textAlign: pw.TextAlign.right,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.Container(
            height: 20.h,
            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            alignment: pw.Alignment.centerRight,
            decoration: pw.BoxDecoration(color: PdfColors.grey100),
            child: pw.Text(
              label2,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green800,
              ),
            ),
          ),
          pw.Container(
            height: 20.h,
            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            alignment: pw.Alignment.centerRight,
            decoration: pw.BoxDecoration(color: PdfColors.white),
            child: pw.Text(
              value1.isEmpty ? '-' : value1,
              textAlign: pw.TextAlign.right,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.Container(
            height: 20.h,
            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            alignment: pw.Alignment.centerRight,
            decoration: pw.BoxDecoration(color: PdfColors.grey100),
            child: pw.Text(
              label1,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green800,
              ),
            ),
          ),
        ],
      );
    }

    pw.Widget buildSection(String title, List<pw.TableRow> rows) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 8,
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
            pw.Table(
              border: pw.TableBorder.symmetric(
                inside: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                outside: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(4),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(4),
                3: const pw.FlexColumnWidth(2),
              },
              children: rows,
            ),
          ],
        ),
      );
    }

    final bgData = await rootBundle.load('assets/images/logo2.png');
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
          margin: const pw.EdgeInsets.all(24),
          buildBackground: (context) {
            return pw.Container(
              width: PdfPageFormat.a4.width,
              height: PdfPageFormat.a4.height,
              child: pw.Opacity(
                opacity: 0.12,
                child: pw.Image(
                  bgImage,
                  fit: pw.BoxFit.cover,
                  width: PdfPageFormat.a4.width,
                  height: PdfPageFormat.a4.height,
                ),
              ),
            );
          },
        ),

        // pageTheme: pw.PageTheme(
        //   pageFormat: PdfPageFormat.a4,
        //   buildBackground: (context) {
        //     debugPrint(
        //       '🔵 buildBackground استُدعيت - رقم الصفحة: ${context.pageNumber}',
        //     );
        //     return pw.FullPage(
        //       ignoreMargins: true,
        //       child: pw.Image(
        //         bgImage,
        //         fit: pw.BoxFit.cover,
        //       ), // بدون Opacity مؤقتًا
        //     );
        //   },
        // ),
        // footer: ,
        footer: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'تم إنشاء الملف آلياً بواسطة نظام إدارة خدمات الطاقة',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    'وزارة الطاقة © ${DateTime.now().year}',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                ],
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Image(logoImage, width: 140, height: 90),
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
                            fontSize: 13,
                            color: PdfColors.grey700,
                          ),
                        ),
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
                        width: 50.w,
                        height: 50.h,
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
                        'تاريخ التقديم: ${_formatDisplayDate(detail!.application.createdAt)}',
                        // 'تاريخ التقديم: ${detail!.application.createdAt.isNotEmpty ? detail!.application.createdAt : DateTime.now().toString().split(' ').first}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                buildSection('بيانات الطلب', [
                  buildFourColumnRow(
                    'رقم الطلب',
                    applicationNumber,
                    'نوع الطلب',
                    requestTypeLabel,
                  ),
                  buildFourColumnRow(
                    'حالة الطلب',
                    detail!.application.statusLabel,
                    'تاريخ التقديم',
                    _formatDisplayDate(detail!.application.createdAt),
                    // detail!.application.createdAt.isNotEmpty
                    //     ? detail!.application.createdAt
                    //     : DateTime.now().toString().split(' ').first,
                    alternate: true,
                  ),
                  buildFourColumnRow(
                    'اسم مقدم الطلب',
                    applicantFullName,
                    'الفئة',
                    stationCategoryLabel,
                  ),
                  if (detail!.application.companyName?.trim().isNotEmpty ==
                      true)
                    buildFourColumnRow(
                      'اسم الشركة',
                      companyName,
                      'رقم رخصة الشركة',
                      companyLicenseNumber,
                    ),
                  if (detail!.application.companyLicenseDate
                          ?.trim()
                          .isNotEmpty ==
                      true)
                    buildFourColumnRow(
                      'تاريخ رخصة الشركة',
                      companyLicenseDateLabel,
                      '',
                      '',
                    ),
                ]),
                buildSection('بيانات مقدم الطلب', [
                  buildFourColumnRow(
                    'الاسم الكامل',
                    applicantFullName,
                    'الرقم الوطني',
                    detail!.nationalId,
                  ),
                  buildFourColumnRow(
                    'مكان الولادة',
                    detail!.application.placeOfBirth?.trim().isNotEmpty == true
                        ? detail!.application.placeOfBirth!
                        : 'غير محدد',
                    'تاريخ الميلاد',
                    birthDate,
                    alternate: true,
                  ),
                  buildFourColumnRow(
                    'البريد الإلكتروني',
                    detail!.email,
                    'رقم التواصل',
                    detail!.phone,
                  ),
                  if (detail!.application.secondaryPhone?.trim().isNotEmpty ==
                      true)
                    buildFourColumnRow(
                      'الهاتف الثانوي',
                      detail!.application.secondaryPhone!,
                      '',
                      '',
                    ),
                  if (detail!.application.companyName?.trim().isNotEmpty ==
                      true)
                    buildFourColumnRow(
                      'اسم الشركة',
                      companyName,
                      'رقم الرخصة',
                      companyLicenseNumber,
                      alternate: true,
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
                    'اسم المحطة',
                    detail!.stationName,
                    'فئة المحطة',
                    stationCategoryLabel,
                    alternate: true,
                  ),
                  buildFourColumnRow(
                    'نوع الطريق',
                    roadTypeLabel,
                    'الحالة التنظيمية',
                    planningLocationLabel,
                  ),
                  buildFourColumnRow(
                    'الإحداثيات',
                    coordinates,
                    '',
                    '',
                    alternate: true,
                  ),
                ]),
                // pw.SizedBox(height: 12),
                // pw.Divider(color: PdfColors.grey300),
                // pw.SizedBox(height: 10),
                // // Spacer(),
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

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/طلب_ترخيص_$applicationNumber.pdf');
    await file.writeAsBytes(await document.save());

    Get.to(() => TermsPdfViewerScreen(pdfPath: file.path));
  }

  String _formatDisplayDate(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      return 'غير محدد';
    }

    final value = rawValue.trim();
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return DateFormat('yyyy/MM/dd - hh:mm', 'ar').format(parsed);
    }

    return value;
  }

  void _toggleSection(String key) {
    setState(() {
      _expandedSections[key] = !(_expandedSections[key] ?? true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = context.themeSurface;
    final borderColor = context.themeBorder;
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;
    final secondary =
        theme.textTheme.bodyMedium?.color ??
        theme.colorScheme.onSurface.withValues(alpha: 0.7);

    if (detail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الطلب')),
        body: const Center(child: Text('لا توجد بيانات')),
      );
    }
    final isDark = Get.isDarkMode;
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: isDark
              ? Theme.of(context).scaffoldBackgroundColor.withAlpha(225)
              : Theme.of(context).scaffoldBackgroundColor.withAlpha(240),
          appBar: _buildAppBar(context, detail!),
          body: Stack(
            children: [
              // خلفية احترافية
              // Positioned(
              //   top: 0,
              //   left: 0,
              //   right: 0,
              //   child: Container(
              //     height: 120.h,
              //     decoration: BoxDecoration(
              //       gradient: LinearGradient(
              //         begin: Alignment.topLeft,
              //         end: Alignment.bottomRight,
              //         colors: [
              //           primary.withValues(alpha: 0.08),
              //           primary.withValues(alpha: 0.02),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusOverview(
                        context,
                        detail!,
                        surface,
                        borderColor,
                      ),
                      SizedBox(height: 24.h),
                      _buildSectionCard(
                        context,
                        title: 'الملخص العام',
                        icon: Icons.description_outlined,
                        isExpanded: _expandedSections['summary'] ?? true,
                        onToggle: () => _toggleSection('summary'),
                        child: _buildUniformInfoList(context, [
                          _InfoEntry(
                            'رقم الطلب',
                            detail!.application.applicationNumber,
                          ),
                          _InfoEntry('نوع الطلب', detail!.requestTypeLabel),
                          _InfoEntry('نوع المستثمر', detail!.investorTypeLabel),
                          _InfoEntry(
                            'تاريخ الإنشاء',
                            DateFormat('dd/MM/yyyy - hh:mm a', 'ar').format(
                              DateTime.parse(detail!.application.createdAt),
                            ),
                            // _formatDisplayDate(detail!.application.createdAt),
                          ),
                        ]),
                      ),
                      SizedBox(height: 18.h),
                      _buildSectionCard(
                        context,
                        title: 'بيانات مقدم الطلب',
                        icon: Icons.person_outline,
                        isExpanded: _expandedSections['applicant'] ?? true,
                        onToggle: () => _toggleSection('applicant'),
                        child: _buildUniformInfoList(
                          context,
                          _buildApplicantEntries(detail!),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      _buildSectionCard(
                        context,
                        title: 'تفاصيل الموقع والمحطة',
                        icon: Icons.location_on_outlined,
                        isExpanded: _expandedSections['location'] ?? true,
                        onToggle: () => _toggleSection('location'),
                        child: _buildUniformInfoList(context, [
                          _InfoEntry('المحافظة', detail!.governorate),
                          _InfoEntry('المنطقة / الحي', detail!.district),
                          _InfoEntry('اسم المحطة', detail!.stationName),
                          _InfoEntry('فئة المحطة', detail!.stationCategory),
                          _InfoEntry('نوع الطريق', detail!.roadType),
                          _InfoEntry(
                            'الموقع التخطيطي',
                            detail!.planningLocation,
                          ),
                          _InfoEntry(
                            'الإحداثيات',
                            detail!.coordinates,
                            onTap: () =>
                                _openCoordinatesOnMap(detail!.coordinates),
                          ),
                        ]),
                      ),
                      SizedBox(height: 18.h),
                      _buildAttachmentsSection(
                        context,
                        detail!,
                        primary,
                        onSurface,
                        isExpanded:
                            _expandedSections['latest_attachments'] ?? true,
                        onToggle: () => _toggleSection('latest_attachments'),
                      ),
                      // SizedBox(height: 18.h),
                      // _buildTimelineSection(
                      //   context,
                      //   detail!,
                      //   primary,
                      //   secondary,
                      //   isExpanded: _expandedSections['timeline'] ?? true,
                      //   onToggle: () => _toggleSection('timeline'),
                      // ),
                      SizedBox(height: 24.h),
                      _buildActionButtons(context, primary),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOverview(
    BuildContext context,
    LicenseDetailModel detail,
    Color surface,
    Color borderColor,
  ) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;
    final statusColor = _getStatusColor(detail.application.status);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: ui.TextDirection.rtl,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      detail.application.stationName ?? 'محطة غير محددة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: onSurface,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          detail.application.governorate ??
                              'المحافظة غير محددة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.sp,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.location_on_outlined,
                          size: 14.sp,
                          color: primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getStatusIcon(detail.application.status),
                      color: statusColor,
                      size: 20.sp,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      detail.application.statusLabel,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (detail.application.correctionTargets.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'الحقول المطلوبة للتعديل',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  alignment: WrapAlignment.end,
                  children: detail.application.correctionTargets
                      .map(
                        (target) => Chip(
                          label: Text(
                            _correctionTargetLabel(target),
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.sp,
                            ),
                          ),
                          backgroundColor: primary.withValues(alpha: 0.12),
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              detail.statusNote,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                color: theme.textTheme.bodyMedium?.color,
                height: 1.5,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSize _buildAppBar(BuildContext context, LicenseDetailModel detail) {
    final theme = Theme.of(context);
    final surface = context.themeSurface;
    final borderColor = context.themeBorder;

    return PreferredSize(
      preferredSize: Size.fromHeight(70.h),

      child: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: Container(),
        // leading: Container(
        //   margin: EdgeInsets.all(8.w),
        //   decoration: BoxDecoration(
        //     color: theme.colorScheme.primary.withValues(alpha: 0.1),
        //     borderRadius: BorderRadius.circular(12.r),
        //   ),
        //   child: IconButton(
        //     icon: Icon(
        //       Icons.arrow_back_ios_new,
        //       color: theme.colorScheme.primary,
        //       size: 20.sp,
        //     ),
        //     onPressed: () => Get.back(),
        //   ),
        // ),
        // alignLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          textDirection: ui.TextDirection.rtl,
          children: [
            Text(
              'تفاصيل الطلب',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              detail.application.applicationNumber,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.sp,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        centerTitle: true,
        toolbarHeight: 60.h,

        // actions: [
        //   Obx(() {
        //     final settingsCtrl = Get.find<SettingsController>();
        //     final isDark = settingsCtrl.isDark;
        //     return IconButton(
        //       onPressed: () => settingsCtrl.toggleTheme(),
        //       tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
        //       icon: ThemedIcon(
        //         isDark ? Icons.light_mode : Icons.dark_mode,
        //         type: IconType.appBar,
        //         customSize: 20.sp,
        //       ),
        //     );
        //   }),
        // ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(height: 1.h, color: borderColor),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final borderColor = context.themeBorder;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: onToggle,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: borderColor.withValues(
                        alpha: isExpanded ? 0.3 : 0.15,
                      ),
                      width: 1.2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: primary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'اضغط لعرض التفاصيل',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.sp,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(icon, color: primary, size: 20.sp),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: child,
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  List<_InfoEntry> _buildApplicantEntries(LicenseDetailModel detail) {
    final app = detail.application;
    final userName = [app.firstName, app.fatherName, app.lastName]
        .where((value) => (value ?? '').trim().isNotEmpty)
        .map((value) => value!.trim())
        .join(' ');

    final fields = <_InfoEntry>[];

    if (_hasMeaningfulValue(detail.applicantName)) {
      fields.add(_InfoEntry('اسم مقدم الطلب', detail.applicantName));
    }
    if (_hasMeaningfulValue(userName)) {
      fields.add(_InfoEntry('اسم المستخدم', userName));
    }
    if (_hasMeaningfulValue(app.nickname)) {
      fields.add(_InfoEntry('الاسم المستعار', app.nickname!));
    }
    if (_hasMeaningfulValue(app.placeOfBirth)) {
      fields.add(_InfoEntry('محل الميلاد', app.placeOfBirth!));
    }
    if (_hasMeaningfulValue(app.dateOfBirth)) {
      fields.add(
        _InfoEntry('تاريخ الميلاد', _formatDisplayDate(app.dateOfBirth)),
      );
    }
    if (_hasMeaningfulValue(detail.email)) {
      fields.add(_InfoEntry('البريد الإلكتروني', detail.email));
    }
    if (_hasMeaningfulValue(detail.phone)) {
      fields.add(_InfoEntry('الهاتف', detail.phone));
    }
    if (_hasMeaningfulValue(app.secondaryPhone)) {
      fields.add(_InfoEntry('الهاتف الإضافي', app.secondaryPhone!));
    }
    if (_hasMeaningfulValue(detail.nationalId)) {
      fields.add(_InfoEntry('الهوية الوطنية', detail.nationalId));
    }
    if (_hasMeaningfulValue(app.companyName)) {
      fields.add(_InfoEntry('اسم الشركة', app.companyName!));
    }
    if (_hasMeaningfulValue(app.companyLicenseNumber)) {
      fields.add(_InfoEntry('رقم رخصة الشركة', app.companyLicenseNumber!));
    }
    if (_hasMeaningfulValue(app.companyLicenseDate)) {
      fields.add(
        _InfoEntry(
          'تاريخ رخصة الشركة',
          DateFormat(
            'dd/MM/yyyy - hh:mm a',
            'ar',
          ).format(DateTime.parse(app.companyLicenseDate!.toString())),
          // _formatDisplayDate(app.companyLicenseDate),
        ),
      );
    }

    return fields;
  }

  bool _hasMeaningfulValue(String? value) {
    final normalized = (value ?? '').trim();
    return normalized.isNotEmpty &&
        normalized != 'غير متوفر' &&
        normalized != 'غير محدد';
  }

  Future<void> _openCoordinatesOnMap(String coordinates) async {
    final parsed = _parseCoordinates(coordinates);
    if (parsed == null) {
      Get.snackbar('تنبيه', 'الإحداثيات غير متاحة أو بصيغة غير صحيحة.');
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps?q=${parsed.$1},${parsed.$2}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('تنبيه', 'تعذر فتح الخريطة على هذا الجهاز.');
    }
  }

  (double lat, double lng)? _parseCoordinates(String coordinates) {
    final normalized = coordinates.trim().replaceAll('،', ',');
    final parts = normalized
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length < 2) {
      return null;
    }

    final latitude = double.tryParse(parts.first);
    final longitude = double.tryParse(parts.last);

    if (latitude == null || longitude == null) {
      return null;
    }

    return (latitude, longitude);
  }

  Widget _buildUniformInfoList(BuildContext context, List<_InfoEntry> items) {
    final borderColor = context.themeBorder;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(items.length, (index) {
          final entry = items[index];
          final isLast = index == items.length - 1;
          return Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: borderColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: entry.onTap != null
                      ? InkWell(
                          onTap: entry.onTap,
                          borderRadius: BorderRadius.circular(10.r),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  entry.value.isEmpty
                                      ? 'غير محدد'
                                      : entry.value,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.map_outlined,
                                size: 16.sp,
                                color: primary,
                              ),
                            ],
                          ),
                        )
                      : Text(
                          entry.value.isEmpty ? 'غير محدد' : entry.value,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.right,
                        ),
                ),
                SizedBox(width: 10.w),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 120.w),
                  child: Text(
                    entry.title,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      color: theme.textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAttachmentsSection(
    BuildContext context,
    LicenseDetailModel detail,
    Color primary,
    Color onSurface, {
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    final theme = Theme.of(context);
    final borderColor = context.themeBorder;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: onToggle,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'المرفقات',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'اضغط لعرض التفاصيل',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.sp,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '${detail.latest_attachments.length}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Padding(
              padding: EdgeInsets.only(top: 14.h),
              child: detail.latest_attachments.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 24.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.folder_open_outlined,
                            size: 40.sp,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'لا توجد مرفقات',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13.sp,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 0.84,
                      children: detail.latest_attachments.map((attachment) {
                        return _buildAttachmentCard(
                          context,
                          attachment,
                          primary,
                        );
                      }).toList(),
                    ),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentCard(
    BuildContext context,
    AttachmentItem attachment,
    Color primary,
  ) {
    final theme = Theme.of(context);
    final icon = attachment.isPdf
        ? Icons.picture_as_pdf_outlined
        : attachment.isImage
        ? Icons.image_outlined
        : Icons.insert_drive_file_outlined;
    final previewUrl = attachment.isImage
        ? attachment.resolveUrl(baseUrl: CoreApiService.baseUrlPublicImages)
        : null;
    final subtitle = attachment.fileName != attachment.displayName
        ? attachment.fileName
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => _openAttachment(context, attachment),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: primary.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      attachment.isPdf
                          ? 'PDF'
                          : attachment.isImage
                          ? 'صورة'
                          : 'ملف',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                  ),
                  Icon(icon, size: 20.sp, color: primary),
                ],
              ),
              SizedBox(height: 8.h),
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  alignment: Alignment.center,
                  child: previewUrl != null && previewUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14.r),
                          child: Image.network(
                            previewUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            headers: {'Accept': 'image/*'},
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(icon, size: 40.sp, color: primary);
                            },
                          ),
                        )
                      : Icon(icon, size: 40.sp, color: primary),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                attachment.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.right,
              ),
              if (subtitle != null) ...[
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.sp,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'فتح',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.open_in_new, size: 14.sp, color: primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAttachment(
    BuildContext context,
    AttachmentItem attachment,
  ) async {
    if (attachment.hasFilePath && attachment.isPdf) {
      final path = await _prepareLocalFile(attachment);

      if (path != null) {
        Get.to(() => TermsPdfViewerScreen(pdfPath: path));
      } else {
        Get.snackbar('تنبيه', 'تعذر تحميل الملف أو الرابط غير متاح حالياً.');
      }
      return;
    }

    if (attachment.hasFilePath && attachment.isImage) {
      final imageUrl = attachment.resolveUrl(
        baseUrl: CoreApiService.baseUrlPublicImages,
      );
      if (imageUrl != null && imageUrl.isNotEmpty) {
        _showImagePreview(context, attachment, imageUrl);
      }
      return;
      //
    }

    if (attachment.hasFilePath && attachment.isRemoteUrl) {
      final uri = Uri.tryParse(attachment.normalizedFilePath);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
        return;
      }
    }

    if (attachment.hasFilePath && attachment.isLocalPath) {
      final file = File(attachment.normalizedFilePath);
      if (await file.exists()) {
        await OpenFilex.open(file.path);
        return;
      }
    }

    Get.snackbar('تنبيه', 'لا يمكن فتح هذا النوع من الملفات حالياً.');
  }

  Future<String?> _prepareLocalFile(AttachmentItem attachment) async {
    if (!attachment.hasFilePath) return null;

    if (attachment.isLocalPath) {
      final file = File(attachment.normalizedFilePath);
      if (await file.exists()) {
        return file.path;
      }
    }

    final resolvedUrl = attachment.resolveUrl(
      baseUrl: CoreApiService.baseUrlPublicImages,
    );
    if (resolvedUrl == null || resolvedUrl.isEmpty) return null;

    final uri = Uri.tryParse(resolvedUrl);
    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return null;
    }

    try {
      final request = await HttpClient().getUrl(uri);
      final response = await request.close();
      if (response.statusCode != 200) return null;

      final bytes = await consolidateHttpClientResponseBytes(response);
      final dir = await getTemporaryDirectory();
      final originalName = attachment.fileName;
      final extension = originalName.contains('.')
          ? '.${originalName.split('.').last}'
          : '';
      final baseName = originalName.contains('.')
          ? originalName.substring(0, originalName.lastIndexOf('.'))
          : originalName;
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = '$baseName-$timestamp$extension';
      final target = File('${dir.path}/$fileName');
      await target.writeAsBytes(bytes, flush: true);
      return target.path;
    } on SocketException catch (error) {
      debugPrint('Attachment download failed: $error');
      return null;
    } on HttpException catch (error) {
      debugPrint('Attachment download failed: $error');
      return null;
    } catch (error) {
      debugPrint('Attachment download failed: $error');
      return null;
    }
  }

  void _showImagePreview(
    BuildContext context,
    AttachmentItem attachment,
    String imageUrl,
  ) {
    // Open a full-screen viewer with pinch-to-zoom and pan support.
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FullscreenImageViewer(
          title: attachment.fileName,
          imageUrl: imageUrl,
          isLocal: attachment.isLocalPath,
          localPath: attachment.isLocalPath
              ? attachment.normalizedFilePath
              : null,
        ),
      ),
    );
  }

  Widget _buildTimelineSection(
    BuildContext context,
    LicenseDetailModel detail,
    Color primary,
    Color secondary, {
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    final theme = Theme.of(context);
    final borderColor = context.themeBorder;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: onToggle,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'خطوات الطلب',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'اضغط لعرض التفاصيل',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.sp,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.checklist_rtl_outlined,
                      color: primary,
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Column(
                children: detail.stepSummary.map((step) {
                  final index = detail.stepSummary.indexOf(step) + 1;
                  final isLast = index == detail.stepSummary.length;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 36.w,
                              height: 36.w,
                              decoration: BoxDecoration(
                                color: primary,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$index',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (!isLast)
                              SizedBox(
                                height: 12.h,
                                child: Center(
                                  child: Container(
                                    width: 2.w,
                                    height: 12.h,
                                    color: primary.withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              step,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13.sp,
                                color: secondary,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Color primary) {
    final ctrl = Get.find<LicenseApplicationController>();

    return Wrap(
      spacing: 12.w,
      runSpacing: 10.h,
      alignment: WrapAlignment.end,
      children: [
        if (detail!.application.needsCorrection)
          ElevatedButton.icon(
            onPressed: () async {
              await ctrl.prepareForCorrection(detail!.application);
              Get.toNamed(AppRoutes.licenseApplication);
            },
            icon: ThemedIcon(
              Icons.edit_outlined,
              type: IconType.button,
              customSize: 16.sp,
            ),
            label: Text('تعديل الطلب', style: TextStyle(fontSize: 12.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        // OutlinedButton.icon(
        //   onPressed: () {},
        //   icon: ThemedIcon(
        //     Icons.share_outlined,
        //     type: IconType.normal,
        //     customSize: 16.sp,
        //   ),
        //   label: Text('مشاركة', style: TextStyle(fontSize: 12.sp)),
        //   style: OutlinedButton.styleFrom(
        //     foregroundColor: primary,
        //     side: BorderSide(color: primary),
        //     padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(12.r),
        //     ),
        //   ),
        // ),
        ElevatedButton.icon(
          onPressed: () async {
            Get.snackbar(
              'تحميل',
              'جاري تحضير ملف PDF...',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: primary,
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
              borderRadius: 8,
              duration: const Duration(seconds: 2),
            );
            try {
              await _exportApplicationPdf();
            } catch (error, stackTrace) {
              debugPrint('❌ PDF ERROR: $error');
              debugPrint('❌ STACK: $stackTrace');
              Get.snackbar(
                'خطأ',
                'تعذر إنشاء ملف PDF. يرجى المحاولة لاحقاً.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.error,
                colorText: Colors.white,
              );
            }
          },
          icon: ThemedIcon(
            Icons.picture_as_pdf_outlined,
            type: IconType.button,
            customSize: 16.sp,
          ),
          label: Text('تحميل PDF', style: TextStyle(fontSize: 12.sp)),
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'pending':
      case 'in_review':
      case 'under_review':
        return AppColors.warning;
      case 'completed':
        return AppColors.statusCompleted;
      case 'draft':
        return AppColors.info;
      case 'cancelled':
        return AppColors.statusCancelled;
      default:
        return AppColors.primary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'pending':
      case 'in_review':
      case 'under_review':
        return Icons.schedule_outlined;
      case 'completed':
        return Icons.done_all_outlined;
      case 'draft':
        return Icons.edit_outlined;
      case 'cancelled':
        return Icons.block_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _correctionTargetLabel(String target) {
    switch (target) {
      case 'contactInfo':
        return 'بيانات التواصل';
      case 'termsContact':
        return 'الموافقة على الشروط';
      case 'licenseDetails':
        return 'تفاصيل الترخيص';
      case 'settlementDetails':
        return 'بيانات التسوية';
      case 'applicantInfo':
        return 'معلومات مقدم الطلب';
      case 'identityDocument':
        return 'وثائق الهوية';
      case 'currentLocation':
        return 'موقع المحطة';
      case 'locationClassification':
        return 'تصنيف الموقع';
      case 'surveyPlan':
        return 'المخطط المساحي';
      case 'propertyRecord':
        return 'سند الملكية';
      case 'validLicenseDocument':
        return 'الرخصة السارية';
      case 'leaseContract':
        return 'عقد الإيجار';
      case 'commercialRegister':
        return 'السجل التجاري';
      case 'investmentContract':
        return 'عقد الاستثمار';
      default:
        return target.replaceAll('_', ' ');
    }
  }
}

class _InfoEntry {
  const _InfoEntry(this.title, this.value, {this.onTap});

  final String title;
  final String value;
  final VoidCallback? onTap;
}
