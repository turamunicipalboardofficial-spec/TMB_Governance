import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/atoms/status_badge.dart';
import '../../../core/design_system/molecules/primary_button.dart';
import '../../../core/design_system/organisms/empty_state.dart';
import '../../../core/utils/formatters.dart';
import '../controllers/holding_tax_admin_controller.dart';
import '../models/holding_tax_model.dart';

class HoldingTaxStatsScreen extends GetView<HoldingTaxAdminController> {
  const HoldingTaxStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Holding Tax'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Column(
        children: [
          _buildStatsCard(),
          _buildSearchAndFilters(),
          Expanded(child: _buildResultsList(context)),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(AppSizes.paddingM, AppSizes.paddingM, AppSizes.paddingM, AppSizes.paddingS),
      child: Column(
        children: [
          Obx(() {
            final s = controller.stats.value;
            if (controller.isLoadingStats.value && s == null) {
              return const SizedBox(height: 64, child: Center(child: CircularProgressIndicator()));
            }
            if (s == null) return const SizedBox.shrink();
            return Row(
              children: [
                _StatChip(label: 'Total', value: s.total, color: AppColors.primary, icon: Icons.receipt_long_outlined),
                const SizedBox(width: AppSizes.paddingS),
                _StatChip(label: 'Paid', value: s.paid, color: AppColors.success, icon: Icons.check_circle_outline),
                const SizedBox(width: AppSizes.paddingS),
                _StatChip(label: 'Unpaid', value: s.unpaid, color: AppColors.warning, icon: Icons.pending_outlined),
              ],
            );
          }),
          const SizedBox(height: AppSizes.paddingS),
          Obx(() => Row(
                children: [
                  _buildTypeChip('All Types', '', controller.statsTypeFilter.value, controller.filterStatsByType),
                  _buildTypeChip('House', 'house', controller.statsTypeFilter.value, controller.filterStatsByType),
                  _buildTypeChip('Commercial', 'commercial', controller.statsTypeFilter.value, controller.filterStatsByType),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, String value, String selected, void Function(String?) onSelect) {
    final isSelected = selected == value;
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.paddingS),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: isSelected,
        onSelected: (_) => onSelect(value.isEmpty ? null : value),
        selectedColor: AppColors.primary.withOpacity(0.15),
        visualDensity: VisualDensity.compact,
      ),
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
              hintText: 'Search by holding number...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM, vertical: AppSizes.paddingS),
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Obx(() => Row(
                children: [
                  _buildTypeChip('All', '', controller.selectedTaxType.value, controller.filterByType),
                  _buildTypeChip('House', 'house', controller.selectedTaxType.value, controller.filterByType),
                  _buildTypeChip('Commercial', 'commercial', controller.selectedTaxType.value, controller.filterByType),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    return Obx(() {
      if (controller.isSearching.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.searchResults.isEmpty) {
        return const EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'No Records Found',
          message: 'No holding tax records match your search.',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.only(
          bottom: AppSizes.paddingL,
          left: AppSizes.paddingM,
          right: AppSizes.paddingM,
          top: AppSizes.paddingS,
        ),
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          final item = controller.searchResults[index];
          return _buildResultCard(context, item);
        },
      );
    });
  }

  Widget _buildResultCard(BuildContext context, HoldingTaxSearchItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        onTap: () => _showDetailSheet(context, item.holdingNo),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.taxType == 'commercial' ? AppColors.accentExtraLight : AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Icon(
                  item.taxType == 'commercial' ? Icons.storefront_outlined : Icons.home_outlined,
                  size: 18,
                  color: item.taxType == 'commercial' ? AppColors.accentDark : AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.holdingNo,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    if (item.name != null && item.name!.isNotEmpty)
                      Text(
                        item.name!,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (item.address != null && item.address!.isNotEmpty)
                      Text(
                        item.address!,
                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, String holdingNo) {
    controller.loadDetails(holdingNo);
    Get.bottomSheet(
      _HoldingTaxDetailSheet(holdingNo: holdingNo),
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusL)),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatChip({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(AppSizes.radiusS)),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 2),
            Text(value.toString(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _HoldingTaxDetailSheet extends GetView<HoldingTaxAdminController> {
  final String holdingNo;

  const _HoldingTaxDetailSheet({required this.holdingNo});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Obx(() {
          if (controller.isLoadingDetail.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final holding = controller.selectedHolding.value;
          if (holding == null) {
            return const Center(child: Text('Record not found'));
          }
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        holding.holdingNo,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    StatusBadge(status: holding.paymentStatus),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingS),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: holding.isCommercial ? AppColors.accentExtraLight : AppColors.primaryExtraLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    holding.isCommercial ? 'COMMERCIAL' : 'HOUSE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: holding.isCommercial ? AppColors.accentDark : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),
                if (holding.name != null) _buildDetailRow('Name', holding.name!),
                if (holding.address != null) _buildDetailRow('Address', holding.address!),
                if (holding.wardNo != null) _buildDetailRow('Ward No', holding.wardNo.toString()),
                if (holding.slNo != null) _buildDetailRow('SL No', holding.slNo.toString()),
                if (holding.taxRate != null)
                  _buildDetailRow('Tax Rate', Formatters.formatCurrency(holding.taxRate!.toDouble())),
                if (holding.amountPayable != null)
                  _buildDetailRow('Amount Payable', Formatters.formatCurrency(holding.amountPayable!.toDouble())),
                if (holding.currentYear != null)
                  _buildDetailRow('Current Year', holding.currentYear.toString()),
                if (holding.lastPaymentYear != null)
                  _buildDetailRow('Last Payment Year', holding.lastPaymentYear.toString()),
                if (holding.isPaid && holding.paidAmount != null)
                  _buildDetailRow('Paid Amount', Formatters.formatCurrency(holding.paidAmount!.toDouble())),
                if (holding.isPaid && holding.paymentDate != null)
                  _buildDetailRow('Payment Date', Formatters.formatDate(holding.paymentDate)),
                if (holding.paymentRemarks != null && holding.paymentRemarks!.isNotEmpty)
                  _buildDetailRow('Remarks', holding.paymentRemarks!),
                const SizedBox(height: AppSizes.paddingXL),
                if (!holding.isPaid)
                  Obx(() => PrimaryButton(
                        text: 'Mark as Paid',
                        icon: Icons.check_circle_outline,
                        backgroundColor: AppColors.success,
                        isLoading: controller.isPaying.value,
                        onPressed: () => _showPayDialog(context, holding),
                      ))
                else
                  PrimaryButton(
                    text: 'Download Receipt',
                    icon: Icons.download_outlined,
                    onPressed: () => controller.downloadReceipt(holding.id),
                  ),
                const SizedBox(height: AppSizes.paddingL),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showPayDialog(BuildContext context, HoldingTaxModel holding) {
    final amountCtrl = TextEditingController(
      text: holding.amountPayable != null ? holding.amountPayable!.toString() : '',
    );
    final remarksCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusL)),
        title: const Text('Mark as Paid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Holding No: ${holding.holdingNo}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: AppSizes.paddingM),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Paid Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            TextField(
              controller: remarksCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Payment Remarks (optional)',
                hintText: 'e.g. Paid via UPI',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final amount = double.tryParse(amountCtrl.text.trim());
              await controller.markAsPaid(
                holdingNo: holding.holdingNo,
                paidAmount: amount,
                paymentRemarks: remarksCtrl.text.trim().isEmpty ? null : remarksCtrl.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Confirm', style: TextStyle(color: AppColors.textOnPrimary)),
          ),
        ],
      ),
    );
  }
}
