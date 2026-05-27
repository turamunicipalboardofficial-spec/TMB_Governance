import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class ApproveRejectDialog extends StatefulWidget {
  final String formId;
  final Function(String status, String? remarks) onConfirm;

  const ApproveRejectDialog({
    super.key,
    required this.formId,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required String formId,
    required Function(String status, String? remarks) onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ApproveRejectDialog(formId: formId, onConfirm: onConfirm),
    );
  }

  @override
  State<ApproveRejectDialog> createState() => _ApproveRejectDialogState();
}

class _ApproveRejectDialogState extends State<ApproveRejectDialog> {
  final remarksController = TextEditingController();
  String? selectedAction;

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusL)),
      title: const Text('Approve or Reject Form'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Form: ${widget.formId}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),
            Row(
              children: [
                Expanded(
                  child: _ActionChip(
                    label: 'Approve',
                    icon: Icons.check_circle,
                    color: AppColors.success,
                    isSelected: selectedAction == 'approved',
                    onTap: () => setState(() => selectedAction = 'approved'),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: _ActionChip(
                    label: 'Reject',
                    icon: Icons.cancel,
                    color: AppColors.error,
                    isSelected: selectedAction == 'rejected',
                    onTap: () => setState(() => selectedAction = 'rejected'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),
            TextField(
              controller: remarksController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Remarks (optional)',
                hintText: 'Enter remarks...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedAction == null
              ? null
              : () {
                  widget.onConfirm(
                    selectedAction!,
                    remarksController.text.trim().isEmpty
                        ? null
                        : remarksController.text.trim(),
                  );
                  Navigator.pop(context);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                selectedAction == 'approved' ? AppColors.success : AppColors.primary,
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : AppColors.textTertiary, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}