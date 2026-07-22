import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/atoms/status_badge.dart';
import '../../../core/design_system/molecules/primary_button.dart';
import '../../../core/utils/formatters.dart';
import '../controllers/billing_admin_controller.dart';
import '../models/billing_models.dart';

class UpdatePaymentScreen extends GetView<BillingAdminController> {
  const UpdatePaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bill = Get.arguments as BillModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Update Payment'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: _UpdatePaymentForm(bill: bill),
      ),
    );
  }
}

class _UpdatePaymentForm extends StatefulWidget {
  final BillModel bill;

  const _UpdatePaymentForm({required this.bill});

  @override
  State<_UpdatePaymentForm> createState() => _UpdatePaymentFormState();
}

class _UpdatePaymentFormState extends State<_UpdatePaymentForm> {
  final _orderIdCtrl = TextEditingController();
  final _paymentDetailIdCtrl = TextEditingController();
  final _paymentIdCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  String _status = 'success';

  @override
  void initState() {
    super.initState();
    _amountCtrl.text = widget.bill.balanceDue > 0
        ? widget.bill.balanceDue.toString()
        : widget.bill.totalAmount.toString();
  }

  @override
  void dispose() {
    _orderIdCtrl.dispose();
    _paymentDetailIdCtrl.dispose();
    _paymentIdCtrl.dispose();
    _amountCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bill = widget.bill;
    final controller = Get.find<BillingAdminController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBillSummary(bill),
        const SizedBox(height: AppSizes.paddingXL),
        const Text('Payment Reference', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSizes.paddingS),
        Text(
          'Provide either a Payment Detail ID or an Order ID to identify the payment record to reconcile.',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSizes.paddingM),
        TextField(
          controller: _paymentDetailIdCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Payment Detail ID',
            prefixIcon: const Icon(Icons.numbers_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        TextField(
          controller: _orderIdCtrl,
          decoration: InputDecoration(
            labelText: 'Order ID (alternative)',
            prefixIcon: const Icon(Icons.confirmation_number_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        TextField(
          controller: _paymentIdCtrl,
          decoration: InputDecoration(
            labelText: 'Payment ID (optional)',
            prefixIcon: const Icon(Icons.payment_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
          ),
        ),
        const SizedBox(height: AppSizes.paddingL),
        const Text('Payment Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSizes.paddingM),
        TextField(
          controller: _amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Amount',
            prefixText: '₹ ',
            prefixIcon: const Icon(Icons.currency_rupee),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        _buildStatusSelector(),
        const SizedBox(height: AppSizes.paddingM),
        TextField(
          controller: _remarksCtrl,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Payment Remarks (optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
          ),
        ),
        const SizedBox(height: AppSizes.paddingXL),
        Obx(() => PrimaryButton(
              text: 'Update Payment Status',
              icon: Icons.sync_outlined,
              isLoading: controller.isUpdatingPayment.value,
              onPressed: () => _submit(context, controller),
            )),
      ],
    );
  }

  Widget _buildBillSummary(BillModel bill) {
    return Container(
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
          Row(
            children: [
              Expanded(
                child: Text(
                  '${bill.marketId} · Shop ${bill.shopNo}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              StatusBadge(status: bill.status),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Row(
            children: [
              Expanded(child: _SummaryItem(label: 'Total', value: bill.totalAmount)),
              Expanded(child: _SummaryItem(label: 'Paid', value: bill.paidAmount, color: AppColors.success)),
              Expanded(child: _SummaryItem(label: 'Balance Due', value: bill.balanceDue, color: AppColors.warning)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Bill ID: ${bill.id}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildStatusSelector() {
    final options = ['success', 'pending', 'failed'];
    return Wrap(
      spacing: AppSizes.paddingS,
      children: options.map((opt) {
        final isSelected = _status == opt;
        return ChoiceChip(
          label: Text(opt[0].toUpperCase() + opt.substring(1)),
          selected: isSelected,
          onSelected: (_) => setState(() => _status = opt),
          selectedColor: AppColors.primary.withOpacity(0.15),
        );
      }).toList(),
    );
  }

  Future<void> _submit(BuildContext context, BillingAdminController controller) async {
    final paymentDetailId = int.tryParse(_paymentDetailIdCtrl.text.trim());
    final orderId = _orderIdCtrl.text.trim();

    if (paymentDetailId == null && orderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provide a Payment Detail ID or Order ID')),
      );
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.trim());

    final success = await controller.updatePaymentStatus(
      billId: widget.bill.id,
      paymentDetailId: paymentDetailId,
      orderId: orderId.isEmpty ? null : orderId,
      paymentId: _paymentIdCtrl.text.trim().isEmpty ? null : _paymentIdCtrl.text.trim(),
      amount: amount,
      status: _status,
      paymentRemarks: _remarksCtrl.text.trim().isEmpty ? null : _remarksCtrl.text.trim(),
    );

    if (success && context.mounted) {
      Get.back();
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final num value;
  final Color? color;

  const _SummaryItem({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        Text(
          Formatters.formatCurrency(value.toDouble()),
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color ?? AppColors.textPrimary),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
