import 'package:get/get.dart';
import 'controllers/billing_admin_controller.dart';
import 'data/billing_admin_data_source.dart';
import 'repositories/billing_admin_repository.dart';

class BillingAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BillingAdminDataSource());
    Get.lazyPut(() => BillingAdminRepository(Get.find<BillingAdminDataSource>()));
    Get.lazyPut(() => BillingAdminController(Get.find<BillingAdminRepository>()));
  }
}
