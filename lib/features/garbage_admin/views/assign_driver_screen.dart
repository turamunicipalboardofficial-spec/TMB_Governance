import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class AssignDriverScreen extends StatelessWidget {
  const AssignDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Driver')),
      body: const Center(
        child: EmptyState(
          icon: Icons.person_add_outlined,
          title: 'Assign Driver',
          message: 'Driver assignment feature coming soon.',
        ),
      ),
    );
  }
}