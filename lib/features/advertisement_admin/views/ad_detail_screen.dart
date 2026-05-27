import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class AdDetailScreen extends StatelessWidget {
  const AdDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advertisement Details')),
      body: const Center(
        child: EmptyState(
          icon: Icons.campaign_outlined,
          title: 'Advertisement Details',
          message: 'Ad details view coming soon.',
        ),
      ),
    );
  }
}