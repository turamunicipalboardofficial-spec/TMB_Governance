import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmb_governance/core/constants/app_colors.dart';
import 'package:tmb_governance/core/constants/app_sizes.dart';
import 'package:tmb_governance/core/models/locality_model.dart';
import 'package:tmb_governance/core/models/ward_model.dart';
import 'package:tmb_governance/features/user_management/controllers/user_management_controller.dart';

class CreateUserScreen extends GetView<UserManagementController> {
  const CreateUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create User'),
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
                _buildRoleSelector(),
                const SizedBox(height: AppSizes.paddingL),
                _buildCommonFields(),
                if (controller.selectedCreateRole.value == 'driver') ...[
                  const SizedBox(height: AppSizes.paddingL),
                  _buildDriverFields(),
                ],
                const SizedBox(height: AppSizes.paddingXL),
                _buildSubmitButton(),
                const SizedBox(height: AppSizes.paddingL),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'User Type',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Obx(() => Row(
          children: [
            _buildRoleChip('Driver', 'driver', Icons.local_shipping),
            const SizedBox(width: AppSizes.paddingS),
            _buildRoleChip('Employee', 'employee', Icons.badge),
            const SizedBox(width: AppSizes.paddingS),
            _buildRoleChip('Consumer', 'consumer', Icons.person),
          ],
        )),
      ],
    );
  }

  Widget _buildRoleChip(String label, String role, IconData icon) {
    final isSelected = controller.selectedCreateRole.value == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedCreateRole.value = role,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.textTertiary.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommonFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.firstnameCtrl,
                decoration: const InputDecoration(
                  labelText: 'First Name *',
                  hintText: 'e.g. John',
                ),
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
                decoration: const InputDecoration(
                  labelText: 'Last Name *',
                  hintText: 'e.g. Sangma',
                ),
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
          decoration: const InputDecoration(
            labelText: 'Email *',
            hintText: 'e.g. john@example.com',
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email is required';
            if (!GetUtils.isEmail(v.trim())) return 'Enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: AppSizes.paddingM),
        TextFormField(
          controller: controller.passwordCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password *',
            hintText: 'Minimum 6 characters',
          ),
          validator: (v) {
            if (v == null || v.length < 6) return 'Min 6 characters';
            return null;
          },
        ),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.dobCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth *',
                  hintText: 'YYYY-MM-DD',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: Get.context!,
                    initialDate: DateTime(1990),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                  );
                  if (date != null) {
                    controller.dobCtrl.text =
                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  }
                },
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'DOB is required';
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: TextFormField(
                controller: controller.phoneNoCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone No *',
                  hintText: 'e.g. 9876543210',
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 10) return 'Min 10 digits';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingM),
        _buildWardDropdown(),
        const SizedBox(height: AppSizes.paddingM),
        _buildLocalityDropdown(),
      ],
    );
  }

  Widget _buildWardDropdown() {
    return Obx(() {
      return DropdownButtonFormField<int>(
        value: controller.selectedCreateWardId.value,
        decoration: const InputDecoration(
          labelText: 'Ward *',
        ),
        items: controller.wards.map((WardModel ward) {
          return DropdownMenuItem<int>(
            value: ward.id,
            child: Text(ward.wardName),
          );
        }).toList(),
        onChanged: (int? value) {
          controller.selectedCreateWardId.value = value;
        },
        validator: (v) {
          if (controller.selectedCreateRole.value != 'consumer' && v == null) {
            return 'Ward is required';
          }
          return null;
        },
      );
    });
  }

  Widget _buildLocalityDropdown() {
    return Obx(() {
      // Disable if no ward selected
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

  Widget _buildDriverFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Driver Details',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSizes.paddingM),
        TextFormField(
          controller: controller.driverLicenseCtrl,
          decoration: const InputDecoration(
            labelText: 'Driver License Number *',
            hintText: 'e.g. ML-2024-12345',
          ),
          validator: (v) {
            if (controller.selectedCreateRole.value == 'driver') {
              if (v == null || v.trim().isEmpty) return 'License number is required';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSizes.paddingM),
        TextFormField(
          controller: controller.licenseExpiryCtrl,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'License Expiry *',
            hintText: 'YYYY-MM-DD',
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: Get.context!,
              initialDate: DateTime.now().add(const Duration(days: 365)),
              firstDate: DateTime.now(),
              lastDate: DateTime(2040),
            );
            if (date != null) {
              controller.licenseExpiryCtrl.text =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            }
          },
          validator: (v) {
            if (controller.selectedCreateRole.value == 'driver') {
              if (v == null || v.trim().isEmpty) return 'License expiry is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() => ElevatedButton(
      onPressed: controller.isCreating.value ? null : controller.createUser,
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
          : Text(
              'Create ${_getRoleLabel()}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    ));
  }

  String _getRoleLabel() {
    switch (controller.selectedCreateRole.value) {
      case 'driver':
        return 'Driver';
      case 'employee':
        return 'Employee';
      case 'consumer':
        return 'Consumer';
      default:
        return 'User';
    }
  }
}