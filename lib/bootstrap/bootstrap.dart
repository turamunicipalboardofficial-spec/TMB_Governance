import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import '../core/services/fcm_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/location_service.dart';
import '../core/network/network_service.dart';
import '../core/storage/secure_storage_service.dart';
import '../core/storage/local_storage_service.dart';
import '../core/services/connectivity_service.dart';

class Bootstrap {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // System UI
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Local storage
    await GetStorage.init();

    // Initialize Firebase
    await Firebase.initializeApp();

    // Register core services
    Get.put<SecureStorageService>(SecureStorageService(), permanent: true);
    Get.put<LocalStorageService>(LocalStorageService(), permanent: true);
    Get.put<NetworkService>(NetworkService(), permanent: true);
    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.put<FcmService>(FcmService(), permanent: true);
    Get.put<LocationService>(LocationService(), permanent: true);
  }
}
