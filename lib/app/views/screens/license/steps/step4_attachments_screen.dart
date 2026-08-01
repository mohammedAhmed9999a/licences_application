import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../../controllers/license_application_controller.dart';
import '../../terms_pdf_viewer_screen.dart';

class Step4AttachmentsScreen extends StatelessWidget {
  const Step4AttachmentsScreen({super.key});
  //
  //

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LicenseApplicationController>();

    return SingleChildScrollView(
      child: Column(
        // textDirection: TextDirection.rtl,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: Row(
              textDirection: TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Remaining count badge
                Obx(() {
                  final requiredAttachments = ctrl
                      .getRequiredAttachments()
                      .where((attachment) => attachment.isRequired)
                      .toList();
                  final remaining = requiredAttachments
                      .where(
                        (attachment) =>
                            !ctrl.isAttachmentUploaded(attachment.key),
                      )
                      .length;
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: remaining > 0
                          ? AppColors.warning.withOpacity(0.1)
                          : AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: remaining > 0
                            ? AppColors.warning.withOpacity(0.3)
                            : AppColors.success.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      remaining > 0
                          ? '$remaining مرفقات متبقية'
                          : 'جميع المرفقات مكتملة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        color: remaining > 0
                            ? AppColors.warning
                            : AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    // textDirection: TextDirection.rtl,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المرفقات ومراجعة الطلب',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ارفع المرفقات المطلوبة، ثم راجع ملخص الطلب قبل الإرسال.',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Attachments Section ──────────────────────────────────────
          Obx(() {
            final requiredAttachments = ctrl.getRequiredAttachments();
            return SectionCard(
              title: 'المرفقات',
              stepNumber: 1,
              child: Column(
                children: [
                  for (var i = 0; i < requiredAttachments.length; i++) ...[
                    AttachmentCard(
                      title: requiredAttachments[i].title,
                      description: _buildAttachmentDescription(
                        requiredAttachments[i].key,
                      ),
                      required: requiredAttachments[i].isRequired,
                      statusText: _buildAttachmentStatusText(
                        requiredAttachments[i].key,
                      ),
                      enabled: ctrl.isAttachmentEditable(
                        requiredAttachments[i].key,
                      ),
                      uploaded: ctrl.isAttachmentUploaded(
                        requiredAttachments[i].key,
                      ),
                      fileName: ctrl.getAttachmentFileName(
                        requiredAttachments[i].key,
                      ),
                      fileSize: ctrl.getAttachmentFileSize(
                        requiredAttachments[i].key,
                      ),
                      onUpload:
                          ctrl.isAttachmentEditable(requiredAttachments[i].key)
                          ? () => _pickFile(ctrl, requiredAttachments[i].key)
                          : null,
                      onView:
                          ctrl.isAttachmentUploaded(requiredAttachments[i].key)
                          ? () => _openFile(
                              ctrl.getAttachmentFile(
                                requiredAttachments[i].key,
                              ),
                            )
                          : null,
                      onRemove:
                          ctrl.isAttachmentEditable(requiredAttachments[i].key)
                          ? () =>
                                ctrl.clearAttachment(requiredAttachments[i].key)
                          : null,
                    ),
                    if (i < requiredAttachments.length - 1)
                      SizedBox(height: 12.h),
                  ],
                ],
              ),
            );
          }),

          // ─── Summary Section ──────────────────────────────────────────
          SectionCard(
            title: 'ملخص الطلب',
            subtitle: 'مراجعة قبل الإرسال',
            stepNumber: 2,
            child: _buildSummary(ctrl),
          ),

          // Error
          Obx(() => ErrorBanner(message: ctrl.errorMessage.value)),

          // Submit Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Obx(
                  () => PrimaryButton(
                    label: 'إرسال الطلب',
                    isLoading: ctrl.isLoading.value,
                    onPressed: ctrl.submitFinal,
                  ),
                ),
                SizedBox(height: 10.h),
                OutlinedButton(
                  onPressed: ctrl.goToPreviousStep,
                  child: const Text('السابق'),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),
          Text(
            'وزارة الطاقة © 2026',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              color: AppColors.textHint,
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  String _buildAttachmentDescription(String attachmentKey) {
    return 'PDF أو صورة - حتى 4MB';
  }

  // ─── Utility Methods ──────────────────────────────────────────────
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  Future<File?> _compressImage(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();

      if (!['jpg', 'jpeg', 'png'].contains(extension)) {
        return imageFile; // Return original if not a compressible format
      }

      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.$extension';

      XFile? result;

      if (extension == 'png') {
        result = await FlutterImageCompress.compressAndGetFile(
          imageFile.path,
          targetPath,
          quality: 80,
          format: CompressFormat.png,
        );
      } else {
        result = await FlutterImageCompress.compressAndGetFile(
          imageFile.path,
          targetPath,
          quality: 80,
          format: CompressFormat.jpeg,
        );
      }

      if (result != null) {
        return File(result.path);
      }
      return imageFile;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء ضغط الصورة: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.8),
      );
      return imageFile;
    }
  }

  void _showFileSizeWarning(String fileName, int fileSize) {
    final fileSizeString = _formatFileSize(fileSize);
    Get.snackbar(
      'تحذير: حجم الملف كبير',
      'حجم الملف ($fileSizeString) أكبر من 4 MB - جاري ضغط الصورة تلقائياً',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.warning.withOpacity(0.8),
      duration: const Duration(seconds: 3),
    );
  }

  String? _buildAttachmentStatusText(String attachmentKey) {
    switch (attachmentKey) {
      case 'lease_contract':
        return 'مطلوب عند الاستئجار';
      case 'commercial_register':
      case 'investment_contract':
        return 'اختياري';
      default:
        return null;
    }
  }

  Widget _buildSummary(LicenseApplicationController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _SummaryRow(
          label: 'نوع الطلب',
          value: ctrl.requestType.value == 'new' ? 'جديد' : 'تسوية',
        ),
        _SummaryRow(
          label: 'نوع المستثمر',
          value: ctrl.investorType.value == 'individual'
              ? 'مستثمر فردي'
              : 'شركة',
        ),
        if (ctrl.investorType.value == 'individual') ...[
          _SummaryRow(label: 'الاسم', value: ctrl.getApplicantFullName()),
          _SummaryRow(
            label: 'الرقم الوطني',
            value: ctrl.nationalIdController.text,
          ),
        ] else ...[
          _SummaryRow(
            label: 'اسم الشركة',
            value: ctrl.companyNameController.text,
          ),
        ],
        _SummaryRow(
          label: 'المحافظة',
          value: ctrl.selectedGovernorate.value?.name ?? 'غير محدد',
        ),
        _SummaryRow(
          label: 'موقع المحطة',
          value: ctrl.planningLocation.value == 'inside'
              ? 'داخل التنظيم'
              : 'خارج التنظيم',
        ),
        _SummaryRow(
          label: 'فئة المحطة',
          value: 'الفئة ${ctrl.stationCategory.value}',
        ),
        _SummaryRow(
          label: 'البريد الإلكتروني',
          value: ctrl.emailController.text,
        ),
        _SummaryRow(
          label: 'رقم التواصل',
          value: ctrl.phoneController.text,
          isLast: true,
        ),
      ],
    );
  }

  Future<void> _pickFile(LicenseApplicationController ctrl, String type) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      var file = File(result.files.single.path!);
      final fileSize = file.lengthSync();
      final fileName = result.files.single.name;
      final fileSizeString = _formatFileSize(fileSize);
      final fileSizeInMB = fileSize / (1024 * 1024);

      // Show file size info
      Get.snackbar(
        'معلومات الملف',
        'اسم الملف: $fileName\nالحجم: $fileSizeString',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      // Check if file is larger than 4 MB
      if (fileSizeInMB > 4) {
        _showFileSizeWarning(fileName, fileSize);

        // Compress image if it's an image file
        final extension = fileName.split('.').last.toLowerCase();
        if (['jpg', 'jpeg', 'png'].contains(extension)) {
          bool dialogOpen = false;
          try {
            // Show loading dialog
            Get.dialog(
              AlertDialog(
                title: Text(
                  'جاري ضغط الصورة...',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(height: 16.h),
                    Text(
                      'يرجى الانتظار',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
              barrierDismissible: false,
            );
            dialogOpen = true;

            // Compress the image
            final compressedFile = await _compressImage(file);

            // Close loading dialog
            if (dialogOpen) {
              Navigator.of(Get.context!).pop();
              dialogOpen = false;
            }

            if (compressedFile != null) {
              file = compressedFile;
              final compressedSize = file.lengthSync();
              final compressedSizeString = _formatFileSize(compressedSize);
              final compressionRatio = ((1 - (compressedSize / fileSize)) * 100)
                  .toStringAsFixed(1);

              // Show compression result
              Get.snackbar(
                'تم ضغط الصورة بنجاح',
                'الحجم الأصلي: $fileSizeString\nالحجم بعد الضغط: $compressedSizeString\nمعدل الضغط: $compressionRatio%',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 4),
              );
            } else {
              Get.snackbar(
                'خطأ',
                'فشل ضغط الصورة',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.error.withOpacity(0.8),
              );
              return;
            }
          } catch (e) {
            // Close loading dialog if still open
            if (dialogOpen) {
              try {
                Navigator.of(Get.context!).pop();
              } catch (_) {}
            }
            Get.snackbar(
              'خطأ',
              'حدث خطأ أثناء ضغط الصورة',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.error.withOpacity(0.8),
            );
            return;
          }
        } else {
          // PDF files cannot be compressed, show message
          Get.snackbar(
            'تنبيه',
            'لا يمكن ضغط ملفات PDF. يرجى اختيار ملف أصغر حجماً.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.warning.withOpacity(0.8),
            duration: const Duration(seconds: 3),
          );
          return;
        }
      }

      ctrl.setAttachmentFile(type, file);
    }
  }

  Future<void> _openFile(File? file) async {
    if (file == null) {
      Get.snackbar('خطأ', 'لا يوجد ملف لعرضه.');
      return;
    }

    if (!file.existsSync()) {
      Get.snackbar('خطأ', 'تعذر العثور على الملف.');
      return;
    }

    final extension = file.path.split('.').last.toLowerCase();
    if (extension == 'pdf') {
      Get.to(() => TermsPdfViewerScreen(pdfPath: file.path));
    } else if ([
      'png',
      'jpg',
      'jpeg',
      'webp',
      'bmp',
      'gif',
    ].contains(extension)) {
      Get.to(() => _ImagePreviewScreen(filePath: file.path));
    } else {
      Get.snackbar('خطأ', 'هذا النوع من الملفات غير مدعوم للعرض داخل التطبيق.');
    }
  }
}

class _ImagePreviewScreen extends StatelessWidget {
  final String filePath;

  const _ImagePreviewScreen({required this.filePath});

  @override
  Widget build(BuildContext context) {
    final file = File(filePath);
    final fileName = file.uri.pathSegments.isNotEmpty
        ? file.uri.pathSegments.last
        : 'image';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          fileName,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: InteractiveViewer(
            maxScale: 4.0,
            minScale: 1.0,
            child: Image.file(
              file,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      size: 64.sp,
                      color: Colors.white70,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'تعذر تحميل الصورة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: const Color.fromARGB(179, 213, 207, 207),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final valueColor = isDark ? AppColors.darkText : AppColors.textPrimary;
    final labelColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.borderLight;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            textDirection: TextDirection.ltr,
            children: [
              Flexible(
                child: Text(
                  value.isEmpty ? '-' : value,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    color: valueColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1.h, color: dividerColor),
      ],
    );
  }
}
