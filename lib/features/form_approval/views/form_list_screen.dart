import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/organisms/empty_state.dart';
import '../controllers/form_approval_controller.dart';
import 'widgets/form_list_card.dart';

class FormListScreen extends GetView<FormApprovalController> {
  const FormListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications'),
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      value: controller.selectedStatus.value.isEmpty
                          ? null
                          : controller.selectedStatus.value,
                      isExpanded: true,
                      hint: const Text('Status'),
                      items: const [
                        DropdownMenuItem(value: '', child: Text('All')),
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'approved',
                          child: Text('Approved'),
                        ),
                        DropdownMenuItem(
                          value: 'rejected',
                          child: Text('Rejected'),
                        ),
                      ],
                      onChanged: (v) => controller.filterByStatus(v ?? ''),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      value: controller.selectedFormType.value.isEmpty
                          ? null
                          : controller.selectedFormType.value,
                      isExpanded: true,
                      hint: const Text('Form Type'),
                      items: const [
                        DropdownMenuItem(value: '', child: Text('All')),
                        DropdownMenuItem(
                          value: '1',
                          child: Text('Birth Registration'),
                        ),
                        DropdownMenuItem(value: '2', child: Text('Complaint')),
                        DropdownMenuItem(
                          value: '3',
                          child: Text('Water Tanker'),
                        ),
                        DropdownMenuItem(
                          value: '5',
                          child: Text('Trade License'),
                        ),
                        DropdownMenuItem(
                          value: '10',
                          child: Text('Death Certificate'),
                        ),
                        DropdownMenuItem(
                          value: '11',
                          child: Text('Birth Certificate'),
                        ),
                        DropdownMenuItem(
                          value: '12',
                          child: Text('Pet Dog Reg.'),
                        ),
                      ],
                      onChanged: (v) => controller.filterByFormType(v ?? ''),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Form list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.forms.isEmpty) {
                return const EmptyState(
                  icon: Icons.description_outlined,
                  title: 'No Forms Found',
                  message: 'No forms match your current filters.',
                );
              }
              return RefreshIndicator(
                onRefresh: controller.fetchForms,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 100) {
                      controller.loadMore();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    itemCount:
                        controller.forms.length +
                        (controller.isPaginating.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.forms.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final form = controller.forms[index];
                      return FormListCard(
                        form: form,
                        onViewDetails: () => controller.viewFormDetail(form),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
