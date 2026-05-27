import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../network/network_service.dart';
import '../network/endpoints/api_endpoints.dart';
import '../storage/secure_storage_service.dart';
import 'notification_service.dart';

class FcmService extends GetxService {
  static FcmService get to => Get.find();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _currentToken;

  @override
  void onInit() {
    super.onInit();
    _initFCM();
  }

  Future<void> _initFCM() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    _currentToken = await _messaging.getToken();
    if (_currentToken != null) {
      // Save token locally only - server sync happens after login
      await SecureStorageService.to.saveFcmToken(_currentToken!);
    }
    _messaging.onTokenRefresh.listen((token) {
      _currentToken = token;
      SecureStorageService.to.saveFcmToken(token);
      // Try to sync if user is logged in
      _syncTokenIfLoggedIn(token);
    });
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Call this after successful login to sync FCM token to server
  Future<void> syncTokenToServer() async {
    final token = _currentToken ?? await _messaging.getToken();
    if (token == null) return;
    _currentToken = token;
    await SecureStorageService.to.saveFcmToken(token);
    try {
      await NetworkService.to.post(
        ApiEndpoints.saveFcmToken,
        data: {'fcm_token': token},
        options: Options(extra: {'noRetry': true}),
      );
    } catch (e) {
      // Token saved locally, will be synced later if needed
    }
  }

  Future<void> _syncTokenIfLoggedIn(String token) async {
    final authToken = await SecureStorageService.to.getToken();
    if (authToken == null) return; // Not logged in, skip server sync
    try {
      await NetworkService.to.post(
        ApiEndpoints.saveFcmToken,
        data: {'fcm_token': token},
        options: Options(extra: {'noRetry': true}),
      );
    } catch (e) {
      // Token saved locally, ignore server error
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    NotificationService.to.showLocalNotification(message);
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Navigate to relevant screen based on notification data
  }

  Future<void> removeToken() async {
    final authToken = await SecureStorageService.to.getToken();
    if (authToken == null) return; // Not logged in, skip server call
    try {
      final token = _currentToken ?? await _messaging.getToken();
      if (token != null) {
        await NetworkService.to.delete(
          ApiEndpoints.removeFcmToken,
          data: {'fcm_token': token},
          options: Options(extra: {'noRetry': true}),
        );
      }
    } catch (e) {
      // Ignore removal errors
    }
  }
}