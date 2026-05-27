import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class NoticeCreateScreen extends StatelessWidget {
  const NoticeCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Notice')),
      body: const Center(
        child: Text(
          'Notice Create Screen',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
      ),
    );
  }
}
