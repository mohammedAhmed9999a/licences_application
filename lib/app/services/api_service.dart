// import 'package:dio/dio.dart' as dio;
// import 'package:get/get.dart';
// import 'storage_service.dart';

// class ApiService extends GetxService {
//   static ApiService get to => Get.find();

//   late dio.Dio _dio;

//   // Change this to your actual API base URL
//   static const String baseUrl =
//       'https://petro-stati     ons.moenergy.gov.sy/api';

//   @override
//   void onInit() {
//     super.onInit();
//     _dio = dio.Dio(
//       dio.BaseOptions(
//         baseUrl: baseUrl,
//         connectTimeout: const Duration(seconds: 30),
//         receiveTimeout: const Duration(seconds: 30),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       ),
//     );

//     _dio.interceptors.add(
//       dio.InterceptorsWrapper(
//         onRequest: (options, handler) {
//           final token = StorageService.to.token;
//           if (token != null && token.isNotEmpty) {
//             // Bearer
//             options.headers['Authorization'] =
//                 'Bearer 3743|LS992oL6uKhGU8w00GuNLUW94700LQuiwLoBC6umacd53722';
//           }
//           return handler.next(options);
//         },
//         onResponse: (response, handler) => handler.next(response),
//         onError: (dio.DioException e, handler) {
//           if (e.response?.statusCode == 401) {
//             StorageService.to.clearAuth();
//             Get.offAllNamed('/home');
//           }
//           return handler.next(e);
//         },
//       ),
//     );
//   }

//   // AUTH
//   Future<dio.Response> login(String email, String password) =>
//       _dio.post('/auth/login', data: {'email': email, 'password': password});

//   Future<dio.Response> signup(String name, String email, String password) =>
//       _dio.post(
//         '/auth/register',
//         data: {'name': name, 'email': email, 'password': password},
//       );

//   Future<dio.Response> logout() => _dio.post('/auth/logout');

//   // LICENSE APPLICATIONS
//   Future<dio.Response> getMyApplications() => _dio.get('/licence-application');

//   Future<dio.Response> submitStep1(Map<String, dynamic> data) =>
//       _dio.post('/licence-application/step1', data: data);

//   Future<dio.Response> submitStep2(String appId, Map<String, dynamic> data) =>
//       _dio.post('/licence-application/$appId/step2', data: data);

//   Future<dio.Response> submitStep3(String appId, Map<String, dynamic> data) =>
//       _dio.post('/licence-application/$appId/step3', data: data);

//   Future<dio.Response> submitStep4(String appId, dio.FormData formData) =>
//       _dio.post('/licence-application/$appId/step4', data: formData);

//   Future<dio.Response> submitApplication(String appId) =>
//       _dio.post('/licence-application/$appId/submit');

//   // LOOKUPS
//   Future<dio.Response> getGovernorates() => _dio.get('/lookups/governorates');
//   Future<dio.Response> getDistricts(int govId) =>
//       _dio.get('/lookups/districts/$govId');
//   Future<dio.Response> getSubdistricts(int distId) =>
//       _dio.get('/lookups/subdistricts/$distId');
//   Future<dio.Response> getTowns(int subdistId) =>
//       _dio.get('/lookups/towns/$subdistId');
// }
