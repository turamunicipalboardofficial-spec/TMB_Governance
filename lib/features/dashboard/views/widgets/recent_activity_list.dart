import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class RecentActivity {
  final String title;
  final String description;
  final String type;
  final String timestamp;

  const RecentActivity({
    required this.title,
    this.description = '',
    this.type = 'default',
    this.timestamp = '',
  });
}

class RecentActivityList extends StatelessWidget {
  final List<RecentActivity> activities;

  const RecentActivityList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.divider),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _getActivityColor(activity.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Icon(
                  _getActivityIcon(activity.type),
                  size: 18,
                  color: _getActivityColor(activity.type),
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (activity.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        activity.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (activity.timestamp.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        activity.timestamp,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'form':
        return Icons.description_outlined;
      case 'payment':
        return Icons.payment;
      case 'notice':
      case 'announcement':
        return Icons.campaign_outlined;
      case 'truck':
      case 'garbage':
        return Icons.local_shipping_outlined;
      case 'grievance':
        return Icons.report_outlined;
      case 'job':
        return Icons.work_outline;
      case 'trade_license':
        return Icons.business_outlined;
      case 'notification':
        return Icons.notifications_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'form':
        return AppColors.info;
      case 'payment':
        return AppColors.success;
      case 'notice':
      case 'announcement':
        return AppColors.warning;
      case 'truck':
      case 'garbage':
        return AppColors.accent;
      case 'grievance':
        return AppColors.error;
      case 'job':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }
}