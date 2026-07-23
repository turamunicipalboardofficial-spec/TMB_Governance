import 'package:get/get.dart';
import 'controllers/garbage_admin_controller.dart';
import 'data/garbage_admin_data_source.dart';
import 'repositories/garbage_admin_repository.dart';

class GarbageAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GarbageAdminDataSource());
    Get.lazyPut(() => GarbageAdminRepository(Get.find<GarbageAdminDataSource>()));
    Get.lazyPut(() => GarbageAdminController(Get.find<GarbageAdminRepository>()));
  }
}
