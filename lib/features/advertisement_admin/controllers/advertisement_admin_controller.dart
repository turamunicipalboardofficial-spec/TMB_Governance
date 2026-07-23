import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/error/failure.dart';
import '../models/advertisement_model.dart';
import '../repositories/advertisement_admin_repository.dart';

const List<String> kAdvertiserTypes = [
  'shop', 'outlet', 'organization', 'school', 'college', 'hospital',
  'restaurant', 'hotel', 'gym', 'salon', 'supermarket', 'other',
];
const List<String> kAdPositions = ['top_banner', 'sidebar', 'inline', 'popup', 'footer'];
const List<String> kAdStatuses = ['draft', 'pending', 'active', 'paused', 'expired', 'rejected'];

class AdvertisementAdminController extends GetxController {
  final AdvertisementAdminRepository _repository;

  AdvertisementAdminController(this._repository);

  // ─── List state ───────────────────────────────────────────────────
  final ads = <AdvertisementModel>[].obs;
  final isLoading = false.obs;
  final isPaginating = false.obs;
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final total = 0.obs;
  final statistics = Rxn<AdStatistics>();

  // Filters
  final selectedStatus = ''.obs;
  final selectedAdvertiserType = ''.obs;
  final selectedPosition = ''.obs;
  final searchQuery = ''.obs;

  // ─── Action state ─────────────────────────────────────────────────
  final isPerformingAction = false.obs;

  // ─── Create / edit form ───────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final advertiserNameCtrl = TextEditingController();
  final contactPersonCtrl = TextEditingController();
  final contactPhoneCtrl = TextEditingController();
  final contactEmailCtrl = TextEditingController();
  final websiteUrlCtrl = TextEditingController();
  final imageUrlCtrl = TextEditingController();
  final redirectUrlCtrl = TextEditingController();
  final amountPaidCtrl = TextEditingController();
  final priorityCtrl = TextEditingController();
  final startDateCtrl = TextEditingController();
  final endDateCtrl = TextEditingController();
  final selectedFormAdvertiserType = RxnString();
  final selectedFormPosition = 'inline'.obs;
  final selectedFormStatus = 'draft'.obs;
  final isSaving = false.obs;
  int? _editingAdId;

  @override
  void onInit() {
    super.onInit();
    fetchAds();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    try {
      final result = await _repository.getStatistics();
      statistics.value = result;
    } catch (e) {
      debugPrint('❌ Failed to fetch advertisement statistics: $e');
    }
  }

  Future<void> fetchAds() async {
    isLoading.value = true;
    currentPage.value = 1;
    try {
      final result = await _repository.listAds(
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
        advertiserType: selectedAdvertiserType.value.isEmpty ? null : selectedAdvertiserType.value,
        position: selectedPosition.value.isEmpty ? null : selectedPosition.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      ads.assignAll(result.ads);
      currentPage.value = result.currentPage;
      lastPage.value = result.lastPage;
      total.value = result.total;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      debugPrint('❌ fetchAds error: $e');
      CustomSnackbar.showError('Failed to load advertisements');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isPaginating.value || currentPage.value >= lastPage.value) return;
    isPaginating.value = true;
    try {
      final result = await _repository.listAds(
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
        advertiserType: selectedAdvertiserType.value.isEmpty ? null : selectedAdvertiserType.value,
        position: selectedPosition.value.isEmpty ? null : selectedPosition.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      ads.addAll(result.ads);
      currentPage.value = result.currentPage;
      lastPage.value = result.lastPage;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to load more advertisements');
    } finally {
      isPaginating.value = false;
    }
  }

  void filterByStatus(String? status) {
    selectedStatus.value = status ?? '';
    fetchAds();
  }

  void filterByAdvertiserType(String? type) {
    selectedAdvertiserType.value = type ?? '';
    fetchAds();
  }

  void filterByPosition(String? position) {
    selectedPosition.value = position ?? '';
    fetchAds();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    fetchAds();
  }

  void _updateInPlace(AdvertisementModel updated) {
    final index = ads.indexWhere((a) => a.id == updated.id);
    if (index != -1) ads[index] = updated;
  }

  Future<void> publish(int id, {String? adminRemarks}) async {
    isPerformingAction.value = true;
    try {
      final updated = await _repository.publishAd(id, adminRemarks: adminRemarks);
      _updateInPlace(updated);
      fetchStatistics();
      CustomSnackbar.showSuccess('Advertisement published successfully');
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to publish advertisement');
    } finally {
      isPerformingAction.value = false;
    }
  }

  Future<void> pause(int id, {String? adminRemarks}) async {
    isPerformingAction.value = true;
    try {
      final updated = await _repository.pauseAd(id, adminRemarks: adminRemarks);
      _updateInPlace(updated);
      fetchStatistics();
      CustomSnackbar.showSuccess('Advertisement paused successfully');
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to pause advertisement');
    } finally {
      isPerformingAction.value = false;
    }
  }

  Future<void> reject(int id, {String? adminRemarks}) async {
    isPerformingAction.value = true;
    try {
      final updated = await _repository.rejectAd(id, adminRemarks: adminRemarks);
      _updateInPlace(updated);
      fetchStatistics();
      CustomSnackbar.showSuccess('Advertisement rejected');
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to reject advertisement');
    } finally {
      isPerformingAction.value = false;
    }
  }

  Future<bool> deleteAd(int id) async {
    isPerformingAction.value = true;
    try {
      await _repository.deleteAd(id);
      ads.removeWhere((a) => a.id == id);
      fetchStatistics();
      CustomSnackbar.showSuccess('Advertisement deleted successfully');
      return true;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
      return false;
    } catch (e) {
      CustomSnackbar.showError('Failed to delete advertisement');
      return false;
    } finally {
      isPerformingAction.value = false;
    }
  }

  // ─── Create / edit form ────────────────────────────────────────────

  void startCreate() {
    _editingAdId = null;
    titleCtrl.clear();
    descriptionCtrl.clear();
    advertiserNameCtrl.clear();
    contactPersonCtrl.clear();
    contactPhoneCtrl.clear();
    contactEmailCtrl.clear();
    websiteUrlCtrl.clear();
    imageUrlCtrl.clear();
    redirectUrlCtrl.clear();
    amountPaidCtrl.clear();
    priorityCtrl.clear();
    startDateCtrl.clear();
    endDateCtrl.clear();
    selectedFormAdvertiserType.value = null;
    selectedFormPosition.value = 'inline';
    selectedFormStatus.value = 'draft';
  }

  void startEdit(AdvertisementModel ad) {
    _editingAdId = ad.id;
    titleCtrl.text = ad.title ?? '';
    descriptionCtrl.text = ad.description ?? '';
    advertiserNameCtrl.text = ad.advertiserName;
    contactPersonCtrl.text = ad.contactPerson ?? '';
    contactPhoneCtrl.text = ad.contactPhone ?? '';
    contactEmailCtrl.text = ad.contactEmail ?? '';
    websiteUrlCtrl.text = ad.websiteUrl ?? '';
    imageUrlCtrl.text = ad.imageUrl ?? '';
    redirectUrlCtrl.text = ad.redirectUrl ?? '';
    amountPaidCtrl.text = ad.amountPaid == 0 ? '' : ad.amountPaid.toString();
    priorityCtrl.text = ad.priority == 0 ? '' : ad.priority.toString();
    startDateCtrl.text = ad.startDate ?? '';
    endDateCtrl.text = ad.endDate ?? '';
    selectedFormAdvertiserType.value = ad.advertiserType;
    selectedFormPosition.value = ad.position;
    selectedFormStatus.value = ad.status;
  }

  bool get isEditing => _editingAdId != null;

  Future<void> submitAdForm() async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) return;
    if (selectedFormAdvertiserType.value == null) {
      CustomSnackbar.showWarning('Select an advertiser type');
      return;
    }

    isSaving.value = true;
    try {
      final wasEditing = isEditing;
      if (wasEditing) {
        await _repository.updateAd(
          id: _editingAdId!,
          advertiserName: advertiserNameCtrl.text.trim(),
          advertiserType: selectedFormAdvertiserType.value,
          title: titleCtrl.text.trim(),
          description: descriptionCtrl.text.trim(),
          contactPerson: contactPersonCtrl.text.trim(),
          contactPhone: contactPhoneCtrl.text.trim(),
          contactEmail: contactEmailCtrl.text.trim(),
          websiteUrl: websiteUrlCtrl.text.trim(),
          imageUrl: imageUrlCtrl.text.trim(),
          redirectUrl: redirectUrlCtrl.text.trim(),
          position: selectedFormPosition.value,
          status: selectedFormStatus.value,
          startDate: startDateCtrl.text.trim().isEmpty ? null : startDateCtrl.text.trim(),
          endDate: endDateCtrl.text.trim().isEmpty ? null : endDateCtrl.text.trim(),
          amountPaid: num.tryParse(amountPaidCtrl.text.trim()),
          priority: int.tryParse(priorityCtrl.text.trim()),
        );
      } else {
        await _repository.createAd(
          advertiserName: advertiserNameCtrl.text.trim(),
          advertiserType: selectedFormAdvertiserType.value!,
          title: titleCtrl.text.trim(),
          description: descriptionCtrl.text.trim(),
          contactPerson: contactPersonCtrl.text.trim(),
          contactPhone: contactPhoneCtrl.text.trim(),
          contactEmail: contactEmailCtrl.text.trim(),
          websiteUrl: websiteUrlCtrl.text.trim(),
          imageUrl: imageUrlCtrl.text.trim(),
          redirectUrl: redirectUrlCtrl.text.trim(),
          position: selectedFormPosition.value,
          status: selectedFormStatus.value,
          startDate: startDateCtrl.text.trim().isEmpty ? null : startDateCtrl.text.trim(),
          endDate: endDateCtrl.text.trim().isEmpty ? null : endDateCtrl.text.trim(),
          amountPaid: num.tryParse(amountPaidCtrl.text.trim()) ?? 0,
          priority: int.tryParse(priorityCtrl.text.trim()) ?? 0,
        );
      }
      fetchAds();
      fetchStatistics();
      Get.back();
      CustomSnackbar.showSuccess(wasEditing ? 'Advertisement updated successfully' : 'Advertisement created successfully');
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to save advertisement');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    advertiserNameCtrl.dispose();
    contactPersonCtrl.dispose();
    contactPhoneCtrl.dispose();
    contactEmailCtrl.dispose();
    websiteUrlCtrl.dispose();
    imageUrlCtrl.dispose();
    redirectUrlCtrl.dispose();
    amountPaidCtrl.dispose();
    priorityCtrl.dispose();
    startDateCtrl.dispose();
    endDateCtrl.dispose();
    super.onClose();
  }
}
