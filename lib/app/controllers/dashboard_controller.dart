import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:licences_application/core/services/core_api_service.dart';
import '../models/application_model.dart';

class DashboardController extends GetxController {
  static DashboardController get to => Get.find();

  final applications = <ApplicationModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadApplications();
  }

  Future<void> loadApplications() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      applications.value = [];

      final response = await CoreApiService.get(
        '/v1/license-applications',
        options: dio.Options(receiveTimeout: const Duration(seconds: 60)),
      );
      final rawData = response.data;
      final payload = rawData is Map<String, dynamic>
          ? rawData['data'] as List? ?? <dynamic>[]
          : rawData as List? ?? <dynamic>[];
      applications.value = payload
          .map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (error) {
      applications.value = [];
      errorMessage.value =
          'تعذر تحميل طلبات التراخيص. يرجى التحقق من الاتصال والمحاولة مرة أخرى.';
    } finally {
      isLoading.value = false;
    }
  }
}
