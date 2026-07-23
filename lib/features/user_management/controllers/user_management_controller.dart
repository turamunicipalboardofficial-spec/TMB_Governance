import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmb_governance/core/design_system/molecules/custom_snackbar.dart';
import 'package:tmb_governance/core/error/failure.dart';
import 'package:tmb_governance/core/models/locality_model.dart';
import 'package:tmb_governance/core/models/ward_model.dart';
import 'package:tmb_governance/core/network/endpoints/api_endpoints.dart';
import 'package:tmb_governance/core/network/network_service.dart';
import 'package:tmb_governance/features/user_management/models/create_consumer_request.dart';
import 'package:tmb_governance/features/user_management/models/create_driver_request.dart';
import 'package:tmb_governance/features/user_management/models/create_employee_request.dart';
import 'package:tmb_governance/features/user_management/models/update_user_request.dart';
import 'package:tmb_governance/features/user_management/models/user_model.dart';
import 'package:tmb_governance/features/user_management/repositories/user_management_repository.dart'
    show UserManagementRepository, TruckOption;

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
  final selectedCreateRole = 'employee'.obs;
  final selectedCreateWardId = RxnInt();
  final selectedTruckId = RxnInt();

  // Wards
  final wards = <WardModel>[].obs;
  final isLoadingWards = false.obs;

  // Localities
  final localities = <LocalityModel>[].obs;
  final isLoadingLocalities = false.obs;

  // Trucks (driver creation only)
  final wardTrucks = <TruckOption>[].obs;
  final isLoadingTrucks = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    fetchWards();
    ever(selectedCreateWardId, (_) {
      fetchLocalities();
      if (selectedCreateRole.value == 'driver') fetchWardTrucks();
    });
    ever(selectedCreateRole, (role) {
      if (role == 'driver' && selectedCreateWardId.value != null) {
        fetchWardTrucks();
      } else {
        wardTrucks.clear();
        selectedTruckId.value = null;
      }
    });
  }

  Future<void> fetchWardTrucks() async {
    final wardId = selectedCreateWardId.value;
    wardTrucks.clear();
    selectedTruckId.value = null;
    if (wardId == null) return;
    isLoadingTrucks.value = true;
    try {
      final trucks = await _repository.getWardTrucks(wardId);
      wardTrucks.assignAll(trucks);
    } catch (e) {
      // Truck list is optional; driver can still be created without one.
      debugPrint('❌ Failed to fetch ward trucks: $e');
    } finally {
      isLoadingTrucks.value = false;
    }
  }

  Future<void> fetchWards() async {
    isLoadingWards.value = true;
    try {
      final response = await NetworkService.to.get('/api/getWardList');
      // API returns {status: success, ward: [...]}
      final data = response.data['ward'] as List? ?? response.data['data'] as List?;
      if (data != null) {
        wards.assignAll(data.map((e) => WardModel.fromJson(e)).toList());
      }
    } catch (e) {
      // Silently fail, wards are optional
    } finally {
      isLoadingWards.value = false;
    }
  }

  Future<void> fetchLocalities() async {
    final wardId = selectedCreateWardId.value;
    localities.clear();
    selectedCreateLocalityId.value = null;
    if (wardId == null) return;
    isLoadingLocalities.value = true;
    try {
      final response = await NetworkService.to.post(
        ApiEndpoints.localityList,
        data: {'ward_id': wardId},
      );
      debugPrint('📍 Locality response for ward $wardId: ${response.data}');
      // Handle different response formats
      List<dynamic> data = [];
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('locality')) {
          data = responseData['locality'] as List? ?? [];
        } else if (responseData.containsKey('data')) {
          final innerData = responseData['data'];
          if (innerData is List) {
            data = innerData;
          } else if (innerData is Map && innerData.containsKey('locality')) {
            data = innerData['locality'] as List? ?? [];
          }
        }
      } else if (responseData is List) {
        data = responseData;
      }
      debugPrint('📍 Parsed ${data.length} localities');
      localities.assignAll(
        data.map((e) => LocalityModel.fromJson(e as Map<String, dynamic>)).toList(),
      );
      // Match pending locality name for edit mode
      if (_pendingLocalityName != null && localities.isNotEmpty) {
        final match = localities.firstWhereOrNull(
          (l) => l.localityName.toLowerCase() == _pendingLocalityName!.toLowerCase(),
        );
        if (match != null) {
          selectedCreateLocalityId.value = match.id;
        }
        _pendingLocalityName = null;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to fetch localities: $e');
      debugPrint('Stack: $stackTrace');
    } finally {
      isLoadingLocalities.value = false;
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
      debugPrint('❌ fetchUsers parsing/unexpected error: $e');
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
    if (formKey.currentState == null || !formKey.currentState!.validate())
      return;

    isCreating.value = true;
    try {
      final role = selectedCreateRole.value;
      if (role == 'employee' || role == 'ceo') {
        final request = CreateEmployeeRequest(
          firstname: firstnameCtrl.text.trim(),
          lastname: lastnameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          password: passwordCtrl.text,
          dob: dobCtrl.text.trim(),
          phoneNo: phoneNoCtrl.text.trim(),
          wardId: selectedCreateWardId.value!,
          localityId: selectedCreateLocalityId.value,
          role: role == 'ceo' ? 'ceo' : null,
        );
        await _repository.createEmployee(request);
        CustomSnackbar.showSuccess('${role == 'ceo' ? 'CEO' : 'Employee'} created successfully');
      } else if (role == 'consumer') {
        final request = CreateConsumerRequest(
          firstname: firstnameCtrl.text.trim(),
          lastname: lastnameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          password: passwordCtrl.text,
          dob: dobCtrl.text.trim(),
          phoneNo: phoneNoCtrl.text.trim(),
          wardId: selectedCreateWardId.value,
          localityId: selectedCreateLocalityId.value,
        );
        await _repository.createConsumer(request);
        CustomSnackbar.showSuccess('Consumer created successfully');
      } else if (role == 'driver') {
        final request = CreateDriverRequest(
          firstname: firstnameCtrl.text.trim(),
          lastname: lastnameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          password: passwordCtrl.text,
          dob: dobCtrl.text.trim(),
          phoneNo: phoneNoCtrl.text.trim(),
          wardId: selectedCreateWardId.value!,
          localityId: selectedCreateLocalityId.value,
          driverLicenseNumber: driverLicenseCtrl.text.trim(),
          licenseExpiry: licenseExpiryCtrl.text.trim(),
          truckId: selectedTruckId.value,
        );
        await _repository.createDriver(request);
        CustomSnackbar.showSuccess('Driver created successfully');
      }

      _clearForm();
      fetchUsers();
      Get.back();
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to create user');
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> updateUser(int userId) async {
    isCreating.value = true;
    try {
      final request = UpdateUserRequest(
        firstname: firstnameCtrl.text.trim().isEmpty
            ? null
            : firstnameCtrl.text.trim(),
        lastname: lastnameCtrl.text.trim().isEmpty
            ? null
            : lastnameCtrl.text.trim(),
        email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
        password: passwordCtrl.text.isEmpty ? null : passwordCtrl.text,
        dob: dobCtrl.text.trim().isEmpty ? null : dobCtrl.text.trim(),
        phoneNo: phoneNoCtrl.text.trim().isEmpty
            ? null
            : phoneNoCtrl.text.trim(),
        wardId: selectedCreateWardId.value,
        localityId: selectedCreateLocalityId.value,
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

  // Locality selection
  final selectedCreateLocalityId = RxnInt();
  String? _pendingLocalityName;

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
    selectedCreateLocalityId.value = null;
    localities.clear();
    wardTrucks.clear();
  }

  void loadUserForEdit(UserModel user) {
    firstnameCtrl.text = user.firstname;
    lastnameCtrl.text = user.lastname;
    emailCtrl.text = user.email;
    phoneNoCtrl.text = user.phoneNo ?? '';
    dobCtrl.text = user.dob ?? '';
    selectedCreateLocalityId.value = null;
    _pendingLocalityName = user.locality;
    selectedCreateRole.value = user.role;
    // Set ward last so ever() triggers fetchLocalities, which will match pending locality
    selectedCreateWardId.value = user.wardId;
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
