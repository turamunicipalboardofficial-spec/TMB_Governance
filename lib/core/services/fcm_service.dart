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
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      // Permission request failed (e.g. no Play Services); continue without push support.
    }

    try {
      _currentToken = await _messaging.getToken();
      if (_currentToken != null) {
        // Save token locally only - server sync happens after login
        await SecureStorageService.to.saveFcmToken(_currentToken!);
      }
    } catch (e) {
      // Token retrieval failed (commonly SERVICE_NOT_AVAILABLE when Google Play
      // Services is missing/outdated or there's no network at startup).
      // The app should keep working without a push token.
      _currentToken = null;
    }

    _messaging.onTokenRefresh.listen((token) {
      _currentToken = token;
      SecureStorageService.to.saveFcmToken(token);
      // Try to sync if user is logged in
      _syncTokenIfLoggedIn(token);
    });
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      // Ignore failures reading the initial message.
    }
  }

  /// Call this after successful login to sync FCM token to server
  Future<void> syncTokenToServer() async {
    String? token = _currentToken;
    if (token == null) {
      try {
        token = await _messaging.getToken();
      } catch (e) {
        // Play Services unavailable or no network; skip sync for now.
        return;
      }
    }
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
      String? token = _currentToken;
      token ??= await _messaging.getToken();
      if (token != null) {
        await NetworkService.to.delete(
          ApiEndpoints.removeFcmToken,
          data: {'fcm_token': token},
          options: Options(extra: {'noRetry': true}),
        );
      }
    } catch (e) {
      // Ignore removal errors (includes Play Services token failures)
    }
  }
}