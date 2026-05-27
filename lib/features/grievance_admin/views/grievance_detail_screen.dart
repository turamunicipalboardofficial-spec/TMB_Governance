import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class GrievanceDetailScreen extends StatelessWidget {
  const GrievanceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grievance Details')),
      body: const Center(
        child: EmptyState(
          icon: Icons.report_problem_outlined,
          title: 'Grievance Details',
          message: 'Grievance detail view coming soon.',
        ),
      ),
    );
  }
}