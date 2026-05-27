import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/organisms/empty_state.dart';
import '../../../routes/app_routes.dart';

class JobListScreen extends StatelessWidget {
  const JobListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Postings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const EmptyState(
              icon: Icons.work_outline,
              title: 'Job Postings',
              message: 'Manage job postings here. Full implementation coming soon.',
            ),
            const SizedBox(height: AppSizes.paddingXL),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.jobCreate),
              icon: const Icon(Icons.add),
              label: const Text('Create Job Posting'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}