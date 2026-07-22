import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/admin_dashboard_response.dart';
import 'simple_bar_chart.dart';

/// Renders the dashboard chart cards: monthly revenue, monthly applications,
/// and top service-wise revenue. Daily series are intentionally omitted from
/// the default view to keep the dashboard minimal; monthly trends give a
/// clearer picture at a glance.
class ChartsSectionView extends StatelessWidget {
  final ChartsData charts;

  const ChartsSectionView({super.key, required this.charts});

  @override
  Widget build(BuildContext context) {
    final hasMonthlyRevenue = charts.monthlyRevenue.any((e) => e.amount > 0);
    final hasMonthlyApps = charts.monthlyApplications.any((e) => e.count > 0);
    final hasServiceRevenue = charts.serviceWiseRevenue.isNotEmpty;

    if (!hasMonthlyRevenue && !hasMonthlyApps && !hasServiceRevenue) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasMonthlyRevenue) ...[
          _ChartCard(
            title: 'Monthly Revenue',
            child: SimpleBarChart(
              color: AppColors.success,
              valueFormatter: (v) => _compactCurrency(v),
              points: charts.monthlyRevenue
                  .map((e) => BarChartPoint(
                        label: _shortMonth(e.month),
                        value: e.amount.toDouble(),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
        ],
        if (hasMonthlyApps) ...[
          _ChartCard(
            title: 'Monthly Applications',
            child: SimpleBarChart(
              color: AppColors.primary,
              points: charts.monthlyApplications
                  .map((e) => BarChartPoint(
                        label: _shortMonth(e.month),
                        value: e.count.toDouble(),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
        ],
        if (hasServiceRevenue)
          _ChartCard(
            title: 'Revenue by Service',
            child: _ServiceRevenueList(services: charts.serviceWiseRevenue),
          ),
      ],
    );
  }

  String _shortMonth(String yyyyMm) {
    // "2026-07" -> "Jul"
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final parts = yyyyMm.split('-');
    if (parts.length != 2) return yyyyMm;
    final monthIndex = int.tryParse(parts[1]);
    if (monthIndex == null || monthIndex < 1 || monthIndex > 12) return yyyyMm;
    return months[monthIndex - 1];
  }

  String _compactCurrency(double value) {
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          child,
        ],
      ),
    );
  }
}

class _ServiceRevenueList extends StatelessWidget {
  final List<ServiceRevenuePoint> services;

  const _ServiceRevenueList({required this.services});

  @override
  Widget build(BuildContext context) {
    final sorted = [...services]
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
    final top = sorted.take(6).toList();
    final maxRevenue = top.isNotEmpty ? top.first.revenue.toDouble() : 1.0;
    final safeMax = maxRevenue <= 0 ? 1.0 : maxRevenue;

    return Column(
      children: top.map((s) {
        final ratio = (s.revenue.toDouble() / safeMax).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  s.service,
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.paddingS),
              SizedBox(
                width: 56,
                child: Text(
                  '₹${s.revenue.toStringAsFixed(0)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
