import 'package:get/get.dart';
import 'controllers/holding_tax_admin_controller.dart';

class HoldingTaxAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HoldingTaxAdminController());
  }
}
