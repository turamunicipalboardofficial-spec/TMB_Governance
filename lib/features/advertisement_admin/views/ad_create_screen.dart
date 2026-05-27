import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class AdCreateScreen extends StatelessWidget {
  const AdCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Advertisement')),
      body: const Center(
        child: EmptyState(
          icon: Icons.add_photo_alternate_outlined,
          title: 'Create Advertisement',
          message: 'Ad creation form coming soon.',
        ),
      ),
    );
  }
}