import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical: AppSizes.paddingXXS,
      ),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color get _bgColor {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'draft':
      case 'unpaid':
        return AppColors.warningLight;
      case 'approved':
      case 'active':
      case 'published':
      case 'paid':
      case 'resolved':
      case 'success':
      case 'completed':
        return AppColors.successLight;
      case 'rejected':
      case 'expired':
      case 'cancelled':
      case 'failed':
      case 'retired':
        return AppColors.errorLight;
      case 'in_progress':
      case 'paused':
      case 'maintenance':
      case 'partial':
        return AppColors.infoLight;
      case 'archived':
      case 'inactive':
        return AppColors.surfaceVariant;
      default:
        return AppColors.surfaceVariant;
    }
  }

  Color get _textColor {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'draft':
      case 'unpaid':
        return AppColors.warning;
      case 'approved':
      case 'active':
      case 'published':
      case 'paid':
      case 'resolved':
      case 'success':
      case 'completed':
        return AppColors.success;
      case 'rejected':
      case 'expired':
      case 'cancelled':
      case 'failed':
      case 'retired':
        return AppColors.error;
      case 'in_progress':
      case 'paused':
      case 'maintenance':
      case 'partial':
        return AppColors.info;
      case 'archived':
      case 'inactive':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }
}