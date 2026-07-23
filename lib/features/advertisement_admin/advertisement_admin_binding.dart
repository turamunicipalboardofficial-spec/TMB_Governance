import 'package:get/get.dart';
import 'controllers/advertisement_admin_controller.dart';
import 'data/advertisement_admin_data_source.dart';
import 'repositories/advertisement_admin_repository.dart';

class AdvertisementAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdvertisementAdminDataSource());
    Get.lazyPut(() => AdvertisementAdminRepository(Get.find<AdvertisementAdminDataSource>()));
    Get.lazyPut(() => AdvertisementAdminController(Get.find<AdvertisementAdminRepository>()));
  }
}
