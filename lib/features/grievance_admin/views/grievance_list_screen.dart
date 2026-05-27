import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class GrievanceListScreen extends StatelessWidget {
  const GrievanceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grievances')),
      body: const Center(
        child: EmptyState(
          icon: Icons.report_problem_outlined,
          title: 'Grievance Management',
          message: 'View and manage citizen grievances here. Full implementation coming soon.',
        ),
      ),
    );
  }
}