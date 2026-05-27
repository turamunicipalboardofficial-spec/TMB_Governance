import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Use post-frame callback to ensure the widget tree is ready before navigating
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      final token = await SecureStorageService.to.getToken();
      final role = await SecureStorageService.to.getRole();

      if (kDebugMode) {
        print('Splash: token=$token, role=$role');
      }

      if (token != null && role != null) {
        if (role == 'driver') {
          Get.offAllNamed(AppRoutes.driverDashboard);
        } else {
          Get.offAllNamed(AppRoutes.adminMainShell);
        }
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      // If anything fails, go to login
      if (kDebugMode) {
        print('Splash auth check error: $e');
      }
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
