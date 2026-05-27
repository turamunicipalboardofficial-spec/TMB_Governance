import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../routes/app_routes.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header with gradient + logo + avatar ──
            _buildProfileHeader(),

            const SizedBox(height: AppSizes.paddingL),

            // ── Personal Information Card ──
            _buildSectionCard(
              title: 'Personal Information',
              icon: Icons.person_rounded,
              children: [
                Obx(() => _buildInfoRow(
                      icon: Icons.badge_rounded,
                      label: 'Full Name',
                      value: controller.userName.value,
                    )),
                Obx(() => _buildInfoRow(
                      icon: Icons.email_rounded,
                      label: 'Email',
                      value: controller.userEmail.value,
                    )),
                Obx(() => _buildInfoRow(
                      icon: Icons.phone_rounded,
                      label: 'Phone',
                      value: controller.userPhone.value.isNotEmpty
                          ? controller.userPhone.value
                          : 'Not provided',
                    )),
                Obx(() => _buildInfoRow(
                      icon: Icons.cake_rounded,
                      label: 'Date of Birth',
                      value: controller.userDob.value.isNotEmpty
                          ? controller.userDob.value
                          : 'Not provided',
                    )),
              ],
            ),

            const SizedBox(height: AppSizes.paddingM),

            // ── Account Card ──
            _buildSectionCard(
              title: 'Account',
              icon: Icons.shield_rounded,
              children: [
                Obx(() => _buildInfoRow(
                      icon: Icons.work_rounded,
                      label: 'Role',
                      value: controller.userRole.value.toUpperCase(),
                      valueColor: AppColors.accentDark,
                      valueBackground: AppColors.accentExtraLight,
                    )),
                Obx(() => _buildInfoRow(
                      icon: Icons.perm_identity_rounded,
                      label: 'First Name',
                      value: controller.userFirstName.value.isNotEmpty
                          ? controller.userFirstName.value
                          : 'Not provided',
                    )),
                Obx(() => _buildInfoRow(
                      icon: Icons.perm_identity_rounded,
                      label: 'Last Name',
                      value: controller.userLastName.value.isNotEmpty
                          ? controller.userLastName.value
                          : 'Not provided',
                    )),
              ],
            ),

            const SizedBox(height: AppSizes.paddingM),

            // ── Actions Card ──
            _buildActionsCard(context),

            const SizedBox(height: AppSizes.paddingXXL),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  Profile Header
  // ──────────────────────────────────────────────────────────────
  Widget _buildProfileHeader() {
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSizes.paddingXXL),

              // Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  AppAssets.logo,
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
              const Text(
                'Tura Municipal Board',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textOnPrimary,
                ),
              ),

              const SizedBox(height: AppSizes.paddingXXL),

              // Avatar with initials
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.textOnPrimary,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.paddingM),

              // Name
              Text(
                name.isNotEmpty ? name : 'Admin',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textOnPrimary,
                ),
              ),

              const SizedBox(height: AppSizes.paddingXS),

              // Role badge
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingXXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textOnPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                    ),
                    child: Text(
                      controller.userRole.value.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textOnPrimary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  )),

              const SizedBox(height: AppSizes.paddingS),

              // Email
              Text(
                email,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textOnPrimary.withOpacity(0.85),
                ),
              ),

              const SizedBox(height: AppSizes.paddingXXL),
            ],
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  Section Card
  // ──────────────────────────────────────────────────────────────
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          side: BorderSide(color: AppColors.border),
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  Info Row
  // ──────────────────────────────────────────────────────────────
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Color? valueBackground,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                valueBackground != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: valueBackground,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusS),
                        ),
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: valueColor ?? AppColors.textPrimary,
                          ),
                        ),
                      )
                    : Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: valueColor ?? AppColors.textPrimary,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  Actions Card
  // ──────────────────────────────────────────────────────────────
  Widget _buildActionsCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          side: BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            children: [
              _buildActionButton(
                icon: Icons.edit_rounded,
                label: 'Edit Profile',
                onTap: () => Get.toNamed(AppRoutes.adminEditProfile),
              ),
              const Divider(height: 1),
              _buildActionButton(
                icon: Icons.lock_rounded,
                label: 'Change Password',
                onTap: () => Get.toNamed(AppRoutes.adminChangePassword),
              ),
              const Divider(height: 1),
              _buildActionButton(
                icon: Icons.logout_rounded,
                label: 'Logout',
                iconColor: AppColors.error,
                textColor: AppColors.error,
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: AppColors.textTertiary,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  Logout Dialog
  // ──────────────────────────────────────────────────────────────
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}