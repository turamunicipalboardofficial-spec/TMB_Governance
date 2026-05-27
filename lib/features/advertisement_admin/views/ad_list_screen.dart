import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class AdListScreen extends StatelessWidget {
  const AdListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advertisements')),
      body: const Center(
        child: EmptyState(
          icon: Icons.campaign_outlined,
          title: 'Advertisements',
          message: 'Advertisement management features coming soon.',
        ),
      ),
    );
  }
}