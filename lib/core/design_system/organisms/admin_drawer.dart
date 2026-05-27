import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          _buildHeader(),
          Expanded(
            child: FutureBuilder<String>(
              future: _getRole(),
              builder: (context, snapshot) {
                final role = snapshot.data ?? '';
                final isCeo = role == 'ceo';
                final isAdmin = role == 'admin';
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildSectionTitle('Management'),
                    _buildTile(
                      Icons.dashboard,
                      'Dashboard',
                      () => Get.toNamed(AppRoutes.adminDashboard),
                    ),
                    if (isCeo)
                      _buildTile(
                        Icons.supervised_user_circle,
                        'Users & Roles',
                        () => Get.toNamed(AppRoutes.userRoleManagement),
                      ),
                    _buildTile(
                      Icons.description_outlined,
                      'Applications',
                      () => Get.toNamed(AppRoutes.formApproval),
                    ),
                    if (isCeo)
                      _buildTile(
                        Icons.description,
                        'Trade License',
                        () => Get.toNamed(AppRoutes.renewalList),
                      ),
                    if (isCeo || isAdmin)
                      _buildTile(
                        Icons.report_problem,
                        'Grievances',
                        () => Get.toNamed(AppRoutes.grievanceList),
                      ),
                    if (isCeo)
                      _buildTile(
                        Icons.receipt_long,
                        'Billing',
                        () => Get.toNamed(AppRoutes.billingDashboard),
                      ),
                    if (isCeo)
                      _buildTile(
                        Icons.delete,
                        'Garbage Management',
                        () => Get.toNamed(AppRoutes.garbageDashboard),
                      ),
                    const Divider(),
                    _buildSectionTitle('Communication'),
                    if (isCeo)
                      _buildTile(
                        Icons.campaign,
                        'Advertisements',
                        () => Get.toNamed(AppRoutes.adList),
                      ),
                    if (isCeo || isAdmin)
                      _buildTile(
                        Icons.announcement,
                        'Notices',
                        () => Get.toNamed(AppRoutes.noticeList),
                      ),
                    if (isCeo || isAdmin)
                      _buildTile(
                        Icons.notifications,
                        'Notifications',
                        () => Get.toNamed(AppRoutes.notificationList),
                      ),
                    const Divider(),
                    _buildSectionTitle('Reports'),
                    if (isCeo)
                      _buildTile(
                        Icons.payment,
                        'Payment History',
                        () => Get.toNamed(AppRoutes.paymentHistory),
                      ),
                    if (isCeo)
                      _buildTile(
                        Icons.pets,
                        'Pet Dog Applications',
                        () => Get.toNamed(AppRoutes.petDogList),
                      ),
                    if (isCeo)
                      _buildTile(
                        Icons.account_balance,
                        'Holding Tax Stats',
                        () => Get.toNamed(AppRoutes.holdingTaxStats),
                      ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),
          _buildTile(
            Icons.person,
            'Profile',
            () => Get.toNamed(AppRoutes.adminProfile),
          ),
          _buildTile(
            Icons.lock,
            'Change Password',
            () => Get.toNamed(AppRoutes.adminChangePassword),
          ),
          _buildTile(
            Icons.logout,
            'Logout',
            () => _showLogoutDialog(context),
            color: AppColors.error,
          ),
          const SizedBox(height: AppSizes.paddingM),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: SecureStorageService.to.getUserData(),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        final name = userData != null
            ? '${userData['firstname']} ${userData['lastname']}'
            : 'Admin';
        final email = userData?['email'] ?? '';
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            AppSizes.paddingL,
            MediaQuery.of(context).padding.top + AppSizes.paddingL,
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
              const CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.textOnPrimary,
                child: Icon(Icons.person, size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: AppSizes.paddingM),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textOnPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textOnPrimary,
                ),
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
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
          letterSpacing: 1.0,
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
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color ?? AppColors.textPrimary,
        ),
      ),
      onTap: () {
        Get.back(); // close drawer
        onTap();
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
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
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
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