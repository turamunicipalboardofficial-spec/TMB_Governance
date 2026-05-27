import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Dashboard')),
      body: const Center(
        child: EmptyState(
          icon: Icons.local_shipping_outlined,
          title: 'Driver Dashboard',
          message: 'Route map and shift controls coming soon.',
        ),
      ),
    );
  }
}