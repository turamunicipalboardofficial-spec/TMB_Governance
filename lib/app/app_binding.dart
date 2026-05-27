import 'package:get/get.dart';
import '../core/network/network_service.dart';
import '../core/storage/secure_storage_service.dart';
import '../core/storage/local_storage_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/notification_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SecureStorageService>(SecureStorageService(), permanent: true);
    Get.put<LocalStorageService>(LocalStorageService(), permanent: true);
    Get.put<NetworkService>(NetworkService(), permanent: true);
    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
  }
}
