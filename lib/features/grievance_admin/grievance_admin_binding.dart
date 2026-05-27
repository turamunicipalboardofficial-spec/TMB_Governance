import 'package:get/get.dart';
import 'controllers/grievance_admin_controller.dart';

class GrievanceAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GrievanceAdminController());
  }
}
