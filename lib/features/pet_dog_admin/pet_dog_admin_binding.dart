import 'package:get/get.dart';
import 'controllers/pet_dog_admin_controller.dart';

class PetDogAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PetDogAdminController());
  }
}
