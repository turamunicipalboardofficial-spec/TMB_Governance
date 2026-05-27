import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/error/failure.dart';
import '../../../core/services/fcm_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../routes/app_routes.dart';
import '../models/login_request.dart';
import '../repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _repository;

  AuthController(this._repository);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final forgotEmailController = TextEditingController();
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    if (!_validate()) return;
    isLoading.value = true;
    try {
      final request = LoginRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      final response = await _repository.login(request);
      await SecureStorageService.to.saveToken(response.accessToken);
      await SecureStorageService.to.saveRole(response.role);
      await SecureStorageService.to.saveUserData(response.userDetails.toJson());

      emailController.clear();
      passwordController.clear();

      // Sync FCM token to server after login
      FcmService.to.syncTokenToServer();

      if (response.role == 'driver') {
        Get.offAllNamed(AppRoutes.driverDashboard);
      } else {
        Get.offAllNamed(AppRoutes.adminMainShell);
      }
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } finally {
      await SecureStorageService.to.clearAll();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  bool _validate() {
    if (emailController.text.trim().isEmpty ||
        !GetUtils.isEmail(emailController.text.trim())) {
      CustomSnackbar.showError('Please enter a valid email');
      return false;
    }
    if (passwordController.text.length < 6) {
      CustomSnackbar.showError('Password must be at least 6 characters');
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    forgotEmailController.dispose();
    super.onClose();
  }
}
