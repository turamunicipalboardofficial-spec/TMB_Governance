import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class LocalStorageService extends GetxService {
  static LocalStorageService get to => Get.find();
  late GetStorage _box;

  @override
  void onInit() {
    super.onInit();
    _box = GetStorage();
  }

  Future<void> write(String key, dynamic value) => _box.write(key, value);

  dynamic read(String key) => _box.read(key);

  Future<void> remove(String key) => _box.remove(key);

  Future<void> clear() => _box.erase();
}