import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../api/api_client.dart';
import '../api/dio_factory.dart';
import '../class/api_result.dart';
import '../../app/services/storage_service.dart';

class CoreApiService {
  CoreApiService._();
  //
  // static const String baseUrl =
  //     'https://api-petro-stations.moenergy.gov.sy/api';

  static const String baseUrl = 'http://192.168.88.125:8000/api';

  static const String baseUrlPublicImages =
      "http://192.168.88.125:8000/storage/";

  static Future<void> updateAuthHeader() async {
    await DioFactory.updateHeaderWithToken(StorageService.to.token);
  }

  static Future<dio.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    await updateAuthHeader();
    final result = await ApiClient.get(
      '$baseUrl$path',
      queryParameters: queryParameters,
      options: options,
    );
    return _toResponse(result, path);
  }

  static Future<dio.Response> getPublic(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    // remover the auhenttion App Token form App
    final dio = await DioFactory.getDio();
    // dio.options.headers.remove('Authorization');
    dio.options.headers.remove('Authorization');

    // dio.options.headers['Authorization'] =
    //     '3743|LS992oL6uKhGU8w00GuNLUW94700LQuiwLoBC6umacd53722';

    final result = await ApiClient.get(
      '$baseUrl$path',
      queryParameters: queryParameters,
    );
    return _toResponse(result, path, redirectOnUnauthorized: false);
  }

  static Future<dio.Response> post(
    String path, {
    dynamic data,
    dio.Options? options,
  }) async {
    await updateAuthHeader();
    final result = await ApiClient.post(
      '$baseUrl$path',
      data: data,
      options: options,
    );
    return _toResponse(result, path);
  }

  static Future<dio.Response> patch(
    String path, {
    dynamic data,
    dio.Options? options,
  }) async {
    await updateAuthHeader();
    final result = await ApiClient.patch(
      '$baseUrl$path',
      data: data,
      options: options,
    );
    return _toResponse(result, path);
  }

  static Future<dio.Response> _toResponse(
    ApiResult result,
    String path, {
    bool redirectOnUnauthorized = true,
  }) async {
    if (result.isSuccess) {
      return dio.Response(
        requestOptions: dio.RequestOptions(path: path),
        data: result.data,
        statusCode: result.statusCode,
      );
    }

    if ((result.statusCode ?? 0) == 401) {
      if (redirectOnUnauthorized) {
        await StorageService.to.clearAuth();
        Get.offAllNamed('/home');
      }
    }

    throw dio.DioException(
      requestOptions: dio.RequestOptions(path: path),
      response: dio.Response(
        requestOptions: dio.RequestOptions(path: path),
        data: result.data,
        statusCode: result.statusCode,
      ),
      error: result.errorMessage,
      type: dio.DioExceptionType.badResponse,
    );
  }
}
