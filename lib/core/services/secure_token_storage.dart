import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

class SecureTokenStorage {
  SecureTokenStorage._();
  static final SecureTokenStorage instance = SecureTokenStorage._();

  static const _key = 'auth_token';
  static const int _xorSeed = 0x5A;

  final FlutterSecureStorage _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
  final GetStorage _fallback = GetStorage();

  Future<void> write(String token) async {
    try {
      await _secure.write(key: _key, value: token);
    } catch (e) {
      debugPrint('SecureStorage write failed – fallback: $e');
      _fallback.write(_key, _xorEncode(token));
    }
  }

  Future<String?> read() async {
    try {
      return await _secure.read(key: _key);
    } catch (e) {
      debugPrint('SecureStorage read failed – fallback: $e');
      final raw = _fallback.read<String>(_key);
      return raw != null ? _xorDecode(raw) : null;
    }
  }

  Future<void> delete() async {
    try {
      await _secure.delete(key: _key);
    } catch (_) {}
    _fallback.remove(_key);
  }

  String _xorEncode(String input) => input.codeUnits
      .map((b) => (b ^ _xorSeed).toString().padLeft(3, '0'))
      .join(':');

  String _xorDecode(String encoded) {
    try {
      return encoded
          .split(':')
          .map((s) => int.parse(s) ^ _xorSeed)
          .map(String.fromCharCode)
          .join();
    } catch (_) {
      return encoded;
    }
  }
}
