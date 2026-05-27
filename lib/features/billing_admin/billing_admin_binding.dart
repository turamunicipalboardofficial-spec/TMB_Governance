import 'package:get/get.dart';
import 'controllers/billing_admin_controller.dart';

class BillingAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BillingAdminController());
  }
}
