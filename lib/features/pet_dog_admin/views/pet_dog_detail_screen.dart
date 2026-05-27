import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class PetDogDetailScreen extends StatelessWidget {
  const PetDogDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pet Dog Application Details')),
      body: const Center(
        child: EmptyState(
          icon: Icons.pets_outlined,
          title: 'Application Details',
          message: 'Pet dog application details coming soon.',
        ),
      ),
    );
  }
}
