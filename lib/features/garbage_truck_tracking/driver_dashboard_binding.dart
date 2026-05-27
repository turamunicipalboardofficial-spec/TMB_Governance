import 'package:get/get.dart';
import 'controllers/driver_dashboard_controller.dart';
import 'data/driver_data_source.dart';
import 'repositories/driver_repository.dart';

class DriverDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverDataSource>(() => DriverDataSource());
    Get.lazyPut<DriverRepository>(
      () => DriverRepository(Get.find<DriverDataSource>()),
    );
    Get.lazyPut<DriverDashboardController>(
      () => DriverDashboardController(Get.find<DriverRepository>()),
    );
  }
}