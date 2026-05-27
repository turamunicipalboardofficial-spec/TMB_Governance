import 'package:get/get.dart';
import '../../../core/storage/secure_storage_service.dart';

class MainShellController extends GetxController {
  final currentIndex = 0.obs;
  final userRole = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRole();
  }

  Future<void> _loadRole() async {
    userRole.value = await SecureStorageService.to.getRole() ?? '';
  }

  void changeTab(int index) => currentIndex.value = index;
}
