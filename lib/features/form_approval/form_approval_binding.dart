import 'package:get/get.dart';
import 'data/form_approval_data_source.dart';
import 'repositories/form_approval_repository.dart';
import 'controllers/form_approval_controller.dart';

class FormApprovalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FormApprovalDataSource());
    Get.lazyPut(() => FormApprovalRepository(Get.find<FormApprovalDataSource>()));
    Get.lazyPut(() => FormApprovalController(Get.find<FormApprovalRepository>()));
  }
}