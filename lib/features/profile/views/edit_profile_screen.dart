import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/molecules/custom_input_field.dart';
import '../../../core/design_system/molecules/primary_button.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends GetView<ProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          children: [
            CustomInputField(
              label: 'First Name',
              controller: controller.firstnameController,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: AppSizes.paddingL),
            CustomInputField(
              label: 'Last Name',
              controller: controller.lastnameController,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: AppSizes.paddingL),
            CustomInputField(
              label: 'Email',
              controller: controller.emailController,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSizes.paddingL),
            CustomInputField(
              label: 'Phone Number',
              controller: controller.phoneController,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSizes.paddingL),
            CustomInputField(
              label: 'Date of Birth',
              controller: controller.dobController,
              prefixIcon: Icons.calendar_today_outlined,
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime(1990),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  controller.dobController.text =
                      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                }
              },
            ),
            const SizedBox(height: AppSizes.paddingXXL),
            Obx(
              () => PrimaryButton(
                text: 'Update Profile',
                onPressed: controller.updateProfile,
                isLoading: controller.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
