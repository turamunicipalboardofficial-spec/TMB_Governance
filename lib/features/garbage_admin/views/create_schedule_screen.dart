import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/molecules/inline_dropdown_field.dart';
import '../../../core/design_system/molecules/primary_button.dart';
import '../../../core/models/ward_model.dart';
import '../controllers/garbage_admin_controller.dart';
import '../models/garbage_models.dart';

class CreateScheduleScreen extends GetView<GarbageAdminController> {
  const CreateScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Collection Schedule'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() => InlineDropdownField<WardModel>(
                  value: controller.wards.firstWhereOrNull(
                    (w) => w.id == controller.selectedScheduleWardId.value,
                  ),
                  items: controller.wards,
                  placeholder: 'Select Ward',
                  label: 'Ward *',
                  prefixIcon: Icons.location_city,
                  itemLabel: (w) => w.wardName,
                  isLoading: controller.isLoadingWards.value,
                  onChanged: (w) => controller.selectedScheduleWardId.value = w?.id,
                )),
            const SizedBox(height: AppSizes.paddingM),
            Obx(() => InlineDropdownField<GarbageTruckModel>(
                  value: controller.trucks.firstWhereOrNull(
                    (t) => t.id == controller.selectedScheduleTruckId.value,
                  ),
                  items: controller.trucks,
                  placeholder: 'Select Truck',
                  label: 'Truck *',
                  prefixIcon: Icons.local_shipping_outlined,
                  itemLabel: (t) => '${t.truckNumber} (${t.plateNumber})',
                  isLoading: controller.isLoadingTrucks.value,
                  emptyMessage: 'No trucks found',
                  onChanged: (t) => controller.selectedScheduleTruckId.value = t?.id,
                )),
            const SizedBox(height: AppSizes.paddingM),
            Obx(() => InlineDropdownField<String>(
                  value: controller.selectedDayOfWeek.value,
                  items: kDaysOfWeek,
                  placeholder: 'Select Day',
                  label: 'Day of Week *',
                  prefixIcon: Icons.calendar_today_outlined,
                  itemLabel: (d) => d[0].toUpperCase() + d.substring(1),
                  onChanged: (d) => controller.selectedDayOfWeek.value = d,
                )),
            const SizedBox(height: AppSizes.paddingM),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.scheduleStartTimeCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Start Time *',
                      hintText: 'HH:MM',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (time != null) {
                        controller.scheduleStartTimeCtrl.text =
                            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: TextFormField(
                    controller: controller.scheduleEndTimeCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'End Time *',
                      hintText: 'HH:MM',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (time != null) {
                        controller.scheduleEndTimeCtrl.text =
                            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),
            Obx(() => InlineDropdownField<String>(
                  value: controller.selectedCollectionType.value,
                  items: kCollectionTypes,
                  placeholder: 'Select Collection Type',
                  label: 'Collection Type',
                  prefixIcon: Icons.recycling_outlined,
                  itemLabel: (t) => t[0].toUpperCase() + t.substring(1),
                  onChanged: (t) => controller.selectedCollectionType.value = t ?? 'regular',
                )),
            const SizedBox(height: AppSizes.paddingXL),
            Obx(() => PrimaryButton(
                  text: 'Create Schedule',
                  isLoading: controller.isCreatingSchedule.value,
                  onPressed: controller.submitCreateSchedule,
                )),
          ],
        ),
      ),
    );
  }
}
