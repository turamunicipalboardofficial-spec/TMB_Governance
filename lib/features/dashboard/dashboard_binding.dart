import 'package:get/get.dart';
import 'controllers/dashboard_controller.dart';
import 'data/dashboard_data_source.dart';
import 'repositories/dashboard_repository.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardDataSource());
    Get.lazyPut(() => DashboardRepository(Get.find<DashboardDataSource>()));
    Get.lazyPut(() => DashboardController(Get.find<DashboardRepository>()));
  }
}
