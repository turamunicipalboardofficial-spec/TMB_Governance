import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/atoms/status_badge.dart';
import '../../../core/design_system/organisms/empty_state.dart';
import '../../../core/utils/formatters.dart';
import '../controllers/payment_history_controller.dart';
import '../models/payment_history_model.dart';

class PaymentHistoryScreen extends GetView<PaymentHistoryController> {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Column(
        children: [
          _buildSummaryBar(),
          _buildSearchAndFilters(),
          Expanded(child: _buildPaymentList()),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(AppSizes.paddingM, AppSizes.paddingM, AppSizes.paddingM, AppSizes.paddingS),
      child: Obx(() => Row(
            children: [
              _SummaryChip(
                icon: Icons.receipt_long_outlined,
                label: 'Total Transactions',
                value: controller.total.value.toString(),
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSizes.paddingS),
              _SummaryChip(
                icon: Icons.currency_rupee,
                label: 'Loaded Revenue',
                value: Formatters.formatCurrency(controller.loadedTotalAmount.toDouble()),
                color: AppColors.success,
              ),
            ],
          )),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.paddingM, 0, AppSizes.paddingM, AppSizes.paddingM),
      color: AppColors.surface,
      child: Column(
        children: [
          TextField(
            onChanged: controller.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by order ID or transaction ID...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM, vertical: AppSizes.paddingS),
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() => Row(
                  children: [
                    _buildStatusChip('All', ''),
                    _buildStatusChip('Success', 'success'),
                    _buildStatusChip('Failed', 'failed'),
                    _buildStatusChip('Pending', 'pending'),
                  ],
                )),
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

  Widget _buildPaymentList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.payments.isEmpty) {
        return const EmptyState(
          icon: Icons.payment_outlined,
          title: 'No Transactions Found',
          message: 'No payment records match your current filters.',
        );
      }
      return RefreshIndicator(
        onRefresh: controller.fetchPaymentHistory,
        child: ListView.builder(
          padding: const EdgeInsets.only(
            bottom: AppSizes.paddingL,
            left: AppSizes.paddingM,
            right: AppSizes.paddingM,
            top: AppSizes.paddingS,
          ),
          itemCount: controller.payments.length +
              (controller.currentPage.value < controller.lastPage.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.payments.length) {
              controller.loadMore();
              return const Padding(
                padding: EdgeInsets.all(AppSizes.paddingM),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _buildPaymentCard(controller.payments[index]);
          },
        ),
      );
    });
  }

  Widget _buildPaymentCard(PaymentHistoryItem payment) {
    final statusColor = _statusColor(payment.status);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Icon(_statusIcon(payment.status), color: statusColor, size: 20),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          payment.userName,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      StatusBadge(status: payment.status),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (payment.orderId != null)
                    Text(
                      'Order: ${payment.orderId}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (payment.transactionId != null)
                    Text(
                      'Txn: ${payment.transactionId}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        Formatters.formatCurrency(payment.amount.toDouble()),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: statusColor),
                      ),
                      const Spacer(),
                      Text(
                        Formatters.timeAgo(payment.paymentDate),
                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'success':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'success':
        return Icons.check_circle_outline;
      case 'failed':
        return Icons.cancel_outlined;
      case 'pending':
        return Icons.pending_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS, horizontal: AppSizes.paddingS),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(AppSizes.radiusS)),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AppSizes.paddingS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
