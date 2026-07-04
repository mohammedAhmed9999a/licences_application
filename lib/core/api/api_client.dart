import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'dio_factory.dart';
import '../class/api_result.dart';

class ApiClient {
  ApiClient._();

  static Future<ApiResult> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      final res = await dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
      );
      return _handle(res);
    } on DioException catch (e) {
      return _fromDioException(e);
    } catch (e) {
      return ApiResult.failure('unexpected_error'.tr);
    }
  }

  static Future<ApiResult> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      final res = await dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handle(res);
    } on DioException catch (e) {
      return _fromDioException(e);
    } catch (e) {
      return ApiResult.failure('unexpected_error'.tr);
    }
  }

  static Future<ApiResult> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      final res = await dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handle(res);
    } on DioException catch (e) {
      return _fromDioException(e);
    } catch (e) {
      return ApiResult.failure('unexpected_error'.tr);
    }
  }

  static Future<ApiResult> delete(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      final res = await dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
      );
      return _handle(res);
    } on DioException catch (e) {
      return _fromDioException(e);
    } catch (e) {
      return ApiResult.failure('unexpected_error'.tr);
    }
  }

  static ApiResult _handle(Response res) {
    final statusCode = res.statusCode ?? 0;
    final data = res.data;

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResult.success(data, statusCode: statusCode);
    }

    final msg = extractMessage(data, statusCode: statusCode);
    return ApiResult.failure(msg, statusCode: statusCode, data: data);
  }

  static ApiResult _fromDioException(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;

    if (body is Map) {
      return ApiResult.failure(
        extractMessage(body, statusCode: status),
        statusCode: status,
        data: body,
      );
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiResult.failure(
        'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.',
        statusCode: status,
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return ApiResult.failure(
        'تعذر الاتصال بالخادم. يرجى التحقق من الإنترنت.',
        statusCode: status,
      );
    }

    return ApiResult.failure(
      extractMessage(body, statusCode: status),
      statusCode: status,
    );
  }

  static String extractMessage(dynamic body, {int? statusCode}) {
    if (body is Map) {
      return _extractMessageFromMap(body, statusCode: statusCode);
    }

    if (body is String) {
      final trimmed = body.trim();
      if (trimmed.isEmpty) return _defaultMessage(statusCode);
      if (_looksLikeHtml(trimmed)) {
        return 'الخادم أعاد استجابة غير متوقعة (HTML). يرجى التحقق من عنوان الـ API أو endpoint المستخدم.';
      }
      return trimmed.length > 180 ? '${trimmed.substring(0, 177)}...' : trimmed;
    }

    return _defaultMessage(statusCode);
  }

  static String _extractMessageFromMap(
    Map<dynamic, dynamic> body, {
    int? statusCode,
  }) {
    for (final key in ['message', 'msg', 'error', 'detail']) {
      final val = body[key];
      if (val != null && val.toString().isNotEmpty) return val.toString();
    }

    final errors = body['errors'];
    if (errors is Map) {
      final first = errors.values.firstOrNull;
      if (first is List && first.isNotEmpty) return first.first.toString();
    }

    return _defaultMessage(statusCode);
  }

  static String _defaultMessage(int? statusCode) {
    if (statusCode == 401) {
      return 'غير مصرح لك بالوصول. يرجى تسجيل الدخول مرة أخرى.';
    }
    if (statusCode == 404) {
      return 'العنوان المطلوب غير موجود. يرجى التحقق من الـ API.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'حدث خطأ من الخادم. يرجى المحاولة لاحقًا.';
    }
    return 'تعذر إكمال الطلب. يرجى المحاولة لاحقًا.';
  }

  static bool _looksLikeHtml(String value) {
    final normalized = value.toLowerCase();
    return normalized.contains('<!doctype') ||
        normalized.contains('<html') ||
        normalized.contains('<body');
  }
}
