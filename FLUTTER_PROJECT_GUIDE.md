# Tura Municipal Board — Admin Flutter App — Complete Project Guide

> **Purpose:** This document is a self-contained specification for building the **Admin/CEO/Driver Flutter app** for the Tura Municipal Board digital services portal. It covers architecture, theme, API integrations, models, screens, controllers, data sources, repositories, routes, and implementation order. An AI agent or developer should be able to build the entire app from this document alone.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Roles & Access Matrix](#2-roles--access-matrix)
3. [Theme & Design Tokens](#3-theme--design-tokens)
4. [Tech Stack & Packages](#4-tech-stack--packages)
5. [Architecture & Folder Structure](#5-architecture--folder-structure)
6. [Core Layer — Full Implementation](#6-core-layer--full-implementation)
7. [Features — Detailed Breakdown](#7-features--detailed-breakdown)
8. [Complete API Reference](#8-complete-api-reference)
9. [Route Definitions](#9-route-definitions)
10. [Implementation Order](#10-implementation-order)

---

## 1. Project Overview

| Key | Value |
|---|---|
| **App Name** | Tura Municipal Admin |
| **Package Name** | `com.turamunicipal.admin` |
| **Base URL (Dev)** | `http://14.102.148.70:8975` |
| **Base URL (Prod)** | `http://14.102.148.70:8975` |
| **Auth** | JWT Bearer Token |
| **Roles** | `ceo`, `admin` (employee), `driver` |
| **State Management** | GetX |
| **Networking** | Dio |
| **Design Frame** | 375 × 812 (iPhone 14) |

### Role Definitions

| Role | Description |
|---|---|
| **CEO** | Full access to all admin features — dashboard, all CRUD operations, approvals, billing, garbage management, advertisements, notices, notifications, payment history, pet dog management |
| **Admin (Employee)** | Limited access — form approvals, grievance management, notice/announcement management, notification broadcast |
| **Driver** | Garbage truck driver — view assigned route, start/end shift, update GPS location |

---

## 2. Roles & Access Matrix

| Feature | CEO | Admin (Employee) | Driver |
|---|:---:|:---:|:---:|
| Login/Logout | ✅ | ✅ | ✅ |
| Profile & Change Password | ✅ | ✅ | ✅ |
| Admin Dashboard | ✅ | ❌ | ❌ |
| Form Approvals | ✅ | ✅ | ❌ |
| Form Statistics | ✅ | ❌ | ❌ |
| Pet Dog Certificate Generation | ✅ | ❌ | ❌ |
| Job Posting CRUD | ✅ | ❌ | ❌ |
| Trade License Renewals | ✅ | ❌ | ❌ |
| Trade License Stats | ✅ | ❌ | ❌ |
| Trade License Broadcast | ✅ | ❌ | ❌ |
| Holding Tax Stats | ✅ | ❌ | ❌ |
| Grievance Management | ✅ | ✅ | ❌ |
| Billing Management | ✅ | ❌ | ❌ |
| Garbage Truck Management | ✅ | ❌ | ❌ |
| Garbage Dashboard | ✅ | ❌ | ❌ |
| Advertisement CRUD | ✅ | ❌ | ❌ |
| Notice/Announcement CRUD | ✅ | ✅ | ❌ |
| Notification Broadcast | ✅ | ✅ | ❌ |
| Notification Statistics | ✅ | ❌ | ❌ |
| Payment History | ✅ | ❌ | ❌ |
| Pet Dog Applications | ✅ | ❌ | ❌ |
| Driver: Start/End Shift | ❌ | ❌ | ✅ |
| Driver: Update Location | ❌ | ❌ | ✅ |
| Driver: View Assigned Route | ❌ | ❌ | ✅ |

**Navigation by Role:**

- **CEO Bottom Nav:** Dashboard → Forms → Jobs → More (drawer/expandable with: Trade License, Grievances, Billing, Garbage, Ads, Notices, Notifications, Payment History, Pet Dog, Profile)
- **Admin (Employee) Bottom Nav:** Forms → Grievances → Notices → Notifications → Profile
- **Driver:** Single screen — Assigned Route Map + Start/End Shift button + Location update

---

## 3. Theme & Design Tokens

### AppColors — Primary & Accent (Exact values from the codebase)

```dart
import 'package:flutter/material.dart';

class AppColors {
  // ── Primary ──────────────────────────────────────
  static const Color primary            = Color(0xFF1B3A6B); // Deep navy blue
  static const Color primaryDark        = Color(0xFF12284D); // Darker navy
  static const Color primaryLight       = Color(0xFF2D5494); // Lighter navy
  static const Color primaryExtraLight  = Color(0xFFE8EDF5); // Very light blue tint

  // ── Accent / Secondary ───────────────────────────
  static const Color accent             = Color(0xFFFF8C00); // Deep orange
  static const Color accentDark         = Color(0xFFCC7000); // Darker orange
  static const Color accentLight        = Color(0xFFFFA333); // Lighter orange
  static const Color accentExtraLight   = Color(0xFFFFF3E0); // Very light orange tint

  // ── Semantic / Status ────────────────────────────
  static const Color success            = Color(0xFF28A745);
  static const Color successLight       = Color(0xFFE8F5E9);
  static const Color error              = Color(0xFFDC3545);
  static const Color errorLight         = Color(0xFFFDEDED);
  static const Color warning            = Color(0xFFFFC107);
  static const Color warningLight       = Color(0xFFFFF8E1);
  static const Color info               = Color(0xFF17A2B8);
  static const Color infoLight          = Color(0xFFE0F7FA);

  // ── Neutral / Background / Surface ───────────────
  static const Color background         = Color(0xFFF5F7FA);
  static const Color surface            = Color(0xFFFFFFFF);
  static const Color surfaceVariant     = Color(0xFFF0F2F5);
  static const Color border             = Color(0xFFD1D5DB);
  static const Color divider            = Color(0xFFE5E7EB);

  // ── Text ─────────────────────────────────────────
  static const Color textPrimary        = Color(0xFF1F2937);
  static const Color textSecondary      = Color(0xFF6B7280);
  static const Color textTertiary       = Color(0xFF9CA3AF);
  static const Color textOnPrimary      = Color(0xFFFFFFFF);
  static const Color textOnAccent       = Color(0xFFFFFFFF);

  // ── Disabled / Overlay ───────────────────────────
  static const Color disabled           = Color(0xFFD1D5DB);
  static const Color disabledText       = Color(0xFF9CA3AF);
  static const Color overlay            = Color(0x80000000);
  static const Color shimmerBase        = Color(0xFFE0E0E0);
  static const Color shimmerHighlight   = Color(0xFFF5F5F5);
}
```

### Text Styles

```dart
class AppTextStyles {
  static const TextStyle h1 = TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2);
  static const TextStyle h2 = TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3);
  static const TextStyle h3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.3);
  static const TextStyle h4 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4);
  static const TextStyle subtitle1 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle subtitle2 = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
  static const TextStyle bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.5);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.5);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.5);
  static const TextStyle button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textOnPrimary);
  static const TextStyle caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textTertiary);
  static const TextStyle overline = TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 1.5);
}
```

### AppSizes

```dart
class AppSizes {
  static const double paddingXXS = 2;
  static const double paddingXS = 4;
  static const double paddingS = 8;
  static const double paddingM = 12;
  static const double paddingL = 16;
  static const double paddingXL = 20;
  static const double paddingXXL = 24;
  static const double paddingXXXL = 32;

  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 20;
  static const double radiusXXL = 24;
  static const double radiusRound = 100;

  static const double iconXS = 12;
  static const double iconS = 16;
  static const double iconM = 20;
  static const double iconL = 24;
  static const double iconXL = 32;
  static const double iconXXL = 48;

  static const double buttonHeight = 50;
  static const double inputHeight = 50;
  static const double cardElevation = 2;

  static const double bottomNavHeight = 70;
  static const double appBarHeight = 60;
}
```

### ThemeData

```dart
ThemeData buildAdminTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      secondary: AppColors.accent,
      onSecondary: AppColors.textOnAccent,
      error: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.button,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
```

---

## 4. Tech Stack & Packages

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6                    # State management, routing, DI
  dio: ^5.4.0                    # HTTP client
  get_storage: ^2.1.1            # Local storage (non-sensitive)
  flutter_secure_storage: ^9.0.0 # Secure storage (JWT tokens)
  flutter_screenutil: ^5.9.0     # Responsive sizing
  flutter_svg: ^2.0.9            # SVG rendering
  firebase_core: ^2.24.0         # Firebase initialization
  firebase_messaging: ^14.7.15   # FCM push notifications
  flutter_local_notifications: ^16.3.0  # Local notification display
  google_maps_flutter: ^2.5.3    # Google Maps (driver route tracking)
  geolocator: ^11.0.0            # GPS location for driver
  location: ^6.0.1               # Background location updates
  intl: ^0.19.0                  # Date/number formatting
  shimmer: ^3.0.0                # Loading skeleton animations
  cached_network_image: ^3.3.0   # Image caching
  photo_view: ^0.15.0            # Image zoom (viewing attachments)
  pull_to_refresh: ^2.0.0        # Pull-to-refresh lists
  flutter_localizations:
    sdk: flutter
  cupertino_icons: ^1.0.6
```

---

## 5. Architecture & Folder Structure

### Full Folder Tree

```
lib/
├── main.dart
│
├── app/
│   ├── app.dart                         # GetMaterialApp + ScreenUtilInit
│   ├── app_binding.dart                 # Global GetX bindings
│   ├── app_lifecycle.dart               # App foreground/background handler
│   ├── app_router.dart                  # Route resolver
│   └── app_theme.dart                   # Theme wrapper
│
├── bootstrap/
│   ├── bootstrap.dart                   # Init orchestrator
│   └── app_initializer.dart             # Firebase, Storage, SystemUI init
│
├── config/
│   ├── env.dart                         # Active env selector
│   ├── dev_env.dart                     # Dev base URL
│   └── prod_env.dart                    # Prod base URL
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_sizes.dart
│   │   ├── app_assets.dart
│   │   └── app_strings.dart
│   ├── design_system/
│   │   ├── tokens/
│   │   │   ├── app_spacing.dart
│   │   │   └── app_radius.dart
│   │   ├── typography/
│   │   │   ├── app_text_styles.dart
│   │   │   └── app_text.dart
│   │   ├── atoms/
│   │   │   ├── app_text.dart
│   │   │   ├── app_icon.dart
│   │   │   ├── app_divider.dart
│   │   │   ├── status_badge.dart       # NEW: colored status chip
│   │   │   └── stat_card.dart          # NEW: dashboard stat card
│   │   ├── molecules/
│   │   │   ├── custom_input_field.dart
│   │   │   ├── custom_dropdown_field.dart
│   │   │   ├── primary_button.dart
│   │   │   ├── gradient_button.dart
│   │   │   ├── search_bar.dart
│   │   │   ├── timer_badge.dart
│   │   │   ├── custom_snackbar.dart
│   │   │   ├── confirmation_dialog.dart # NEW: approve/reject dialog
│   │   │   └── filter_chip_row.dart     # NEW: status filter chips
│   │   ├── organisms/
│   │   │   ├── app_card.dart
│   │   │   ├── app_bottom_nav_bar.dart
│   │   │   ├── admin_drawer.dart        # NEW: admin side drawer
│   │   │   ├── dashboard_stat_grid.dart # NEW: stat cards grid
│   │   │   ├── list_item_card.dart      # NEW: generic list item
│   │   │   └── empty_state.dart         # NEW: empty list placeholder
│   │   └── templates/
│   │       ├── app_scaffold.dart
│   │       ├── admin_layout.dart        # NEW: admin scaffold with drawer
│   │       └── driver_layout.dart       # NEW: driver scaffold (map)
│   ├── error/
│   │   ├── failure.dart
│   │   ├── app_exceptions.dart
│   │   └── error_handler.dart
│   ├── extensions/
│   │   └── context_extensions.dart
│   ├── localization/
│   │   ├── translations.dart
│   │   └── supported_locales.dart
│   ├── models/
│   │   ├── ward_model.dart
│   │   ├── locality_model.dart
│   │   └── paginated_response.dart     # NEW: generic pagination wrapper
│   ├── network/
│   │   ├── network_service.dart
│   │   ├── network_info.dart
│   │   ├── api_constants.dart
│   │   ├── client/
│   │   │   └── dio_client.dart
│   │   ├── endpoints/
│   │   │   └── api_endpoints.dart
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       ├── logging_interceptor.dart
│   │       └── retry_interceptor.dart
│   ├── services/
│   │   ├── logger_service.dart
│   │   ├── connectivity_service.dart
│   │   ├── fcm_service.dart
│   │   ├── notification_service.dart
│   │   └── location_service.dart       # GPS for driver app
│   ├── storage/
│   │   ├── storage_keys.dart
│   │   ├── local_storage_service.dart
│   │   └── secure_storage_service.dart
│   └── utils/
│       ├── validators.dart
│       ├── formatters.dart
│       ├── debouncer.dart
│       └── extensions.dart
│
├── features/
│   ├── splash/
│   ├── auth/
│   ├── main_shell/
│   ├── dashboard/
│   ├── form_approval/
│   ├── job_posting/
│   ├── trade_license_admin/
│   ├── holding_tax_admin/
│   ├── grievance_admin/
│   ├── billing_admin/
│   ├── garbage_admin/
│   ├── garbage_driver/
│   ├── advertisement_admin/
│   ├── notice_admin/
│   ├── notification_admin/
│   ├── payment_history/
│   ├── pet_dog_admin/
│   └── profile/
│
├── routes/
│   ├── app_routes.dart
│   └── app_pages.dart
│
├── theme/
│   ├── theme_config.dart
│   └── text_styles.dart
│
└── l10n/
    ├── app_en.arb
    └── app_hi.arb
```

---

## 6. Core Layer — Full Implementation

### 6.1 Network Service

```dart
// core/network/network_service.dart
class NetworkService extends GetxService {
  static NetworkService get to => Get.find();
  late final Dio _dio;

  @override
  void onInit() {
    super.onInit();
    _dio = DioClient.create();
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) =>
      _dio.get(path, queryParameters: queryParameters, options: options);

  Future<Response> post(String path, {dynamic data, Options? options}) =>
      _dio.post(path, data: data, options: options);

  Future<Response> put(String path, {dynamic data, Options? options}) =>
      _dio.put(path, data: data, options: options);

  Future<Response> delete(String path, {dynamic data, Options? options}) =>
      _dio.delete(path, data: data, options: options);
}
```

### 6.2 Dio Client

```dart
// core/network/client/dio_client.dart
class DioClient {
  static Dio create() {
    final dio = Dio(BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));
    dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      RetryInterceptor(dio: dio, maxRetries: 2),
    ]);
    return dio;
  }
}
```

### 6.3 API Endpoints

```dart
// core/network/endpoints/api_endpoints.dart
class ApiEndpoints {
  // ── Auth ──────────────────────────────────────
  static const String login = '/api/login';
  static const String register = '/api/register';
  static const String logout = '/api/logout';
  static const String forgotPassword = '/api/forgot-password';
  static const String resetPassword = '/api/reset-password';
  static const String profileUpdate = '/api/profileUpdate';
  static const String changePassword = '/api/changePassword';
  static const String wardList = '/api/getWardList';
  static const String localityList = '/api/getLocalityList';

  // ── Admin — Dashboard ─────────────────────────
  static const String adminDashboard = '/api/admin/dashboard';
  static const String adminPaymentHistory = '/api/admin/payment-history';

  // ── Admin — Forms ─────────────────────────────
  static const String adminGetAllForms = '/api/admin/getAllForms';
  static const String adminFormStats = '/api/admin/getFormsPercentageBasedOnDate';
  static const String adminApproveRejectForm = '/api/admin/approvedOrRejectForm';
  static const String adminTradeLicenseFee = '/api/admin/tradeLicenseFee';
  static const String adminGeneratePetDogCert = '/api/admin/generatePetDogCertificate';

  // ── Admin — Jobs ──────────────────────────────
  static const String adminCreateJob = '/api/admin/createJobPosting';
  static const String adminGetAllJobs = '/api/admin/getAllJobPostings';
  static const String adminGetJobById = '/api/admin/getJobPostingById';
  static const String adminUpdateJob = '/api/admin/updateJobPosting';
  static const String adminDeleteJob = '/api/admin/deleteJobPosting';

  // ── Admin — Trade License ─────────────────────
  static const String adminRenewals = '/api/admin/trade-license/renewals';
  static const String adminApproveRenewal = '/api/admin/trade-license/approve-renewal';
  static const String adminRejectRenewal = '/api/admin/trade-license/reject-renewal';
  static const String adminCompleteRenewal = '/api/admin/trade-license/complete-renewal';
  static const String adminTradeLicenseStats = '/api/admin/trade-license/stats';
  static const String adminTradeLicenseBroadcast = '/api/admin/trade-license/broadcast-notification';

  // ── Admin — Holding Tax ───────────────────────
  static const String adminHoldingTaxStats = '/api/admin/holding-tax/stats';

  // ── Admin — Grievances ────────────────────────
  static const String adminGrievances = '/api/admin/grievances';
  static const String adminUpdateGrievance = '/api/admin/grievances/update-status';

  // ── Admin — Billing ───────────────────────────
  static const String adminGenerateBills = '/api/admin/billing/generate-bills';
  static const String adminUploadBillSheet = '/api/admin/billing/upload-sheet';
  static const String adminUpdatePayment = '/api/admin/billing/update-payment';
  static const String adminMarkets = '/api/markets';

  // ── Admin — Garbage Trucks ────────────────────
  static const String adminAddTruck = '/api/admin/garbage/add-truck';
  static const String adminUpdateTruck = '/api/admin/garbage/update-truck';
  static const String adminAssignDriver = '/api/admin/garbage/assign-driver';
  static const String adminCreateSchedule = '/api/admin/garbage/create-schedule';
  static const String adminGarbageDashboard = '/api/admin/garbage/dashboard';

  // ── Admin — Advertisements ────────────────────
  static const String adminAds = '/api/admin/advertisements';
  static const String adminAdPublish = '/api/admin/advertisements/{id}/publish';
  static const String adminAdPause = '/api/admin/advertisements/{id}/pause';
  static const String adminAdReject = '/api/admin/advertisements/{id}/reject';
  static const String adminAdStats = '/api/admin/advertisements/statistics';

  // ── Admin — Notices / Announcements ───────────
  static const String adminNotices = '/api/admin/notices';
  static const String adminNoticePublish = '/api/admin/notices/{id}/publish';
  static const String adminNoticeArchive = '/api/admin/notices/{id}/archive';
  static const String adminNoticeTogglePin = '/api/admin/notices/{id}/toggle-pin';
  static const String adminNoticeStats = '/api/admin/notices/statistics';

  // ── Admin — Notifications ─────────────────────
  static const String adminNotifications = '/api/admin/notifications';
  static const String adminBroadcast = '/api/admin/notifications/broadcast';
  static const String adminSendToUser = '/api/admin/notifications/send-to-user';
  static const String adminNotificationStats = '/api/admin/notifications/statistics';

  // ── Admin — Pet Dog ───────────────────────────
  static const String adminPetDogApps = '/api/admin/pet-dog/applications';
  static const String adminPetDogDetail = '/api/admin/pet-dog/application';
  static const String adminPetDogUpdatePayment = '/api/admin/pet-dog/update-payment';

  // ── Driver ────────────────────────────────────
  static const String driverStartShift = '/api/driver/start-shift';
  static const String driverEndShift = '/api/driver/end-shift';
  static const String driverUpdateLocation = '/api/driver/update-location';
  static const String driverAssignedRoute = '/api/driver/assigned-route';

  // ── Trade License (FCM Token) ─────────────────
  static const String saveFcmToken = '/api/trade-license/save-fcm-token';
  static const String removeFcmToken = '/api/trade-license/remove-fcm-token';
}
```

### 6.4 Auth Interceptor

```dart
// core/network/interceptors/auth_interceptor.dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorageService.to.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await SecureStorageService.to.deleteToken();
      Get.offAllNamed(AppRoutes.login);
    }
    handler.next(err);
  }
}
```

### 6.5 Secure Storage

```dart
// core/storage/secure_storage_service.dart
class SecureStorageService extends GetxService {
  static SecureStorageService get to => Get.find();
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) => _storage.write(key: StorageKeys.jwtToken, value: token);
  Future<String?> getToken() => _storage.read(key: StorageKeys.jwtToken);
  Future<void> deleteToken() => _storage.delete(key: StorageKeys.jwtToken);

  Future<void> saveRole(String role) => _storage.write(key: StorageKeys.userRole, value: role);
  Future<String?> getRole() => _storage.read(key: StorageKeys.userRole);
  Future<void> deleteRole() => _storage.delete(key: StorageKeys.userRole);

  Future<void> saveUserData(Map<String, dynamic> userData) =>
      _storage.write(key: StorageKeys.userData, value: jsonEncode(userData));
  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: StorageKeys.userData);
    return data != null ? jsonDecode(data) : null;
  }

  Future<void> clearAll() => _storage.deleteAll();
}

class StorageKeys {
  static const String jwtToken = 'jwt_token';
  static const String userRole = 'user_role';
  static const String userData = 'user_data';
  static const String fcmToken = 'fcm_token';
}
```

### 6.6 FCM Service

```dart
// core/services/fcm_service.dart
class FcmService extends GetxService {
  static FcmService get to => Get.find();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  void onInit() {
    super.onInit();
    _initFCM();
  }

  Future<void> _initFCM() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveTokenToServer(token);
    }
    _messaging.onTokenRefresh.listen(_saveTokenToServer);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  Future<void> _saveTokenToServer(String token) async {
    await SecureStorageService.to.saveToken(token); // save locally
    await NetworkService.to.post(ApiEndpoints.saveFcmToken, data: {'fcm_token': token});
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification
    NotificationService.to.showLocalNotification(message);
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Navigate to relevant screen based on notification data
  }
}
```

### 6.7 Location Service (for Driver)

```dart
// core/services/location_service.dart
class LocationService extends GetxService {
  static LocationService get to => Get.find();

  Future<bool> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  Future<Position?> getCurrentPosition() async {
    if (!await checkPermission()) return null;
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 50),
    );
  }
}
```

### 6.8 Error Handling

```dart
// core/error/failure.dart
abstract class Failure {
  final String message;
  final int? statusCode;
  const Failure(this.message, this.statusCode);
}

class ServerFailure extends Failure {
  const ServerFailure(String message, int? statusCode) : super(message, statusCode);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection', 0);
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message, 401);
}

// core/error/error_handler.dart
class ErrorHandler {
  static Failure handle(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerFailure('Connection timeout', 408);
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);
      default:
        return ServerFailure(error.message ?? 'Unknown error', error.response?.statusCode);
    }
  }

  static Failure _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;
    String message = 'Something went wrong';
    if (data is Map) {
      message = data['message'] ?? data['error'] ?? message;
    }
    if (statusCode == 401) return AuthFailure(message);
    return ServerFailure(message, statusCode);
  }
}
```

---

## 7. Features — Detailed Breakdown

Each feature follows this structure:
```
feature_name/
├── feature_binding.dart
├── controllers/
│   └── feature_controller.dart
├── data/
│   └── feature_data_source.dart
├── models/
│   ├── request_model.dart
│   └── response_model.dart
├── repositories/
│   └── feature_repository.dart
└── views/
    ├── feature_screen.dart
    └── widgets/
```

---

### 7.1 Splash Feature

**Purpose:** Show splash screen, check auth state, navigate to login or main shell based on stored token and role.

```
splash/
├── splash_binding.dart
├── controllers/
│   └── splash_controller.dart
└── views/
    └── splash_screen.dart
```

**SplashController:**
```dart
class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    final token = await SecureStorageService.to.getToken();
    final role = await SecureStorageService.to.getRole();

    if (token != null && role != null) {
      if (role == 'driver') {
        Get.offAllNamed(AppRoutes.driverHome);
      } else {
        Get.offAllNamed(AppRoutes.adminDashboard);
      }
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
```

---

### 7.2 Auth Feature

**Purpose:** Login for all roles (CEO, Admin, Driver), logout, forgot password.

```
auth/
├── auth_binding.dart
├── controllers/
│   └── auth_controller.dart
├── data/
│   └── auth_data_source.dart
├── models/
│   ├── login_request.dart
│   └── login_response.dart
├── repositories/
│   └── auth_repository.dart
└── views/
    ├── login_screen.dart
    └── widgets/
        └── login_form.dart
```

**LoginRequest:**
```dart
class LoginRequest {
  final String email;
  final String password;
  LoginRequest({required this.email, required this.password});
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}
```

**LoginResponse:**
```dart
class LoginResponse {
  final String status;
  final String accessToken;
  final String tokenType;
  final String role;
  final String message;
  final UserDetails userDetails;

  LoginResponse.fromJson(Map<String, dynamic> json)
      : status = json['status'],
        accessToken = json['access_token'],
        tokenType = json['token_type'],
        role = json['role'],
        message = json['message'],
        userDetails = UserDetails.fromJson(json['user_details']);
}

class UserDetails {
  final String firstname;
  final String lastname;
  final String email;
  final String phoneNo;
  final String dob;

  UserDetails.fromJson(Map<String, dynamic> json)
      : firstname = json['firstname'],
        lastname = json['lastname'],
        email = json['email'],
        phoneNo = json['phone_no'],
        dob = json['dob'];
}
```

**AuthController:**
```dart
class AuthController extends GetxController {
  final AuthRepository _repository;
  AuthController(this._repository);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  Future<void> login() async {
    if (!_validate()) return;
    isLoading.value = true;
    try {
      final request = LoginRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      final response = await _repository.login(request);
      await SecureStorageService.to.saveToken(response.accessToken);
      await SecureStorageService.to.saveRole(response.role);
      await SecureStorageService.to.saveUserData(response.userDetails.toJson());

      if (response.role == 'driver') {
        Get.offAllNamed(AppRoutes.driverHome);
      } else {
        Get.offAllNamed(AppRoutes.adminDashboard);
      }
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate() {
    if (emailController.text.trim().isEmpty || !GetUtils.isEmail(emailController.text.trim())) {
      CustomSnackbar.showError('Please enter a valid email');
      return false;
    }
    if (passwordController.text.length < 6) {
      CustomSnackbar.showError('Password must be at least 6 characters');
      return false;
    }
    return true;
  }
}
```

**AuthDataSource:**
```dart
class AuthDataSource {
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await NetworkService.to.post(ApiEndpoints.login, data: request.toJson());
    return LoginResponse.fromJson(response.data);
  }

  Future<void> logout() async {
    await NetworkService.to.post(ApiEndpoints.logout);
  }
}
```

**Role Guard Middleware (for route protection):**
```dart
class RoleGuard extends GetMiddleware {
  final List<String> allowedRoles;
  RoleGuard({required this.allowedRoles});

  @override
  RouteSettings? redirect(String? route) async {
    final role = await SecureStorageService.to.getRole();
    if (role == null || !allowedRoles.contains(role)) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
```

---

### 7.3 Main Shell Feature (CEO / Admin)

**Purpose:** Bottom navigation bar host with role-based tab visibility.

```
main_shell/
├── main_shell_binding.dart
├── controllers/
│   └── main_shell_controller.dart
└── views/
    └── main_shell_screen.dart
```

**CEO Tabs:**
1. Dashboard
2. Forms
3. Jobs
4. More (opens drawer with: Trade License, Grievances, Billing, Garbage, Ads, Notices, Notifications, Payment History, Pet Dog, Profile)

**Admin (Employee) Tabs:**
1. Forms
2. Grievances
3. Notices
4. Notifications
5. Profile

**MainShellController:**
```dart
class MainShellController extends GetxController {
  final currentIndex = 0.obs;
  final userRole = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRole();
  }

  Future<void> _loadRole() async {
    userRole.value = await SecureStorageService.to.getRole() ?? '';
  }

  void changeTab(int index) => currentIndex.value = index;
}
```

**MainShellScreen:**
```dart
class MainShellScreen extends GetView<MainShellController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isCeo = controller.userRole.value == 'ceo';
      final screens = isCeo ? _ceoScreens : _adminScreens;
      return Scaffold(
        body: IndexedStack(index: controller.currentIndex.value, children: screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          items: isCeo ? _ceoNavItems : _adminNavItems,
        ),
        drawer: isCeo ? const AdminDrawer() : null,
      );
    });
  }
}
```

---

### 7.4 Dashboard Feature (CEO only)

**Purpose:** Show admin statistics, recent activity, quick actions.

```
dashboard/
├── dashboard_binding.dart
├── controllers/
│   └── dashboard_controller.dart
├── data/
│   └── dashboard_data_source.dart
├── models/
│   └── admin_dashboard_response.dart
├── repositories/
│   └── dashboard_repository.dart
└── views/
    ├── dashboard_screen.dart
    └── widgets/
        ├── stat_card.dart
        └── recent_activity_list.dart
```

**API:** `GET /api/admin/dashboard`

**AdminDashboardResponse:**
```dart
class AdminDashboardResponse {
  final int totalUsers;
  final int totalForms;
  final int pendingForms;
  final int totalJobs;
  final int totalGrievances;
  final int pendingGrievances;
  final int totalTradeLicenses;
  final int totalRenewalsPending;
  final int totalHoldingTaxes;
  final int totalUnpaidHoldingTaxes;
  final double totalRevenue;
  final List<RecentActivity> recentActivities;

  AdminDashboardResponse.fromJson(Map<String, dynamic> json)
      : totalUsers = json['total_users'] ?? 0,
        totalForms = json['total_forms'] ?? 0,
        pendingForms = json['pending_forms'] ?? 0,
        totalJobs = json['total_jobs'] ?? 0,
        totalGrievances = json['total_grievances'] ?? 0,
        pendingGrievances = json['pending_grievances'] ?? 0,
        totalTradeLicenses = json['total_trade_licenses'] ?? 0,
        totalRenewalsPending = json['total_renewals_pending'] ?? 0,
        totalHoldingTaxes = json['total_holding_taxes'] ?? 0,
        totalUnpaidHoldingTaxes = json['total_unpaid_holding_taxes'] ?? 0,
        totalRevenue = (json['total_revenue'] ?? 0).toDouble(),
        recentActivities = (json['recent_activities'] as List? ?? [])
            .map((e) => RecentActivity.fromJson(e))
            .toList();
}
```

**DashboardScreen Layout:**
```
┌──────────────────────────────────┐
│  Admin Dashboard            [🔔] │  ← AppBar
├──────────────────────────────────┤
│  ┌────────┐  ┌────────┐         │
│  │ Users  │  │ Forms  │         │  ← Stat cards grid
│  │  1,234 │  │  567   │         │
│  └────────┘  └────────┘         │
│  ┌────────┐  ┌────────┐         │
│  │ Jobs   │  │Griev.  │         │
│  │   89   │  │   42   │         │
│  └────────┘  └────────┘         │
│  ┌────────┐  ┌────────┐         │
│  │Revenue │  │Pending │         │
│  │₹12.5L  │  │   15   │         │
│  └────────┘  └────────┘         │
│                                  │
│  Recent Activity                 │
│  ─────────────────               │
│  📋 New form submitted...        │
│  💰 Payment received ₹500...     │
│  📢 Notice published...          │
│  🚛 Truck #TN01 started shift...│
└──────────────────────────────────┘
```

---

### 7.5 Form Approval Feature (CEO + Admin)

**Purpose:** View all submitted citizen forms, filter by type/status/date, approve or reject.

```
form_approval/
├── form_approval_binding.dart
├── controllers/
│   └── form_approval_controller.dart
├── data/
│   └── form_approval_data_source.dart
├── models/
│   ├── form_list_item.dart
│   ├── form_detail.dart
│   └── form_stats_response.dart
├── repositories/
│   └── form_approval_repository.dart
└── views/
    ├── form_list_screen.dart
    ├── form_detail_screen.dart
    └── widgets/
        ├── form_list_card.dart
        ├── form_filter_bar.dart
        └── approve_reject_dialog.dart
```

**APIs:**
- `GET /api/admin/getAllForms?page=1&form_type=...&status=...&date_from=...&date_to=...`
- `GET /api/admin/getFormsPercentageBasedOnDate?date_from=...&date_to=...`
- `POST /api/admin/approvedOrRejectForm`

**FormListItem:**
```dart
class FormListItem {
  final int id;
  final String applicationId;
  final String formName;
  final int formId;
  final String status; // pending, approved, rejected
  final String insertedBy;
  final String createdAt;
  final Map<String, dynamic>? formData;

  FormListItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        applicationId = json['application_id'],
        formName = json['form_name'] ?? '',
        formId = json['form_id'],
        status = json['status'],
        insertedBy = json['inserted_by']?.toString() ?? '',
        createdAt = json['created_at'] ?? '',
        formData = json['form_data'];
}
```

**ApproveRejectRequest:**
```dart
class ApproveRejectRequest {
  final int formId;
  final String status; // 'approved' or 'rejected'
  final String? remarks;

  ApproveRejectRequest({required this.formId, required this.status, this.remarks});

  Map<String, dynamic> toJson() => {
    'form_id': formId,
    'status': status,
    if (remarks != null) 'remarks': remarks,
  };
}
```

**FormApprovalController:**
```dart
class FormApprovalController extends GetxController {
  final FormApprovalRepository _repository;

  final forms = <FormListItem>[].obs;
  final isLoading = false.obs;
  final isPaginating = false.obs;
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final selectedStatus = ''.obs;
  final selectedFormType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchForms();
  }

  Future<void> fetchForms() async {
    isLoading.value = true;
    currentPage.value = 1;
    try {
      final result = await _repository.getAllForms(
        page: 1,
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
        formType: selectedFormType.value.isEmpty ? null : selectedFormType.value,
      );
      forms.assignAll(result.data);
      lastPage.value = result.lastPage;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isPaginating.value || currentPage.value >= lastPage.value) return;
    isPaginating.value = true;
    try {
      currentPage.value++;
      final result = await _repository.getAllForms(page: currentPage.value);
      forms.addAll(result.data);
    } finally {
      isPaginating.value = false;
    }
  }

  Future<void> approveOrReject(int formId, String status, String? remarks) async {
    try {
      await _repository.approveOrReject(ApproveRejectRequest(formId: formId, status: status, remarks: remarks));
      CustomSnackbar.showSuccess('Form ${status}successfully');
      fetchForms(); // refresh
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    }
  }
}
```

**FormListScreen:**
```
┌──────────────────────────────────┐
│  Form Approvals                  │
├──────────────────────────────────┤
│  [All ▼] [Pending ▼] [Search 🔍]│  ← Filter bar
├──────────────────────────────────┤
│  ┌──────────────────────────────┐│
│  │ TMBNAC20260523001            ││
│  │ NAC Birth Registration       ││
│  │ Status: 🟡 Pending           ││
│  │ Submitted: 23 May 2026       ││
│  │ [View Details]               ││
│  └──────────────────────────────┘│
│  ┌──────────────────────────────┐│
│  │ TMBCMP20260523002            ││
│  │ Complaint Form               ││
│  │ Status: 🟢 Approved          ││
│  │ Submitted: 23 May 2026       ││
│  │ [View Details]               ││
│  └──────────────────────────────┘│
└──────────────────────────────────┘
```

**FormDetailScreen:**
```
┌──────────────────────────────────┐
│  Form Details                    │
├──────────────────────────────────┤
│  Application ID: TMBNAC2026...   │
│  Form Type: NAC Birth            │
│  Status: 🟡 Pending              │
│  Submitted By: John Doe          │
│  Date: 23 May 2026               │
│                                  │
│  Form Data:                      │
│  ─────────────                   │
│  Name: Baby John                 │
│  DOB: 2026-05-01                 │
│  Father: John Doe                │
│  ... (all key-value fields)      │
│                                  │
│  [📎 Attachment 1] [📎 Att 2]    │  ← File download links
│                                  │
│  ┌──────────┐  ┌──────────┐     │
│  │ ✅ Approve│  │ ❌ Reject │     │
│  └──────────┘  └──────────┘     │
│  Remarks: [________________]     │
└──────────────────────────────────┘
```

---

### 7.6 Job Posting Feature (CEO only)

**Purpose:** CRUD for job postings.

```
job_posting/
├── job_posting_binding.dart
├── controllers/
│   └── job_posting_controller.dart
├── data/
│   └── job_posting_data_source.dart
├── models/
│   ├── job_posting.dart
│   └── job_posting_request.dart
├── repositories/
│   └── job_posting_repository.dart
└── views/
    ├── job_list_screen.dart
    ├── job_create_screen.dart
    └── widgets/
        └── job_card.dart
```

**APIs:**
- `POST /api/admin/createJobPosting`
- `GET /api/admin/getAllJobPostings`
- `GET /api/admin/getJobPostingById?id=...`
- `POST /api/admin/updateJobPosting`
- `POST /api/admin/deleteJobPosting`

**JobPosting:**
```dart
class JobPosting {
  final int id;
  final String name;
  final String description;
  final String salaryRange;
  final String requiredQualification;
  final String postingDate;
  final String lastDateToApply;
  final String status; // 'Active', 'Closed'

  JobPosting.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        salaryRange = json['salary_range'],
        requiredQualification = json['required_qualification'],
        postingDate = json['posting_date'],
        lastDateToApply = json['last_date_to_apply'],
        status = json['status'];
}
```

**JobPostingRequest:**
```dart
class JobPostingRequest {
  final String name;
  final String description;
  final String salaryRange;
  final String requiredQualification;
  final String postingDate;
  final String lastDateToApply;
  final int? id; // null for create, set for update

  JobPostingRequest({
    this.id,
    required this.name,
    required this.description,
    required this.salaryRange,
    required this.requiredQualification,
    required this.postingDate,
    required this.lastDateToApply,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'description': description,
    'salary_range': salaryRange,
    'required_qualification': requiredQualification,
    'posting_date': postingDate,
    'last_date_to_apply': lastDateToApply,
  };
}
```

**JobCreateScreen:**
```
┌──────────────────────────────────┐
│  Create Job Posting              │
├──────────────────────────────────┤
│  Job Title: [__________________] │
│  Description: [________________] │
│             [________________]   │
│  Salary Range: [_______________] │
│  Qualification: [______________] │
│  Posting Date: [📅 ___________] │
│  Last Date: [📅 ______________] │
│                                  │
│  [     Create Job Posting      ] │
└──────────────────────────────────┘
```

---

### 7.7 Trade License Admin Feature (CEO only)

**Purpose:** Manage trade license renewals — list, approve, reject, complete after cash payment, view stats, broadcast notifications.

```
trade_license_admin/
├── trade_license_admin_binding.dart
├── controllers/
│   └── trade_license_admin_controller.dart
├── data/
│   └── trade_license_admin_data_source.dart
├── models/
│   ├── trade_license_renewal.dart
│   └── trade_license_stats.dart
├── repositories/
│   └── trade_license_admin_repository.dart
└── views/
    ├── renewal_list_screen.dart
    ├── renewal_detail_screen.dart
    ├── trade_license_stats_screen.dart
    └── widgets/
        ├── renewal_card.dart
        └── collect_payment_sheet.dart
```

**APIs:**
- `GET /api/admin/trade-license/renewals?status=pending&page=1`
- `POST /api/admin/trade-license/approve-renewal` → `{ renewal_id, remarks? }`
- `POST /api/admin/trade-license/reject-renewal` → `{ renewal_id, remarks? }`
- `POST /api/admin/trade-license/complete-renewal` → `{ renewal_id, paid_amount, remarks? }`
- `GET /api/admin/trade-license/stats`
- `POST /api/admin/trade-license/broadcast-notification` → `{ title, body }`

**TradeLicenseRenewal Model:**
```dart
class TradeLicenseRenewal {
  final int id;
  final int tradeLicenseId;
  final String licenseNo;
  final String holderName;
  final String businessName;
  final String businessType;
  final String businessAddress;
  final String currentExpiryDate;
  final String requestedRenewalDate;
  final double renewalFee;
  final String status; // pending, approved, rejected
  final double? paidAmount;
  final String? paymentStatus; // unpaid, paid
  final String? remarks;

  TradeLicenseRenewal.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        tradeLicenseId = json['trade_license_id'],
        licenseNo = json['license_no'],
        holderName = json['holder_name'],
        businessName = json['business_name'],
        businessType = json['business_type'],
        businessAddress = json['business_address'],
        currentExpiryDate = json['current_expiry_date'],
        requestedRenewalDate = json['requested_renewal_date'],
        renewalFee = (json['renewal_fee'] ?? 0).toDouble(),
        status = json['status'],
        paidAmount = json['paid_amount']?.toDouble(),
        paymentStatus = json['payment_status'],
        remarks = json['remarks'];
}
```

**RenewalDetailScreen with Cash Collection:**
```
┌──────────────────────────────────┐
│  Renewal Details                 │
├──────────────────────────────────┤
│  License: TL-2026-001           │
│  Holder: John Doe                │
│  Business: ABC Store             │
│  Type: Retail                    │
│  Expiry: 2026-03-31              │
│  Requested: 2027-03-31           │
│  Fee: ₹5,000                     │
│  Status: 🟡 Pending              │
│                                  │
│  ┌──────────────────────────┐   │
│  │ Remarks: [______________]│   │
│  └──────────────────────────┘   │
│                                  │
│  ┌──────────┐  ┌──────────┐     │
│  │ ✅ Approve│  │ ❌ Reject │     │
│  └──────────┘  └──────────┘     │
│                                  │
│  ── After Approval ──            │
│                                  │
│  ┌──────────────────────────┐   │
│  │ 💰 Collect Cash Payment  │   │
│  │ Amount: [₹5,000________]│   │
│  │ Remarks: [_____________] │   │
│  │ [  Complete Renewal  ]   │   │
│  └──────────────────────────┘   │
└──────────────────────────────────┘
```

---

### 7.8 Grievance Admin Feature (CEO + Admin)

**Purpose:** View all grievances, filter by status/category, update status with remarks.

```
grievance_admin/
├── grievance_admin_binding.dart
├── controllers/
│   └── grievance_admin_controller.dart
├── data/
│   └── grievance_admin_data_source.dart
├── models/
│   └── admin_grievance.dart
├── repositories/
│   └── grievance_admin_repository.dart
└── views/
    ├── grievance_list_screen.dart
    ├── grievance_detail_screen.dart
    └── widgets/
        ├── grievance_card.dart
        └── status_update_sheet.dart
```

**APIs:**
- `GET /api/admin/grievances?status=pending&category=...&page=1`
- `POST /api/admin/grievances/update-status` → `{ grievance_id, status, admin_remarks? }`

**AdminGrievance:**
```dart
class AdminGrievance {
  final int id;
  final int userId;
  final String category;
  final String subject;
  final String description;
  final String? attachmentPath;
  final String status; // pending, in_progress, resolved, rejected
  final String? adminRemarks;
  final String? resolvedAt;
  final String createdAt;
  final String? userName;

  AdminGrievance.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        category = json['category'],
        subject = json['subject'],
        description = json['description'],
        attachmentPath = json['attachment_path'],
        status = json['status'],
        adminRemarks = json['admin_remarks'],
        resolvedAt = json['resolved_at'],
        createdAt = json['created_at'],
        userName = json['user']?['firstname'] != null
            ? '${json['user']['firstname']} ${json['user']['lastname']}'
            : null;
}
```

**Status Update Bottom Sheet:**
```
┌──────────────────────────────────┐
│  Update Grievance Status         │
│                                  │
│  Status:                         │
│  [Pending] [In Progress]         │
│  [Resolved] [Rejected]           │
│                                  │
│  Admin Remarks:                  │
│  [____________________________]  │
│  [____________________________]  │
│                                  │
│  [      Update Status          ] │
└──────────────────────────────────┘
```

---

### 7.9 Billing Admin Feature (CEO only)

**Purpose:** Generate monthly bills, upload billing spreadsheet, update payment status (for cash collection).

```
billing_admin/
├── billing_admin_binding.dart
├── controllers/
│   └── billing_admin_controller.dart
├── data/
│   └── billing_admin_data_source.dart
├── models/
│   ├── market.dart
│   ├── billing_transaction.dart
│   └── generate_bills_request.dart
├── repositories/
│   └── billing_admin_repository.dart
└── views/
    ├── billing_dashboard_screen.dart
    ├── generate_bills_screen.dart
    ├── update_payment_screen.dart
    └── widgets/
        └── market_card.dart
```

**APIs:**
- `GET /api/markets` — List markets
- `POST /api/admin/billing/generate-bills` → `{ market_id, billing_month }`
- `POST /api/admin/billing/upload-sheet` — multipart file upload
- `PUT /api/admin/billing/update-payment` → `{ market_id, shop_no, billing_month, paid_amount, remarks }`

**UpdatePaymentScreen (Cash Collection):**
```
┌──────────────────────────────────┐
│  Update Payment Status           │
├──────────────────────────────────┤
│  Market: [Dropdown ▼]            │
│  Shop No: [___________________]  │
│  Billing Month: [📅 May 2026]   │
│                                  │
│  Outstanding: ₹15,000            │
│                                  │
│  Amount Paid: [₹______________]  │
│  Remarks: [___________________]  │
│                                  │
│  [  Update Payment Status      ] │
└──────────────────────────────────┘
```

---

### 7.10 Garbage Admin Feature (CEO only)

**Purpose:** Manage trucks, drivers, schedules, view fleet dashboard.

```
garbage_admin/
├── garbage_admin_binding.dart
├── controllers/
│   └── garbage_admin_controller.dart
├── data/
│   └── garbage_admin_data_source.dart
├── models/
│   ├── garbage_truck.dart
│   ├── garbage_driver.dart
│   ├── garbage_schedule.dart
│   └── garbage_dashboard.dart
├── repositories/
│   └── garbage_admin_repository.dart
└── views/
    ├── garbage_dashboard_screen.dart
    ├── add_truck_screen.dart
    ├── assign_driver_screen.dart
    ├── create_schedule_screen.dart
    └── widgets/
        ├── truck_card.dart
        ├── driver_tile.dart
        └── schedule_tile.dart
```

**APIs:**
- `GET /api/admin/garbage/dashboard`
- `POST /api/admin/garbage/add-truck` → `{ plate_number, truck_name, truck_type, capacity_tons, ward_id }`
- `POST /api/admin/garbage/update-truck/{id}` → `{ truck_name?, truck_type?, capacity_tons?, status? }`
- `POST /api/admin/garbage/assign-driver` → `{ driver_id, truck_id }`
- `POST /api/admin/garbage/create-schedule` → `{ route_id?, ward_id, truck_id?, day_of_week, start_time, end_time, collection_type }`

**GarbageTruck:**
```dart
class GarbageTruck {
  final int id;
  final String plateNumber;
  final String truckName;
  final String truckType; // compactor, dumper, tipper, mini, side_loader
  final double capacityTons;
  final int wardId;
  final String status; // active, inactive, maintenance, retired
  final bool isOnRoute;

  GarbageTruck.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        plateNumber = json['plate_number'],
        truckName = json['truck_name'],
        truckType = json['truck_type'],
        capacityTons = (json['capacity_tons'] ?? 0).toDouble(),
        wardId = json['ward_id'],
        status = json['status'],
        isOnRoute = json['is_on_route'] ?? false;
}
```

---

### 7.11 Garbage Driver Feature (Driver only)

**Purpose:** View assigned route on map, start/end shift, send GPS location updates.

```
garbage_driver/
├── garbage_driver_binding.dart
├── controllers/
│   └── garbage_driver_controller.dart
├── data/
│   └── garbage_driver_data_source.dart
├── models/
│   ├── assigned_route.dart
│   └── shift_status.dart
├── repositories/
│   └── garbage_driver_repository.dart
└── views/
    ├── driver_home_screen.dart
    └── widgets/
        ├── route_map_widget.dart
        └── shift_controls.dart
```

**APIs:**
- `GET /api/driver/assigned-route`
- `POST /api/driver/start-shift` → `{ truck_id }`
- `POST /api/driver/end-shift` → `{ truck_id }`
- `POST /api/driver/update-location` → `{ truck_id, latitude, longitude, speed?, heading? }`

**DriverHomeController:**
```dart
class DriverHomeController extends GetxController {
  final GarbageDriverRepository _repository;

  final assignedRoute = Rxn<AssignedRoute>();
  final isOnShift = false.obs;
  final currentTruckId = 0.obs;
  final currentPosition = Rxn<LatLng>();
  final isLoading = false.obs;
  StreamSubscription<Position>? _locationSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchAssignedRoute();
  }

  Future<void> fetchAssignedRoute() async {
    isLoading.value = true;
    try {
      assignedRoute.value = await _repository.getAssignedRoute();
      if (assignedRoute.value != null) {
        currentTruckId.value = assignedRoute.value!.truckId;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startShift() async {
    try {
      await _repository.startShift(currentTruckId.value);
      isOnShift.value = true;
      _startLocationTracking();
      CustomSnackbar.showSuccess('Shift started');
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    }
  }

  Future<void> endShift() async {
    try {
      await _repository.endShift(currentTruckId.value);
      isOnShift.value = false;
      _locationSubscription?.cancel();
      CustomSnackbar.showSuccess('Shift ended');
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    }
  }

  void _startLocationTracking() {
    _locationSubscription = LocationService.to.getPositionStream().listen((position) {
      currentPosition.value = LatLng(position.latitude, position.longitude);
      _repository.updateLocation(
        currentTruckId.value,
        position.latitude,
        position.longitude,
        speed: position.speed,
        heading: position.heading,
      );
    });
  }

  @override
  void onClose() {
    _locationSubscription?.cancel();
    super.onClose();
  }
}
```

**DriverHomeScreen:**
```
┌──────────────────────────────────┐
│  🚛 Driver Dashboard             │
├──────────────────────────────────┤
│  ┌──────────────────────────────┐│
│  │                              ││
│  │     [Google Map View]        ││
│  │     Route waypoints drawn    ││
│  │     Current position marker  ││
│  │                              ││
│  └──────────────────────────────┘│
│                                  │
│  Route: Ward 3 - Route A         │
│  Distance: 12.5 km               │
│  Duration: 45 min                │
│  Status: 🟢 On Shift             │
│                                  │
│  ┌──────────────────────────┐   │
│  │    [ End Shift 🛑 ]      │   │
│  └──────────────────────────┘   │
└──────────────────────────────────┘
```

---

### 7.12 Advertisement Admin Feature (CEO only)

**Purpose:** CRUD for advertisements, publish/pause/reject workflow, view statistics.

```
advertisement_admin/
├── advertisement_admin_binding.dart
├── controllers/
│   └── advertisement_admin_controller.dart
├── data/
│   └── advertisement_admin_data_source.dart
├── models/
│   ├── advertisement.dart
│   └── ad_stats.dart
├── repositories/
│   └── advertisement_admin_repository.dart
└── views/
    ├── ad_list_screen.dart
    ├── ad_create_screen.dart
    ├── ad_detail_screen.dart
    └── widgets/
        ├── ad_card.dart
        └── ad_stats_widget.dart
```

**APIs:**
- `GET /api/admin/advertisements?status=...&position=...&page=1`
- `POST /api/admin/advertisements` — create (multipart: title, description, image, redirect_url, position, start_date, end_date)
- `GET /api/admin/advertisements/{id}`
- `PUT /api/admin/advertisements/{id}` — update
- `DELETE /api/admin/advertisements/{id}`
- `POST /api/admin/advertisements/{id}/publish`
- `POST /api/admin/advertisements/{id}/pause`
- `POST /api/admin/advertisements/{id}/reject` → `{ rejection_reason? }`
- `GET /api/admin/advertisements/statistics`

**Advertisement:**
```dart
class Advertisement {
  final int id;
  final String title;
  final String? description;
  final String imagePath;
  final String? redirectUrl;
  final String position; // top_banner, sidebar, inline, popup, footer
  final String status; // draft, pending, active, paused, expired, rejected
  final String? startDate;
  final String? endDate;
  final int impressions;
  final int clicks;

  Advertisement.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        description = json['description'],
        imagePath = json['image_path'],
        redirectUrl = json['redirect_url'],
        position = json['position'],
        status = json['status'],
        startDate = json['start_date'],
        endDate = json['end_date'],
        impressions = json['impressions'] ?? 0,
        clicks = json['clicks'] ?? 0;
}
```

---

### 7.13 Notice / Announcement Admin Feature (CEO + Admin)

**Purpose:** CRUD for notices and announcements, publish/archive workflow, toggle pin.

```
notice_admin/
├── notice_admin_binding.dart
├── controllers/
│   └── notice_admin_controller.dart
├── data/
│   └── notice_admin_data_source.dart
├── models/
│   └── notice_announcement.dart
├── repositories/
│   └── notice_admin_repository.dart
└── views/
    ├── notice_list_screen.dart
    ├── notice_create_screen.dart
    ├── notice_detail_screen.dart
    └── widgets/
        ├── notice_card.dart
        └── notice_stats_widget.dart
```

**APIs:**
- `GET /api/admin/notices?type=notice&status=published&priority=high&page=1`
- `POST /api/admin/notices` — create (multipart: title, content, type, priority, attachment?, target_audience, is_pinned, publish_date?, expire_date?)
- `GET /api/admin/notices/{id}`
- `PUT /api/admin/notices/{id}` — update
- `DELETE /api/admin/notices/{id}`
- `POST /api/admin/notices/{id}/publish`
- `POST /api/admin/notices/{id}/archive`
- `POST /api/admin/notices/{id}/toggle-pin`
- `GET /api/admin/notices/statistics`

**NoticeAnnouncement:**
```dart
class NoticeAnnouncement {
  final int id;
  final String title;
  final String content;
  final String type; // notice, announcement
  final String priority; // low, medium, high, urgent
  final String? attachmentPath;
  final String status; // draft, published, archived
  final String targetAudience; // all, citizens, employees
  final bool isPinned;
  final String? publishDate;
  final String? expireDate;

  NoticeAnnouncement.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        content = json['content'],
        type = json['type'],
        priority = json['priority'],
        attachmentPath = json['attachment_path'],
        status = json['status'],
        targetAudience = json['target_audience'] ?? 'all',
        isPinned = json['is_pinned'] ?? false,
        publishDate = json['publish_date'],
        expireDate = json['expire_date'];
}
```

**NoticeCreateScreen:**
```
┌──────────────────────────────────┐
│  Create Notice/Announcement      │
├──────────────────────────────────┤
│  Title: [_____________________]  │
│  Type: (●) Notice ( ) Announcement│
│  Priority: [Dropdown ▼]          │
│  Target: [Dropdown ▼]            │
│  Content:                        │
│  [____________________________]  │
│  [____________________________]  │
│  [____________________________]  │
│                                  │
│  📎 Attachment: [Choose File]     │
│                                  │
│  ☐ Pin this notice               │
│  Publish Date: [📅 Optional]     │
│  Expire Date: [📅 Optional]      │
│                                  │
│  [     Create & Save Draft     ] │
│  [     Create & Publish        ] │
└──────────────────────────────────┘
```

---

### 7.14 Notification Admin Feature (CEO + Admin)

**Purpose:** Broadcast push notifications to all users, send to specific user, view statistics.

```
notification_admin/
├── notification_admin_binding.dart
├── controllers/
│   └── notification_admin_controller.dart
├── data/
│   └── notification_admin_data_source.dart
├── models/
│   ├── broadcast_request.dart
│   ├── send_to_user_request.dart
│   └── notification_stats.dart
├── repositories/
│   └── notification_admin_repository.dart
└── views/
    ├── notification_list_screen.dart
    ├── broadcast_screen.dart
    ├── send_to_user_screen.dart
    └── widgets/
        ├── notification_tile.dart
        └── notification_stats_card.dart
```

**APIs:**
- `GET /api/admin/notifications?page=1`
- `POST /api/admin/notifications/broadcast` → `{ title, body, category?, data?, ward_no? }`
- `POST /api/admin/notifications/send-to-user` → `{ user_id, title, body, category?, data? }`
- `GET /api/admin/notifications/statistics`

**BroadcastRequest:**
```dart
class BroadcastRequest {
  final String title;
  final String body;
  final String? category;
  final Map<String, dynamic>? data;
  final String? wardNo; // null = all wards

  BroadcastRequest({required this.title, required this.body, this.category, this.data, this.wardNo});

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    if (category != null) 'category': category,
    if (data != null) 'data': data,
    if (wardNo != null) 'ward_no': wardNo,
  };
}
```

**BroadcastScreen:**
```
┌──────────────────────────────────┐
│  📢 Broadcast Notification       │
├──────────────────────────────────┤
│  Title: [_____________________]  │
│  Message:                        │
│  [____________________________]  │
│  [____________________________]  │
│                                  │
│  Category: [Dropdown ▼]          │
│  (announcement / payment /       │
│   notice / general)              │
│                                  │
│  Target Ward: [All Wards ▼]      │
│  (Optional — specific ward)      │
│                                  │
│  [   📢 Send to All Users      ] │
└──────────────────────────────────┘
```

---

### 7.15 Payment History Feature (CEO only)

**Purpose:** View all payment transactions across the system.

```
payment_history/
├── payment_history_binding.dart
├── controllers/
│   └── payment_history_controller.dart
├── data/
│   └── payment_history_data_source.dart
├── models/
│   └── payment_record.dart
├── repositories/
│   └── payment_history_repository.dart
└── views/
    ├── payment_history_screen.dart
    └── widgets/
        └── payment_tile.dart
```

**API:** `GET /api/admin/payment-history?page=1&type=...&status=...&date_from=...&date_to=...`

**PaymentRecord:**
```dart
class PaymentRecord {
  final int id;
  final String type; // form, job, trade_license, holding_tax, billing
  final String applicationId;
  final double amount;
  final String status; // pending, success, failed
  final String paymentDate;
  final String? userName;

  PaymentRecord.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        type = json['type'] ?? '',
        applicationId = json['application_id'] ?? json['order_id'] ?? '',
        amount = (json['amount'] ?? 0).toDouble(),
        status = json['status'],
        paymentDate = json['payment_date'] ?? json['created_at'] ?? '',
        userName = json['user']?['firstname'] != null
            ? '${json['user']['firstname']} ${json['user']['lastname']}'
            : null;
}
```

---

### 7.16 Pet Dog Admin Feature (CEO only)

**Purpose:** View pet dog registration applications, update payment status after cash collection.

```
pet_dog_admin/
├── pet_dog_admin_binding.dart
├── controllers/
│   └── pet_dog_admin_controller.dart
├── data/
│   └── pet_dog_admin_data_source.dart
├── models/
│   └── pet_dog_application.dart
├── repositories/
│   └── pet_dog_admin_repository.dart
└── views/
    ├── pet_dog_list_screen.dart
    ├── pet_dog_detail_screen.dart
    └── widgets/
        └── pet_dog_card.dart
```

**APIs:**
- `GET /api/admin/pet-dog/applications?status=...&page=1`
- `GET /api/admin/pet-dog/application?id=...`
- `POST /api/admin/pet-dog/update-payment` → `{ application_id, status, paid_amount?, remarks? }`
- `POST /api/admin/generatePetDogCertificate` → `{ application_id }`

---

### 7.17 Profile Feature (All roles)

**Purpose:** View and edit profile, change password, logout.

```
profile/
├── profile_binding.dart
├── controllers/
│   └── profile_controller.dart
├── data/
│   └── profile_data_source.dart
├── models/
│   ├── profile_update_request.dart
│   └── change_password_request.dart
├── repositories/
│   └── profile_repository.dart
└── views/
    ├── profile_screen.dart
    ├── edit_profile_screen.dart
    └── change_password_screen.dart
```

**APIs:**
- `POST /api/profileUpdate` → `{ firstname, lastname, dob, phone_no, email }`
- `POST /api/changePassword` → `{ current_password, password, confirm_password }`
- `POST /api/logout`

**ProfileScreen:**
```
┌──────────────────────────────────┐
│  👤 Profile                      │
├──────────────────────────────────┤
│  ┌──────────────────────────────┐│
│  │  [Avatar]                    ││
│  │  John Doe                    ││
│  │  CEO                         ││
│  │  john@example.com            ││
│  │  +91 9876543210              ││
│  └──────────────────────────────┘│
│                                  │
│  [✏️ Edit Profile]               │
│  [🔒 Change Password]            │
│  [🚪 Logout]                     │
└──────────────────────────────────┘
```

---

### 7.18 Holding Tax Admin Feature (CEO only)

**Purpose:** View holding tax statistics.

```
holding_tax_admin/
├── holding_tax_admin_binding.dart
├── controllers/
│   └── holding_tax_admin_controller.dart
├── data/
│   └── holding_tax_admin_data_source.dart
├── models/
│   └── holding_tax_stats.dart
├── repositories/
│   └── holding_tax_admin_repository.dart
└── views/
    └── holding_tax_stats_screen.dart
```

**API:** `GET /api/admin/holding-tax/stats`

---

## 8. Complete API Reference

### Authentication Headers (for all authenticated requests)

```
Authorization: Bearer {jwt_token}
Content-Type: application/json
Accept: application/json
```

### 8.1 Public Endpoints

| Method | Endpoint | Request Body | Success Response |
|---|---|---|---|
| `POST` | `/api/login` | `{ "email": "...", "password": "..." }` | `{ "status": "success", "access_token": "...", "token_type": "Bearer", "role": "ceo", "message": "Login successful", "user_details": { "firstname": "...", "lastname": "...", "email": "...", "phone_no": "...", "dob": "..." } }` |
| `POST` | `/api/register` | `{ "firstname": "...", "lastname": "...", "ward_id": 1, "locality": "...", "dob": "YYYY-MM-DD", "phone_no": "...", "email": "...", "password": "...", "confirm_password": "..." }` | `{ "status": "success", "message": "User Successfully Registered", "user_id": 1 }` |
| `POST` | `/api/forgot-password` | `{ "email": "..." }` | `{ "status": "success", "message": "Reset link sent" }` |
| `POST` | `/api/reset-password` | `{ "token": "...", "email": "...", "password": "...", "confirm_password": "..." }` | `{ "status": "success", "message": "Password reset" }` |

### 8.2 Profile Endpoints (Authenticated)

| Method | Endpoint | Request Body | Response |
|---|---|---|---|
| `POST` | `/api/profileUpdate` | `{ "firstname": "...", "lastname": "...", "dob": "YYYY-MM-DD", "phone_no": "...", "email": "..." }` | `{ "status": "success", "message": "Profile updated" }` |
| `POST` | `/api/changePassword` | `{ "current_password": "...", "password": "...", "confirm_password": "..." }` | `{ "status": "success", "message": "Password changed" }` |
| `POST` | `/api/logout` | — | `{ "status": "success", "message": "Logged out" }` |

### 8.3 Admin — Dashboard

| Method | Endpoint | Response |
|---|---|---|
| `GET` | `/api/admin/dashboard` | `{ "status": "success", "data": { "total_users": 1234, "total_forms": 567, "pending_forms": 15, "total_jobs": 89, "total_grievances": 42, "pending_grievances": 8, "total_trade_licenses": 200, "total_renewals_pending": 5, "total_holding_taxes": 500, "total_unpaid_holding_taxes": 120, "total_revenue": 1250000, "recent_activities": [...] } }` |
| `GET` | `/api/admin/payment-history?page=1` | `{ "status": "success", "data": { "data": [...], "current_page": 1, "last_page": 10, "total": 200 } }` |

### 8.4 Admin — Forms

| Method | Endpoint | Request | Response |
|---|---|---|---|
| `GET` | `/api/admin/getAllForms?page=1&form_type=...&status=...&date_from=...&date_to=...` | Query params | `{ "status": "success", "data": { "data": [...], "current_page": 1, "last_page": 5, "total": 100 } }` |
| `GET` | `/api/admin/getFormsPercentageBasedOnDate?date_from=...&date_to=...` | Query params | `{ "status": "success", "data": { "total": 100, "by_form_type": {...}, "by_status": {...} } }` |
| `POST` | `/api/admin/approvedOrRejectForm` | `{ "form_id": 1, "status": "approved", "remarks": "..." }` | `{ "status": "success", "message": "Form approved" }` |
| `GET` | `/api/admin/tradeLicenseFee` | — | `{ "status": "success", "data": {...} }` |
| `POST` | `/api/admin/generatePetDogCertificate` | `{ "application_id": "..." }` | PDF file download |

### 8.5 Admin — Job Postings

| Method | Endpoint | Request | Response |
|---|---|---|---|
| `POST` | `/api/admin/createJobPosting` | `{ "name": "...", "description": "...", "salary_range": "...", "required_qualification": "...", "posting_date": "YYYY-MM-DD", "last_date_to_apply": "YYYY-MM-DD" }` | `{ "status": "success", "message": "Job created", "data": {...} }` |
| `GET` | `/api/admin/getAllJobPostings` | — | `{ "status": "success", "data": [...] }` |
| `GET` | `/api/admin/getJobPostingById?id=1` | Query | `{ "status": "success", "data": {...} }` |
| `POST` | `/api/admin/updateJobPosting` | `{ "id": 1, "name": "...", ... }` | `{ "status": "success", "message": "Job updated" }` |
| `POST` | `/api/admin/deleteJobPosting` | `{ "id": 1 }` | `{ "status": "success", "message": "Job deleted" }` |

### 8.6 Admin — Trade License Renewals

| Method | Endpoint | Request | Response |
|---|---|---|---|
| `GET` | `/api/admin/trade-license/renewals?status=pending&page=1` | Query | `{ "status": "success", "data": { "data": [...], "current_page": 1, "last_page": 3, "total": 25 } }` |
| `POST` | `/api/admin/trade-license/approve-renewal` | `{ "renewal_id": 1, "remarks": "..." }` | `{ "status": "success", "message": "Renewal approved" }` |
| `POST` | `/api/admin/trade-license/reject-renewal` | `{ "renewal_id": 1, "remarks": "..." }` | `{ "status": "success", "message": "Renewal rejected" }` |
| `POST` | `/api/admin/trade-license/complete-renewal` | `{ "renewal_id": 1, "paid_amount": 5000, "remarks": "Cash collected" }` | `{ "status": "success", "message": "Renewal completed" }` |
| `GET` | `/api/admin/trade-license/stats` | — | `{ "status": "success", "data": { "total_licenses": ..., "active": ..., "expired": ..., "pending_renewals": ..., ... } }` |
| `POST` | `/api/admin/trade-license/broadcast-notification` | `{ "title": "...", "body": "..." }` | `{ "status": "success", "message": "Notification sent" }` |

### 8.7 Admin — Holding Tax

| Method | Endpoint | Response |
|---|---|---|
| `GET` | `/api/admin/holding-tax/stats` | `{ "status": "success", "data": { "total": ..., "paid": ..., "unpaid": ..., "total_amount": ..., "collected_amount": ... } }` |

### 8.8 Admin — Grievances

| Method | Endpoint | Request | Response |
|---|---|---|---|
| `GET` | `/api/admin/grievances?status=pending&category=...&page=1` | Query | `{ "status": "success", "data": { "data": [...], "current_page": 1, "last_page": 5, "total": 42 } }` |
| `POST` | `/api/admin/grievances/update-status` | `{ "grievance_id": 1, "status": "resolved", "admin_remarks": "..." }` | `{ "status": "success", "message": "Status updated" }` |

### 8.9 Admin — Billing

| Method | Endpoint | Request | Response |
|---|---|---|---|
| `GET` | `/api/markets` | — | `{ "status": "success", "data": [{ "id": 1, "market_name": "...", "location": "...", "total_shops": 50 }] }` |
| `POST` | `/api/admin/billing/generate-bills` | `{ "market_id": 1, "billing_month": "2026-05" }` | `{ "status": "success", "message": "Bills generated", "count": 50 }` |
| `POST` | `/api/admin/billing/upload-sheet` | Multipart: `file` | `{ "status": "success", "message": "Sheet processed", "records_created": 50 }` |
| `PUT` | `/api/admin/billing/update-payment` | `{ "market_id": 1, "shop_no": "A01", "billing_month": "2026-05", "paid_amount": 5000, "remarks": "Cash collected" }` | `{ "status": "success", "message": "Payment updated" }` |

### 8.10 Admin — Garbage Trucks

| Method | Endpoint | Request | Response |
|---|---|---|---|
| `GET` | `/api/admin/garbage/dashboard` | — | `{ "status": "success", "data": { "total_trucks": ..., "active_trucks": ..., "on_route": ..., "total_drivers": ..., "total_routes": ..., ... } }` |
| `POST` | `/api/admin/garbage/add-truck` | `{ "plate_number": "ML-01-1234", "truck_name": "...", "truck_type": "compactor", "capacity_tons": 5, "ward_id": 1 }` | `{ "status": "success", "message": "Truck added", "data": {...} }` |
| `POST` | `/api/admin/garbage/update-truck/{id}` | `{ "truck_name": "...", "status": "maintenance" }` | `{ "status": "success", "message": "Truck updated" }` |
| `POST` | `/api/admin/garbage/assign-driver` | `{ "driver_id": 5, "truck_id": 1 }` | `{ "status": "success", "message": "Driver assigned" }` |
| `POST` | `/api/admin/garbage/create-schedule` | `{ "ward_id": 1, "truck_id": 1, "day_of_week": "monday", "start_time": "06:00", "end_time": "10:00", "collection_type": "regular" }` | `{ "status": "success", "message": "Schedule created" }` |

### 8.11 Admin — Advertisements

| Method | Endpoint | Request | Response |
|---|---|---|---|
| `GET` | `/api/admin/advertisements?status=...&page=1` | Query | `{ "status": "success", "data": { "data": [...], "current_page": 1, "last_page": 3 } }` |
| `POST` | `/api/admin/advertisements` | Multipart: `title, description, image, redirect_url?, position, start_date?, end_date?` | `{ "status": "success", "message": "Ad created", "data": {...} }` |
| `GET` | `/api/admin/advertisements/{id}` | — | `{ "status": "success", "data": {...} }` |
| `PUT` | `/api/admin/advertisements/{id}` | Multipart: fields to update | `{ "status": "success", "message": "Ad updated" }` |
| `DELETE` | `/api/admin/advertisements/{id}` | — | `{ "status": "success", "message": "Ad deleted" }` |
| `POST` | `/api/admin/advertisements/{id}/publish` | — | `{ "status": "success", "message": "Ad published" }` |
| `POST` | `/api/admin/advertisements/{id}/pause` | — | `{ "status": "success", "message": "Ad paused" }` |
| `POST` | `/api/admin/advertisements/{id}/reject` | `{ "rejection_reason": "..." }` | `{ "status": "success", "message": "Ad rejected" }` |
| `GET` | `/api/admin/advertisements/statistics` | — | `{ "status": "success", "data": { "total": ..., "active": ..., "draft": ..., "total_impressions": ..., "total_clicks": ... } }` |

### 8.12 Admin — Notices / Announcements

| Method | Endpoint | Request | Response |
|---|---|---|---|
| `GET` | `/api/admin/notices?type=...&status=...&priority=...&page=1` | Query | `{ "status": "success", "data": { "data": [...], "current_page": 1, "last_page": 3 } }` |
| `POST` | `/api/admin/notices` | Multipart: `title, content, type, priority, attachment?, target_audience, is_pinned, publish_date?, expire_date?` | `{ "status": "success", "message": "Notice created", "data": {...} }` |
| `GET` | `/api/admin/notices/{id}` | — | `{ "status": "success", "data": {...} }` |
| `PUT` | `/api/admin/notices/{id}` | Multipart: fields to update | `{ "status": "success", "message": "Notice updated" }` |
| `DELETE` | `/api/admin/notices/{id}` | — | `{ "status": "success", "message": "Notice deleted" }` |
| `POST` | `/api/admin/notices/{id}/publish` | — | `{ "status": "success", "message": "Notice published" }` |
| `POST` | `/api/admin/notices/{id}/archive` | — | `{ "status": "success", "message": "Notice archived" }` |
| `POST` | `/api/admin/notices/{id}/toggle-pin` | — | `{ "status": "success", "message": "Pin toggled", "is_pinned": true }` |
| `GET` | `/api/admin/notices/statistics` | — | `{ "status": "success", "data": { "total": ..., "published": ..., "draft": ..., "archived": ... } }` |

### 8.13 Admin — Notifications

| Method | Endpoint | Request | Response |
|---|---|---|---|
| `GET` | `/api/admin/notifications?page=1` | Query | `{ "status": "success", "data": { "data": [...], "current_page": 1, "last_page": 5 } }` |
| `POST` | `/api/admin/notifications/broadcast` | `{ "title": "...", "body": "...", "category": "...", "data": {...}, "ward_no": "5" }` | `{ "status": "success", "message": "Broadcast sent", "sent_count": 1234 }` |
| `POST` | `/api/admin/notifications/send-to-user` | `{ "user_id": 42, "title": "...", "body": "...", "category": "...", "data": {...} }` | `{ "status": "success", "message": "Notification sent" }` |
| `GET` | `/api/admin/notifications/statistics` | — | `{ "status": "success", "data": { "total_sent": ..., "total_read": ..., "total_unread": ..., "by_category": {...} } }` |

### 8.14 Admin — Pet Dog

| Method | Endpoint | Request | Response |
|---|---|---|---|
| `GET` | `/api/admin/pet-dog/applications?status=...&page=1` | Query | `{ "status": "success", "data": { "data": [...], "current_page": 1, "last_page": 3 } }` |
| `GET` | `/api/admin/pet-dog/application?id=1` | Query | `{ "status": "success", "data": {...} }` |
| `POST` | `/api/admin/pet-dog/update-payment` | `{ "application_id": "...", "status": "paid", "paid_amount": 500, "remarks": "Cash" }` | `{ "status": "success", "message": "Payment updated" }` |

### 8.15 Driver Endpoints

| Method | Endpoint | Request | Response |
|---|---|---|---|
| `GET` | `/api/driver/assigned-route` | — | `{ "status": "success", "data": { "truck_id": 1, "truck_name": "...", "plate_number": "...", "route": { "route_name": "...", "ward_id": 1, "waypoints": [{"lat": 25.5, "lng": 90.2}], "estimated_duration_minutes": 45, "distance_km": 12.5 } } }` |
| `POST` | `/api/driver/start-shift` | `{ "truck_id": 1 }` | `{ "status": "success", "message": "Shift started" }` |
| `POST` | `/api/driver/end-shift` | `{ "truck_id": 1 }` | `{ "status": "success", "message": "Shift ended" }` |
| `POST` | `/api/driver/update-location` | `{ "truck_id": 1, "latitude": 25.5138, "longitude": 90.2195, "speed": 25.5, "heading": 180 }` | `{ "status": "success", "message": "Location updated" }` |

### 8.16 FCM Token Management

| Method | Endpoint | Request | Response |
|---|---|---|---|
| `POST` | `/api/trade-license/save-fcm-token` | `{ "fcm_token": "..." }` | `{ "status": "success", "message": "Token saved" }` |
| `DELETE` | `/api/trade-license/remove-fcm-token` | `{ "fcm_token": "..." }` | `{ "status": "success", "message": "Token removed" }` |

### Error Responses (All endpoints)

| Status | Response |
|---|---|
| `400` | `{ "status": "failed", "message": "Validation Failed", "errors": { "field": ["error message"] } }` |
| `401` | `{ "error": "Token is Invalid" }` or `{ "error": "Token is Expired" }` or `{ "error": "Authorization Token not found" }` |
| `403` | `{ "error": "Forbidden. Required role(s): admin, ceo. Your role: user" }` |
| `404` | `{ "status": "error", "message": "Not found" }` |
| `500` | `{ "status": "error", "message": "Something went wrong" }` |

---

## 9. Route Definitions

```dart
// routes/app_routes.dart
class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';

  // CEO / Admin
  static const adminMainShell = '/admin/main';
  static const adminDashboard = '/admin/dashboard';
  static const formApproval = '/admin/forms';
  static const formDetail = '/admin/forms/detail';
  static const jobList = '/admin/jobs';
  static const jobCreate = '/admin/jobs/create';
  static const jobEdit = '/admin/jobs/edit';
  static const renewalList = '/admin/trade-license/renewals';
  static const renewalDetail = '/admin/trade-license/renewals/detail';
  static const tradeLicenseStats = '/admin/trade-license/stats';
  static const holdingTaxStats = '/admin/holding-tax/stats';
  static const grievanceList = '/admin/grievances';
  static const grievanceDetail = '/admin/grievances/detail';
  static const billingDashboard = '/admin/billing';
  static const generateBills = '/admin/billing/generate';
  static const updatePayment = '/admin/billing/update-payment';
  static const garbageDashboard = '/admin/garbage';
  static const addTruck = '/admin/garbage/add-truck';
  static const assignDriver = '/admin/garbage/assign-driver';
  static const createSchedule = '/admin/garbage/create-schedule';
  static const adList = '/admin/advertisements';
  static const adCreate = '/admin/advertisements/create';
  static const adDetail = '/admin/advertisements/detail';
  static const adEdit = '/admin/advertisements/edit';
  static const noticeList = '/admin/notices';
  static const noticeCreate = '/admin/notices/create';
  static const noticeDetail = '/admin/notices/detail';
  static const noticeEdit = '/admin/notices/edit';
  static const notificationList = '/admin/notifications';
  static const broadcastNotification = '/admin/notifications/broadcast';
  static const sendToUser = '/admin/notifications/send-to-user';
  static const paymentHistory = '/admin/payment-history';
  static const petDogList = '/admin/pet-dog';
  static const petDogDetail = '/admin/pet-dog/detail';
  static const adminProfile = '/admin/profile';
  static const adminEditProfile = '/admin/profile/edit';
  static const adminChangePassword = '/admin/profile/change-password';

  // Driver
  static const driverHome = '/driver/home';
  static const driverProfile = '/driver/profile';
}

// routes/app_pages.dart
class AppPages {
  static final pages = <GetPage>[
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen(), binding: SplashBinding()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen(), binding: AuthBinding()),
    GetPage(name: AppRoutes.forgotPassword, page: () => const ForgotPasswordScreen(), binding: AuthBinding()),

    // Admin Main Shell
    GetPage(name: AppRoutes.adminMainShell, page: () => const MainShellScreen(), binding: MainShellBinding(), middlewares: [RoleGuard(allowedRoles: ['ceo', 'admin'])]),

    // Dashboard (CEO only)
    GetPage(name: AppRoutes.adminDashboard, page: () => const DashboardScreen(), binding: DashboardBinding(), middlewares: [RoleGuard(allowedRoles: ['ceo'])]),

    // Forms
    GetPage(name: AppRoutes.formApproval, page: () => const FormListScreen(), binding: FormApprovalBinding(), middlewares: [RoleGuard(allowedRoles: ['ceo', 'admin'])]),
    GetPage(name: AppRoutes.formDetail, page: () => const FormDetailScreen(), binding: FormApprovalBinding()),

    // Jobs (CEO only)
    GetPage(name: AppRoutes.jobList, page: () => const JobListScreen(), binding: JobPostingBinding(), middlewares: [RoleGuard(allowedRoles: ['ceo'])]),
    GetPage(name: AppRoutes.jobCreate, page: () => const JobCreateScreen(), binding: JobPostingBinding()),

    // Trade License Renewals (CEO only)
    GetPage(name: AppRoutes.renewalList, page: () => const RenewalListScreen(), binding: TradeLicenseAdminBinding(), middlewares: [RoleGuard(allowedRoles: ['ceo'])]),
    GetPage(name: AppRoutes.renewalDetail, page: () => const RenewalDetailScreen(), binding: TradeLicenseAdminBinding()),
    GetPage(name: AppRoutes.tradeLicenseStats, page: () => const TradeLicenseStatsScreen(), binding: TradeLicenseAdminBinding()),

    // Grievances (CEO + Admin)
    GetPage(name: AppRoutes.grievanceList, page: () => const GrievanceListScreen(), binding: GrievanceAdminBinding(), middlewares: [RoleGuard(allowedRoles: ['ceo', 'admin'])]),
    GetPage(name: AppRoutes.grievanceDetail, page: () => const GrievanceDetailScreen(), binding: GrievanceAdminBinding()),

    // Billing (CEO only)
    GetPage(name: AppRoutes.billingDashboard, page: () => const BillingDashboardScreen(), binding: BillingAdminBinding(), middlewares: [RoleGuard(allowedRoles: ['ceo'])]),
    GetPage(name: AppRoutes.generateBills, page: () => const GenerateBillsScreen(), binding: BillingAdminBinding()),
    GetPage(name: AppRoutes.updatePayment, page: () => const UpdatePaymentScreen(), binding: BillingAdminBinding()),

    // Garbage (CEO only)
    GetPage(name: AppRoutes.garbageDashboard, page: () => const GarbageDashboardScreen(), binding: GarbageAdminBinding(), middlewares: [RoleGuard(allowedRoles: ['ceo'])]),
    GetPage(name: AppRoutes.addTruck, page: () => const AddTruckScreen(), binding: GarbageAdminBinding()),
    GetPage(name: AppRoutes.assignDriver, page: () => const AssignDriverScreen(), binding: GarbageAdminBinding()),
    GetPage(name: AppRoutes.createSchedule, page: () => const CreateScheduleScreen(), binding: GarbageAdminBinding()),

    // Advertisements (CEO only)
    GetPage(name: AppRoutes.adList, page: () => const AdListScreen(), binding: AdvertisementAdminBinding(), middlewares: [RoleGuard(allowedRoles: ['ceo'])]),
    GetPage(name: AppRoutes.adCreate, page: () => const AdCreateScreen(), binding: AdvertisementAdminBinding()),
    GetPage(name: AppRoutes.adDetail, page: () => const AdDetailScreen(), binding: AdvertisementAdminBinding()),

    // Notices (CEO + Admin)
    GetPage(name: AppRoutes.noticeList, page: () => const NoticeListScreen(), binding: NoticeAdminBinding(), middlewares: [RoleGuard(allowedRoles: ['ceo', 'admin'])]),
    GetPage(name: AppRoutes.noticeCreate, page: () => const NoticeCreateScreen(), binding: NoticeAdminBinding()),
    GetPage(name: AppRoutes.noticeDetail, page: () => const NoticeDetailScreen(), binding: NoticeAdminBinding()),

    // Notifications (CEO + Admin)
    GetPage(name: AppRoutes.notificationList, page: () => const NotificationListScreen(), binding: NotificationAdminBinding(), middlewares: [RoleGuard(allowedRoles: ['ceo', 'admin'])]),
    GetPage(name: AppRoutes.broadcastNotification, page: () => const BroadcastScreen(), binding: NotificationAdminBinding()),
    GetPage(name: AppRoutes.sendToUser, page: () => const SendToUserScreen(), binding: NotificationAdminBinding()),

    // Payment History (CEO only)
    GetPage(name: AppRoutes.paymentHistory, page: () => const PaymentHistoryScreen(), binding: PaymentHistoryBinding(), middlewares: [RoleGuard(allowedRoles: ['ceo'])]),

    // Pet Dog (CEO only)
    GetPage(name: AppRoutes.petDogList, page: () => const PetDogListScreen(), binding: PetDogAdminBinding(), middlewares: [RoleGuard(allowedRoles: ['ceo'])]),
    GetPage(name: AppRoutes.petDogDetail, page: () => const PetDogDetailScreen(), binding: PetDogAdminBinding()),

    // Profile (All roles)
    GetPage(name: AppRoutes.adminProfile, page: () => const ProfileScreen(), binding: ProfileBinding()),
    GetPage(name: AppRoutes.adminEditProfile, page: () => const EditProfileScreen(), binding: ProfileBinding()),
    GetPage(name: AppRoutes.adminChangePassword, page: () => const ChangePasswordScreen(), binding: ProfileBinding()),

    // Driver
    GetPage(name: AppRoutes.driverHome, page: () => const DriverHomeScreen(), binding: GarbageDriverBinding(), middlewares: [RoleGuard(allowedRoles: ['driver'])]),
    GetPage(name: AppRoutes.driverProfile, page: () => const ProfileScreen(), binding: ProfileBinding()),
  ];
}
```

---

## 10. Implementation Order

Build features in this order to minimize blocked dependencies:

### Phase 1 — Foundation (Week 1)
1. **Project setup** — Create Flutter project, add pubspec.yaml dependencies, configure Android/iOS
2. **Core layer** — AppColors, AppSizes, AppTextStyles, ThemeConfig, NetworkService, DioClient, AuthInterceptor, SecureStorageService, LocalStorageService, ApiEndpoints, ErrorHandler, Failure classes
3. **Bootstrap** — Firebase init, System UI, Storage init
4. **Splash** — Check auth state, navigate to login or main shell
5. **Auth** — Login screen, AuthController, AuthDataSource, LoginRequest/Response models, role-based navigation after login

### Phase 2 — Shell & Profile (Week 1-2)
6. **Main Shell** — Bottom navigation with role-based tabs (CEO vs Admin)
7. **Profile** — View, edit, change password, logout

### Phase 3 — CEO Dashboard (Week 2)
8. **Dashboard** — AdminDashboardController, stat cards grid, recent activity list

### Phase 4 — Core Admin Features (Week 2-3)
9. **Form Approval** — List with filters, detail view, approve/reject dialog
10. **Grievance Management** — List with filters, detail view, status update
11. **Notice/Announcement CRUD** — Create, list, detail, publish/archive/toggle-pin

### Phase 5 — Business Features (Week 3-4)
12. **Job Posting CRUD** — Create, list, edit, delete
13. **Trade License Renewals** — List, approve/reject, cash collection (complete-renewal), stats, broadcast
14. **Holding Tax Stats** — Stats screen

### Phase 6 — Financial & Fleet (Week 4-5)
15. **Billing Management** — Market list, generate bills, upload sheet, cash payment update
16. **Garbage Admin** — Dashboard, add truck, assign driver, create schedule
17. **Payment History** — Paginated list with filters

### Phase 7 — Communication (Week 5)
18. **Advertisement CRUD** — Create (with image upload), list, detail, publish/pause/reject, stats
19. **Notification Admin** — Broadcast, send-to-user, list, statistics

### Phase 8 — Specialized (Week 5-6)
20. **Pet Dog Admin** — List applications, details, update payment
21. **Garbage Driver** — Route map with Google Maps, shift management, GPS location tracking

### Phase 9 — Polish (Week 6)
22. **FCM integration** — Foreground/background notification handling, token save/remove
23. **Error states** — Empty states, network error states, retry logic
24. **Loading states** — Shimmer/skeleton loading for all lists
25. **Pull-to-refresh** — All list screens
26. **Localization** — English + Hindi ARB files
27. **Testing** — Widget tests for key components, integration tests for auth flow

---

## Appendix A — Status Badge Colors

| Status | Color | Hex |
|---|---|---|
| pending / draft | Warning yellow | `#FFC107` |
| approved / active / published / paid / resolved / success | Success green | `#28A745` |
| rejected / expired / cancelled / failed / retired | Error red | `#DC3545` |
| in_progress / paused / maintenance | Info blue | `#17A2B8` |
| unpaid / inactive / archived | Neutral gray | `#6B7280` |
| partial | Warning orange | `#FF8C00` |

## Appendix B — Form Types Reference

| Form ID | Form Name | Application ID Prefix |
|---|---|---|
| 1 | NAC Birth Registration | TMBNAC |
| 2 | Complaint Form | TMBCMP |
| 3 | Water Tanker Request | TMBWT |
| 4 | Cesspool Tanker | TMBCT |
| 5 | Trade License | TMBTL |
| 6 | New Trade License | TMBNTL |
| 7 | NOC Telecom/Electricity | TMBNOC |
| 8 | NOC Establishment | TMBNOCE |
| 9 | Banner/Poster | TMBBP |
| 10 | Death Certificate | TMBDC |
| 11 | Birth Certificate | TMBCERT |
| 12 | Pet Dog Registration | TMBPET |

## Appendix C — Google Maps Configuration

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

Add to `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

The driver route map should:
1. Fetch assigned route from `GET /api/driver/assigned-route`
2. Draw polylines from `waypoints` array
3. Show current driver position as a custom marker (truck icon)
4. Auto-center camera on current position
5. Update position marker as driver moves (from location stream)

---

> **End of Guide** — This document contains everything needed to build the Tura Municipal Admin Flutter app from scratch. Follow the architecture conventions, implement features in the specified order, and use the exact API endpoints and models documented above.