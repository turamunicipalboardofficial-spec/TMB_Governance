import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'storage_keys.dart';

class SecureStorageService extends GetxService {
  static SecureStorageService get to => Get.find();
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) =>
      _storage.write(key: StorageKeys.jwtToken, value: token);

  Future<String?> getToken() => _storage.read(key: StorageKeys.jwtToken);

  Future<void> deleteToken() => _storage.delete(key: StorageKeys.jwtToken);

  Future<void> saveRole(String role) =>
      _storage.write(key: StorageKeys.userRole, value: role);

  Future<String?> getRole() => _storage.read(key: StorageKeys.userRole);

  Future<void> deleteRole() => _storage.delete(key: StorageKeys.userRole);

  Future<void> saveUserData(Map<String, dynamic> userData) =>
      _storage.write(key: StorageKeys.userData, value: jsonEncode(userData));

  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: StorageKeys.userData);
    return data != null ? jsonDecode(data) : null;
  }

  Future<void> saveFcmToken(String token) =>
      _storage.write(key: StorageKeys.fcmToken, value: token);
  Future<String?> getFcmToken() => _storage.read(key: StorageKeys.fcmToken);
  Future<void> deleteFcmToken() => _storage.delete(key: StorageKeys.fcmToken);

  Future<void> clearAll() => _storage.deleteAll();
}
