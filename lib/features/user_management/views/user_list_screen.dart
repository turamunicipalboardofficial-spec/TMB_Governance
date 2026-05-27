import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmb_governance/core/constants/app_colors.dart';
import 'package:tmb_governance/core/constants/app_sizes.dart';
import 'package:tmb_governance/core/design_system/organisms/empty_state.dart';
import 'package:tmb_governance/features/user_management/controllers/user_management_controller.dart';
import 'package:tmb_governance/features/user_management/models/user_model.dart';
import 'package:tmb_governance/routes/app_routes.dart';

class UserListScreen extends GetView<UserManagementController> {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => Get.toNamed(AppRoutes.createUser),
            tooltip: 'Create User',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.createUser),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: AppColors.textOnPrimary),
        label: const Text(
          'Add User',
          style: TextStyle(color: AppColors.textOnPrimary),
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      color: AppColors.surface,
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: controller.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by name, email, or phone...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() => Row(
              children: [
                _buildRoleFilterChip('All', ''),
                _buildRoleFilterChip('Consumers', 'user'),
                _buildRoleFilterChip('Employees', 'editor'),
                _buildRoleFilterChip('CEO', 'ceo'),
                _buildRoleFilterChip('Drivers', 'driver'),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilterChip(String label, String role) {
    final isSelected = controller.selectedRole.value == role;
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.paddingS),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 12)),
        selected: isSelected,
        onSelected: (_) => controller.filterByRole(role.isEmpty ? null : role),
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildUserList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.users.isEmpty) {
        return const EmptyState(
          icon: Icons.people_outline,
          title: 'No Users Found',
          message: 'No users match your current filters.',
        );
      }
      return RefreshIndicator(
        onRefresh: controller.fetchUsers,
        child: ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 80,
            left: AppSizes.paddingM,
            right: AppSizes.paddingM,
            top: AppSizes.paddingS,
          ),
          itemCount: controller.users.length +
              (controller.users.length < controller.totalUsers.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.users.length) {
              // Load more
              controller.loadMore();
              return const Padding(
                padding: EdgeInsets.all(AppSizes.paddingM),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _buildUserCard(controller.users[index]);
          },
        ),
      );
    });
  }

  Widget _buildUserCard(UserModel user) {
    final roleColor = _getRoleColor(user.role);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.1),
          child: Icon(_getRoleIcon(user.role), color: roleColor, size: 20),
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              user.email,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getRoleDisplayName(user.role),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: roleColor,
                    ),
                  ),
                ),
                if (user.wardId != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    'Ward ${user.wardId}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, user),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit User')),
            PopupMenuItem(
              value: 'toggle',
              child: Text((user.isActive ?? false) ? 'Deactivate' : 'Activate'),
            ),
          ],
        ),
        onTap: () => _showUserDetails(user),
      ),
    );
  }

  void _handleMenuAction(String action, UserModel user) {
    switch (action) {
      case 'edit':
        controller.loadUserForEdit(user);
        Get.toNamed(AppRoutes.editUser, arguments: user);
        break;
      case 'toggle':
        _showToggleDialog(user);
        break;
    }
  }

  void _showToggleDialog(UserModel user) {
    final newStatus = !(user.isActive ?? false);
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Text(newStatus ? 'Activate User' : 'Deactivate User'),
        content: Text(
          newStatus
              ? 'Are you sure you want to activate ${user.fullName}?'
              : 'Are you sure you want to deactivate ${user.fullName}? They will not be able to log in.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.toggleUserActive(user);
            },
            child: Text(
              newStatus ? 'Activate' : 'Deactivate',
              style: TextStyle(color: newStatus ? AppColors.success : AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(UserModel user) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusL)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),
              Text(
                user.fullName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.paddingS),
              _buildDetailRow('Email', user.email),
              if (user.phoneNo != null) _buildDetailRow('Phone', user.phoneNo!),
              if (user.dob != null) _buildDetailRow('DOB', user.dob!),
              _buildDetailRow('Role', user.role.toUpperCase()),
              if (user.wardId != null) _buildDetailRow('Ward ID', user.wardId.toString()),
              if (user.locality != null) _buildDetailRow('Locality', user.locality!),
              const SizedBox(height: AppSizes.paddingM),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        controller.loadUserForEdit(user);
                        Get.toNamed(AppRoutes.editUser, arguments: user);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        _showToggleDialog(user);
                      },
                      icon: Icon(
                        (user.isActive ?? false) ? Icons.block : Icons.check_circle,
                      ),
                      label: Text((user.isActive ?? false) ? 'Deactivate' : 'Activate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (user.isActive ?? false) ? AppColors.error : AppColors.success,
                        foregroundColor: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ceo':
        return const Color(0xFF6A1B9A);
      case 'editor':
        return const Color(0xFF2E7D32);
      case 'user':
        return const Color(0xFF1565C0);
      case 'driver':
        return const Color(0xFFEF6C00);
      default:
        return AppColors.textSecondary;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'editor':
        return 'EMPLOYEE';
      case 'user':
        return 'CONSUMER';
      case 'ceo':
        return 'CEO';
      case 'driver':
        return 'DRIVER';
      default:
        return role.toUpperCase();
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'ceo':
        return Icons.workspace_premium;
      case 'editor':
        return Icons.badge;
      case 'user':
        return Icons.person;
      case 'driver':
        return Icons.local_shipping;
      default:
        return Icons.person;
    }
  }
}