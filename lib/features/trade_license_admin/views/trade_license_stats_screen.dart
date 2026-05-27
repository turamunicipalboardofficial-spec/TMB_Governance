import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class TradeLicenseStatsScreen extends StatelessWidget {
  const TradeLicenseStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trade License Stats')),
      body: const Center(
        child: EmptyState(
          icon: Icons.bar_chart_outlined,
          title: 'Trade License Statistics',
          message: 'Statistics view coming soon.',
        ),
      ),
    );
  }
}