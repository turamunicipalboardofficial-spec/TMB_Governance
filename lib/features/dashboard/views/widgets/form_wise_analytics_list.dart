import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/design_system/atoms/status_badge.dart';
import '../../models/admin_dashboard_response.dart';

/// Grid of per-form-type stat cards. Each service gets a distinct icon and
/// accent color so the section reads as a set of different cards rather
/// than repeated identical templates.
class FormWiseAnalyticsList extends StatelessWidget {
  final List<FormAnalytic> forms;

  const FormWiseAnalyticsList({super.key, required this.forms});

  @override
  Widget build(BuildContext context) {
    if (forms.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show only forms that actually have applications, most active first.
    final activeForms = forms.where((f) => f.totalApplications > 0).toList()
      ..sort((a, b) => b.totalApplications.compareTo(a.totalApplications));

    if (activeForms.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.paddingM,
        mainAxisSpacing: AppSizes.paddingM,
        childAspectRatio: 0.78,
      ),
      itemCount: activeForms.length,
      itemBuilder: (context, index) {
        final form = activeForms[index];
        final style = _formStyle(form.formName);
        return _FormAnalyticCard(form: form, style: style);
      },
    );
  }

  /// Maps a form name to a distinct icon + accent color so each service
  /// card looks visually different from the others.
  _FormCardStyle _formStyle(String formName) {
    final name = formName.toLowerCase();

    if (name.contains('trade license')) {
      return const _FormCardStyle(Icons.business_center_outlined, AppColors.primary);
    }
    if (name.contains('holding tax')) {
      return const _FormCardStyle(Icons.receipt_long_outlined, AppColors.success);
    }
    if (name.contains('pet dog')) {
      return const _FormCardStyle(Icons.pets_outlined, AppColors.accent);
    }
    if (name.contains('birth certificate') || name.contains('nac birth')) {
      return const _FormCardStyle(Icons.child_care_outlined, AppColors.info);
    }
    if (name.contains('death certificate')) {
      return const _FormCardStyle(Icons.description_outlined, AppColors.textSecondary);
    }
    if (name.contains('complaint')) {
      return const _FormCardStyle(Icons.report_gmailerrorred_outlined, AppColors.error);
    }
    if (name.contains('water tanker')) {
      return const _FormCardStyle(Icons.water_drop_outlined, AppColors.info);
    }
    if (name.contains('cesspool')) {
      return const _FormCardStyle(Icons.plumbing_outlined, AppColors.primaryDark);
    }
    if (name.contains('noc') && name.contains('electricity')) {
      return const _FormCardStyle(Icons.electrical_services_outlined, AppColors.warning);
    }
    if (name.contains('noc')) {
      return const _FormCardStyle(Icons.verified_outlined, AppColors.primaryLight);
    }
    if (name.contains('banner') || name.contains('poster')) {
      return const _FormCardStyle(Icons.campaign_outlined, AppColors.accentDark);
    }
    return const _FormCardStyle(Icons.description_outlined, AppColors.primary);
  }
}

class _FormCardStyle {
  final IconData icon;
  final Color color;

  const _FormCardStyle(this.icon, this.color);
}

class _FormAnalyticCard extends StatelessWidget {
  final FormAnalytic form;
  final _FormCardStyle style;

  const _FormAnalyticCard({required this.form, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border(
          left: BorderSide(color: style.color, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: style.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Icon(style.icon, size: 15, color: style.color),
              ),
              const Spacer(),
              if (form.topStatus.isNotEmpty) StatusBadge(status: form.topStatus),
            ],
          ),
          const SizedBox(height: AppSizes.paddingXS),
          Text(
            form.formName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            form.totalApplications.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: style.color,
            ),
          ),
          const Text(
            'Total applications',
            style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSizes.paddingXS),
          _MiniStat(label: 'Pending', value: form.pending, color: AppColors.warning),
          const SizedBox(height: 3),
          _MiniStat(label: 'Paid', value: form.paymentCompleted, color: AppColors.success),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '$value $label',
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
