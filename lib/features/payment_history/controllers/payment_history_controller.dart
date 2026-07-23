import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/error/failure.dart';
import '../../../core/utils/debouncer.dart';
import '../models/payment_history_model.dart';
import '../repositories/payment_history_repository.dart';

class PaymentHistoryController extends GetxController {
  final PaymentHistoryRepository _repository;

  PaymentHistoryController(this._repository);

  final _debouncer = Debouncer(milliseconds: 400);

  final payments = <PaymentHistoryItem>[].obs;
  final isLoading = false.obs;
  final isPaginating = false.obs;
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final total = 0.obs;

  // Filters
  final selectedStatus = ''.obs; // '', success, failed, pending
  final searchQuery = ''.obs;

  static const statusOptions = ['success', 'failed', 'pending'];

  @override
  void onInit() {
    super.onInit();
    fetchPaymentHistory();
  }

  Future<void> fetchPaymentHistory() async {
    isLoading.value = true;
    currentPage.value = 1;
    try {
      final result = await _repository.getAdminPaymentHistory(
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        page: 1,
      );
      payments.assignAll(result.payments);
      currentPage.value = result.pagination.currentPage;
      lastPage.value = result.pagination.lastPage;
      total.value = result.pagination.total;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      debugPrint('❌ fetchPaymentHistory error: $e');
      CustomSnackbar.showError('Failed to load payment history');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isPaginating.value || currentPage.value >= lastPage.value) return;
    isPaginating.value = true;
    try {
      final nextPage = currentPage.value + 1;
      final result = await _repository.getAdminPaymentHistory(
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        page: nextPage,
      );
      payments.addAll(result.payments);
      currentPage.value = result.pagination.currentPage;
      lastPage.value = result.pagination.lastPage;
      total.value = result.pagination.total;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to load more transactions');
    } finally {
      isPaginating.value = false;
    }
  }

  void filterByStatus(String? status) {
    selectedStatus.value = status ?? '';
    fetchPaymentHistory();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _debouncer.run(fetchPaymentHistory);
  }

  /// Computed summary from the currently loaded page (not a separate API call).
  num get loadedTotalAmount =>
      payments.where((p) => p.status == 'success').fold<num>(0, (sum, p) => sum + p.amount);

  @override
  void onClose() {
    _debouncer.dispose();
    super.onClose();
  }
}
