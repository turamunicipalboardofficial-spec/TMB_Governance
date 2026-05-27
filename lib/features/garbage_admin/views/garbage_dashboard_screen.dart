import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class GarbageDashboardScreen extends StatelessWidget {
  const GarbageDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Garbage Management')),
      body: const Center(
        child: EmptyState(
          icon: Icons.delete_outline,
          title: 'Garbage Management',
          message: 'Fleet and garbage management features coming soon.',
        ),
      ),
    );
  }
}