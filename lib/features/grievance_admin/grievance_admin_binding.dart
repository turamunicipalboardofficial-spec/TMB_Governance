import 'package:get/get.dart';
import 'controllers/grievance_admin_controller.dart';
import 'data/grievance_admin_data_source.dart';
import 'repositories/grievance_admin_repository.dart';

class GrievanceAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GrievanceAdminDataSource());
    Get.lazyPut(() => GrievanceAdminRepository(Get.find<GrievanceAdminDataSource>()));
    Get.lazyPut(() => GrievanceAdminController(Get.find<GrievanceAdminRepository>()));
  }
}
