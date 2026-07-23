import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/atoms/status_badge.dart';
import '../../../core/design_system/molecules/inline_dropdown_field.dart';
import '../../../core/design_system/organisms/empty_state.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/app_routes.dart';
import '../controllers/advertisement_admin_controller.dart';
import '../models/advertisement_model.dart';

class AdListScreen extends GetView<AdvertisementAdminController> {
  const AdListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Advertisements'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        onPressed: () {
          controller.startCreate();
          Get.toNamed(AppRoutes.adCreate);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([controller.fetchAds(), controller.fetchStatistics()]);
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
              controller.loadMore();
            }
            return false;
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsSection(),
                const SizedBox(height: AppSizes.paddingL),
                _buildFilters(),
                const SizedBox(height: AppSizes.paddingM),
                _buildList(),
                Obx(() => controller.isPaginating.value
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSizes.paddingL),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Obx(() {
      final stats = controller.statistics.value;
      if (stats == null) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatChip(label: 'Active', value: '${stats.overview.active}', color: AppColors.success),
              const SizedBox(width: AppSizes.paddingS),
              _StatChip(label: 'Pending', value: '${stats.overview.pending}', color: AppColors.warning),
              const SizedBox(width: AppSizes.paddingS),
              _StatChip(label: 'Paused', value: '${stats.overview.paused}', color: AppColors.info),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Container(
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
                Expanded(
                  child: _MiniMetric(
                    icon: Icons.visibility_outlined,
                    label: 'Impressions',
                    value: '${stats.performance.totalImpressions}',
                  ),
                ),
                Expanded(
                  child: _MiniMetric(
                    icon: Icons.touch_app_outlined,
                    label: 'Clicks',
                    value: '${stats.performance.totalClicks}',
                  ),
                ),
                Expanded(
                  child: _MiniMetric(
                    icon: Icons.percent,
                    label: 'CTR',
                    value: '${stats.performance.clickThroughRate}%',
                  ),
                ),
                Expanded(
                  child: _MiniMetric(
                    icon: Icons.currency_rupee,
                    label: 'Revenue',
                    value: Formatters.formatCurrency(stats.performance.totalRevenue.toDouble()),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: controller.onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search by title, advertiser, or description',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: Obx(() => InlineDropdownField<String>(
                    value: controller.selectedStatus.value.isEmpty ? null : controller.selectedStatus.value,
                    items: kAdStatuses,
                    placeholder: 'All Statuses',
                    itemLabel: (s) => s[0].toUpperCase() + s.substring(1),
                    onChanged: controller.filterByStatus,
                  )),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Obx(() => InlineDropdownField<String>(
                    value: controller.selectedPosition.value.isEmpty ? null : controller.selectedPosition.value,
                    items: kAdPositions,
                    placeholder: 'All Positions',
                    itemLabel: (p) => p.replaceAll('_', ' '),
                    onChanged: controller.filterByPosition,
                  )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingXL),
            child: CircularProgressIndicator(),
          ),
        );
      }
      if (controller.ads.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.paddingXL),
          child: EmptyState(
            icon: Icons.campaign_outlined,
            title: 'No Advertisements Found',
            message: 'Create an advertisement to get started.',
          ),
        );
      }
      return Column(
        children: controller.ads.map((a) => _buildAdCard(a)).toList(),
      );
    });
  }

  Widget _buildAdCard(AdvertisementModel ad) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        onTap: () => Get.toNamed(AppRoutes.adDetail, arguments: ad),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(ad),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ad.displayTitle,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StatusBadge(status: ad.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ad.advertiserName} · ${ad.advertiserType}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    Row(
                      children: [
                        _MiniInfo(icon: Icons.dashboard_outlined, label: ad.position.replaceAll('_', ' ')),
                        const SizedBox(width: AppSizes.paddingM),
                        _MiniInfo(icon: Icons.visibility_outlined, label: '${ad.impressions}'),
                        const SizedBox(width: AppSizes.paddingM),
                        _MiniInfo(icon: Icons.touch_app_outlined, label: '${ad.clicks}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(AdvertisementModel ad) {
    if (!ad.hasImage) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
        child: const Icon(Icons.campaign_outlined, color: AppColors.primary, size: 22),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusS),
      child: Image.network(
        ad.imageUrl!,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: const Icon(Icons.broken_image_outlined, color: AppColors.textTertiary, size: 20),
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniMetric({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS, horizontal: AppSizes.paddingS),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(AppSizes.radiusS)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
