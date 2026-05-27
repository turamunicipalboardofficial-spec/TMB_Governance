import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design_system/organisms/admin_drawer.dart';
import '../../../features/dashboard/views/dashboard_screen.dart';
import '../../../features/garbage_driver/views/driver_home_screen.dart';
import '../controllers/main_shell_controller.dart';

class MainShellScreen extends GetView<MainShellController> {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final role = controller.userRole.value;
      final isDriver = role == 'driver';
      final roleLoaded = role.isNotEmpty;

      // For driver, show driver home directly (no drawer)
      if (isDriver) {
        return const DriverHomeScreen();
      }

      // For admin roles, wrap dashboard body with drawer
      if (roleLoaded) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            leading: Builder(
              builder: (scaffoldContext) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
              ),
            ),
          ),
          drawer: const AdminDrawer(),
          body: const DashboardBody(),
        );
      }

      // While role is loading, show dashboard without drawer
      return const DashboardScreen();
    });
  }
}