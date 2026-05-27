import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmb_governance/core/constants/app_colors.dart';
import 'package:tmb_governance/core/constants/app_sizes.dart';
import 'package:tmb_governance/core/models/locality_model.dart';
import 'package:tmb_governance/core/models/ward_model.dart';
import 'package:tmb_governance/features/user_management/controllers/user_management_controller.dart';
import 'package:tmb_governance/features/user_management/models/user_model.dart';

class EditUserScreen extends GetView<UserManagementController> {
  const EditUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.arguments as UserModel;
    controller.loadUserForEdit(user);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${user.fullName}'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Obx(() {
        if (controller.isLoadingWards.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                      const SizedBox(width: AppSizes.paddingS),
                      Expanded(
                        child: Text(
                          'Editing user: ${user.email} (${user.role})',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.firstnameCtrl,
                        decoration: const InputDecoration(labelText: 'First Name'),
                        validator: (v) {
                          if (v == null || v.trim().length < 2) return 'Min 2 characters';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: TextFormField(
                        controller: controller.lastnameCtrl,
                        decoration: const InputDecoration(labelText: 'Last Name'),
                        validator: (v) {
                          if (v == null || v.trim().length < 2) return 'Min 2 characters';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingM),
                TextFormField(
                  controller: controller.emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty && !GetUtils.isEmail(v.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.paddingM),
                TextFormField(
                  controller: controller.phoneNoCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone No'),
                ),
                const SizedBox(height: AppSizes.paddingM),
                TextFormField(
                  controller: controller.dobCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: Get.context!,
                      initialDate: DateTime(1990),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      controller.dobCtrl.text =
                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                    }
                  },
                ),
                const SizedBox(height: AppSizes.paddingM),
                _buildWardDropdown(),
                const SizedBox(height: AppSizes.paddingM),
                _buildLocalityDropdown(),
                const SizedBox(height: AppSizes.paddingL),
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, size: 18, color: Colors.orange),
                      const SizedBox(width: AppSizes.paddingS),
                      const Expanded(
                        child: Text(
                          'Leave password empty to keep current password',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                TextFormField(
                  controller: controller.passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password (optional)',
                    hintText: 'Leave empty to keep current',
                  ),
                  validator: (v) {
                    if (v != null && v.isNotEmpty && v.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.paddingXL),
                Obx(() => ElevatedButton(
                  onPressed: controller.isCreating.value
                      ? null
                      : () => controller.updateUser(user.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                  child: controller.isCreating.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textOnPrimary,
                          ),
                        )
                      : const Text(
                          'Update User',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                )),
                const SizedBox(height: AppSizes.paddingL),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLocalityDropdown() {
    return Obx(() {
      final wardSelected = controller.selectedCreateWardId.value != null;
      final loading = controller.isLoadingLocalities.value;
      final items = controller.localities.map((LocalityModel loc) {
        return DropdownMenuItem<int>(
          value: loc.id,
          child: Text(loc.localityName),
        );
      }).toList();

      return DropdownButtonFormField<int>(
        value: controller.selectedCreateLocalityId.value,
        decoration: InputDecoration(
          labelText: 'Locality',
          hintText: !wardSelected
              ? 'Select a ward first'
              : loading
                  ? 'Loading localities...'
                  : controller.localities.isEmpty
                      ? 'No localities found'
                      : 'Select locality',
        ),
        items: items,
        onChanged: wardSelected && !loading
            ? (int? value) {
                controller.selectedCreateLocalityId.value = value;
              }
            : null,
      );
    });
  }

  Widget _buildWardDropdown() {
    return Obx(() {
      return DropdownButtonFormField<int>(
        value: controller.selectedCreateWardId.value,
        decoration: const InputDecoration(labelText: 'Ward'),
        items: controller.wards.map((WardModel ward) {
          return DropdownMenuItem<int>(
            value: ward.id,
            child: Text(ward.wardName),
          );
        }).toList(),
        onChanged: (int? value) {
          controller.selectedCreateWardId.value = value;
        },
      );
    });
  }
}