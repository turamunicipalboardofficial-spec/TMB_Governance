import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../controllers/driver_dashboard_controller.dart';
import 'driver_shift_tab.dart';
import 'driver_route_tab.dart';
import 'driver_map_tab.dart';

class DriverView extends GetView<DriverDashboardController> {
  DriverView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isLoggedIn.value) {
        return _buildLoginScreen();
      }
      return _buildDashboard();
    });
  }

  // ── Login Screen ──────────────────────────────

  Widget _buildLoginScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Logo / Icon
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Driver Login',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your phone number and password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              // Phone field
              TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone_rounded),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
              const SizedBox(height: 16),
              // Password field
              Obx(
                () => TextField(
                  controller: controller.passwordController,
                  obscureText: controller.isPasswordHidden.value,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordHidden.value
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Sign In button
              Obx(
                () => SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        controller.authState.value == DriverAuthState.loading
                            ? null
                            : controller.login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child:
                        controller.authState.value == DriverAuthState.loading
                            ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Main Dashboard ────────────────────────────

  Widget _buildDashboard() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        return IndexedStack(
          index: _currentTabIndex.value,
          children: const [
            DriverShiftTab(),
            DriverRouteTab(),
            DriverMapTab(),
          ],
        );
      }),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  final RxInt _currentTabIndex = 0.obs;

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Text(
              controller.driverName.value ?? 'Driver',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Obx(() {
            final truck = controller.truckNumber.value;
            if (truck != null && truck.isNotEmpty) {
              return Text(
                '🚛 $truck',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      actions: [
        Obx(() {
          if (controller.isOnShift &&
              controller.lastLocationSentAt.value != null) {
            final time = controller.lastLocationSentAt.value!;
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '📍 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          onPressed: _showLogoutDialog,
          tooltip: 'Logout',
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Obx(() {
      return BottomNavigationBar(
        currentIndex: _currentTabIndex.value,
        onTap: (i) {
          _currentTabIndex.value = i;
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_rounded),
            activeIcon: Icon(Icons.local_shipping_rounded),
            label: 'Shift',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.route_rounded),
            activeIcon: Icon(Icons.route_rounded),
            label: 'Route',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            activeIcon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
        ],
      );
    });
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}