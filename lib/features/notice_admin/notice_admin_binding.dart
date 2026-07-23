import 'package:get/get.dart';
import 'controllers/notice_admin_controller.dart';
import 'data/notice_admin_data_source.dart';
import 'repositories/notice_admin_repository.dart';

class NoticeAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NoticeAdminDataSource());
    Get.lazyPut(() => NoticeAdminRepository(Get.find<NoticeAdminDataSource>()));
    Get.lazyPut(() => NoticeAdminController(Get.find<NoticeAdminRepository>()));
  }
}
