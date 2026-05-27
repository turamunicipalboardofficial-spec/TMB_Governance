import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmb_governance/core/design_system/molecules/custom_snackbar.dart';
import 'package:tmb_governance/core/error/failure.dart';
import 'package:tmb_governance/core/models/ward_model.dart';
import 'package:tmb_governance/core/network/network_service.dart';
import 'package:tmb_governance/features/user_management/models/create_consumer_request.dart';
import 'package:tmb_governance/features/user_management/models/create_driver_request.dart';
import 'package:tmb_governance/features/user_management/models/create_employee_request.dart';
import 'package:tmb_governance/features/user_management/models/update_user_request.dart';
import 'package:tmb_governance/features/user_management/models/user_model.dart';
import 'package:tmb_governance/features/user_management/repositories/user_management_repository.dart';

class UserManagementController extends GetxController {
  final UserManagementRepository _repository;

  UserManagementController(this._repository);

  // User list state
  final users = <UserModel>[].obs;
  final isLoading = false.obs;
  final isPaginating = false.obs;
  final currentPage = 1.obs;
  final totalUsers = 0.obs;
  final perPage = 15.obs;

  // Filters
  final selectedRole = ''.obs;
  final selectedWardId = RxnInt();
  final searchQuery = ''.obs;

  // Create form state
  final isCreating = false.obs;
  final formKey = GlobalKey<FormState>();

  // Form fields
  final firstnameCtrl = TextEditingController();
  final lastnameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final phoneNoCtrl = TextEditingController();
  final localityCtrl = TextEditingController();
  final driverLicenseCtrl = TextEditingController();
  final licenseExpiryCtrl = TextEditingController();

  // Dropdowns
  final selectedCreateRole = 'driver'.obs;
  final selectedCreateWardId = RxnInt();
  final selectedTruckId = RxnInt();

  // Wards
  final wards = <WardModel>[].obs;
  final isLoadingWards = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    fetchWards();
  }

  Future<void> fetchWards() async {
    isLoadingWards.value = true;
    try {
      final response = await NetworkService.to.get('/api/wards');
      final data = response.data['data'] as List;
      wards.assignAll(data.map((e) => WardModel.fromJson(e)).toList());
    } catch (e) {
      // Silently fail, wards are optional
    } finally {
      isLoadingWards.value = false;
    }
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;
    currentPage.value = 1;
    try {
      final result = await _repository.listUsers(
        role: selectedRole.value.isEmpty ? null : selectedRole.value,
        wardId: selectedWardId.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        perPage: perPage.value,
        page: 1,
      );
      users.assignAll(result['users'] as List<UserModel>);
      totalUsers.value = result['total'] as int;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to load users');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isPaginating.value || users.length >= totalUsers.value) return;
    isPaginating.value = true;
    try {
      currentPage.value++;
      final result = await _repository.listUsers(
        role: selectedRole.value.isEmpty ? null : selectedRole.value,
        wardId: selectedWardId.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        perPage: perPage.value,
        page: currentPage.value,
      );
      users.addAll(result['users'] as List<UserModel>);
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to load more users');
    } finally {
      isPaginating.value = false;
    }
  }

  void filterByRole(String? role) {
    selectedRole.value = role ?? '';
    fetchUsers();
  }

  void filterByWard(int? wardId) {
    selectedWardId.value = wardId;
    fetchUsers();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    fetchUsers();
  }

  Future<void> createUser() async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) return;

    isCreating.value = true;
    try {
      final role = selectedCreateRole.value;
      if (role == 'driver') {
        final request = CreateDriverRequest(
          firstname: firstnameCtrl.text.trim(),
          lastname: lastnameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          password: passwordCtrl.text,
          dob: dobCtrl.text.trim(),
          phoneNo: phoneNoCtrl.text.trim(),
          wardId: selectedCreateWardId.value!,
          locality: localityCtrl.text.trim().isEmpty ? null : localityCtrl.text.trim(),
          driverLicenseNumber: driverLicenseCtrl.text.trim(),
          licenseExpiry: licenseExpiryCtrl.text.trim(),
          truckId: selectedTruckId.value,
        );
        await _repository.createDriver(request);
        CustomSnackbar.showSuccess('Driver created successfully');
      } else if (role == 'employee') {
        final request = CreateEmployeeRequest(
          firstname: firstnameCtrl.text.trim(),
          lastname: lastnameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          password: passwordCtrl.text,
          dob: dobCtrl.text.trim(),
          phoneNo: phoneNoCtrl.text.trim(),
          wardId: selectedCreateWardId.value!,
          locality: localityCtrl.text.trim().isEmpty ? null : localityCtrl.text.trim(),
        );
        await _repository.createEmployee(request);
        CustomSnackbar.showSuccess('Employee created successfully');
      } else if (role == 'consumer') {
        final request = CreateConsumerRequest(
          firstname: firstnameCtrl.text.trim(),
          lastname: lastnameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          password: passwordCtrl.text,
          dob: dobCtrl.text.trim(),
          phoneNo: phoneNoCtrl.text.trim(),
          wardId: selectedCreateWardId.value,
          locality: localityCtrl.text.trim().isEmpty ? null : localityCtrl.text.trim(),
        );
        await _repository.createConsumer(request);
        CustomSnackbar.showSuccess('Consumer created successfully');
      }

      _clearForm();
      fetchUsers();
      Get.back();
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to create user: ${e.toString()}');
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> updateUser(int userId) async {
    isCreating.value = true;
    try {
      final request = UpdateUserRequest(
        firstname: firstnameCtrl.text.trim().isEmpty ? null : firstnameCtrl.text.trim(),
        lastname: lastnameCtrl.text.trim().isEmpty ? null : lastnameCtrl.text.trim(),
        email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
        password: passwordCtrl.text.isEmpty ? null : passwordCtrl.text,
        dob: dobCtrl.text.trim().isEmpty ? null : dobCtrl.text.trim(),
        phoneNo: phoneNoCtrl.text.trim().isEmpty ? null : phoneNoCtrl.text.trim(),
        wardId: selectedCreateWardId.value,
        locality: localityCtrl.text.trim().isEmpty ? null : localityCtrl.text.trim(),
      );
      await _repository.updateUser(userId, request);
      CustomSnackbar.showSuccess('User updated successfully');
      _clearForm();
      fetchUsers();
      Get.back();
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to update user');
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> toggleUserActive(UserModel user) async {
    try {
      final newStatus = !(user.isActive ?? true);
      await _repository.toggleUserActive(user.id, newStatus);
      CustomSnackbar.showSuccess(
        'User ${newStatus ? "activated" : "deactivated"} successfully',
      );
      fetchUsers();
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to toggle user status');
    }
  }

  void _clearForm() {
    firstnameCtrl.clear();
    lastnameCtrl.clear();
    emailCtrl.clear();
    passwordCtrl.clear();
    dobCtrl.clear();
    phoneNoCtrl.clear();
    localityCtrl.clear();
    driverLicenseCtrl.clear();
    licenseExpiryCtrl.clear();
    selectedCreateWardId.value = null;
    selectedTruckId.value = null;
  }

  void loadUserForEdit(UserModel user) {
    firstnameCtrl.text = user.firstname;
    lastnameCtrl.text = user.lastname;
    emailCtrl.text = user.email;
    phoneNoCtrl.text = user.phoneNo ?? '';
    dobCtrl.text = user.dob ?? '';
    localityCtrl.text = user.locality ?? '';
    selectedCreateWardId.value = user.wardId;
    selectedCreateRole.value = user.role;
  }

  String getWardName(int? wardId) {
    if (wardId == null) return 'N/A';
    final ward = wards.firstWhereOrNull((w) => w.id == wardId);
    return ward?.wardName ?? 'Ward $wardId';
  }

  @override
  void onClose() {
    firstnameCtrl.dispose();
    lastnameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    dobCtrl.dispose();
    phoneNoCtrl.dispose();
    localityCtrl.dispose();
    driverLicenseCtrl.dispose();
    licenseExpiryCtrl.dispose();
    super.onClose();
  }
}