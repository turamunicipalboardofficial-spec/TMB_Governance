import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class PetDogListScreen extends StatelessWidget {
  const PetDogListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pet Dog Applications')),
      body: const Center(
        child: EmptyState(
          icon: Icons.pets_outlined,
          title: 'Pet Dog Applications',
          message: 'Pet dog registration applications coming soon.',
        ),
      ),
    );
  }
}
