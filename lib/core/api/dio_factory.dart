import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioFactory {
  DioFactory._();

  static Dio? _dio;

  static Future<Dio> getDio() async {
    const timeOut = Duration(seconds: 60);

    _dio ??= Dio(
      BaseOptions(
        connectTimeout: timeOut,
        receiveTimeout: timeOut,
        validateStatus: (s) => s != null && s < 500,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (_dio!.interceptors.whereType<PrettyDioLogger>().isEmpty) {
      _dio!.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    return _dio!;
  }

  static Future<void> updateHeaderWithToken(String? accessToken) async {
    final dio = await getDio();
    if (accessToken == null || accessToken.isEmpty) {
      dio.options.headers.remove('Authorization');
    } else {
      // 3743|LS992oL6uKhGU8w00GuNLUW94700LQuiwLoBC6umacd53722
      dio.options.headers['Authorization'] = 'Bearer $accessToken';
      // dio.options.headers['Authorization'] =
      //     '3743|LS992oL6uKhGU8w00GuNLUW94700LQuiwLoBC6umacd53722';
    }
  }

  static Future<void> updateHeaderWithLang(String lang) async {
    final dio = await getDio();
    dio.options.headers['lang'] = lang;
  }

  static void reset() {
    _dio = null;
  }
}
