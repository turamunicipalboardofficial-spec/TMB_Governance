import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/molecules/custom_input_field.dart';
import '../../../core/design_system/molecules/primary_button.dart';
import '../controllers/profile_controller.dart';

class ChangePasswordScreen extends GetView<ProfileController> {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          children: [
            Obx(
              () => CustomInputField(
                label: 'Current Password',
                controller: controller.currentPasswordController,
                prefixIcon: Icons.lock_outline,
                obscureText: controller.isPasswordHidden.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordHidden.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => controller.isPasswordHidden.toggle(),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),
            Obx(
              () => CustomInputField(
                label: 'New Password',
                controller: controller.newPasswordController,
                prefixIcon: Icons.lock_outline,
                obscureText: controller.isNewPasswordHidden.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isNewPasswordHidden.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => controller.isNewPasswordHidden.toggle(),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),
            Obx(
              () => CustomInputField(
                label: 'Confirm New Password',
                controller: controller.confirmPasswordController,
                prefixIcon: Icons.lock_outline,
                obscureText: controller.isConfirmPasswordHidden.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isConfirmPasswordHidden.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => controller.isConfirmPasswordHidden.toggle(),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingXXL),
            Obx(
              () => PrimaryButton(
                text: 'Change Password',
                onPressed: controller.changePassword,
                isLoading: controller.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
