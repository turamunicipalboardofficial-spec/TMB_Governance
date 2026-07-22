import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/error/failure.dart';
import '../models/grievance_model.dart';
import '../repositories/grievance_admin_repository.dart';

class GrievanceAdminController extends GetxController {
  final GrievanceAdminRepository _repository;

  GrievanceAdminController(this._repository);

  // List state
  final grievances = <GrievanceModel>[].obs;
  final isLoading = false.obs;
  final isPaginating = false.obs;
  final isUpdating = false.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final total = 0.obs;
  final summary = Rxn<GrievanceSummary>();

  // Filters
  final selectedStatus = ''.obs; // '', pending, in_progress, resolved, rejected
  final selectedCategory = ''.obs;
  final searchQuery = ''.obs;

  // Categories (for filter dropdown)
  final categories = <String>[].obs;

  static const statusOptions = ['pending', 'in_progress', 'resolved', 'rejected'];

  @override
  void onInit() {
    super.onInit();
    fetchGrievances();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final result = await _repository.getCategories();
      categories.assignAll(result);
    } catch (e) {
      // Categories are optional for filtering; fail silently.
      debugPrint('Failed to load grievance categories: $e');
    }
  }

  Future<void> fetchGrievances() async {
    isLoading.value = true;
    currentPage.value = 1;
    try {
      final result = await _repository.getAllGrievances(
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
        category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      grievances.assignAll(result.grievances);
      currentPage.value = result.currentPage;
      totalPages.value = result.totalPages;
      total.value = result.total;
      summary.value = result.summary;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      debugPrint('❌ fetchGrievances error: $e');
      CustomSnackbar.showError('Failed to load grievances');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isPaginating.value || currentPage.value >= totalPages.value) return;
    isPaginating.value = true;
    try {
      final nextPage = currentPage.value + 1;
      final result = await _repository.getAllGrievances(
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
        category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        page: nextPage,
      );
      grievances.addAll(result.grievances);
      currentPage.value = result.currentPage;
      totalPages.value = result.totalPages;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to load more grievances');
    } finally {
      isPaginating.value = false;
    }
  }

  void filterByStatus(String? status) {
    selectedStatus.value = status ?? '';
    fetchGrievances();
  }

  void filterByCategory(String? category) {
    selectedCategory.value = category ?? '';
    fetchGrievances();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    fetchGrievances();
  }

  Future<void> updateStatus({
    required GrievanceModel grievance,
    required String newStatus,
    String? adminRemarks,
  }) async {
    isUpdating.value = true;
    try {
      final updated = await _repository.updateStatus(
        grievanceId: grievance.grievanceId,
        status: newStatus,
        adminRemarks: adminRemarks,
      );
      // Update the item in-place in the list
      final index = grievances.indexWhere((g) => g.id == grievance.id);
      if (index != -1) {
        grievances[index] = updated;
      }
      CustomSnackbar.showSuccess('Grievance status updated to ${_statusLabel(newStatus)}');
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to update grievance status');
    } finally {
      isUpdating.value = false;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'in_progress':
        return 'In Progress';
      default:
        return status[0].toUpperCase() + status.substring(1);
    }
  }
}
