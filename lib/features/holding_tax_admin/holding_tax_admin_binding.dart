import 'package:get/get.dart';
import 'controllers/holding_tax_admin_controller.dart';
import 'data/holding_tax_admin_data_source.dart';
import 'repositories/holding_tax_admin_repository.dart';

class HoldingTaxAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HoldingTaxAdminDataSource());
    Get.lazyPut(() => HoldingTaxAdminRepository(Get.find<HoldingTaxAdminDataSource>()));
    Get.lazyPut(() => HoldingTaxAdminController(Get.find<HoldingTaxAdminRepository>()));
  }
}
