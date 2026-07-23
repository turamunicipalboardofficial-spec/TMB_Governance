import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/molecules/primary_button.dart';
import '../controllers/billing_admin_controller.dart';
import '../models/billing_models.dart';

class GenerateBillsScreen extends GetView<BillingAdminController> {
  const GenerateBillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Optional navigation argument 'upload' opens directly on the upload tab.
    final startOnUpload = Get.arguments == 'upload';

    return DefaultTabController(
      initialIndex: startOnUpload ? 1 : 0,
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Generate Rent Bills'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          bottom: const TabBar(
            indicatorColor: AppColors.textOnPrimary,
            labelColor: AppColors.textOnPrimary,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Manual Entry', icon: Icon(Icons.edit_note_outlined, size: 18)),
              Tab(text: 'Upload Sheet', icon: Icon(Icons.upload_file_outlined, size: 18)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ManualEntryTab(),
            _UploadSheetTab(),
          ],
        ),
      ),
    );
  }
}

class _ManualEntryTab extends GetView<BillingAdminController> {
  const _ManualEntryTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller.generateBillMonthCtrl,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Bill Month',
              hintText: 'Select month',
              prefixIcon: const Icon(Icons.calendar_month_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
            ),
            onTap: () => _pickMonth(context, controller.generateBillMonthCtrl),
          ),
          const SizedBox(height: AppSizes.paddingL),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shops', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              TextButton.icon(
                onPressed: controller.addBillRow,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Shop'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Obx(() => Column(
                children: controller.billRows.asMap().entries.map((entry) {
                  return _BillRowCard(index: entry.key, row: entry.value);
                }).toList(),
              )),
          const SizedBox(height: AppSizes.paddingXL),
          Obx(() => PrimaryButton(
                text: 'Generate Rent Bills',
                icon: Icons.receipt_long_outlined,
                isLoading: controller.isGenerating.value,
                onPressed: controller.submitGenerateBills,
              )),
          const SizedBox(height: AppSizes.paddingL),
          Obx(() {
            final result = controller.generateResult.value;
            if (result == null) return const SizedBox.shrink();
            return _GenerateResultCard(result: result);
          }),
        ],
      ),
    );
  }

  Future<void> _pickMonth(BuildContext context, TextEditingController ctrl) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select bill month',
    );
    if (picked != null) {
      ctrl.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
    }
  }
}

class _BillRowCard extends GetView<BillingAdminController> {
  final int index;
  final BillRowInput row;

  const _BillRowCard({required this.index, required this.row});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Shop #${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const Spacer(),
              Obx(() => controller.billRows.length > 1
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18, color: AppColors.error),
                      onPressed: () => controller.removeBillRow(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: row.marketId,
                  decoration: const InputDecoration(labelText: 'Market ID', isDense: true),
                  onChanged: (v) => row.marketId = v.trim(),
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: TextFormField(
                  initialValue: row.shopNo,
                  decoration: const InputDecoration(labelText: 'Shop No', isDense: true),
                  onChanged: (v) => row.shopNo = v.trim(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          TextFormField(
            initialValue: row.electricityAmount == 0 ? '' : row.electricityAmount.toString(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Electricity Amount', isDense: true, prefixText: '₹ '),
            onChanged: (v) => row.electricityAmount = double.tryParse(v) ?? 0,
          ),
        ],
      ),
    );
  }
}

class _GenerateResultCard extends StatelessWidget {
  final GenerateBillsResult result;

  const _GenerateResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 18),
              const SizedBox(width: AppSizes.paddingS),
              Text(
                '${result.generatedCount} bill(s) generated for ${result.billMonth}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text('Due date: ${result.dueDate}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _UploadSheetTab extends GetView<BillingAdminController> {
  const _UploadSheetTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller.uploadBillMonthCtrl,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Bill Month',
              hintText: 'Select month',
              prefixIcon: const Icon(Icons.calendar_month_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
            ),
            onTap: () => _pickMonth(context, controller.uploadBillMonthCtrl),
          ),
          const SizedBox(height: AppSizes.paddingM),
          TextField(
            controller: controller.uploadSheetNameCtrl,
            decoration: InputDecoration(
              labelText: 'Sheet Name (optional)',
              hintText: 'For XLSX files with multiple sheets',
              prefixIcon: const Icon(Icons.table_chart_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          Obx(() => _FilePickerBox(fileName: controller.pickedFileName.value)),
          const SizedBox(height: AppSizes.paddingXL),
          Obx(() => PrimaryButton(
                text: 'Upload & Generate',
                icon: Icons.upload_file_outlined,
                isLoading: controller.isUploading.value,
                onPressed: controller.submitUploadBillingSheet,
              )),
          const SizedBox(height: AppSizes.paddingL),
          Obx(() {
            final result = controller.uploadResult.value;
            if (result == null) return const SizedBox.shrink();
            return _GenerateResultCard(result: result);
          }),
        ],
      ),
    );
  }

  Future<void> _pickMonth(BuildContext context, TextEditingController ctrl) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select bill month',
    );
    if (picked != null) {
      ctrl.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
    }
  }
}

class _FilePickerBox extends GetView<BillingAdminController> {
  final String fileName;

  const _FilePickerBox({required this.fileName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: fileName.isEmpty ? AppColors.border : AppColors.primary,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              fileName.isEmpty ? Icons.cloud_upload_outlined : Icons.insert_drive_file_outlined,
              size: 36,
              color: fileName.isEmpty ? AppColors.textTertiary : AppColors.primary,
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              fileName.isEmpty ? 'Tap to select XLSX or CSV file' : fileName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: fileName.isEmpty ? FontWeight.w400 : FontWeight.w600,
                color: fileName.isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (fileName.isNotEmpty) ...[
              const SizedBox(height: AppSizes.paddingS),
              TextButton.icon(
                onPressed: controller.clearPickedFile,
                icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                label: const Text('Remove', style: TextStyle(color: AppColors.error, fontSize: 12)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'csv'],
    );
    if (result != null && result.files.single.path != null) {
      controller.setPickedFile(result.files.single.path!, result.files.single.name);
    }
  }
}
