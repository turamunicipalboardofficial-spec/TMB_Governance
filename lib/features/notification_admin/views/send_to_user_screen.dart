import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SendToUserScreen extends StatelessWidget {
  const SendToUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send to User')),
      body: const Center(
        child: Text(
          'Send to User Screen',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
      ),
    );
  }
}
