import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class GenerateBillsScreen extends StatelessWidget {
  const GenerateBillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Bills')),
      body: const Center(
        child: EmptyState(
          icon: Icons.receipt_outlined,
          title: 'Generate Bills',
          message: 'Bill generation feature coming soon.',
        ),
      ),
    );
  }
}