import 'package:flutter/material.dart';
import '../../../core/design_system/organisms/empty_state.dart';

class NoticeListScreen extends StatelessWidget {
  const NoticeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notices & Announcements')),
      body: const Center(
        child: EmptyState(
          icon: Icons.campaign_outlined,
          title: 'Notices & Announcements',
          message: 'Manage notices and announcements here. Full implementation coming soon.',
        ),
      ),
    );
  }
}