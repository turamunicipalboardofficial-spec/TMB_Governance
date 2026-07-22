import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/formatters.dart';
import '../../models/admin_dashboard_response.dart';

class BillingAnalyticsCard extends StatelessWidget {
  final BillingData billing;

  const BillingAnalyticsCard({super.key, required this.billing});

  @override
  Widget build(BuildContext context) {
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
              _BillingStat(
                label: 'Markets',
                value: billing.totalMarkets.toString(),
                icon: Icons.storefront_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSizes.paddingM),
              _BillingStat(
                label: 'Shops',
                value: billing.totalShops.toString(),
                icon: Icons.store_outlined,
                color: AppColors.info,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          Row(
            children: [
              _OccupancyBar(
                label: 'Occupied',
                value: billing.occupiedShops,
                total: billing.totalShops,
                color: AppColors.success,
              ),
              const SizedBox(width: AppSizes.paddingM),
              _OccupancyBar(
                label: 'Vacant',
                value: billing.vacantShops,
                total: billing.totalShops,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          const Divider(height: AppSizes.paddingXXL),
          Row(
            children: [
              Expanded(
                child: _AmountItem(
                  label: 'Collected',
                  amount: billing.collectedAmount,
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _AmountItem(
                  label: 'Outstanding',
                  amount: billing.outstandingAmount,
                  color: AppColors.warning,
                ),
              ),
              Expanded(
                child: _AmountItem(
                  label: 'Overdue',
                  amount: billing.overdueAmount,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          if (billing.collectionRate > 0) ...[
            const SizedBox(height: AppSizes.paddingM),
            Row(
              children: [
                Text(
                  'Collection rate: ',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                Text(
                  '${billing.collectionRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
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

class _BillingStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _BillingStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: AppSizes.paddingS),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OccupancyBar extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;

  const _OccupancyBar({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? value / total : 0.0;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(
                '$value',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountItem extends StatelessWidget {
  final String label;
  final num amount;
  final Color color;

  const _AmountItem({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Formatters.formatCurrency(amount.toDouble()),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
