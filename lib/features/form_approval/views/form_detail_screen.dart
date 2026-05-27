import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/atoms/status_badge.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/design_system/organisms/empty_state.dart';
import '../controllers/form_approval_controller.dart';
import '../models/form_list_item.dart';
import 'widgets/approve_reject_dialog.dart';

class FormDetailScreen extends StatelessWidget {
  const FormDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FormListItem? form = Get.arguments as FormListItem?;

    if (form == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Form Details')),
        body: const EmptyState(
          icon: Icons.error_outline,
          title: 'No Data',
          message: 'Form details not available.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(form.applicationFor),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: StatusBadge(status: form.status),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Application Info Card ──
            _SectionCard(
              title: 'Application Information',
              icon: Icons.description_outlined,
              children: [
                _DetailRow(
                  label: 'Application ID',
                  value: form.applicationId,
                  icon: Icons.tag,
                ),
                _DetailRow(
                  label: 'Form Type',
                  value: form.applicationFor,
                  icon: Icons.category_outlined,
                ),
                _DetailRow(
                  label: 'Submitted At',
                  value: form.applicationSubmittedAt,
                  icon: Icons.calendar_today_outlined,
                ),
                _DetailRow(
                  label: 'Status',
                  value: form.status,
                  icon: Icons.info_outline,
                  valueColor: _statusColor(form.status),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),

            // ── Owner / Applicant Info ──
            if (form.ownerName.isNotEmpty || form.ownerPhone.isNotEmpty)
              _SectionCard(
                title: 'Applicant Details',
                icon: Icons.person_outline,
                children: [
                  if (form.ownerName.isNotEmpty)
                    _DetailRow(
                      label: 'Name',
                      value: form.ownerName,
                      icon: Icons.person,
                    ),
                  if (form.ownerPhone.isNotEmpty)
                    _DetailRow(
                      label: 'Phone',
                      value: form.ownerPhone,
                      icon: Icons.phone_outlined,
                    ),
                ],
              ),
            if (form.ownerName.isNotEmpty || form.ownerPhone.isNotEmpty)
              const SizedBox(height: AppSizes.paddingM),

            // ── Payment Info ──
            if (form.payment != null ||
                form.paymentStatus != null ||
                form.paymentAmount != null)
              _SectionCard(
                title: 'Payment Information',
                icon: Icons.payment_outlined,
                children: [
                  if (form.payment != null && form.payment!.isNotEmpty)
                    _DetailRow(
                      label: 'Payment',
                      value: form.payment!,
                      icon: Icons.receipt_long_outlined,
                    ),
                  if (form.paymentAmount != null)
                    _DetailRow(
                      label: 'Amount',
                      value: '₹${form.paymentAmount}',
                      icon: Icons.currency_rupee,
                    ),
                  if (form.paymentStatus != null)
                    _DetailRow(
                      label: 'Payment Status',
                      value: form.paymentStatus!,
                      icon: Icons.account_balance_wallet_outlined,
                      valueColor: form.paymentStatus == 'Paid'
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                ],
              ),
            if (form.payment != null ||
                form.paymentStatus != null ||
                form.paymentAmount != null)
              const SizedBox(height: AppSizes.paddingM),

            // ── Dynamic Form Data ──
            if (form.form != null && form.form!.isNotEmpty)
              _SectionCard(
                title: 'Form Data',
                icon: Icons.article_outlined,
                children: _buildFormFields(form.form!),
              ),
            if (form.form != null && form.form!.isNotEmpty)
              const SizedBox(height: AppSizes.paddingM),

            // ── Counts / Stats ──
            if (form.counts != null && form.counts!.isNotEmpty)
              _SectionCard(
                title: 'Statistics',
                  icon: Icons.analytics_outlined,
                children: _buildFormFields(form.counts!),
              ),
            if (form.counts != null && form.counts!.isNotEmpty)
              const SizedBox(height: AppSizes.paddingM),

            // ── Action Buttons ──
            if (form.status.toLowerCase() == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showApproveReject(context, form, 'approved'),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showApproveReject(context, form, 'rejected'),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingL),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormFields(Map<String, dynamic> data) {
    return data.entries.map((entry) {
      final value = entry.value;
      final displayValue = value is List
          ? value.join(', ')
          : value is Map
              ? value.toString()
              : value?.toString() ?? 'N/A';

      return _DetailRow(
        label: _formatLabel(entry.key),
        value: displayValue,
        icon: Icons.circle,
      );
    }).toList();
  }

  String _formatLabel(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showApproveReject(BuildContext context, FormListItem form, String action) {
    final statusLabel = action == 'approved' ? 'Approved' : 'Rejected';
    ApproveRejectDialog.show(
      context,
      formId: form.applicationId,
      onConfirm: (status, remarks) {
        if (Get.isRegistered<FormApprovalController>()) {
          Get.find<FormApprovalController>().approveOrReject(
            formId: form.formId.toString(),
            applicationId: form.applicationId,
            status: statusLabel,
          );
          Get.back();
        } else {
          CustomSnackbar.showError('Controller not available');
        }
      },
    );
  }
}

// ── Section Card ──
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ── Detail Row ──
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}