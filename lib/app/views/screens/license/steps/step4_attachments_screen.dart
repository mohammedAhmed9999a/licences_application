import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../../controllers/license_application_controller.dart';
import '../../terms_pdf_viewer_screen.dart';

class Step4AttachmentsScreen extends StatelessWidget {
  const Step4AttachmentsScreen({super.key});

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
                  final requiredAttachments = ctrl.getRequiredAttachments();
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
                      description: 'PDF أو صورة - حتى 4MB',
                      required: true,
                      uploaded: ctrl.isAttachmentUploaded(
                        requiredAttachments[i].key,
                      ),
                      fileName: ctrl.getAttachmentFileName(
                        requiredAttachments[i].key,
                      ),
                      onUpload: () =>
                          _pickFile(ctrl, requiredAttachments[i].key),
                      onView: () => _openFile(
                        ctrl.getAttachmentFile(requiredAttachments[i].key),
                      ),
                      onRemove: () =>
                          ctrl.clearAttachment(requiredAttachments[i].key),
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
          _SummaryRow(
            label: 'الاسم',
            value:
                '${ctrl.firstNameController.text} ${ctrl.fatherNameController.text} ${ctrl.lastNameController.text}',
          ),
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
      final file = File(result.files.single.path!);
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

    Get.to(() => TermsPdfViewerScreen(pdfPath: file.path));
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
                    color: AppColors.textPrimary,
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
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1.h, color: AppColors.borderLight),
      ],
    );
  }
}
