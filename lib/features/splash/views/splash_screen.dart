import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../theme/text_styles.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.textOnPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tura Municipal Board',
              style: AppTextStyles.h2.copyWith(color: AppColors.textOnPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Admin Portal',
              style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.textOnPrimary.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}
