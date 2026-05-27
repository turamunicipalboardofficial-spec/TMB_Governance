# Firebase / FCM Push Notification - Flutter Integration Guide

## Overview

This guide covers all the changes needed in the **Flutter application** to integrate Firebase Cloud Messaging (FCM) push notifications with the Tura Municipal Board API. The backend is already deployed and ready — this document focuses exclusively on the Flutter side.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Flutter Dependencies](#2-flutter-dependencies)
3. [Android Configuration](#3-android-configuration)
4. [iOS Configuration (if applicable)](#4-ios-configuration-if-applicable)
5. [Firebase Initialization in Flutter](#5-firebase-initialization-in-flutter)
6. [FCM Token Management (Save/Remove)](#6-fcm-token-management)
7. [Handling Incoming Notifications](#7-handling-incoming-notifications)
8. [Notification Permission Handling](#8-notification-permission-handling)
9. [Token Refresh Handling](#9-token-refresh-handling)
10. [Integration with Existing Auth Flow](#10-integration-with-existing-auth-flow)
11. [Complete Service File](#11-complete-push-notification-service-file)
12. [Notification Payload Structure](#12-notification-payload-structure)
13. [Testing](#13-testing)
14. [Troubleshooting](#14-troubleshooting)

---

## 1. Prerequisites

- Flutter project with minimum SDK 21 (Android) / 13.0 (iOS)
- Firebase project: `turamunicipalboard-5d2eb`
- Access to Firebase Console: https://console.firebase.google.com/
- The file `google-services.json` (already provided in the Laravel project root)

---

## 2. Flutter Dependencies

### Add to `pubspec.yaml`

```yaml
dependencies:
  # Firebase Core (required)
  firebase_core: ^3.8.1
  
  # Firebase Cloud Messaging
  firebase_messaging: ^15.2.1
  
  # For displaying local notifications (foreground)
  flutter_local_notifications: ^18.0.1
  
  # For HTTP requests to save FCM token
  http: ^1.2.2
  
  # For storing token locally (optional but recommended)
  shared_preferences: ^2.3.3
```

### Install dependencies

```bash
flutter pub get
```

---

## 3. Android Configuration

### 3.1 Place `google-services.json`

Copy the `google-services.json` file to:

```
android/app/google-services.json
```

The file should contain:
- `project_id`: `turamunicipalboard-5d2eb`
- `package_name`: Your app's package name (e.g., `com.turamunicipalboard.app`)

### 3.2 Update `android/build.gradle` (Project-level)

```groovy
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

### 3.3 Update `android/app/build.gradle` (App-level)

```groovy
// At the top of the file
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'com.google.gms.google-services'  // ADD THIS LINE
}

// In the defaultConfig section
android {
    defaultConfig {
        minSdkVersion 21  // Minimum required for FCM
        // ... other config
    }
}
```

### 3.4 Update `android/app/src/main/AndroidManifest.xml`

Add the following permissions and metadata:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

    <application
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:label="Tura Municipal Board">

        <!-- Add this meta-data for default notification channel -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="tura_municipal_notifications" />

        <!-- Optional: Set default notification icon -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@mipmap/ic_launcher" />

        <!-- Optional: Set notification color -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_color"
            android:resource="@color/ic_launcher_background" />

        <!-- ... existing activity and other config ... -->
    </application>
</manifest>
```

### 3.5 Create Notification Channel (Android 8.0+)

Create a notification channel for the app. This is typically done in the main activity or application class:

**`android/app/src/main/kotlin/.../MainActivity.kt`** (if using Kotlin):

```kotlin
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onStart() {
        super.onStart()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "tura_municipal_notifications",
                "Tura Municipal Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications from Tura Municipal Board"
                enableVibration(true)
            }
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
}
```

---

## 4. iOS Configuration (if applicable)

### 4.1 Place `GoogleService-Info.plist`

Copy the file to:
```
ios/Runner/GoogleService-Info.plist
```

### 4.2 Update `ios/Runner/Info.plist`

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 4.3 Update `ios/Runner/AppDelegate.swift`

```swift
import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        GeneratedPluginRegistrant.register(with: self)
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

---

## 5. Firebase Initialization in Flutter

### 5.1 Update `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart'; // Generated by flutterfire CLI

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message received: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(MyApp());
}
```

### 5.2 Generate `firebase_options.dart` (Recommended)

Use the FlutterFire CLI to generate platform-specific configuration:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter project
flutterfire configure --project=turamunicipalboard-5d2eb
```

This will generate `lib/firebase_options.dart` with the correct configuration for each platform.

If not using FlutterFire CLI, you can manually create it:

```dart
// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Return Android options for Android, iOS for iOS, etc.
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'turamunicipalboard-5d2eb',
    storageBucket: 'turamunicipalboard-5d2eb.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'turamunicipalboard-5d2eb',
    storageBucket: 'turamunicipalboard-5d2eb.appspot.com',
    iosBundleId: 'com.turamunicipalboard.app',
  );
}
```

---

## 6. FCM Token Management

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/trade-licenses/fcm-token` | Save FCM token (after login) |
| `DELETE` | `/api/trade-licenses/fcm-token` | Remove FCM token (on logout) |

### Base URL

```
https://laravelv2.turamunicipalboard.com
```

### 6.1 Save FCM Token After Login

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FcmService {
  static const String baseUrl = 'https://laravelv2.turamunicipalboard.com';
  
  /// Save FCM token to server - call this after successful login
  static Future<bool> saveFcmToken(String jwtToken) async {
    try {
      // Get the device's FCM token
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      
      if (fcmToken == null) {
        print('Failed to get FCM token');
        return false;
      }
      
      print('FCM Token: $fcmToken');
      
      // Send to server
      final response = await http.post(
        Uri.parse('$baseUrl/api/trade-licenses/fcm-token'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': fcmToken,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('FCM token saved: ${data['message']}');
        return true;
      } else {
        print('Failed to save FCM token: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error saving FCM token: $e');
      return false;
    }
  }
  
  /// Remove FCM token from server - call this on logout
  static Future<bool> removeFcmToken(String jwtToken) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/trade-licenses/fcm-token'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('FCM token removed: ${data['message']}');
        
        // Also delete the token from the device
        await FirebaseMessaging.instance.deleteToken();
        return true;
      } else {
        print('Failed to remove FCM token: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error removing FCM token: $e');
      return false;
    }
  }
}
```

### 6.2 API Request/Response Examples

**Save Token Request:**
```http
POST /api/trade-licenses/fcm-token HTTP/1.1
Host: laravelv2.turamunicipalboard.com
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
Content-Type: application/json

{
    "fcm_token": "dLxK7Yz8Efc:APA91bHq4xO7v..."
}
```

**Save Token Response (200):**
```json
{
    "success": true,
    "message": "FCM token saved successfully"
}
```

**Remove Token Request:**
```http
DELETE /api/trade-licenses/fcm-token HTTP/1.1
Host: laravelv2.turamunicipalboard.com
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

**Remove Token Response (200):**
```json
{
    "success": true,
    "message": "FCM token removed successfully"
}
```

**Error Response (401):**
```json
{
    "success": false,
    "message": "Unauthorized"
}
```

---

## 7. Handling Incoming Notifications

### 7.1 Foreground Notifications (App is open)

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandler {
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  /// Initialize local notifications for foreground display
  static Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        _handleNotificationTap(response.payload);
      },
    );
  }
  
  /// Listen for foreground messages
  static void listenForForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received:');
      print('  Title: ${message.notification?.title}');
      print('  Body: ${message.notification?.body}');
      print('  Data: ${message.data}');
      
      // Show local notification since FCM doesn't display
      // notifications automatically when app is in foreground
      _showLocalNotification(message);
    });
  }
  
  /// Display a local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'tura_municipal_notifications',
      'Tura Municipal Notifications',
      channelDescription: 'Notifications from Tura Municipal Board',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );
    
    await _localNotifications.show(
      message.hashCode, // Unique ID
      message.notification?.title ?? 'Tura Municipal Board',
      message.notification?.body ?? '',
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }
  
  /// Handle notification tap
  static void _handleNotificationTap(String? payload) {
    if (payload != null) {
      final data = jsonDecode(payload);
      print('Notification tapped with data: $data');
      
      // Navigate based on notification type
      if (data.containsKey('renewal_id')) {
        // Navigate to trade license renewal details
        // Navigator.pushNamed(context, '/trade-license-renewal', arguments: data['renewal_id']);
      }
    }
  }
}
```

### 7.2 Background/Quit Notifications (App is closed or in background)

```dart
/// This is already set up in main.dart as _firebaseMessagingBackgroundHandler
/// When user taps a notification that opened the app:

// Check if app was opened from a notification
FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
  if (message != null) {
    print('App opened from notification:');
    print('  Title: ${message.notification?.title}');
    print('  Body: ${message.notification?.body}');
    print('  Data: ${message.data}');
    
    // Navigate to appropriate screen after a delay (to allow app to initialize)
    Future.delayed(Duration(seconds: 1), () {
      _handleNotificationNavigation(message.data);
    });
  }
});

// Handle notification tap when app is in background
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  print('Notification opened app from background:');
  print('  Title: ${message.notification?.title}');
  print('  Body: ${message.notification?.body}');
  print('  Data: ${message.data}');
  
  _handleNotificationNavigation(message.data);
});

/// Navigation handler
void _handleNotificationNavigation(Map<String, dynamic> data) {
  if (data.containsKey('type')) {
    switch (data['type']) {
      case 'renewal_approved':
        // Navigate to renewal details
        // Navigator.pushNamed(context, '/trade-license-renewal', args: data['renewal_id']);
        break;
      case 'renewal_rejected':
        // Navigate to renewal details with rejection info
        // Navigator.pushNamed(context, '/trade-license-renewal', args: data['renewal_id']);
        break;
      case 'license_issued':
        // Navigate to license details
        // Navigator.pushNamed(context, '/trade-license', args: data['license_id']);
        break;
      default:
        // Navigate to notifications list or home
        // Navigator.pushNamed(context, '/notifications');
        break;
    }
  }
}
```

---

## 8. Notification Permission Handling

### 8.1 Request Permission (Android 13+ and iOS)

```dart
class PermissionHandler {
  /// Request notification permission
  static Future<bool> requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    
    // Request permission (iOS and Android 13+)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    print('Notification permission status: ${settings.authorizationStatus}');
    
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        print('User granted permission');
        return true;
      case AuthorizationStatus.provisional:
        print('User granted provisional permission');
        return true;
      case AuthorizationStatus.denied:
        print('User denied permission');
        return false;
      case AuthorizationStatus.notDetermined:
        print('Permission not determined');
        return false;
    }
  }
  
  /// Check current permission status
  static Future<bool> isNotificationPermissionGranted() async {
    NotificationSettings settings = 
        await FirebaseMessaging.instance.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}
```

---

## 9. Token Refresh Handling

FCM tokens can change when:
- App is restored on a new device
- User uninstalls/reinstalls the app
- User clears app data
- Firebase refreshes the token

```dart
class TokenRefreshHandler {
  /// Listen for token refreshes and sync with server
  static void listenForTokenRefresh(String jwtToken) {
    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) {
      print('FCM token refreshed: $newToken');
      
      // Re-save the new token to server
      _saveRefreshedToken(jwtToken, newToken);
    });
  }
  
  static Future<void> _saveRefreshedToken(String jwtToken, String newToken) async {
    try {
      final response = await http.post(
        Uri.parse('https://laravelv2.turamunicipalboard.com/api/trade-licenses/fcm-token'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': newToken,
        }),
      );
      
      if (response.statusCode == 200) {
        print('Refreshed FCM token saved to server');
      } else {
        print('Failed to save refreshed token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving refreshed token: $e');
    }
  }
}
```

---

## 10. Integration with Existing Auth Flow

### 10.1 After Login

```dart
// In your login function
Future<void> loginUser(String email, String password) async {
  // 1. Call login API
  final response = await http.post(
    Uri.parse('https://laravelv2.turamunicipalboard.com/api/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    String jwtToken = data['token'];
    
    // 2. Save JWT token locally
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', jwtToken);
    
    // 3. Save FCM token to server
    await FcmService.saveFcmToken(jwtToken);
    
    // 4. Start listening for token refresh
    TokenRefreshHandler.listenForTokenRefresh(jwtToken);
    
    // 5. Navigate to home
    Navigator.pushReplacementNamed(context, '/home');
  }
}
```

### 10.2 On Logout

```dart
Future<void> logoutUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? jwtToken = prefs.getString('jwt_token');
  
  // 1. Remove FCM token from server (before clearing JWT)
  if (jwtToken != null) {
    await FcmService.removeFcmToken(jwtToken);
  }
  
  // 2. Call logout API
  if (jwtToken != null) {
    await http.post(
      Uri.parse('https://laravelv2.turamunicipalboard.com/api/logout'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      },
    );
  }
  
  // 3. Clear local storage
  await prefs.remove('jwt_token');
  
  // 4. Navigate to login
  Navigator.pushReplacementNamed(context, '/login');
}
```

### 10.3 On App Start (Re-check Token)

```dart
// In your splash screen or main initialization
Future<void> initializeApp() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? jwtToken = prefs.getString('jwt_token');
  
  if (jwtToken != null) {
    // User is logged in - ensure FCM token is saved
    await FcmService.saveFcmToken(jwtToken);
    TokenRefreshHandler.listenForTokenRefresh(jwtToken);
  }
}
```

---

## 11. Complete Push Notification Service File

Create this file in your Flutter project: `lib/services/push_notification_service.dart`

```dart
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  static const String baseUrl = 'https://laravelv2.turamunicipalboard.com';
  static const String channelId = 'tura_municipal_notifications';
  static const String channelName = 'Tura Municipal Notifications';

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  String? _currentJwtToken;
  GlobalKey<NavigatorState>? navigatorKey;

  /// Initialize push notifications
  Future<void> initialize({GlobalKey<NavigatorState>? navKey}) async {
    navigatorKey = navKey;
    
    // 1. Request permission
    await _requestPermission();
    
    // 2. Initialize local notifications
    await _initializeLocalNotifications();
    
    // 3. Get and log FCM token
    String? token = await _fcm.getToken();
    print('FCM Token: $token');
    
    // 4. Set up message handlers
    _setupMessageHandlers();
    
    // 5. Listen for token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
      if (_currentJwtToken != null) {
        _saveFcmTokenToServer(_currentJwtToken!, newToken);
      }
    });
  }

  /// Set the current JWT token (call after login/token refresh)
  void setJwtToken(String token) {
    _currentJwtToken = token;
    // Also save FCM token when JWT is set
    saveFcmTokenToServer(token);
  }

  /// Clear JWT token (call on logout)
  void clearJwtToken() {
    _currentJwtToken = null;
  }

  // ============================================================
  // PERMISSION
  // ============================================================

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    print('Notification permission: ${settings.authorizationStatus}');
    
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('User denied notification permissions. Consider guiding them to settings.');
    }
  }

  // ============================================================
  // LOCAL NOTIFICATIONS (for foreground display)
  // ============================================================

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: 'Notifications from Tura Municipal Board',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ============================================================
  // MESSAGE HANDLERS
  // ============================================================

  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Background message tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from background notification');
      _handleNotificationNavigation(message.data);
    });

    // App opened from terminated state via notification
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state via notification');
        Future.delayed(const Duration(seconds: 2), () {
          _handleNotificationNavigation(message.data);
        });
      }
    });
  }

  // ============================================================
  // SHOW LOCAL NOTIFICATION (foreground)
  // ============================================================

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title ?? 'Tura Municipal Board',
        notification.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: 'Notifications from Tura Municipal Board',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF1976D2), // Blue color
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  // ============================================================
  // NOTIFICATION TAP HANDLING
  // ============================================================

  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        _handleNotificationNavigation(data);
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    print('Notification data: $data');
    
    if (navigatorKey?.currentContext == null) {
      print('Navigator context not available, skipping navigation');
      return;
    }

    final type = data['type'] as String?;
    
    switch (type) {
      case 'renewal_approved':
      case 'renewal_rejected':
        final renewalId = data['renewal_id'];
        if (renewalId != null) {
          // Navigate to trade license renewal details
          // Navigator.of(navigatorKey!.currentContext!).pushNamed(
          //   '/trade-license-renewal-detail',
          //   arguments: renewalId.toString(),
          // );
        }
        break;
      case 'license_issued':
        final licenseId = data['license_id'];
        if (licenseId != null) {
          // Navigate to trade license details
          // Navigator.of(navigatorKey!.currentContext!).pushNamed(
          //   '/trade-license-detail',
          //   arguments: licenseId.toString(),
          // );
        }
        break;
      default:
        // Navigate to notifications list or home
        // Navigator.of(navigatorKey!.currentContext!).pushNamed('/notifications');
        break;
    }
  }

  // ============================================================
  // FCM TOKEN MANAGEMENT (API calls)
  // ============================================================

  /// Save FCM token to server
  Future<bool> saveFcmTokenToServer(String jwtToken) async {
    _currentJwtToken = jwtToken;
    
    try {
      String? fcmToken = await _fcm.getToken();
      if (fcmToken == null) {
        print('Cannot get FCM token');
        return false;
      }
      
      return await _saveFcmTokenToServer(jwtToken, fcmToken);
    } catch (e) {
      print('Error in saveFcmTokenToServer: $e');
      return false;
    }
  }

  Future<bool> _saveFcmTokenToServer(String jwtToken, String fcmToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/trade-licenses/fcm-token'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'fcm_token': fcmToken}),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        print('FCM token saved to server successfully');
        return true;
      } else {
        print('Failed to save FCM token: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error saving FCM token to server: $e');
      return false;
    }
  }

  /// Remove FCM token from server (call on logout)
  Future<bool> removeFcmTokenFromServer(String jwtToken) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/trade-licenses/fcm-token'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        print('FCM token removed from server successfully');
        await _fcm.deleteToken();
        return true;
      } else {
        print('Failed to remove FCM token: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error removing FCM token from server: $e');
      return false;
    }
  }

  /// Get current FCM token (for debugging)
  Future<String?> getCurrentFcmToken() async {
    return await _fcm.getToken();
  }
}
```

---

## 12. Notification Payload Structure

When the server sends a notification, it includes both `notification` (display) and `data` (custom payload) fields:

### Notification Payload Example

```json
{
  "notification": {
    "title": "Trade License Renewal Approved",
    "body": "Your trade license renewal (ID: TLR-2026-001) has been approved."
  },
  "data": {
    "type": "renewal_approved",
    "renewal_id": "123",
    "license_number": "TL-2026-0045",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  }
}
```

### Notification Types

| `data.type` | Title | Body | Navigation Target |
|-------------|-------|------|-------------------|
| `renewal_approved` | Trade License Renewal Approved | Your renewal (ID: TLR-XXX) has been approved. | Renewal detail screen |
| `renewal_rejected` | Trade License Renewal Rejected | Your renewal (ID: TLR-XXX) has been rejected. Reason: ... | Renewal detail screen |
| `license_issued` | Trade License Issued | Your renewed license (No: XXX) has been issued. | License detail screen |

### Data Fields

| Field | Type | Description |
|-------|------|-------------|
| `type` | String | Notification type (see table above) |
| `renewal_id` | String | Trade license renewal ID |
| `license_id` | String | Trade license ID (for license issued) |
| `license_number` | String | License number |
| `click_action` | String | Always `FLUTTER_NOTIFICATION_CLICK` |

---

## 13. Testing

### 13.1 Test FCM Token Save

```bash
# Get a valid JWT token first, then:
curl -X POST "https://laravelv2.turamunicipalboard.com/api/trade-licenses/fcm-token" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"fcm_token": "test_token_123"}'
```

Expected response:
```json
{
    "success": true,
    "message": "FCM token saved successfully"
}
```

### 13.2 Test FCM Token Remove

```bash
curl -X DELETE "https://laravelv2.turamunicipalboard.com/api/trade-licenses/fcm-token" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Accept: application/json"
```

Expected response:
```json
{
    "success": true,
    "message": "FCM token removed successfully"
}
```

### 13.3 Test Sending a Notification (via Firebase Console)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `turamunicipalboard-5d2eb`
3. Go to **Messaging** → **Send your first message**
4. Enter notification title and body
5. Select **Single device** and paste the FCM token
6. Click **Review** → **Publish**

### 13.4 Debug FCM Token in Flutter

```dart
// Add this to any screen for debugging
ElevatedButton(
  onPressed: () async {
    String? token = await PushNotificationService().getCurrentFcmToken();
    print('Current FCM Token: $token');
    // Copy to clipboard or display
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('FCM Token: ${token?.substring(0, 30)}...')),
    );
  },
  child: Text('Get FCM Token'),
),
```

---

## 14. Troubleshooting

### Notifications not received on device

1. **Check FCM token is saved**: Call `getCurrentFcmToken()` and verify it matches what's in the database
2. **Check notification permission**: Ensure user granted notification permission
3. **Check Android battery optimization**: Some devices kill background apps. Guide user to disable battery optimization for the app
4. **Check logcat** (Android): `adb logcat | grep -i firebase`
5. **Verify `google-services.json`**: Ensure it's in `android/app/` and matches your package name

### "No FCM token" error

- Ensure `Firebase.initializeApp()` is called before `FirebaseMessaging.instance.getToken()`
- Check internet connectivity
- Verify `google-services.json` is up to date

### Notification shows but no sound/vibration

- Check the notification channel settings on Android
- Ensure `importance: Importance.high` is set
- Check device Do Not Disturb settings

### Background notifications not working

- Ensure `_firebaseMessagingBackgroundHandler` is a **top-level function** (not inside a class)
- It must be annotated with `@pragma('vm:entry-point')`
- `FirebaseMessaging.onBackgroundMessage()` must be called in `main()` before `runApp()`

### Token refresh not syncing with server

- Ensure `onTokenRefresh` listener is set up
- Check that `jwtToken` is available when refresh happens
- Look for network errors in logs

### App crashes on notification

- Check that `message.data` contains expected fields before accessing them
- Ensure notification icon exists (`@mipmap/ic_launcher`)
- Check for null values in notification title/body

---

## Quick Checklist

- [ ] `google-services.json` placed in `android/app/`
- [ ] Firebase dependencies added to `pubspec.yaml`
- [ ] Google Services plugin added to `android/build.gradle` and `android/app/build.gradle`
- [ ] `minSdkVersion` set to 21 or higher
- [ ] `Firebase.initializeApp()` called in `main()`
- [ ] Background message handler registered in `main()`
- [ ] Notification permission requested
- [ ] Local notifications initialized (for foreground display)
- [ ] FCM token saved to server after login (`POST /api/trade-licenses/fcm-token`)
- [ ] FCM token removed from server on logout (`DELETE /api/trade-licenses/fcm-token`)
- [ ] Token refresh listener set up
- [ ] Notification tap handling implemented
- [ ] Notification navigation implemented
- [ ] Tested foreground notifications
- [ ] Tested background notifications
- [ ] Tested app opened from terminated state via notification