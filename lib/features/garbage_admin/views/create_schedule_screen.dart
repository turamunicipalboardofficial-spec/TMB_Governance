import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class CreateScheduleScreen extends StatelessWidget {
  const CreateScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Schedule')),
      body: const Center(
        child: EmptyState(
          icon: Icons.schedule_outlined,
          title: 'Create Schedule',
          message: 'Schedule creation feature coming soon.',
        ),
      ),
    );
  }
}