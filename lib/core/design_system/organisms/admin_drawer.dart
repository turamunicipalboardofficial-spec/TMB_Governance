import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../../routes/app_routes.dart';
import '../../storage/secure_storage_service.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  Future<String> _getRole() async {
    return await SecureStorageService.to.getRole() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: FutureBuilder<String>(
              future: _getRole(),
              builder: (context, snapshot) {
                final role = snapshot.data ?? '';
                final isCeo = role == 'ceo';
                // Note: the backend has no literal 'admin' role — the closest
                // equivalent is 'editor'. Kept as isAdmin for readability
                // across the nav sections below.
                final isAdmin = role == 'editor';
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildSectionTitle('Management'),
                    _buildTile(
                      Icons.dashboard_rounded,
                      'Dashboard',
                      () => Get.toNamed(AppRoutes.adminDashboard),
                    ),
                    if (isCeo)
                      _buildTile(
                        Icons.supervised_user_circle_rounded,
                        'Users & Roles',
                        () => Get.toNamed(AppRoutes.userRoleManagement),
                      ),
                    _buildTile(
                      Icons.description_outlined,
                      'Applications',
                      () => Get.toNamed(AppRoutes.formApproval),
                    ),
                 
                    if (isCeo || isAdmin)
                      _buildTile(
                        Icons.report_problem_rounded,
                        'Grievances',
                        () => Get.toNamed(AppRoutes.grievanceList),
                      ),
                    if (isCeo || isAdmin)
                      _buildTile(
                        Icons.receipt_rounded,
                        'Commercial Rent',
                        () => Get.toNamed(AppRoutes.billingDashboard),
                      ),
                    if (isCeo || isAdmin)
                      _buildTile(
                        Icons.delete_rounded,
                        'Garbage Management',
                        () => Get.toNamed(AppRoutes.garbageDashboard),
                      ),
                    const Divider(indent: 16, endIndent: 16),
                    _buildSectionTitle('Communication'),
                    if (isCeo || isAdmin)
                      _buildTile(
                        Icons.campaign_rounded,
                        'Advertisements',
                        () => Get.toNamed(AppRoutes.adList),
                      ),
                    if (isCeo || isAdmin)
                      _buildTile(
                        Icons.announcement_rounded,
                        'Notices',
                        () => Get.toNamed(AppRoutes.noticeList),
                      ),
                    if (isCeo || isAdmin)
                      _buildTile(
                        Icons.notifications_rounded,
                        'Notifications',
                        () => Get.toNamed(AppRoutes.notificationList),
                      ),
                    const Divider(indent: 16, endIndent: 16),
                    _buildSectionTitle('Reports'),
                    if (isCeo || isAdmin)
                      _buildTile(
                        Icons.payment_rounded,
                        'Payment History',
                        () => Get.toNamed(AppRoutes.paymentHistory),
                      ),
                    
                    if (isCeo || isAdmin)
                      _buildTile(
                        Icons.account_balance_rounded,
                        'Holding Tax Stats',
                        () => Get.toNamed(AppRoutes.holdingTaxStats),
                      ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),
          _buildTile(
            Icons.person_rounded,
            'Profile',
            () => Get.toNamed(AppRoutes.adminProfile),
          ),
          _buildTile(
            Icons.lock_rounded,
            'Change Password',
            () => Get.toNamed(AppRoutes.adminChangePassword),
          ),
          _buildTile(
            Icons.logout_rounded,
            'Logout',
            () => _showLogoutDialog(context),
            color: AppColors.error,
          ),
          const SizedBox(height: AppSizes.paddingM),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: SecureStorageService.to.getUserData(),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        final firstName = userData?['firstname'] ?? '';
        final lastName = userData?['lastname'] ?? '';
        final name = '$firstName $lastName'.trim();
        final email = userData?['email'] ?? '';

        // Build initials from first letter of first name + first letter of last name
        String initials = '';
        if (firstName.isNotEmpty) initials += firstName[0].toUpperCase();
        if (lastName.isNotEmpty) initials += lastName[0].toUpperCase();
        if (initials.isEmpty) initials = 'A';

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            AppSizes.paddingL,
            MediaQuery.of(context).padding.top + AppSizes.paddingXL,
            AppSizes.paddingL,
            AppSizes.paddingL,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      AppAssets.logo,
                      width: 44,
                      height: 44,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TMB Governance',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                        Text(
                          'Admin Portal',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingL),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: AppSizes.paddingL),
              // User avatar with initials + name/email
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.textOnPrimary,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isNotEmpty ? name : 'Admin',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textOnPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textOnPrimary.withOpacity(0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.paddingM,
        AppSizes.paddingL,
        AppSizes.paddingS,
      ),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    final tileColor = color ?? AppColors.textSecondary;
    return ListTile(
      leading: Icon(icon, color: tileColor, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color ?? AppColors.textPrimary,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: () {
        Get.back(); // close drawer
        onTap();
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingL,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await SecureStorageService.to.clearAll();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}