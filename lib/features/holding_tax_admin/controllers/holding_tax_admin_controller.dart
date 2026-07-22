import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/env.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/error/failure.dart';
import '../../../core/utils/debouncer.dart';
import '../models/holding_tax_model.dart';
import '../repositories/holding_tax_admin_repository.dart';

class HoldingTaxAdminController extends GetxController {
  final HoldingTaxAdminRepository _repository;

  HoldingTaxAdminController(this._repository);

  final _debouncer = Debouncer(milliseconds: 400);

  // Stats
  final stats = Rxn<HoldingTaxStats>();
  final isLoadingStats = false.obs;
  final statsTypeFilter = ''.obs; // '', house, commercial

  // Search / list
  final searchResults = <HoldingTaxSearchItem>[].obs;
  final isSearching = false.obs;
  final searchQuery = ''.obs;
  final selectedTaxType = ''.obs; // '', house, commercial

  // Detail
  final selectedHolding = Rxn<HoldingTaxModel>();
  final isLoadingDetail = false.obs;

  // Payment
  final isPaying = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
    search('');
  }

  Future<void> fetchStats() async {
    isLoadingStats.value = true;
    try {
      final result = await _repository.getStats(
        type: statsTypeFilter.value.isEmpty ? null : statsTypeFilter.value,
      );
      stats.value = result;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      debugPrint('❌ fetchStats error: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }

  void filterStatsByType(String? type) {
    statsTypeFilter.value = type ?? '';
    fetchStats();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _debouncer.run(() => search(query));
  }

  Future<void> search(String query) async {
    isSearching.value = true;
    try {
      final results = await _repository.search(
        query: query,
        type: selectedTaxType.value.isEmpty ? null : selectedTaxType.value,
      );
      searchResults.assignAll(results);
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      debugPrint('❌ search error: $e');
      CustomSnackbar.showError('Failed to search holding tax records');
    } finally {
      isSearching.value = false;
    }
  }

  void filterByType(String? type) {
    selectedTaxType.value = type ?? '';
    search(searchQuery.value);
  }

  Future<void> loadDetails(String holdingNo) async {
    isLoadingDetail.value = true;
    selectedHolding.value = null;
    try {
      final result = await _repository.getDetails(holdingNo);
      if (result == null) {
        CustomSnackbar.showError('Holding tax record not found');
        return;
      }
      selectedHolding.value = result;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to load holding tax details');
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<bool> markAsPaid({
    required String holdingNo,
    double? paidAmount,
    String? paymentRemarks,
  }) async {
    isPaying.value = true;
    try {
      final updated = await _repository.pay(
        holdingNo: holdingNo,
        paidAmount: paidAmount,
        paymentRemarks: paymentRemarks,
      );
      selectedHolding.value = updated;
      CustomSnackbar.showSuccess('Holding tax marked as paid');
      // Refresh stats + list in the background so counts stay accurate
      fetchStats();
      search(searchQuery.value);
      return true;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
      return false;
    } catch (e) {
      CustomSnackbar.showError('Failed to update payment');
      return false;
    } finally {
      isPaying.value = false;
    }
  }

  /// Opens the PDF receipt download link in an external browser/PDF viewer.
  /// The receipt endpoints require no JWT auth (public, accessed via
  /// payment confirmation), so a direct URL launch is sufficient.
  Future<void> downloadReceipt(int holdingTaxId) async {
    final url = Uri.parse('${Env.baseUrl}/api/receipts/holding-tax/download/$holdingTaxId');
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        CustomSnackbar.showError('Could not open the receipt');
      }
    } catch (e) {
      CustomSnackbar.showError('Could not open the receipt');
    }
  }

  @override
  void onClose() {
    _debouncer.dispose();
    super.onClose();
  }
}
