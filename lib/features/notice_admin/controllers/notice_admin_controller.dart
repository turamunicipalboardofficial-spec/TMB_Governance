import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/error/failure.dart';
import '../models/notice_model.dart';
import '../repositories/notice_admin_repository.dart';

const List<String> kNoticeTypes = ['notice', 'announcement'];
const List<String> kNoticePriorities = ['low', 'medium', 'high', 'urgent'];
const List<String> kNoticeStatuses = ['draft', 'published', 'archived'];
const List<String> kTargetAudiences = ['all', 'consumer', 'driver', 'editor', 'ceo'];

class NoticeAdminController extends GetxController {
  final NoticeAdminRepository _repository;

  NoticeAdminController(this._repository);

  // ─── List state ───────────────────────────────────────────────────
  final notices = <NoticeModel>[].obs;
  final isLoading = false.obs;
  final isPaginating = false.obs;
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final total = 0.obs;
  final stats = Rxn<NoticeStats>();

  // Filters
  final selectedStatus = ''.obs;
  final selectedType = ''.obs;
  final selectedPriority = ''.obs;
  final searchQuery = ''.obs;

  // ─── Detail state ─────────────────────────────────────────────────
  final selectedNotice = Rxn<NoticeModel>();
  final isLoadingDetail = false.obs;
  final isPerformingAction = false.obs;

  // ─── Create / edit form ───────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  final publishDateCtrl = TextEditingController();
  final expiryDateCtrl = TextEditingController();
  final selectedFormType = 'notice'.obs;
  final selectedFormPriority = 'medium'.obs;
  final selectedFormStatus = 'draft'.obs;
  final selectedFormTargetAudience = RxnString();
  final formIsPinned = false.obs;
  final pickedPdfPath = ''.obs;
  final pickedPdfName = ''.obs;
  final existingAttachmentUrl = RxnString();
  final removeExistingPdf = false.obs;
  final isSaving = false.obs;
  int? _editingNoticeId;

  @override
  void onInit() {
    super.onInit();
    fetchNotices();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    try {
      final result = await _repository.getStatistics();
      stats.value = result;
    } catch (e) {
      debugPrint('❌ Failed to fetch notice statistics: $e');
    }
  }

  Future<void> fetchNotices() async {
    isLoading.value = true;
    currentPage.value = 1;
    try {
      final result = await _repository.listNotices(
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
        type: selectedType.value.isEmpty ? null : selectedType.value,
        priority: selectedPriority.value.isEmpty ? null : selectedPriority.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      notices.assignAll(result.items);
      currentPage.value = result.currentPage;
      lastPage.value = result.lastPage;
      total.value = result.total;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      debugPrint('❌ fetchNotices error: $e');
      CustomSnackbar.showError('Failed to load notices');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isPaginating.value || currentPage.value >= lastPage.value) return;
    isPaginating.value = true;
    try {
      final result = await _repository.listNotices(
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
        type: selectedType.value.isEmpty ? null : selectedType.value,
        priority: selectedPriority.value.isEmpty ? null : selectedPriority.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      notices.addAll(result.items);
      currentPage.value = result.currentPage;
      lastPage.value = result.lastPage;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to load more notices');
    } finally {
      isPaginating.value = false;
    }
  }

  void filterByStatus(String? status) {
    selectedStatus.value = status ?? '';
    fetchNotices();
  }

  void filterByType(String? type) {
    selectedType.value = type ?? '';
    fetchNotices();
  }

  void filterByPriority(String? priority) {
    selectedPriority.value = priority ?? '';
    fetchNotices();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    fetchNotices();
  }

  // ─── Detail ────────────────────────────────────────────────────────

  Future<void> fetchNoticeDetail(int id) async {
    isLoadingDetail.value = true;
    try {
      final result = await _repository.getNotice(id);
      selectedNotice.value = result;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to load notice details');
    } finally {
      isLoadingDetail.value = false;
    }
  }

  void _updateInPlace(NoticeModel updated) {
    selectedNotice.value = updated;
    final index = notices.indexWhere((n) => n.id == updated.id);
    if (index != -1) notices[index] = updated;
  }

  Future<void> publish(int id, {String? adminRemarks}) async {
    isPerformingAction.value = true;
    try {
      final updated = await _repository.publishNotice(id, adminRemarks: adminRemarks);
      _updateInPlace(updated);
      CustomSnackbar.showSuccess('Notice published successfully');
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to publish notice');
    } finally {
      isPerformingAction.value = false;
    }
  }

  Future<void> archive(int id, {String? adminRemarks}) async {
    isPerformingAction.value = true;
    try {
      final updated = await _repository.archiveNotice(id, adminRemarks: adminRemarks);
      _updateInPlace(updated);
      CustomSnackbar.showSuccess('Notice archived successfully');
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to archive notice');
    } finally {
      isPerformingAction.value = false;
    }
  }

  Future<void> togglePin(NoticeModel notice) async {
    try {
      final updated = await _repository.togglePin(notice.id);
      _updateInPlace(updated);
      CustomSnackbar.showSuccess(updated.isPinned ? 'Notice pinned' : 'Notice unpinned');
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to update pin status');
    }
  }

  Future<bool> deleteNotice(int id) async {
    isPerformingAction.value = true;
    try {
      await _repository.deleteNotice(id);
      notices.removeWhere((n) => n.id == id);
      CustomSnackbar.showSuccess('Notice deleted successfully');
      return true;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
      return false;
    } catch (e) {
      CustomSnackbar.showError('Failed to delete notice');
      return false;
    } finally {
      isPerformingAction.value = false;
    }
  }

  // ─── Create / edit form ────────────────────────────────────────────

  void startCreate() {
    _editingNoticeId = null;
    titleCtrl.clear();
    contentCtrl.clear();
    publishDateCtrl.clear();
    expiryDateCtrl.clear();
    selectedFormType.value = 'notice';
    selectedFormPriority.value = 'medium';
    selectedFormStatus.value = 'draft';
    selectedFormTargetAudience.value = null;
    formIsPinned.value = false;
    existingAttachmentUrl.value = null;
    removeExistingPdf.value = false;
    clearPickedPdf();
  }

  void startEdit(NoticeModel notice) {
    _editingNoticeId = notice.id;
    titleCtrl.text = notice.title;
    contentCtrl.text = notice.content;
    publishDateCtrl.text = notice.publishDate ?? '';
    expiryDateCtrl.text = notice.expiryDate ?? '';
    selectedFormType.value = notice.type;
    selectedFormPriority.value = notice.priority;
    selectedFormStatus.value = notice.status;
    selectedFormTargetAudience.value = notice.targetAudience;
    formIsPinned.value = notice.isPinned;
    existingAttachmentUrl.value = notice.attachmentUrl;
    removeExistingPdf.value = false;
    clearPickedPdf();
  }

  bool get isEditing => _editingNoticeId != null;

  void setPickedPdf(String path, String name) {
    pickedPdfPath.value = path;
    pickedPdfName.value = name;
    removeExistingPdf.value = false;
  }

  void clearPickedPdf() {
    pickedPdfPath.value = '';
    pickedPdfName.value = '';
  }

  void markRemoveExistingPdf() {
    removeExistingPdf.value = true;
    existingAttachmentUrl.value = null;
  }

  Future<void> submitNoticeForm() async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) return;

    isSaving.value = true;
    try {
      if (isEditing) {
        await _repository.updateNotice(
          id: _editingNoticeId!,
          title: titleCtrl.text.trim(),
          content: contentCtrl.text.trim(),
          type: selectedFormType.value,
          priority: selectedFormPriority.value,
          status: selectedFormStatus.value,
          targetAudience: selectedFormTargetAudience.value,
          publishDate: publishDateCtrl.text.trim().isEmpty ? null : publishDateCtrl.text.trim(),
          expiryDate: expiryDateCtrl.text.trim().isEmpty ? null : expiryDateCtrl.text.trim(),
          isPinned: formIsPinned.value,
          pdfFilePath: pickedPdfPath.value.isEmpty ? null : pickedPdfPath.value,
          pdfFileName: pickedPdfName.value.isEmpty ? null : pickedPdfName.value,
          removePdf: removeExistingPdf.value,
        );
      } else {
        await _repository.createNotice(
          title: titleCtrl.text.trim(),
          content: contentCtrl.text.trim(),
          type: selectedFormType.value,
          priority: selectedFormPriority.value,
          status: selectedFormStatus.value,
          targetAudience: selectedFormTargetAudience.value,
          publishDate: publishDateCtrl.text.trim().isEmpty ? null : publishDateCtrl.text.trim(),
          expiryDate: expiryDateCtrl.text.trim().isEmpty ? null : expiryDateCtrl.text.trim(),
          isPinned: formIsPinned.value,
          pdfFilePath: pickedPdfPath.value.isEmpty ? null : pickedPdfPath.value,
          pdfFileName: pickedPdfName.value.isEmpty ? null : pickedPdfName.value,
        );
      }
      final wasEditing = isEditing;
      fetchNotices();
      fetchStatistics();
      Get.back();
      CustomSnackbar.showSuccess(wasEditing ? 'Notice updated successfully' : 'Notice created successfully');
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to save notice');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    contentCtrl.dispose();
    publishDateCtrl.dispose();
    expiryDateCtrl.dispose();
    super.onClose();
  }
}
