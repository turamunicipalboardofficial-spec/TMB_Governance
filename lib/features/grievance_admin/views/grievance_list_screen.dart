import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/atoms/status_badge.dart';
import '../../../core/design_system/organisms/empty_state.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/app_routes.dart';
import '../controllers/grievance_admin_controller.dart';
import '../models/grievance_model.dart';

class GrievanceListScreen extends GetView<GrievanceAdminController> {
  const GrievanceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Grievances'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Column(
        children: [
          _buildSummaryRow(),
          _buildSearchAndFilters(),
          Expanded(child: _buildGrievanceList()),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Obx(() {
      final s = controller.summary.value;
      if (s == null) return const SizedBox.shrink();
      return Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingM, AppSizes.paddingM, AppSizes.paddingM, AppSizes.paddingS,
        ),
        child: Row(
          children: [
            _SummaryChip(label: 'Total', value: s.total, color: AppColors.primary),
            const SizedBox(width: AppSizes.paddingS),
            _SummaryChip(label: 'Pending', value: s.pending, color: AppColors.warning),
            const SizedBox(width: AppSizes.paddingS),
            _SummaryChip(label: 'In Progress', value: s.inProgress, color: AppColors.info),
            const SizedBox(width: AppSizes.paddingS),
            _SummaryChip(label: 'Resolved', value: s.resolved, color: AppColors.success),
            const SizedBox(width: AppSizes.paddingS),
            _SummaryChip(label: 'Rejected', value: s.rejected, color: AppColors.error),
          ],
        ),
      );
    });
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingM, 0, AppSizes.paddingM, AppSizes.paddingM,
      ),
      color: AppColors.surface,
      child: Column(
        children: [
          TextField(
            onChanged: controller.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by ID, name, subject, or phone...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(
              () => Row(
                children: [
                  _buildStatusChip('All', ''),
                  _buildStatusChip('Pending', 'pending'),
                  _buildStatusChip('In Progress', 'in_progress'),
                  _buildStatusChip('Resolved', 'resolved'),
                  _buildStatusChip('Rejected', 'rejected'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, String status) {
    final isSelected = controller.selectedStatus.value == status;
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.paddingS),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: isSelected,
        onSelected: (_) => controller.filterByStatus(status.isEmpty ? null : status),
        selectedColor: AppColors.primary.withOpacity(0.15),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildGrievanceList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.grievances.isEmpty) {
        return const EmptyState(
          icon: Icons.report_problem_outlined,
          title: 'No Grievances Found',
          message: 'No grievances match your current filters.',
        );
      }
      return RefreshIndicator(
        onRefresh: controller.fetchGrievances,
        child: ListView.builder(
          padding: const EdgeInsets.only(
            bottom: AppSizes.paddingL,
            left: AppSizes.paddingM,
            right: AppSizes.paddingM,
            top: AppSizes.paddingS,
          ),
          itemCount: controller.grievances.length +
              (controller.currentPage.value < controller.totalPages.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.grievances.length) {
              controller.loadMore();
              return const Padding(
                padding: EdgeInsets.all(AppSizes.paddingM),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _buildGrievanceCard(controller.grievances[index]);
          },
        ),
      );
    });
  }

  Widget _buildGrievanceCard(GrievanceModel grievance) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        onTap: () => Get.toNamed(AppRoutes.grievanceDetail, arguments: grievance),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      grievance.grievanceId,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  StatusBadge(status: grievance.status),
                ],
              ),
              const SizedBox(height: AppSizes.paddingXS),
              Text(
                grievance.subject,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                grievance.description,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSizes.paddingS),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryExtraLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      grievance.category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingS),
                  Icon(Icons.person_outline, size: 13, color: AppColors.textTertiary),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      grievance.name,
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    Formatters.timeAgo(grievance.createdAt),
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

class _SummaryChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _SummaryChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
