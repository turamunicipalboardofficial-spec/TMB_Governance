import 'package:get/get.dart';
import 'package:tmb_governance/features/user_management/controllers/user_management_controller.dart';
import 'package:tmb_governance/features/user_management/data/user_management_data_source.dart';
import 'package:tmb_governance/features/user_management/repositories/user_management_repository.dart';

class UserManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserManagementDataSource());
    Get.lazyPut(() => UserManagementRepository(Get.find<UserManagementDataSource>()));
    Get.lazyPut(() => UserManagementController(Get.find<UserManagementRepository>()));
  }
}
