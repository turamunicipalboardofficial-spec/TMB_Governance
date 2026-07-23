import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/atoms/status_badge.dart';
import '../../../core/design_system/molecules/inline_dropdown_field.dart';
import '../../../core/design_system/organisms/empty_state.dart';
import '../../../routes/app_routes.dart';
import '../controllers/notice_admin_controller.dart';
import '../models/notice_model.dart';

class NoticeListScreen extends GetView<NoticeAdminController> {
  const NoticeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notices & Announcements'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        onPressed: () {
          controller.startCreate();
          Get.toNamed(AppRoutes.noticeCreate);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([controller.fetchNotices(), controller.fetchStatistics()]);
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
                _buildStatsRow(),
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

  Widget _buildStatsRow() {
    return Obx(() {
      final s = controller.stats.value;
      if (s == null) return const SizedBox.shrink();
      return Row(
        children: [
          _StatChip(label: 'Published', value: '${s.published}', color: AppColors.success),
          const SizedBox(width: AppSizes.paddingS),
          _StatChip(label: 'Draft', value: '${s.draft}', color: AppColors.warning),
          const SizedBox(width: AppSizes.paddingS),
          _StatChip(label: 'Pinned', value: '${s.pinned}', color: AppColors.primary),
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
            hintText: 'Search by title or content',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: Obx(() => InlineDropdownField<String>(
                    value: controller.selectedType.value.isEmpty ? null : controller.selectedType.value,
                    items: kNoticeTypes,
                    placeholder: 'All Types',
                    itemLabel: (t) => t[0].toUpperCase() + t.substring(1),
                    onChanged: controller.filterByType,
                  )),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Obx(() => InlineDropdownField<String>(
                    value: controller.selectedStatus.value.isEmpty ? null : controller.selectedStatus.value,
                    items: kNoticeStatuses,
                    placeholder: 'All Statuses',
                    itemLabel: (s) => s[0].toUpperCase() + s.substring(1),
                    onChanged: controller.filterByStatus,
                  )),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingM),
        Obx(() => InlineDropdownField<String>(
              value: controller.selectedPriority.value.isEmpty ? null : controller.selectedPriority.value,
              items: kNoticePriorities,
              placeholder: 'All Priorities',
              itemLabel: (p) => p[0].toUpperCase() + p.substring(1),
              onChanged: controller.filterByPriority,
            )),
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
      if (controller.notices.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.paddingXL),
          child: EmptyState(
            icon: Icons.campaign_outlined,
            title: 'No Notices Found',
            message: 'Create a notice or announcement to get started.',
          ),
        );
      }
      return Column(
        children: controller.notices.map((n) => _buildNoticeCard(n)).toList(),
      );
    });
  }

  Widget _buildNoticeCard(NoticeModel notice) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        onTap: () => Get.toNamed(AppRoutes.noticeDetail, arguments: notice),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    notice.isAnnouncement ? Icons.campaign : Icons.description_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSizes.paddingS),
                  Expanded(
                    child: Text(
                      notice.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (notice.isPinned) ...[
                    const Icon(Icons.push_pin, size: 14, color: AppColors.warning),
                    const SizedBox(width: 6),
                  ],
                  StatusBadge(status: notice.status),
                ],
              ),
              const SizedBox(height: AppSizes.paddingXS),
              Text(
                notice.content,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSizes.paddingS),
              Row(
                children: [
                  _PriorityChip(priority: notice.priority),
                  const SizedBox(width: AppSizes.paddingS),
                  if (notice.hasAttachment) ...[
                    const Icon(Icons.attach_file, size: 13, color: AppColors.textTertiary),
                    const SizedBox(width: 2),
                  ],
                  const Spacer(),
                  if (notice.targetAudience != null)
                    Text(
                      notice.targetAudience!,
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String priority;

  const _PriorityChip({required this.priority});

  Color get _color {
    switch (priority) {
      case 'urgent':
        return AppColors.error;
      case 'high':
        return AppColors.warning;
      case 'low':
        return AppColors.textTertiary;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _color),
      ),
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
