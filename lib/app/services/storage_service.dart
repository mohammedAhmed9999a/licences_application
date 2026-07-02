import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  late GetStorage _box;

  static StorageService get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    _box = GetStorage();
  }

  // Auth
  String? get token => _box.read('token');
  String? get userEmail => _box.read('user_email');
  String? get userName => _box.read('user_name');
  bool get isLoggedIn => token != null && token!.isNotEmpty;
  bool get rememberMe => _box.read('remember_me') ?? false;

  Future<void> saveToken(String token) => _box.write('token', token);
  Future<void> saveUserEmail(String email) => _box.write('user_email', email);
  Future<void> saveUserName(String name) => _box.write('user_name', name);
  Future<void> saveRememberMe(bool val) => _box.write('remember_me', val);

  Future<void> clearAuth() async {
    await _box.remove('token');
    await _box.remove('user_name');
    if (!rememberMe) await _box.remove('user_email');
  }
}
