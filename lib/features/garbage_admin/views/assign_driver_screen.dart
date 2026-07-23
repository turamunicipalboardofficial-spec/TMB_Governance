import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/molecules/inline_dropdown_field.dart';
import '../../../core/design_system/molecules/primary_button.dart';
import '../controllers/garbage_admin_controller.dart';
import '../models/garbage_models.dart';

class AssignDriverScreen extends GetView<GarbageAdminController> {
  const AssignDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Driver'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select a driver and the truck to assign them to. This replaces any current assignment for that driver.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.paddingL),
            Obx(() => InlineDropdownField<DriverProfileModel>(
                  value: controller.drivers.firstWhereOrNull(
                    (d) => d.userId == controller.selectedAssignDriverUserId.value,
                  ),
                  items: controller.drivers,
                  placeholder: 'Select Driver',
                  label: 'Driver *',
                  prefixIcon: Icons.person_outline,
                  itemLabel: (d) => d.displayLabel,
                  isLoading: controller.isLoadingDrivers.value,
                  emptyMessage: 'No drivers found',
                  onChanged: (d) => controller.selectedAssignDriverUserId.value = d?.userId,
                )),
            const SizedBox(height: AppSizes.paddingM),
            Obx(() => InlineDropdownField<GarbageTruckModel>(
                  value: controller.trucks.firstWhereOrNull(
                    (t) => t.id == controller.selectedAssignTruckId.value,
                  ),
                  items: controller.trucks,
                  placeholder: 'Select Truck',
                  label: 'Truck *',
                  prefixIcon: Icons.local_shipping_outlined,
                  itemLabel: (t) => '${t.truckNumber} (${t.plateNumber})',
                  isLoading: controller.isLoadingTrucks.value,
                  emptyMessage: 'No trucks found',
                  onChanged: (t) => controller.selectedAssignTruckId.value = t?.id,
                )),
            const SizedBox(height: AppSizes.paddingXL),
            Obx(() => PrimaryButton(
                  text: 'Assign Driver',
                  isLoading: controller.isAssigningDriver.value,
                  onPressed: controller.submitAssignDriver,
                )),
          ],
        ),
      ),
    );
  }
}
