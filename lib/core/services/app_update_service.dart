import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

/// Handles Play Store in-app updates.
/// - Immediate update: Forces the user to update before using the app.
/// - Flexible update: Shows a notification and lets the user update later.
class AppUpdateService {
  static final AppUpdateService _instance = AppUpdateService._();
  static AppUpdateService get instance => _instance;
  AppUpdateService._();

  /// Call this on app startup (e.g. in splash screen or main).
  /// Uses IMMEDIATE update type which blocks the app until updated.
  Future<void> checkForUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        // If an immediate update is allowed, force it.
        if (updateInfo.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        }
        // Otherwise try flexible update (user can continue using app).
        else if (updateInfo.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
          // Once downloaded, prompt to install.
          await InAppUpdate.completeFlexibleUpdate();
        }
      }
    } catch (e) {
      // In-app update not available (e.g. debug build, sideloaded, emulator).
      // Silently ignore — don't block the user.
      debugPrint('In-app update check failed: $e');
    }
  }
}
