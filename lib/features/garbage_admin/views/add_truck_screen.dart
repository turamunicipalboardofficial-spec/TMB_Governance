import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class AddTruckScreen extends StatelessWidget {
  const AddTruckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Truck')),
      body: const Center(
        child: EmptyState(
          icon: Icons.local_shipping_outlined,
          title: 'Add Truck',
          message: 'Truck registration form coming soon.',
        ),
      ),
    );
  }
}