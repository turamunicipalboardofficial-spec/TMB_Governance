import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class UpdatePaymentScreen extends StatelessWidget {
  const UpdatePaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Payment')),
      body: const Center(
        child: EmptyState(
          icon: Icons.payment_outlined,
          title: 'Update Payment',
          message: 'Payment update feature coming soon.',
        ),
      ),
    );
  }
}