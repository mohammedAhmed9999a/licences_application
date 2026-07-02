import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

Future<File?> compressImage(File file) async {
  final dir = await getTemporaryDirectory();
  final targetPath =
      '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 85,
    minWidth: 1280,
    minHeight: 1280,
  );

  if (result == null) return null;
  return File(result.path);
}
