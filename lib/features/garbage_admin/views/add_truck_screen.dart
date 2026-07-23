import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/molecules/inline_dropdown_field.dart';
import '../../../core/design_system/molecules/primary_button.dart';
import '../../../core/models/ward_model.dart';
import '../controllers/garbage_admin_controller.dart';

class AddTruckScreen extends GetView<GarbageAdminController> {
  const AddTruckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditingTruck ? 'Edit Truck' : 'Add Truck'),
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
              TextFormField(
                controller: controller.truckNumberCtrl,
                decoration: const InputDecoration(
                  labelText: 'Truck Number *',
                  hintText: 'e.g. TMB-GT-01',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Truck number is required';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: controller.plateNumberCtrl,
                decoration: const InputDecoration(
                  labelText: 'Plate Number *',
                  hintText: 'e.g. ML-05-AB-1234',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Plate number is required';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingM),
              Obx(() => InlineDropdownField<String>(
                    value: controller.selectedTruckType.value,
                    items: kTruckTypes,
                    placeholder: 'Select Truck Type',
                    label: 'Truck Type *',
                    prefixIcon: Icons.category_outlined,
                    itemLabel: (t) => t.replaceAll('_', ' ').split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
                    onChanged: (t) => controller.selectedTruckType.value = t,
                  )),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: controller.capacityTonsCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Capacity (Tons) *',
                  hintText: 'e.g. 5.0',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Capacity is required';
                  final n = num.tryParse(v.trim());
                  if (n == null || n < 0.5) return 'Enter a valid capacity (min 0.5)';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingM),
              Obx(() => InlineDropdownField<WardModel>(
                    value: controller.wards.firstWhereOrNull((w) => w.id == controller.selectedFormWardId.value),
                    items: controller.wards,
                    placeholder: 'Select Ward',
                    label: 'Ward *',
                    prefixIcon: Icons.location_city,
                    itemLabel: (w) => w.wardName,
                    isLoading: controller.isLoadingWards.value,
                    onChanged: (w) => controller.selectedFormWardId.value = w?.id,
                  )),
              const SizedBox(height: AppSizes.paddingM),
              Obx(() => InlineDropdownField<String>(
                    value: controller.selectedTruckStatus.value,
                    items: kTruckStatuses,
                    placeholder: 'Select Status',
                    label: 'Status',
                    prefixIcon: Icons.info_outline,
                    itemLabel: (s) => s[0].toUpperCase() + s.substring(1),
                    onChanged: (s) => controller.selectedTruckStatus.value = s ?? 'active',
                  )),
              const SizedBox(height: AppSizes.paddingXL),
              Obx(() => PrimaryButton(
                    text: controller.isEditingTruck ? 'Update Truck' : 'Add Truck',
                    isLoading: controller.isSavingTruck.value,
                    onPressed: controller.submitTruckForm,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
