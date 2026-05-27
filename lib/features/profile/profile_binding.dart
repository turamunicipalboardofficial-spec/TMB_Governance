import 'package:get/get.dart';
import 'controllers/profile_controller.dart';
import 'data/profile_data_source.dart';
import 'repositories/profile_repository.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileDataSource());
    Get.lazyPut(() => ProfileRepository(Get.find<ProfileDataSource>()));
    Get.lazyPut(() => ProfileController(Get.find<ProfileRepository>()));
  }
}
