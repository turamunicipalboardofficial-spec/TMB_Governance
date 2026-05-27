import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/admin_dashboard_response.dart';

class DashboardStatGrid extends StatelessWidget {
  final AdminDashboardResponse data;

  const DashboardStatGrid({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final summary = data.systemSummary;
    final payments = data.paymentRevenue.payments;
    final workflow = data.workflowAnalytics.workflow;

    final stats = [
      _StatItem(
        title: 'Total Users',
        value: _formatNumber(summary.totalUsers),
        icon: Icons.people_outline,
        color: AppColors.primary,
      ),
      _StatItem(
        title: 'Total Forms',
        value: _formatNumber(summary.totalFormsSubmitted),
        icon: Icons.description_outlined,
        color: AppColors.info,
      ),
      _StatItem(
        title: 'Pending Forms',
        value: _formatNumber(summary.totalPendingForms),
        icon: Icons.pending_actions,
        color: AppColors.warning,
      ),
      _StatItem(
        title: 'Approved',
        value: _formatNumber(workflow.paymentCompleted),
        icon: Icons.check_circle_outline,
        color: AppColors.success,
      ),
      _StatItem(
        title: 'In Review',
        value: _formatNumber(summary.totalUnderReviewForms),
        icon: Icons.rate_review_outlined,
        color: AppColors.info,
      ),
      _StatItem(
        title: 'Rejected',
        value: _formatNumber(summary.totalRejectedForms),
        icon: Icons.cancel_outlined,
        color: AppColors.error,
      ),
      _StatItem(
        title: 'Transactions',
        value: _formatNumber(payments.totalTransactions),
        icon: Icons.payment,
        color: AppColors.accent,
      ),
      _StatItem(
        title: 'Revenue',
        value: _formatCurrency(payments.totalRevenue.toDouble()),
        icon: Icons.currency_rupee,
        color: AppColors.success,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.paddingM,
        mainAxisSpacing: AppSizes.paddingM,
        childAspectRatio: 1.6,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(stat.icon, color: stat.color, size: 20),
              const SizedBox(height: 4),
              Text(
                stat.value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stat.title,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatNumber(int value) {
    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  String _formatCurrency(double value) {
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }
}

class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}
