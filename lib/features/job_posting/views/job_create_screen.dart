import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class JobCreateScreen extends StatelessWidget {
  const JobCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Job Posting')),
      body: const Center(
        child: EmptyState(
          icon: Icons.work_outline,
          title: 'Create Job',
          message: 'Job creation form coming soon.',
        ),
      ),
    );
  }
}