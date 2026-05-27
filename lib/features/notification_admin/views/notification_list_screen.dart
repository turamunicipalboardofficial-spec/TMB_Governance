import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(
        child: EmptyState(
          icon: Icons.notifications_outlined,
          title: 'Notification Management',
          message: 'Broadcast and manage notifications here. Full implementation coming soon.',
        ),
      ),
    );
  }
}