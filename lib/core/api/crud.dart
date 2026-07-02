import 'package:dio/dio.dart';
import 'api_client.dart';
import '../class/api_result.dart';

/// Base CRUD helper — extend this in each feature's data source.
abstract class Crud {
  // ── GET ──────────────────────────────────────────────────────────────
  Future<ApiResult> getData(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) =>
      ApiClient.get(url, queryParameters: queryParameters);

  // ── POST ─────────────────────────────────────────────────────────────
  Future<ApiResult> postData(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      ApiClient.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

  // ── POST multipart (file upload) ─────────────────────────────────────
  Future<ApiResult> postMultipart(
    String url,
    FormData formData,
  ) =>
      ApiClient.post(
        url,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

  // ── PUT ──────────────────────────────────────────────────────────────
  Future<ApiResult> putData(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      ApiClient.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

  // ── DELETE ───────────────────────────────────────────────────────────
  Future<ApiResult> deleteData(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) =>
      ApiClient.delete(
        url,
        data: data,
        queryParameters: queryParameters,
      );
}
