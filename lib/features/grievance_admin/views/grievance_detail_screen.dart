import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/atoms/status_badge.dart';
import '../../../core/design_system/molecules/primary_button.dart';
import '../../../core/utils/formatters.dart';
import '../controllers/grievance_admin_controller.dart';
import '../models/grievance_model.dart';

class GrievanceDetailScreen extends GetView<GrievanceAdminController> {
  const GrievanceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final initialGrievance = Get.arguments as GrievanceModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(initialGrievance.grievanceId),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Obx(() {
        // Prefer the live copy from the controller's list (kept in sync after
        // a status update) but fall back to the argument if it's not found
        // there (e.g. navigated from a context where the list wasn't loaded).
        final grievance = controller.grievances.firstWhereOrNull(
              (g) => g.id == initialGrievance.id,
            ) ??
            initialGrievance;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusHeader(grievance),
              const SizedBox(height: AppSizes.paddingL),
              _buildInfoCard(grievance),
              const SizedBox(height: AppSizes.paddingL),
              _buildDescriptionCard(grievance),
              if (grievance.hasAttachment) ...[
                const SizedBox(height: AppSizes.paddingL),
                _buildAttachmentCard(grievance),
              ],
              if (grievance.adminRemarks != null && grievance.adminRemarks!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.paddingL),
                _buildRemarksCard(grievance),
              ],
              const SizedBox(height: AppSizes.paddingXL),
              _buildActionButtons(context, grievance),
              const SizedBox(height: AppSizes.paddingL),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusHeader(GrievanceModel grievance) {
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
              Expanded(
                child: Text(
                  grievance.subject,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              StatusBadge(status: grievance.status),
            ],
          ),
          const SizedBox(height: AppSizes.paddingXS),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              grievance.category,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(GrievanceModel grievance) {
    return Container(
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
          const Text('Complainant Details',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: AppSizes.paddingS),
          _buildDetailRow(Icons.person_outline, 'Name', grievance.name),
          if (grievance.email != null && grievance.email!.isNotEmpty)
            _buildDetailRow(Icons.email_outlined, 'Email', grievance.email!),
          _buildDetailRow(Icons.phone_outlined, 'Phone', grievance.phone),
          if (grievance.wardId != null)
            _buildDetailRow(Icons.location_city_outlined, 'Ward', grievance.wardId!),
          if (grievance.locality != null && grievance.locality!.isNotEmpty)
            _buildDetailRow(Icons.place_outlined, 'Locality', grievance.locality!),
          _buildDetailRow(Icons.calendar_today_outlined, 'Submitted', Formatters.formatDateTime(grievance.createdAt)),
          if (grievance.resolvedBy != null && grievance.resolvedAt != null)
            _buildDetailRow(Icons.check_circle_outline, 'Resolved By',
                '${grievance.resolvedBy} on ${Formatters.formatDate(grievance.resolvedAt)}'),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(GrievanceModel grievance) {
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
          const Text('Description',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: AppSizes.paddingS),
          Text(grievance.description, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildAttachmentCard(GrievanceModel grievance) {
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
          const Text('Attachment',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: AppSizes.paddingS),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            child: Image.network(
              grievance.attachmentUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: AppColors.surfaceVariant,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.insert_drive_file_outlined, size: 40, color: AppColors.textTertiary),
                      SizedBox(height: 8),
                      Text('Attachment could not be previewed', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarksCard(GrievanceModel grievance) {
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
              Text('Admin Remarks',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.info)),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(grievance.adminRemarks!, style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.textTertiary),
          const SizedBox(width: AppSizes.paddingS),
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, GrievanceModel grievance) {
    return Obx(() {
      final isUpdating = controller.isUpdating.value;
      return Column(
        children: [
          if (grievance.status != 'in_progress')
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
              child: PrimaryButton(
                text: 'Mark In Progress',
                icon: Icons.hourglass_top_outlined,
                backgroundColor: AppColors.info,
                isLoading: isUpdating,
                onPressed: () => _showRemarksDialog(context, grievance, 'in_progress'),
              ),
            ),
          if (grievance.status != 'resolved')
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
              child: PrimaryButton(
                text: 'Mark Resolved',
                icon: Icons.check_circle_outline,
                backgroundColor: AppColors.success,
                isLoading: isUpdating,
                onPressed: () => _showRemarksDialog(context, grievance, 'resolved'),
              ),
            ),
          if (grievance.status != 'rejected')
            PrimaryButton(
              text: 'Reject Grievance',
              icon: Icons.cancel_outlined,
              backgroundColor: AppColors.error,
              isLoading: isUpdating,
              onPressed: () => _showRemarksDialog(context, grievance, 'rejected'),
            ),
        ],
      );
    });
  }

  void _showRemarksDialog(BuildContext context, GrievanceModel grievance, String newStatus) {
    final remarksCtrl = TextEditingController();
    final statusLabel = newStatus == 'in_progress'
        ? 'In Progress'
        : newStatus[0].toUpperCase() + newStatus.substring(1);

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusL)),
        title: Text('Mark as $statusLabel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Grievance: ${grievance.grievanceId}',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: AppSizes.paddingM),
            TextField(
              controller: remarksCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Admin Remarks (optional)',
                hintText: 'Add notes about this action...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // close the dialog only
              await controller.updateStatus(
                grievance: grievance,
                newStatus: newStatus,
                adminRemarks: remarksCtrl.text.trim().isEmpty ? null : remarksCtrl.text.trim(),
              );
              // Stay on the detail screen; the Obx above reflects the
              // updated status/remarks automatically once the list item
              // is replaced by the controller.
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Confirm', style: TextStyle(color: AppColors.textOnPrimary)),
          ),
        ],
      ),
    );
  }
}
