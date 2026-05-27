import 'package:get/get.dart';
import 'controllers/advertisement_admin_controller.dart';

class AdvertisementAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdvertisementAdminController());
  }
}
