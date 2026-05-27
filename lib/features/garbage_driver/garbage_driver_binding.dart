import 'package:get/get.dart';
import 'controllers/garbage_driver_controller.dart';

class GarbageDriverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GarbageDriverController());
  }
}
