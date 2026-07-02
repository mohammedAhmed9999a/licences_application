import 'package:get/get.dart';

class ApiResult {
  final bool isSuccess;
  final dynamic data;
  final String? errorMessage;
  final int? statusCode;

  const ApiResult._({
    required this.isSuccess,
    this.data,
    this.errorMessage,
    this.statusCode,
  });

  factory ApiResult.success(dynamic data, {int? statusCode}) =>
      ApiResult._(isSuccess: true, data: data, statusCode: statusCode);

  factory ApiResult.failure(String message,
          {int? statusCode, dynamic data}) =>
      ApiResult._(
        isSuccess: false,
        errorMessage: message,
        statusCode: statusCode,
        data: data,
      );

  T when<T>({
    required T Function(dynamic data, int? statusCode) success,
    required T Function(String message, int? statusCode) failure,
  }) {
    if (isSuccess) return success(data, statusCode);
    return failure(errorMessage ?? 'error'.tr, statusCode);
  }

  Map<String, dynamic>? get dataAsMap {
    if (data is Map) return Map<String, dynamic>.from(data as Map);
    return null;
  }
}
