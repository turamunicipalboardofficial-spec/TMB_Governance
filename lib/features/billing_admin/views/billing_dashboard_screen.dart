import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/atoms/status_badge.dart';
import '../../../core/design_system/molecules/inline_dropdown_field.dart';
import '../../../core/design_system/molecules/primary_button.dart';
import '../../../core/design_system/organisms/empty_state.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/app_routes.dart';
import '../controllers/billing_admin_controller.dart';
import '../models/billing_models.dart';

class BillingDashboardScreen extends GetView<BillingAdminController> {
  const BillingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Commercial Rent'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickActions(),
            const SizedBox(height: AppSizes.paddingXL),
            Text(
              'Shop Lookup',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSizes.paddingS),
            _buildShopLookupForm(),
            const SizedBox(height: AppSizes.paddingL),
            Obx(() {
              if (controller.isLoadingShopBills.value) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingXL),
                  child: CircularProgressIndicator(),
                ));
              }
              final result = controller.shopBills.value;
              final due = controller.outstanding.value;
              if (result == null) return const SizedBox.shrink();
              return _buildShopResult(context, result, due);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.edit_note_outlined,
            label: 'Generate Rent Bills',
            color: AppColors.primary,
            onTap: () => Get.toNamed(AppRoutes.generateBills),
          ),
        ),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(
          child: _ActionCard(
            icon: Icons.upload_file_outlined,
            label: 'Upload Sheet',
            color: AppColors.info,
            onTap: () => Get.toNamed(AppRoutes.generateBills, arguments: 'upload'),
          ),
        ),
      ],
    );
  }

  Widget _buildShopLookupForm() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Obx(() => InlineDropdownField<MarketModel>(
                value: controller.selectedMarket.value,
                items: controller.markets,
                placeholder: 'Select Market',
                label: 'Market',
                prefixIcon: Icons.storefront_outlined,
                itemLabel: (m) => m.marketName,
                isLoading: controller.isLoadingMarkets.value,
                emptyMessage: 'No markets available',
                onChanged: (m) => controller.selectedMarket.value = m,
              )),
          const SizedBox(height: AppSizes.paddingM),
          TextField(
            controller: controller.shopNoCtrl,
            decoration: InputDecoration(
              labelText: 'Shop No',
              hintText: 'e.g. S-101',
              prefixIcon: const Icon(Icons.store_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Obx(() => PrimaryButton(
                text: 'Search',
                icon: Icons.search,
                isLoading: controller.isLoadingShopBills.value,
                onPressed: controller.lookupShop,
              )),
        ],
      ),
    );
  }

  Widget _buildShopResult(BuildContext context, ShopBillsResult result, OutstandingResult? due) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.shopName ?? result.shopNo,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Text(
                '${result.marketName ?? result.marketId} · Shop ${result.shopNo}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              if (result.ownerName != null) ...[
                const SizedBox(height: 2),
                Text('Owner: ${result.ownerName}', style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
              ],
              const SizedBox(height: AppSizes.paddingM),
              Row(
                children: [
                  _StatChip(label: 'Monthly Rent', value: Formatters.formatCurrency(result.monthlyRent.toDouble()), color: AppColors.primary),
                  const SizedBox(width: AppSizes.paddingS),
                  _StatChip(label: 'Outstanding', value: Formatters.formatCurrency(result.summary.totalOutstandingAmount.toDouble()), color: AppColors.warning),
                ],
              ),
              if (due != null && due.overdueAmount > 0) ...[
                const SizedBox(height: AppSizes.paddingS),
                Row(
                  children: [
                    _StatChip(label: 'Overdue', value: Formatters.formatCurrency(due.overdueAmount.toDouble()), color: AppColors.error),
                    const SizedBox(width: AppSizes.paddingS),
                    _StatChip(label: 'Open Bills', value: due.openBillsCount.toString(), color: AppColors.info),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSizes.paddingL),
        Text(
          'Bill History (${result.summary.totalBills})',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSizes.paddingS),
        if (result.bills.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.paddingXL),
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No Bills Yet',
              message: 'No commercial rent history found for this shop.',
            ),
          )
        else
          ...result.bills.map((bill) => _buildBillCard(context, bill)),
      ],
    );
  }

  Widget _buildBillCard(BuildContext context, BillModel bill) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        onTap: () => Get.toNamed(AppRoutes.updatePayment, arguments: bill),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _monthLabel(bill.billMonth),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  StatusBadge(status: bill.status),
                  if (bill.isOverdue) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.error),
                  ],
                ],
              ),
              const SizedBox(height: AppSizes.paddingS),
              Row(
                children: [
                  Expanded(child: _MiniAmount(label: 'Total', value: bill.totalAmount)),
                  Expanded(child: _MiniAmount(label: 'Paid', value: bill.paidAmount, color: AppColors.success)),
                  Expanded(child: _MiniAmount(label: 'Due', value: bill.balanceDue, color: AppColors.warning)),
                ],
              ),
              if (bill.dueDate != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Due: ${Formatters.formatDate(bill.dueDate)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _monthLabel(String? billMonth) {
    if (billMonth == null || billMonth.isEmpty) return '';
    try {
      final date = DateTime.parse(billMonth);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return billMonth;
    }
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(AppSizes.radiusS)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS, horizontal: AppSizes.paddingS),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(AppSizes.radiusS)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color), overflow: TextOverflow.ellipsis),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _MiniAmount extends StatelessWidget {
  final String label;
  final num value;
  final Color? color;

  const _MiniAmount({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
        Text(
          Formatters.formatCurrency(value.toDouble()),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
