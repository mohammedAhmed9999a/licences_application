import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:licences_application/core/constant/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class TermsPdfViewerScreen extends StatefulWidget {
  final String? pdfPath;

  const TermsPdfViewerScreen({super.key, this.pdfPath});

  @override
  State<TermsPdfViewerScreen> createState() => _TermsPdfViewerScreenState();
}

class _TermsPdfViewerScreenState extends State<TermsPdfViewerScreen> {
  String? displayPdfPath;
  final String? pdfAssetPath = 'assets/file/terms.pdf';
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _preparePdf();
  }

  Future<void> _preparePdf() async {
    try {
      final pdfInput = widget.pdfPath?.trim();
      if (pdfInput != null && pdfInput.isNotEmpty) {
        if (pdfInput.startsWith('http://') || pdfInput.startsWith('https://')) {
          final downloadedPath = await _downloadPdfFromUrl(pdfInput);
          if (downloadedPath != null) {
            displayPdfPath = downloadedPath;
          }
        } else if (pdfInput.startsWith('file://')) {
          final fileUri = Uri.tryParse(pdfInput);
          if (fileUri != null) {
            final file = File(fileUri.toFilePath());
            if (await file.exists()) {
              displayPdfPath = file.path;
            }
          }
        } else if (File(pdfInput).existsSync()) {
          displayPdfPath = pdfInput;
        }
      }

      if (displayPdfPath == null) {
        final byteData = await rootBundle.load(pdfAssetPath!);
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/terms.pdf');
        await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
        displayPdfPath = file.path;
      }

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'تعذر تحميل الملف. يرجى المحاولة مرة أخرى.';
        isLoading = false;
      });
    }
  }

  Future<String?> _downloadPdfFromUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return null;
    }

    try {
      final request = await HttpClient().getUrl(uri);
      final response = await request.close();
      if (response.statusCode != 200) return null;

      final bytes = await consolidateHttpClientResponseBytes(response);
      final dir = await getTemporaryDirectory();
      final originalName = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : 'document.pdf';
      final target = File('${dir.path}/$originalName');
      await target.writeAsBytes(bytes, flush: true);
      return target.path;
    } catch (e) {
      debugPrint('PDF download failed: $e');
      return null;
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid) return true;
    if (await Permission.manageExternalStorage.isGranted) return true;
    if (await Permission.storage.isGranted) return true;

    final storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) return true;

    final manageStatus = await Permission.manageExternalStorage.request();
    return manageStatus.isGranted;
  }

  Future<void> _downloadPdf() async {
    if (displayPdfPath == null) return;

    try {
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'يرجى منح التطبيق إذن الوصول للتخزين ليتم حفظ الملف في التنزيلات.',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        );
        return;
      }

      final sourceFile = File(displayPdfPath!);
      final bytes = await sourceFile.readAsBytes();
      final originalName = displayPdfPath!.split('/').last;
      final extension = originalName.contains('.')
          ? '.${originalName.split('.').last}'
          : '';
      final baseName = originalName.contains('.')
          ? originalName.substring(0, originalName.lastIndexOf('.'))
          : originalName;
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = '$baseName-$timestamp$extension';
      final targetDir = Platform.isAndroid
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final targetPath = '${targetDir.path}/$fileName';
      final downloadFile = File(targetPath);
      await downloadFile.writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تنزيل الملف إلى $targetPath',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر حفظ الملف، يرجى المحاولة لاحقاً',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.borderDark,
        title: Text(
          widget.pdfPath != null ? 'عرض ملف PDF' : 'الشروط والأحكام',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp),
        ),
        actions: [
          IconButton(
            onPressed: displayPdfPath == null ? null : _downloadPdf,
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: isLoading
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [ShimmerLoadingCard(height: 200)],
              ),
            )
          : errorMessage != null
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
                ),
              ),
            )
          : Column(
              children: [
                // Container(
                //   width: double.infinity,
                //   padding: EdgeInsets.symmetric(
                //     horizontal: 14.w,
                //     vertical: 8.h,
                //   ),
                //   color: Colors.grey.shade100,
                //   child: Text(
                //     'المسار الداخلي: ${displayPdfPath ?? pdfAssetPath}',
                //     style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp),
                //     textDirection: TextDirection.rtl,
                //   ),
                // ),
                Expanded(
                  child: PDFView(
                    filePath: displayPdfPath,
                    enableSwipe: true,
                    swipeHorizontal: false,
                    autoSpacing: true,
                    pageFling: true,
                    onError: (error) {
                      if (!mounted) return;
                      setState(() {
                        errorMessage = 'تعذر عرض الملف داخل التطبيق.';
                      });
                    },
                    onPageError: (page, error) {
                      if (!mounted) return;
                      setState(() {
                        errorMessage = 'حدث خطأ أثناء فتح الصفحة $page.';
                      });
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
