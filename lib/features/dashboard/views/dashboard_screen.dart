import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/organisms/empty_state.dart';
import '../controllers/dashboard_controller.dart';
import '../models/admin_dashboard_response.dart';
import 'widgets/stat_grid.dart';

class _WorkflowPipeline extends StatelessWidget {
  final AdminDashboardResponse data;

  const _WorkflowPipeline({required this.data});

  @override
  Widget build(BuildContext context) {
    final workflow = data.workflowAnalytics.workflow;
    final stages = [
      _PipelineStage('Submitted', workflow.submitted, AppColors.info),
      _PipelineStage(
          'Doc Verification', workflow.documentVerification, AppColors.warning),
      _PipelineStage(
          'Field Inspection', workflow.fieldInspection, AppColors.accent),
      _PipelineStage(
          'Payment Pending', workflow.paymentPending, AppColors.error),
      _PipelineStage(
          'Payment Done', workflow.paymentCompleted, AppColors.success),
      _PipelineStage(
          'Approval Pending', workflow.approvalPending, AppColors.primaryLight),
      _PipelineStage('Approved', workflow.approved, AppColors.success),
      _PipelineStage('Rejected', workflow.rejected, AppColors.error),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        children: stages.map((stage) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: stage.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingS),
                Expanded(
                  child: Text(
                    stage.label,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  stage.count.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: stage.color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PipelineStage {
  final String label;
  final int count;
  final Color color;

  const _PipelineStage(this.label, this.count, this.color);
}

class _PendingActionsSummary extends StatelessWidget {
  final AdminDashboardResponse data;

  const _PendingActionsSummary({required this.data});

  @override
  Widget build(BuildContext context) {
    final pending = data.pendingActions.pendingActions;
    final items = [
      _PendingItem('Total Pending', pending.totalPending, AppColors.warning),
      _PendingItem(
          'Payment Pending', pending.paymentPending, AppColors.error),
      _PendingItem(
          'Verification Pending', pending.verificationPending, AppColors.info),
      _PendingItem(
          'Inspection Pending', pending.inspectionPending, AppColors.accent),
      _PendingItem('High Priority', pending.highPriorityPending,
          AppColors.error),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        children: [
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 8, color: item.color),
                  const SizedBox(width: AppSizes.paddingS),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    item.count.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: item.color,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (pending.oldestPendingDays > 0) ...[
            const Divider(height: 16),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppColors.textTertiary),
                const SizedBox(width: AppSizes.paddingS),
                Text(
                  'Oldest pending: ${pending.oldestPendingDays} days',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PendingItem {
  final String label;
  final int count;
  final Color color;

  const _PendingItem(this.label, this.count, this.color);
}

/// The dashboard body content (no Scaffold wrapper).
/// Used both embedded in MainShellScreen and in the standalone DashboardScreen.
class DashboardBody extends GetView<DashboardController> {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final data = controller.dashboardData.value;
      if (data == null) {
        return EmptyState(
          icon: Icons.dashboard_outlined,
          title: 'No Data',
          message: 'Dashboard data is not available',
          actionText: 'Retry',
          onAction: controller.fetchDashboard,
        );
      }
      return RefreshIndicator(
        onRefresh: controller.fetchDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Here\'s what\'s happening today',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingXL),

              // Stat Cards Grid
              DashboardStatGrid(data: data),
              const SizedBox(height: AppSizes.paddingXXL),

              // Workflow Pipeline
              Text(
                'Workflow Pipeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
              _WorkflowPipeline(data: data),
              const SizedBox(height: AppSizes.paddingXXL),

              // Pending Actions Summary
              Text(
                'Pending Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
              _PendingActionsSummary(data: data),
            ],
          ),
        ),
      );
    });
  }
}

/// Standalone DashboardScreen with its own Scaffold/AppBar.
/// Used when navigating directly to the dashboard route.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: const DashboardBody(),
    );
  }
}