import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: const Center(
        child: EmptyState(
          icon: Icons.payment_outlined,
          title: 'Payment History',
          message: 'Payment history and transaction records coming soon.',
        ),
      ),
    );
  }
}
