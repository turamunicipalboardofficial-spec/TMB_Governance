import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class HoldingTaxStatsScreen extends StatelessWidget {
  const HoldingTaxStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Holding Tax Stats')),
      body: const Center(
        child: EmptyState(
          icon: Icons.pie_chart_outline,
          title: 'Holding Tax Statistics',
          message: 'Holding tax statistics view coming soon.',
        ),
      ),
    );
  }
}