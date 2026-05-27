import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'data/auth_data_source.dart';
import 'repositories/auth_repository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthDataSource>(() => AuthDataSource());
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find()));
    Get.lazyPut<AuthController>(() => AuthController(Get.find()));
  }
}
