import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/error/failure.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/form_list_item.dart';
import '../models/approve_reject_request.dart';
import '../repositories/form_approval_repository.dart';

class FormApprovalController extends GetxController {
  final FormApprovalRepository _repository;

  FormApprovalController(this._repository);

  final forms = <FormListItem>[].obs;
  final isLoading = false.obs;
  final isPaginating = false.obs;
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final limit = 10.obs;
  final userRole = ''.obs;
  final selectedStatus = ''.obs;
  final selectedFormType = ''.obs;
  final searchQuery = ''.obs;
  final remarksController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await SecureStorageService.to.getRole();
    userRole.value = role ?? '';
    fetchForms();
  }

  /// Maps app role to API stage value.
  /// The API uses "employee" for what the app calls "editor".
  String _getStageParam() {
    final role = userRole.value;
    if (role == 'editor') return 'employee';
    return role;
  }

  Future<void> fetchForms() async {
    isLoading.value = true;
    currentPage.value = 1;
    try {
      final result = await _repository.getAllForms(
        page: 1,
        limit: limit.value,
        stage: _getStageParam(),
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
        formType: selectedFormType.value.isEmpty
            ? null
            : int.tryParse(selectedFormType.value),
      );
      forms.assignAll(result.data);
      lastPage.value = result.lastPage;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isPaginating.value || currentPage.value >= lastPage.value) return;
    isPaginating.value = true;
    try {
      currentPage.value++;
      final result = await _repository.getAllForms(
        page: currentPage.value,
        limit: limit.value,
        stage: _getStageParam(),
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
        formType: selectedFormType.value.isEmpty
            ? null
            : int.tryParse(selectedFormType.value),
      );
      forms.addAll(result.data);
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } finally {
      isPaginating.value = false;
    }
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    fetchForms();
  }

  void filterByFormType(String formType) {
    selectedFormType.value = formType;
    fetchForms();
  }

  Future<void> approveOrReject({
    required String formId,
    required String applicationId,
    required String status,
  }) async {
    try {
      final approver = _getStageParam();
      await _repository.approveOrReject(
        ApproveRejectRequest(
          formId: formId,
          applicationId: applicationId,
          approver: approver,
          status: status,
        ),
      );
      CustomSnackbar.showSuccess('Form ${status}d successfully');
      fetchForms();
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    }
  }

  void viewFormDetail(FormListItem form) {
    Get.toNamed('/admin/forms/detail', arguments: form);
  }

  @override
  void onClose() {
    remarksController.dispose();
    super.onClose();
  }
}
