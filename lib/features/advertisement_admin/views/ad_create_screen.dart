import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/molecules/inline_dropdown_field.dart';
import '../../../core/design_system/molecules/primary_button.dart';
import '../controllers/advertisement_admin_controller.dart';

class AdCreateScreen extends GetView<AdvertisementAdminController> {
  const AdCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditing ? 'Edit Advertisement' : 'Create Advertisement'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionLabel('Advertiser Details'),
              TextFormField(
                controller: controller.advertiserNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Advertiser Name *',
                  hintText: 'e.g. Green Valley Restaurant',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Advertiser name is required';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingM),
              Obx(() => InlineDropdownField<String>(
                    value: controller.selectedFormAdvertiserType.value,
                    items: kAdvertiserTypes,
                    placeholder: 'Select Advertiser Type',
                    label: 'Advertiser Type *',
                    prefixIcon: Icons.category_outlined,
                    itemLabel: (t) => t[0].toUpperCase() + t.substring(1),
                    onChanged: (t) => controller.selectedFormAdvertiserType.value = t,
                  )),
              const SizedBox(height: AppSizes.paddingM),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.contactPersonCtrl,
                      decoration: const InputDecoration(labelText: 'Contact Person'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: TextFormField(
                      controller: controller.contactPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Contact Phone'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: controller.contactEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Contact Email'),
              ),
              const SizedBox(height: AppSizes.paddingXL),
              _sectionLabel('Ad Content'),
              TextFormField(
                controller: controller.titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. 20% off this weekend',
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: controller.descriptionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: controller.imageUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: controller.websiteUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Website URL',
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: controller.redirectUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Redirect URL (on ad click)',
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: AppSizes.paddingXL),
              _sectionLabel('Placement & Schedule'),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => InlineDropdownField<String>(
                          value: controller.selectedFormPosition.value,
                          items: kAdPositions,
                          placeholder: 'Position',
                          label: 'Position',
                          prefixIcon: Icons.dashboard_outlined,
                          itemLabel: (p) => p.replaceAll('_', ' '),
                          onChanged: (p) => controller.selectedFormPosition.value = p ?? 'inline',
                        )),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: Obx(() => InlineDropdownField<String>(
                          value: controller.selectedFormStatus.value,
                          items: kAdStatuses,
                          placeholder: 'Status',
                          label: 'Status',
                          prefixIcon: Icons.info_outline,
                          itemLabel: (s) => s[0].toUpperCase() + s.substring(1),
                          onChanged: (s) => controller.selectedFormStatus.value = s ?? 'draft',
                        )),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.startDateCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        hintText: 'YYYY-MM-DD',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () => _pickDate(context, controller.startDateCtrl),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: TextFormField(
                      controller: controller.endDateCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        hintText: 'YYYY-MM-DD',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () => _pickDate(context, controller.endDateCtrl),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.amountPaidCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount Paid',
                        prefixText: '₹ ',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: TextFormField(
                      controller: controller.priorityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        hintText: 'Higher shows first',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingXL),
              Obx(() => PrimaryButton(
                    text: controller.isEditing ? 'Update Advertisement' : 'Create Advertisement',
                    isLoading: controller.isSaving.value,
                    onPressed: controller.submitAdForm,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, TextEditingController ctrl) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) {
      ctrl.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }
}
