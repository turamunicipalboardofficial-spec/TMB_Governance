import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class BillingDashboardScreen extends StatelessWidget {
  const BillingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Billing Management')),
      body: const Center(
        child: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Billing Management',
          message: 'Billing management features coming soon.',
        ),
      ),
    );
  }
}