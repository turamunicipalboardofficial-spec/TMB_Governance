import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/atoms/status_badge.dart';
import '../../../core/design_system/molecules/primary_button.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/app_routes.dart';
import '../controllers/notice_admin_controller.dart';
import '../models/notice_model.dart';

class NoticeDetailScreen extends GetView<NoticeAdminController> {
  const NoticeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final initialNotice = Get.arguments as NoticeModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notice Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          Obx(() {
            final notice = controller.notices.firstWhereOrNull((n) => n.id == initialNotice.id) ?? initialNotice;
            return IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                controller.startEdit(notice);
                Get.toNamed(AppRoutes.noticeCreate);
              },
            );
          }),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, initialNotice.id),
          ),
        ],
      ),
      body: Obx(() {
        final notice = controller.notices.firstWhereOrNull((n) => n.id == initialNotice.id) ?? initialNotice;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(notice),
              const SizedBox(height: AppSizes.paddingL),
              _buildContentCard(notice),
              if (notice.hasAttachment) ...[
                const SizedBox(height: AppSizes.paddingL),
                _buildAttachmentCard(notice),
              ],
              if (notice.adminRemarks != null && notice.adminRemarks!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.paddingL),
                _buildRemarksCard(notice),
              ],
              const SizedBox(height: AppSizes.paddingL),
              _buildMetaCard(notice),
              const SizedBox(height: AppSizes.paddingXL),
              _buildActionButtons(context, notice),
              const SizedBox(height: AppSizes.paddingL),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(NoticeModel notice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (notice.isPinned) ...[
                const Icon(Icons.push_pin, size: 16, color: AppColors.warning),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(notice.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              StatusBadge(status: notice.status),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  notice.type[0].toUpperCase() + notice.type.substring(1),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: AppSizes.paddingS),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  notice.priority.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warning),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(NoticeModel notice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Content', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: AppSizes.paddingS),
          Text(notice.content, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildAttachmentCard(NoticeModel notice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: AppColors.error, size: 22),
          const SizedBox(width: AppSizes.paddingM),
          const Expanded(
            child: Text('PDF Attachment', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          TextButton.icon(
            onPressed: () => _openAttachment(notice.attachmentUrl!),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('View', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarksCard(NoticeModel notice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.notes_outlined, size: 16, color: AppColors.info),
              SizedBox(width: AppSizes.paddingS),
              Text('Admin Remarks', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.info)),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(notice.adminRemarks!, style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildMetaCard(NoticeModel notice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notice.targetAudience != null)
            _detailRow(Icons.groups_outlined, 'Audience', notice.targetAudience!),
          if (notice.publishDate != null)
            _detailRow(Icons.event_available_outlined, 'Publish Date', notice.publishDate!),
          if (notice.expiryDate != null)
            _detailRow(Icons.event_busy_outlined, 'Expiry Date', notice.expiryDate!),
          if (notice.creator != null)
            _detailRow(Icons.person_outline, 'Created By', notice.creator!.name),
          if (notice.createdAt != null)
            _detailRow(Icons.calendar_today_outlined, 'Created', Formatters.formatDateTime(notice.createdAt)),
        ],
      ),
    );
  }

  Future<void> _openAttachment(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.textTertiary),
          const SizedBox(width: AppSizes.paddingS),
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, NoticeModel notice) {
    return Obx(() {
      final isBusy = controller.isPerformingAction.value;
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isBusy ? null : () => controller.togglePin(notice),
                  icon: Icon(notice.isPinned ? Icons.push_pin : Icons.push_pin_outlined, size: 18),
                  label: Text(notice.isPinned ? 'Unpin' : 'Pin'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          if (notice.status != 'published')
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
              child: PrimaryButton(
                text: 'Publish',
                icon: Icons.publish_outlined,
                backgroundColor: AppColors.success,
                isLoading: isBusy,
                onPressed: () => _showRemarksDialog(context, notice, isPublish: true),
              ),
            ),
          if (notice.status != 'archived')
            PrimaryButton(
              text: 'Archive',
              icon: Icons.archive_outlined,
              backgroundColor: AppColors.textSecondary,
              isLoading: isBusy,
              onPressed: () => _showRemarksDialog(context, notice, isPublish: false),
            ),
        ],
      );
    });
  }

  void _showRemarksDialog(BuildContext context, NoticeModel notice, {required bool isPublish}) {
    final remarksCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusL)),
        title: Text(isPublish ? 'Publish Notice' : 'Archive Notice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notice.title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: AppSizes.paddingM),
            TextField(
              controller: remarksCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Admin Remarks (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final remarks = remarksCtrl.text.trim().isEmpty ? null : remarksCtrl.text.trim();
              if (isPublish) {
                await controller.publish(notice.id, adminRemarks: remarks);
              } else {
                await controller.archive(notice.id, adminRemarks: remarks);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Confirm', style: TextStyle(color: AppColors.textOnPrimary)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusL)),
        title: const Text('Delete Notice'),
        content: const Text('Are you sure you want to delete this notice? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await controller.deleteNotice(id);
              if (success) Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: AppColors.textOnPrimary)),
          ),
        ],
      ),
    );
  }
}
