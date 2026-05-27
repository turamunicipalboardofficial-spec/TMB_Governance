import 'package:get/get.dart';
import 'controllers/trade_license_admin_controller.dart';

class TradeLicenseAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TradeLicenseAdminController());
  }
}
