import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../routes/app_routes.dart';
import '../models/profile_update_request.dart';
import '../models/change_password_request.dart';
import '../repositories/profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repository;

  ProfileController(this._repository);

  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final isNewPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final userRole = ''.obs;
  final userName = ''.obs;
  final userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userRole.value = await SecureStorageService.to.getRole() ?? '';
    final userData = await SecureStorageService.to.getUserData();
    if (userData != null) {
      userName.value =
          '${userData['firstname'] ?? ''} ${userData['lastname'] ?? ''}'.trim();
      userEmail.value = userData['email'] ?? '';
      firstnameController.text = userData['firstname'] ?? '';
      lastnameController.text = userData['lastname'] ?? '';
      emailController.text = userData['email'] ?? '';
      phoneController.text = userData['phone_no'] ?? '';
      dobController.text = userData['dob'] ?? '';
    }
  }

  Future<void> updateProfile() async {
    if (!_validateProfile()) return;
    isLoading.value = true;
    try {
      final request = ProfileUpdateRequest(
        firstname: firstnameController.text.trim(),
        lastname: lastnameController.text.trim(),
        dob: dobController.text.trim(),
        phoneNo: phoneController.text.trim(),
        email: emailController.text.trim(),
      );
      await _repository.updateProfile(request);
      // Update local storage
      await SecureStorageService.to.saveUserData({
        'firstname': firstnameController.text.trim(),
        'lastname': lastnameController.text.trim(),
        'email': emailController.text.trim(),
        'phone_no': phoneController.text.trim(),
        'dob': dobController.text.trim(),
      });
      userName.value =
          '${firstnameController.text.trim()} ${lastnameController.text.trim()}';
      userEmail.value = emailController.text.trim();
      CustomSnackbar.showSuccess('Profile updated successfully');
    } catch (e) {
      CustomSnackbar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword() async {
    if (!_validatePassword()) return;
    isLoading.value = true;
    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPasswordController.text,
        password: newPasswordController.text,
        confirmPassword: confirmPasswordController.text,
      );
      await _repository.changePassword(request);
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      CustomSnackbar.showSuccess('Password changed successfully');
    } catch (e) {
      CustomSnackbar.showError(e.toString());
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

  bool _validateProfile() {
    if (firstnameController.text.trim().isEmpty) {
      CustomSnackbar.showError('First name is required');
      return false;
    }
    if (lastnameController.text.trim().isEmpty) {
      CustomSnackbar.showError('Last name is required');
      return false;
    }
    if (emailController.text.trim().isEmpty ||
        !GetUtils.isEmail(emailController.text.trim())) {
      CustomSnackbar.showError('Please enter a valid email');
      return false;
    }
    return true;
  }

  bool _validatePassword() {
    if (currentPasswordController.text.length < 6) {
      CustomSnackbar.showError('Current password is required');
      return false;
    }
    if (newPasswordController.text.length < 6) {
      CustomSnackbar.showError('New password must be at least 6 characters');
      return false;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      CustomSnackbar.showError('Passwords do not match');
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
