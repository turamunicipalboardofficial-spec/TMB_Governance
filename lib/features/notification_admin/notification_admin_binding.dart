import 'package:get/get.dart';
import 'controllers/notification_admin_controller.dart';

class NotificationAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationAdminController());
  }
}
