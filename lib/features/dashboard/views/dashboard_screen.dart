import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/organisms/empty_state.dart';
import '../../../core/utils/formatters.dart';
import '../controllers/dashboard_controller.dart';
import '../models/admin_dashboard_response.dart';
import 'widgets/billing_analytics_card.dart';
import 'widgets/charts_section.dart';
import 'widgets/citizen_analytics_card.dart';
import 'widgets/form_wise_analytics_list.dart';
import 'widgets/recent_activity_list.dart';
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

class _AlertsBanner extends StatelessWidget {
  final AdminDashboardResponse data;

  const _AlertsBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    final alerts = data.alerts.alerts;
    if (!alerts.hasAlerts) return const SizedBox.shrink();

    final chips = <_AlertChip>[
      if (alerts.pendingApprovals > 0)
        _AlertChip('${alerts.pendingApprovals} pending approvals',
            Icons.pending_actions, AppColors.warning),
      if (alerts.failedPayments > 0)
        _AlertChip('${alerts.failedPayments} failed payments',
            Icons.error_outline, AppColors.error),
      if (alerts.expiringTradeLicenses > 0)
        _AlertChip('${alerts.expiringTradeLicenses} licenses expiring',
            Icons.badge_outlined, AppColors.accent),
      if (alerts.highDueAccounts > 0)
        _AlertChip('${alerts.highDueAccounts} high due accounts',
            Icons.account_balance_wallet_outlined, AppColors.error),
      if (alerts.systemErrors > 0)
        _AlertChip('${alerts.systemErrors} system errors',
            Icons.warning_amber_outlined, AppColors.error),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Wrap(
        spacing: AppSizes.paddingS,
        runSpacing: AppSizes.paddingS,
        children: chips
            .map((c) => Chip(
                  avatar: Icon(c.icon, size: 16, color: c.color),
                  label: Text(
                    c.label,
                    style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                  backgroundColor: AppColors.surface,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ))
            .toList(),
      ),
    );
  }
}

class _AlertChip {
  final String label;
  final IconData icon;
  final Color color;

  const _AlertChip(this.label, this.icon, this.color);
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

              // Alerts Banner
              _AlertsBanner(data: data),
              if (data.alerts.alerts.hasAlerts)
                const SizedBox(height: AppSizes.paddingXL),

              // Stat Cards Grid
              DashboardStatGrid(data: data),
              const SizedBox(height: AppSizes.paddingXXL),

              // Form-wise Analytics
              if (data.formWiseAnalytics.any((f) => f.totalApplications > 0)) ...[
                Text(
                  'Services Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                FormWiseAnalyticsList(forms: data.formWiseAnalytics),
                const SizedBox(height: AppSizes.paddingXXL),
              ],

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

              // Charts (monthly revenue / applications / service-wise revenue)
              const SizedBox(height: AppSizes.paddingXXL),
              ChartsSectionView(charts: data.charts.charts),

              // Billing Analytics
              if (data.billingAnalytics.billing.totalMarkets > 0) ...[
                const SizedBox(height: AppSizes.paddingXXL),
                Text(
                  'Billing Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                BillingAnalyticsCard(billing: data.billingAnalytics.billing),
              ],

              // Citizen Analytics
              if (data.citizenAnalytics.citizens.totalRegistered > 0) ...[
                const SizedBox(height: AppSizes.paddingXXL),
                Text(
                  'Citizen Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                CitizenAnalyticsCard(citizens: data.citizenAnalytics.citizens),
              ],

              // Recent Activities
              if (data.recentActivities.isNotEmpty) ...[
                const SizedBox(height: AppSizes.paddingXXL),
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                Container(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                  ),
                  child: RecentActivityList(
                    activities: data.recentActivities
                        .map((a) => RecentActivityItem(
                              title: a.message,
                              type: a.type,
                              timestamp: Formatters.timeAgo(a.dateTime),
                            ))
                        .toList(),
                  ),
                ),
              ],
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