import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:licences_application/app/views/screens/terms_pdf_viewer_screen.dart';
import 'package:licences_application/core/services/core_api_service.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_theme.dart';
import '../../../models/application_model.dart';
import '../../../models/license_detail_model.dart';
import '../../../../core/constant/app_constants.dart';

class LicenseDetailsScreen extends StatefulWidget {
  const LicenseDetailsScreen({super.key});

  @override
  State<LicenseDetailsScreen> createState() => _LicenseDetailsScreenState();
}

class _LicenseDetailsScreenState extends State<LicenseDetailsScreen> {
  LicenseDetailModel? detail;

  @override
  void initState() {
    super.initState();
    detail = Get.arguments as LicenseDetailModel?;
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

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'تفاصيل الطلب',
            style: TextStyle(color: Colors.black, fontSize: 20.sp),
          ),
          centerTitle: true,
          backgroundColor: surface,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusOverview(context, detail!, surface, borderColor),
                SizedBox(height: 16.h),
                _buildSectionTitle('الملخص العام'),
                SizedBox(height: 12.h),
                _buildInfoGrid(context, [
                  _InfoEntry(
                    'رقم الطلب',
                    detail!.application.applicationNumber,
                  ),
                  _InfoEntry('نوع الطلب', detail!.requestTypeLabel),
                  _InfoEntry('نوع المستثمر', detail!.investorTypeLabel),
                  _InfoEntry('تاريخ الإنشاء', detail!.application.createdAt),
                ]),
                SizedBox(height: 18.h),
                _buildSectionTitle('بيانات مقدم الطلب'),
                SizedBox(height: 12.h),
                _buildInfoCard(context, [
                  _InfoEntry('اسم مقدم الطلب', detail!.applicantName),
                  _InfoEntry('البريد الإلكتروني', detail!.email),
                  _InfoEntry('الهاتف', detail!.phone),
                  _InfoEntry('الهوية الوطنية', detail!.nationalId),
                ]),
                SizedBox(height: 18.h),
                _buildSectionTitle('تفاصيل الموقع والمحطة'),
                SizedBox(height: 12.h),
                _buildInfoCard(context, [
                  _InfoEntry('المحافظة', detail!.governorate),
                  _InfoEntry('المنطقة / الحي', detail!.district),
                  _InfoEntry('اسم المحطة', detail!.stationName),
                  _InfoEntry('فئة المحطة', detail!.stationCategory),
                  //
                  _InfoEntry('نوع الطريق', detail!.roadType),
                  _InfoEntry('الموقع التخطيطي', detail!.planningLocation),
                  _InfoEntry('الإحداثيات', detail!.coordinates),
                ]),
                SizedBox(height: 18.h),
                _buildAttachmentsSection(context, detail!, primary, onSurface),

                SizedBox(height: 18.h),
                _buildTimelineSection(context, detail!, primary, secondary),
                SizedBox(height: 24.h),
                _buildActionButtons(context, primary),
              ],
            ),
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

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
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
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      detail.application.governorate ?? 'المحافظة غير محددة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.sp,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Text(
                  detail.application.statusLabel,
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
          SizedBox(height: 16.h),
          Text(
            detail.statusNote,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              color: theme.textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: TextDirection.rtl,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          width: 42.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(BuildContext context, List<_InfoEntry> items) {
    final theme = Theme.of(context);
    final borderColor = context.themeBorder;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: borderColor),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.h),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 24.h,
        ),
        itemBuilder: (context, index) {
          final entry = items[index];
          return _buildInfoTile(entry.title, entry.value, context);
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<_InfoEntry> items) {
    final theme = Theme.of(context);
    final borderColor = context.themeBorder;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: borderColor),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: items
            .map(
              (entry) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildInfoRow(entry.title, entry.value, context),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(width: 10.w),
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              color: theme.textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection(
    BuildContext context,
    LicenseDetailModel detail,
    Color primary,
    Color onSurface,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: context.themeBorder),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Text(
                '${detail.attachments.length} مرفق',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (detail.attachments.isEmpty)
            Text(
              'لا توجد مرفقات للعرض.',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                color: theme.textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.right,
            )
          else
            // Container(),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: detail.attachments.map((attachment) {
                return _buildAttachmentChip(context, attachment, primary);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAttachmentChip(
    BuildContext context,
    AttachmentItem attachment,
    Color primary,
  ) {
    final theme = Theme.of(context);
    final icon = attachment.isPdf
        ? Icons.picture_as_pdf
        : attachment.isImage
        ? Icons.image_outlined
        : Icons.insert_drive_file_outlined;

    return GestureDetector(
      onTap: () => _openAttachment(context, attachment),
      child: Container(
        constraints: BoxConstraints(maxWidth: 390.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: primary.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18.sp, color: primary),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                attachment.fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
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
        print("pathhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh +${path.toString()}");
        Get.to(
          () => TermsPdfViewerScreen(
            pdfPath: CoreApiService.baseUrlPublicImages + path,
          ),
        );
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

    final resolvedUrl = attachment.resolveUrl(baseUrl: AppConstants.baseUrl);
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
      final fileName = attachment.fileName;
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
    print("imageUrl: ${imageUrl.toString()}");

    showDialog(
      context: context,
      builder: (context) {
        final imageWidget = attachment.isLocalPath
            ? Image.file(
                File(attachment.normalizedFilePath),
                fit: BoxFit.contain,
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.contain,
                headers: {'Accept': 'image/*'},
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 48.sp,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'تعذر تحميل الصورة.\nقد تكون الرابط غير صالح أو غير متاح الآن.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 32.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 560.h, maxWidth: 360.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          attachment.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    child: imageWidget,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineSection(
    BuildContext context,
    LicenseDetailModel detail,
    Color primary,
    Color secondary,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: context.themeBorder),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'خطوات الطلب',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 14.h),
          ...detail.stepSummary.map((step) {
            final index = detail.stepSummary.indexOf(step) + 1;
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$index',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.sp,
                        color: secondary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Color primary) {
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 12.w,
        runSpacing: 8.h,
        alignment: WrapAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text('مشاركة'),
            style: OutlinedButton.styleFrom(
              foregroundColor: primary,
              side: BorderSide(color: primary.withValues(alpha: 0.7)),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.print),
            label: const Text('طباعة التقرير'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoEntry {
  const _InfoEntry(this.title, this.value);

  final String title;
  final String value;
}
