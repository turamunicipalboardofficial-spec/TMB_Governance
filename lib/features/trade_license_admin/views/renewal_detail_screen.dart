import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class RenewalDetailScreen extends StatelessWidget {
  const RenewalDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Renewal Details')),
      body: const Center(
        child: EmptyState(
          icon: Icons.business_outlined,
          title: 'Renewal Details',
          message: 'Renewal detail view coming soon.',
        ),
      ),
    );
  }
}