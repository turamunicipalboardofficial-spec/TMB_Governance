import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/admin_dashboard_response.dart';

class CitizenAnalyticsCard extends StatelessWidget {
  final CitizenData citizens;

  const CitizenAnalyticsCard({super.key, required this.citizens});

  @override
  Widget build(BuildContext context) {
    final genderTotal =
        citizens.maleUsers + citizens.femaleUsers + citizens.otherUsers;

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
        children: [
          Row(
            children: [
              _CitizenStat(
                value: citizens.totalRegistered.toString(),
                label: 'Registered',
                color: AppColors.primary,
              ),
              _CitizenStat(
                value: citizens.activeUsers.toString(),
                label: 'Active',
                color: AppColors.success,
              ),
              _CitizenStat(
                value: citizens.newUsersThisMonth.toString(),
                label: 'New this month',
                color: AppColors.info,
              ),
            ],
          ),
          const Divider(height: AppSizes.paddingXXL),
          Row(
            children: [
              Expanded(
                child: _VerificationRow(
                  verified: citizens.verifiedUsers,
                  unverified: citizens.unverifiedUsers,
                ),
              ),
            ],
          ),
          if (genderTotal > 0) ...[
            const SizedBox(height: AppSizes.paddingL),
            Text(
              'Gender distribution',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Row(
              children: [
                _GenderChip(
                  label: 'Male',
                  count: citizens.maleUsers,
                  color: AppColors.info,
                ),
                const SizedBox(width: AppSizes.paddingS),
                _GenderChip(
                  label: 'Female',
                  count: citizens.femaleUsers,
                  color: AppColors.accent,
                ),
                const SizedBox(width: AppSizes.paddingS),
                _GenderChip(
                  label: 'Other',
                  count: citizens.otherUsers,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CitizenStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _CitizenStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _VerificationRow extends StatelessWidget {
  final int verified;
  final int unverified;

  const _VerificationRow({required this.verified, required this.unverified});

  @override
  Widget build(BuildContext context) {
    final total = verified + unverified;
    final ratio = total > 0 ? verified / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Email verified',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            Text(
              '$verified / $total',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.errorLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
          ),
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _GenderChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingS,
          vertical: AppSizes.paddingXS,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
