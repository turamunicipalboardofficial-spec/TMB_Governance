import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/atoms/status_badge.dart';
import '../../../core/design_system/molecules/primary_button.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/app_routes.dart';
import '../controllers/advertisement_admin_controller.dart';
import '../models/advertisement_model.dart';

class AdDetailScreen extends GetView<AdvertisementAdminController> {
  const AdDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final initialAd = Get.arguments as AdvertisementModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Advertisement Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          Obx(() {
            final ad = controller.ads.firstWhereOrNull((a) => a.id == initialAd.id) ?? initialAd;
            return IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                controller.startEdit(ad);
                Get.toNamed(AppRoutes.adCreate);
              },
            );
          }),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, initialAd.id),
          ),
        ],
      ),
      body: Obx(() {
        final ad = controller.ads.firstWhereOrNull((a) => a.id == initialAd.id) ?? initialAd;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ad.hasImage) ...[
                _buildImage(ad),
                const SizedBox(height: AppSizes.paddingL),
              ],
              _buildHeader(ad),
              const SizedBox(height: AppSizes.paddingL),
              _buildPerformanceCard(ad),
              const SizedBox(height: AppSizes.paddingL),
              _buildContactCard(ad),
              const SizedBox(height: AppSizes.paddingL),
              _buildScheduleCard(ad),
              if (ad.adminRemarks != null && ad.adminRemarks!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.paddingL),
                _buildRemarksCard(ad),
              ],
              const SizedBox(height: AppSizes.paddingXL),
              _buildActionButtons(context, ad),
              const SizedBox(height: AppSizes.paddingL),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildImage(AdvertisementModel ad) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Image.network(
        ad.imageUrl!,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 180,
          color: AppColors.surfaceVariant,
          child: const Center(
            child: Icon(Icons.broken_image_outlined, size: 40, color: AppColors.textTertiary),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AdvertisementModel ad) {
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
                child: Text(ad.displayTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              StatusBadge(status: ad.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${ad.advertiserName} · ${ad.advertiserType}',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          if (ad.description != null && ad.description!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingS),
            Text(ad.description!, style: const TextStyle(fontSize: 13, height: 1.4)),
          ],
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
                  ad.position.replaceAll('_', ' '),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: AppSizes.paddingS),
              Text('Priority ${ad.priority}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(AdvertisementModel ad) {
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
          const Text('Performance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: AppSizes.paddingS),
          Row(
            children: [
              Expanded(child: _MiniAmount(label: 'Impressions', value: '${ad.impressions}')),
              Expanded(child: _MiniAmount(label: 'Clicks', value: '${ad.clicks}')),
              Expanded(child: _MiniAmount(label: 'CTR', value: '${ad.ctr}%')),
              Expanded(child: _MiniAmount(label: 'Revenue', value: Formatters.formatCurrency(ad.amountPaid.toDouble()))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(AdvertisementModel ad) {
    final hasContact = (ad.contactPerson?.isNotEmpty ?? false) ||
        (ad.contactPhone?.isNotEmpty ?? false) ||
        (ad.contactEmail?.isNotEmpty ?? false) ||
        (ad.websiteUrl?.isNotEmpty ?? false);
    if (!hasContact) return const SizedBox.shrink();

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
          const Text('Contact', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: AppSizes.paddingS),
          if (ad.contactPerson != null && ad.contactPerson!.isNotEmpty)
            _detailRow(Icons.person_outline, 'Person', ad.contactPerson!),
          if (ad.contactPhone != null && ad.contactPhone!.isNotEmpty)
            _detailRow(Icons.phone_outlined, 'Phone', ad.contactPhone!),
          if (ad.contactEmail != null && ad.contactEmail!.isNotEmpty)
            _detailRow(Icons.email_outlined, 'Email', ad.contactEmail!),
          if (ad.websiteUrl != null && ad.websiteUrl!.isNotEmpty)
            _detailRow(Icons.link, 'Website', ad.websiteUrl!),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(AdvertisementModel ad) {
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
          const Text('Schedule', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: AppSizes.paddingS),
          _detailRow(Icons.event_available_outlined, 'Start', ad.startDate ?? 'Not set'),
          _detailRow(Icons.event_busy_outlined, 'End', ad.endDate ?? 'Not set'),
          if (ad.createdByName != null) _detailRow(Icons.person_outline, 'Created By', ad.createdByName!),
          if (ad.createdAt != null) _detailRow(Icons.calendar_today_outlined, 'Created', Formatters.formatDateTime(ad.createdAt)),
        ],
      ),
    );
  }

  Widget _buildRemarksCard(AdvertisementModel ad) {
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
          Text(ad.adminRemarks!, style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.textTertiary),
          const SizedBox(width: AppSizes.paddingS),
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AdvertisementModel ad) {
    return Obx(() {
      final isBusy = controller.isPerformingAction.value;
      return Column(
        children: [
          if (ad.status != 'active')
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
              child: PrimaryButton(
                text: 'Publish',
                icon: Icons.publish_outlined,
                backgroundColor: AppColors.success,
                isLoading: isBusy,
                onPressed: () => _showRemarksDialog(context, ad, action: 'publish'),
              ),
            ),
          if (ad.status != 'paused')
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
              child: PrimaryButton(
                text: 'Pause',
                icon: Icons.pause_circle_outline,
                backgroundColor: AppColors.warning,
                isLoading: isBusy,
                onPressed: () => _showRemarksDialog(context, ad, action: 'pause'),
              ),
            ),
          if (ad.status != 'rejected')
            PrimaryButton(
              text: 'Reject',
              icon: Icons.cancel_outlined,
              backgroundColor: AppColors.error,
              isLoading: isBusy,
              onPressed: () => _showRemarksDialog(context, ad, action: 'reject'),
            ),
        ],
      );
    });
  }

  void _showRemarksDialog(BuildContext context, AdvertisementModel ad, {required String action}) {
    final remarksCtrl = TextEditingController();
    final label = action[0].toUpperCase() + action.substring(1);

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusL)),
        title: Text('$label Advertisement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ad.displayTitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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
              switch (action) {
                case 'publish':
                  await controller.publish(ad.id, adminRemarks: remarks);
                  break;
                case 'pause':
                  await controller.pause(ad.id, adminRemarks: remarks);
                  break;
                case 'reject':
                  await controller.reject(ad.id, adminRemarks: remarks);
                  break;
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
        title: const Text('Delete Advertisement'),
        content: const Text('Are you sure you want to delete this advertisement? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await controller.deleteAd(id);
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

class _MiniAmount extends StatelessWidget {
  final String label;
  final String value;

  const _MiniAmount({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
