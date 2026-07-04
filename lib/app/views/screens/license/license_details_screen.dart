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
import '../../../controllers/settings_controller.dart';
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
        appBar: _buildAppBar(context, detail!),
        body: Stack(
          children: [
            // خلفية احترافية
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primary.withValues(alpha: 0.08),
                      primary.withValues(alpha: 0.02),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                      child: _buildInfoGrid(context, [
                        _InfoEntry(
                          'رقم الطلب',
                          detail!.application.applicationNumber,
                        ),
                        _InfoEntry('نوع الطلب', detail!.requestTypeLabel),
                        _InfoEntry('نوع المستثمر', detail!.investorTypeLabel),
                        _InfoEntry(
                          'تاريخ الإنشاء',
                          detail!.application.createdAt,
                        ),
                      ]),
                    ),
                    SizedBox(height: 18.h),
                    _buildSectionCard(
                      context,
                      title: 'بيانات مقدم الطلب',
                      icon: Icons.person_outline,
                      child: _buildInfoCard(context, [
                        _InfoEntry('اسم مقدم الطلب', detail!.applicantName),
                        _InfoEntry('البريد الإلكتروني', detail!.email),
                        _InfoEntry('الهاتف', detail!.phone),
                        _InfoEntry('الهوية الوطنية', detail!.nationalId),
                      ]),
                    ),
                    SizedBox(height: 18.h),
                    _buildSectionCard(
                      context,
                      title: 'تفاصيل الموقع والمحطة',
                      icon: Icons.location_on_outlined,
                      child: _buildInfoCard(context, [
                        _InfoEntry('المحافظة', detail!.governorate),
                        _InfoEntry('المنطقة / الحي', detail!.district),
                        _InfoEntry('اسم المحطة', detail!.stationName),
                        _InfoEntry('فئة المحطة', detail!.stationCategory),
                        _InfoEntry('نوع الطريق', detail!.roadType),
                        _InfoEntry('الموقع التخطيطي', detail!.planningLocation),
                        _InfoEntry('الإحداثيات', detail!.coordinates),
                      ]),
                    ),
                    SizedBox(height: 18.h),
                    _buildAttachmentsSection(
                      context,
                      detail!,
                      primary,
                      onSurface,
                    ),
                    SizedBox(height: 18.h),
                    _buildTimelineSection(context, detail!, primary, secondary),
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
        leading: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: theme.colorScheme.primary,
              size: 20.sp,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
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
        centerTitle: false,
        toolbarHeight: 70.h,
        actions: [
          Obx(() {
            final settingsCtrl = Get.find<SettingsController>();
            final isDark = settingsCtrl.isDark;
            return IconButton(
              onPressed: () => settingsCtrl.toggleTheme(),
              tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
              icon: ThemedIcon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                type: IconType.appBar,
                customSize: 20.sp,
              ),
            );
          }),
        ],
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
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: borderColor.withValues(alpha: 0.3),
                  width: 1.2,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context, List<_InfoEntry> items) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 14.w,
        mainAxisSpacing: 14.h,
      ),
      itemBuilder: (context, index) {
        final entry = items[index];
        return _buildInfoTile(entry.title, entry.value, context);
      },
    );
  }

  Widget _buildInfoCard(BuildContext context, List<_InfoEntry> items) {
    final borderColor = context.themeBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(items.length, (index) {
        final entry = items[index];
        final isLast = index == items.length - 1;
        return Column(
          children: [
            _buildInfoRow(entry.title, entry.value, context),
            if (!isLast)
              Padding(
                padding: EdgeInsets.only(top: 14.h, bottom: 14.h),
                child: Container(
                  height: 1.h,
                  color: borderColor.withValues(alpha: 0.2),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoTile(String title, String value, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.themeBorder.withValues(alpha: 0.3)),
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
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value.isEmpty ? 'غير محدد' : value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.themeBorder.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              value.isEmpty ? 'غير محدد' : value,
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
          Flexible(
            child: Text(
              title,
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
  }

  Widget _buildAttachmentsSection(
    BuildContext context,
    LicenseDetailModel detail,
    Color primary,
    Color onSurface,
  ) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${detail.attachments.length}',
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
          SizedBox(height: 14.h),
          if (detail.attachments.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.h),
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
          else
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
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: primary.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20.sp, color: primary),
            SizedBox(width: 10.w),
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
            SizedBox(width: 6.w),
            ThemedIcon(
              Icons.download_outlined,
              type: IconType.normal,
              customSize: 16.sp,
              customColor: primary,
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
                        icon: const ThemedIcon(
                          Icons.close,
                          type: IconType.normal,
                        ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
          SizedBox(height: 16.h),
          ...detail.stepSummary.map((step) {
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
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Color primary) {
    return Wrap(
      spacing: 12.w,
      runSpacing: 10.h,
      alignment: WrapAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: ThemedIcon(
            Icons.share_outlined,
            type: IconType.normal,
            customSize: 16.sp,
          ),
          label: Text('مشاركة', style: TextStyle(fontSize: 12.sp)),
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: BorderSide(color: primary),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: ThemedIcon(
            Icons.print_outlined,
            type: IconType.button,
            customSize: 16.sp,
          ),
          label: Text('طباعة التقرير', style: TextStyle(fontSize: 12.sp)),
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
}

class _InfoEntry {
  const _InfoEntry(this.title, this.value);

  final String title;
  final String value;
}
