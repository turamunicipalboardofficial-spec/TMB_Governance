import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class RenewalListScreen extends StatelessWidget {
  const RenewalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trade License Renewals')),
      body: const Center(
        child: EmptyState(
          icon: Icons.business_outlined,
          title: 'Trade License Renewals',
          message: 'Manage trade license renewals here. Full implementation coming soon.',
        ),
      ),
    );
  }
}