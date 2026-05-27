import 'package:get/get.dart';
import 'controllers/garbage_admin_controller.dart';

class GarbageAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GarbageAdminController());
  }
}
