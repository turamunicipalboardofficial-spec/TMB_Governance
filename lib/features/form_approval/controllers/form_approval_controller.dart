import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/error/failure.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/form_list_item.dart';
import '../models/form_type.dart';
import '../models/approve_reject_request.dart';
import '../repositories/form_approval_repository.dart';

class FormApprovalController extends GetxController {
  final FormApprovalRepository _repository;

  FormApprovalController(this._repository);

  final forms = <FormListItem>[].obs;
  final formTypes = <FormType>[].obs;
  final isLoading = false.obs;
  final isLoadingFormTypes = false.obs;
  final isPaginating = false.obs;
  final hasMore = true.obs;      // true until API returns fewer items than limit
  final currentPage = 1.obs;
  final limit = 10.obs;
  final userRole = ''.obs;
  final selectedStatus = ''.obs;
  final selectedFormTypeId = Rxn<int>();
  final searchQuery = ''.obs;
  final remarksController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadUserRole();
    fetchFormTypes();
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
    hasMore.value = true;
    try {
      final result = await _repository.getAllForms(
        page: 1,
        limit: limit.value,
        stage: _getStageParam(),
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
        formType: selectedFormTypeId.value,
      );
      forms.assignAll(result.data);
      // If we got fewer items than the limit, there are no more pages
      hasMore.value = result.data.length >= limit.value;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFormTypes() async {
    isLoadingFormTypes.value = true;
    try {
      final types = await _repository.getFormTypes();
      formTypes.assignAll(types);
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } finally {
      isLoadingFormTypes.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isPaginating.value || !hasMore.value) return;
    isPaginating.value = true;
    try {
      currentPage.value++;
      final result = await _repository.getAllForms(
        page: currentPage.value,
        limit: limit.value,
        stage: _getStageParam(),
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
        formType: selectedFormTypeId.value,
      );
      forms.addAll(result.data);
      // If this page returned fewer items than the limit, we've reached the end
      hasMore.value = result.data.length >= limit.value;
    } on Failure catch (f) {
      currentPage.value--;   // roll back on error so retry is possible
      CustomSnackbar.showError(f.message);
    } finally {
      isPaginating.value = false;
    }
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    fetchForms();
  }

  void filterByFormType(int? formTypeId) {
    selectedFormTypeId.value = formTypeId;
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
