import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/molecules/inline_dropdown_field.dart';
import '../../../core/design_system/molecules/primary_button.dart';
import '../controllers/notice_admin_controller.dart';

class NoticeCreateScreen extends GetView<NoticeAdminController> {
  const NoticeCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditing ? 'Edit Notice' : 'Create Notice'),
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
                controller: controller.titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'e.g. Water Supply Interruption Notice',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Title is required';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: controller.contentCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Content *',
                  hintText: 'Describe the notice or announcement...',
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Content is required';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingM),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => InlineDropdownField<String>(
                          value: controller.selectedFormType.value,
                          items: kNoticeTypes,
                          placeholder: 'Type',
                          label: 'Type',
                          prefixIcon: Icons.label_outline,
                          itemLabel: (t) => t[0].toUpperCase() + t.substring(1),
                          onChanged: (t) => controller.selectedFormType.value = t ?? 'notice',
                        )),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: Obx(() => InlineDropdownField<String>(
                          value: controller.selectedFormPriority.value,
                          items: kNoticePriorities,
                          placeholder: 'Priority',
                          label: 'Priority',
                          prefixIcon: Icons.flag_outlined,
                          itemLabel: (p) => p[0].toUpperCase() + p.substring(1),
                          onChanged: (p) => controller.selectedFormPriority.value = p ?? 'medium',
                        )),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => InlineDropdownField<String>(
                          value: controller.selectedFormStatus.value,
                          items: kNoticeStatuses,
                          placeholder: 'Status',
                          label: 'Status',
                          prefixIcon: Icons.info_outline,
                          itemLabel: (s) => s[0].toUpperCase() + s.substring(1),
                          onChanged: (s) => controller.selectedFormStatus.value = s ?? 'draft',
                        )),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: Obx(() => InlineDropdownField<String>(
                          value: controller.selectedFormTargetAudience.value,
                          items: kTargetAudiences,
                          placeholder: 'Target Audience',
                          label: 'Audience',
                          prefixIcon: Icons.groups_outlined,
                          itemLabel: (a) => a[0].toUpperCase() + a.substring(1),
                          onChanged: (a) => controller.selectedFormTargetAudience.value = a,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.publishDateCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Publish Date',
                        hintText: 'YYYY-MM-DD',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () => _pickDate(context, controller.publishDateCtrl),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: TextFormField(
                      controller: controller.expiryDateCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date',
                        hintText: 'YYYY-MM-DD',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () => _pickDate(context, controller.expiryDateCtrl),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              Obx(() => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Pin to top', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Pinned notices always appear first', style: TextStyle(fontSize: 12)),
                    value: controller.formIsPinned.value,
                    activeColor: AppColors.primary,
                    onChanged: (v) => controller.formIsPinned.value = v,
                  )),
              const SizedBox(height: AppSizes.paddingM),
              Obx(() {
                if (controller.pickedPdfName.value.isEmpty &&
                    controller.existingAttachmentUrl.value != null) {
                  return _ExistingPdfBox(
                    onRemove: controller.markRemoveExistingPdf,
                    onReplace: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                      );
                      if (result != null && result.files.single.path != null) {
                        controller.setPickedPdf(result.files.single.path!, result.files.single.name);
                      }
                    },
                  );
                }
                return _PdfPickerBox(fileName: controller.pickedPdfName.value);
              }),
              const SizedBox(height: AppSizes.paddingXL),
              Obx(() => PrimaryButton(
                    text: controller.isEditing ? 'Update Notice' : 'Create Notice',
                    isLoading: controller.isSaving.value,
                    onPressed: controller.submitNoticeForm,
                  )),
            ],
          ),
        ),
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

class _PdfPickerBox extends GetView<NoticeAdminController> {
  final String fileName;

  const _PdfPickerBox({required this.fileName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: fileName.isEmpty ? AppColors.border : AppColors.primary,
          ),
        ),
        child: Column(
          children: [
            Icon(
              fileName.isEmpty ? Icons.picture_as_pdf_outlined : Icons.insert_drive_file_outlined,
              size: 32,
              color: fileName.isEmpty ? AppColors.textTertiary : AppColors.primary,
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              fileName.isEmpty ? 'Tap to attach a PDF (optional, max 10MB)' : fileName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: fileName.isEmpty ? FontWeight.w400 : FontWeight.w600,
                color: fileName.isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (fileName.isNotEmpty) ...[
              const SizedBox(height: AppSizes.paddingS),
              TextButton.icon(
                onPressed: controller.clearPickedPdf,
                icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                label: const Text('Remove', style: TextStyle(color: AppColors.error, fontSize: 12)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      controller.setPickedPdf(result.files.single.path!, result.files.single.name);
    }
  }
}

class _ExistingPdfBox extends StatelessWidget {
  final VoidCallback onRemove;
  final VoidCallback onReplace;

  const _ExistingPdfBox({required this.onRemove, required this.onReplace});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        children: [
          const Icon(Icons.picture_as_pdf, size: 32, color: AppColors.primary),
          const SizedBox(height: AppSizes.paddingS),
          const Text(
            'A PDF is already attached',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: onReplace,
                icon: const Icon(Icons.swap_horiz, size: 16),
                label: const Text('Replace', style: TextStyle(fontSize: 12)),
              ),
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                label: const Text('Remove', style: TextStyle(color: AppColors.error, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
