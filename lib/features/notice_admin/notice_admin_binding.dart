import 'package:get/get.dart';
import 'controllers/notice_admin_controller.dart';

class NoticeAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NoticeAdminController());
  }
}
