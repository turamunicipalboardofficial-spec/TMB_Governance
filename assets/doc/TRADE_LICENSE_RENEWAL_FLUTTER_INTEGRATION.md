# Trade License Renewal - Flutter Integration Guide

## Overview

This document describes how to integrate the Trade License Renewal API into a Flutter mobile/web application.

## API Endpoints

| Endpoint | Method | Content-Type | Auth | Description |
|---|---|---|---|---|
| `/api/trade-licenses/search` | GET | - | No | Search trade licenses for dropdown |
| `/api/trade-licenses/details` | POST | `application/json` | No | Get full license details |
| `/api/tradeLicense` | POST | `multipart/form-data` | No | Submit renewal request |
| `/api/trade-licenses/renewal/status` | GET | - | No | Check renewal status |
| `/api/trade-licenses/pay` | POST | `application/json` | No | Process payment |
| `/api/trade-licenses/fcm-token` | POST | `application/json` | JWT | Save FCM device token |
| `/api/trade-licenses/fcm-token` | DELETE | - | JWT | Remove FCM device token |
| `/api/trade-licenses/renewals` | GET | - | JWT | List all renewals (Admin) |
| `/api/trade-licenses/renewal/approve` | POST | `application/json` | JWT | Approve renewal (Admin) |
| `/api/trade-licenses/renewal/reject` | POST | `application/json` | JWT | Reject renewal (Admin) |
| `/api/trade-licenses/renewal/complete` | POST | `application/json` | JWT | Complete renewal (Admin) |

---

## Flow

```
Search Trade License (GET /api/trade-licenses/search?q=)
        ↓
Select From Dropdown (returns id, license_no, etc.)
        ↓
Show License Details (read-only display)
        ↓
Upload Documents (Previous License Copy, Identity Proof, etc.)
        ↓
Accept Declaration Checkbox
        ↓
Submit Renewal Request (POST /api/tradeLicense)
        ↓
Approval Process (PENDING_APPROVAL → APPROVED)
        ↓
Payment (handled by existing Trade License Payment module)
        ↓
Renewal Completed
```

---

## 1. Search Trade Licenses

### Request

```dart
// GET /api/trade-licenses/search?q=searchTerm
final response = await http.get(
  Uri.parse('$baseUrl/api/trade-licenses/search?q=$searchTerm'),
);
```

### Response

```json
{
  "status": true,
  "message": "License search results",
  "data": [
    {
      "id": 1,
      "license_no": "No.TMB/TL/2022/03 (A)",
      "name": "John Doe",
      "business_name": "Doe Enterprises",
      "mobile_no": "9876543210",
      "business_address": "Main Road, Tura",
      "trade_type": "Retail",
      "ward_no": "5",
      "valid_upto": "2025-03-31",
      "renewal_date": "2025-04-01",
      "category": "General",
      "status": "active"
    }
  ]
}
```

### Flutter Implementation

```dart
class TradeLicenseSearchResult {
  final int id;
  final String licenseNo;
  final String name;
  final String businessName;
  final String mobileNo;
  final String businessAddress;
  final String tradeType;
  final String wardNo;
  final String? validUpto;
  final String? renewalDate;
  final String category;
  final String status;

  TradeLicenseSearchResult({
    required this.id,
    required this.licenseNo,
    required this.name,
    required this.businessName,
    required this.mobileNo,
    required this.businessAddress,
    required this.tradeType,
    required this.wardNo,
    this.validUpto,
    this.renewalDate,
    required this.category,
    required this.status,
  });

  factory TradeLicenseSearchResult.fromJson(Map<String, dynamic> json) {
    return TradeLicenseSearchResult(
      id: json['id'],
      licenseNo: json['license_no'] ?? '',
      name: json['name'] ?? '',
      businessName: json['business_name'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
      businessAddress: json['business_address'] ?? '',
      tradeType: json['trade_type'] ?? '',
      wardNo: json['ward_no'] ?? '',
      validUpto: json['valid_upto'],
      renewalDate: json['renewal_date'],
      category: json['category'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

Future<List<TradeLicenseSearchResult>> searchTradeLicenses(String query) async {
  // GET request - no POST body needed
  final uri = Uri.parse('$baseUrl/api/trade-licenses/search').replace(
    queryParameters: query.isNotEmpty ? {'q': query} : {},
  );
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['status'] == true) {
      return (data['data'] as List)
          .map((item) => TradeLicenseSearchResult.fromJson(item))
          .toList();
    }
  }
  return [];
}
```

---

## 2. Show License Details (Read-Only)

After selecting from dropdown, the details are already available from the search response. No additional API call needed.

Display these fields as read-only:
- Trade License Number
- Business Name
- Owner Name
- Mobile Number
- Address
- Trade Type
- Ward Number
- Existing Validity (valid_upto)
- Category Details

---

## 3. Submit Renewal

### Request (multipart/form-data)

```dart
Future<Map<String, dynamic>?> submitRenewal({
  required int tradeLicenseId,
  required bool declarationAccepted,
  String remarks = '',
  required List<File> documents,
}) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/api/tradeLicense'),  // Note: POST /api/tradeLicense
  );

  // Add fields
  request.fields['trade_license_id'] = tradeLicenseId.toString();
  request.fields['declaration_accepted'] = declarationAccepted.toString();
  request.fields['remarks'] = remarks;

  // Add document files
  for (var doc in documents) {
    request.files.add(
      await http.MultipartFile.fromPath('documents[]', doc.path),
    );
  }

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);

  return jsonDecode(response.body);
}
```

### Usage Example

```dart
// 1. Search and select license
final results = await searchTradeLicenses('TMB');
final selectedLicense = results.first; // User selected from dropdown

// 2. Prepare documents (from file picker)
List<File> documents = [
  File('/path/to/previous_license.pdf'),
  File('/path/to/identity_proof.pdf'),
];

// 3. Submit renewal
final result = await submitRenewal(
  tradeLicenseId: selectedLicense.id,
  declarationAccepted: true,  // Must be true
  remarks: 'Trade license renewal request',
  documents: documents,
);

if (result?['status'] == true) {
  print('Renewal submitted! Application ID: ${result?['data']['application_id']}');
} else {
  print('Error: ${result?['message']}');
}
```

### Success Response (201)

```json
{
  "status": true,
  "message": "Trade license renewal request submitted successfully. Your application ID is: TLR-A1B2C3D4",
  "data": {
    "id": 1,
    "trade_license_id": 12,
    "application_id": "TLR-A1B2C3D4",
    "license_no": "No.TMB/TL/2022/03 (A)",
    "name": "John Doe",
    "business_name": "Doe Enterprises",
    "business_address": "Main Road, Tura",
    "status": "PENDING_APPROVAL",
    "payment_status": "pending_approval",
    "declaration_accepted": "[\"I hereby declare that all information provided is correct.\"]",
    "remarks": "Trade license renewal request",
    "created_at": "2026-05-20T14:30:00.000000Z"
  }
}
```

### Error Responses (422)

```json
{
  "status": false,
  "message": "At least one document must be uploaded (Previous License Copy, Identity Proof, or Supporting Document)",
  "data": null
}
```

```json
{
  "status": false,
  "message": "A pending renewal request already exists for this trade license",
  "data": null
}
```

```json
{
  "status": false,
  "message": "Trade license is cancelled or blacklisted and cannot be renewed",
  "data": null
}
```

---

## 4. Check Renewal Status

### Request

```dart
// GET /api/trade-licenses/renewal/status?application_id=TLR-A1B2C3D4
// OR
// GET /api/trade-licenses/renewal/status?trade_license_id=12
final response = await http.get(
  Uri.parse('$baseUrl/api/trade-licenses/renewal/status?application_id=$applicationId'),
);
```

### Response

```json
{
  "status": true,
  "message": "Renewal status retrieved",
  "data": {
    "id": 1,
    "trade_license_id": 12,
    "application_id": "TLR-A1B2C3D4",
    "license_no": "No.TMB/TL/2022/03 (A)",
    "name": "John Doe",
    "business_name": "Doe Enterprises",
    "status": "PENDING_APPROVAL",
    "payment_status": "pending_approval",
    "created_at": "2026-05-20T14:30:00.000000Z",
    "reviewed_at": null,
    "admin_remarks": null
  }
}
```

---

## 5. Process Payment

### Request

```dart
final response = await http.post(
  Uri.parse('$baseUrl/api/trade-licenses/pay'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'license_no': 'No.TMB/TL/2022/03 (A)',
    'paid_amount': 500.00,
    'payment_remarks': 'Paid via UPI',
  }),
);
```

---

## 6. Push Notifications (FCM)

Push notifications are sent automatically when the renewal status changes. The Flutter app needs to:

1. **Initialize Firebase** in the app
2. **Get FCM token** after user login
3. **Register the FCM token** with the backend
4. **Remove the FCM token** on logout

### Setup Firebase in Flutter

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
```

### Register FCM Token After Login

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> registerFcmToken(String jwtToken) async {
  // Get FCM token
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  
  if (fcmToken != null) {
    // Register with backend
    await http.post(
      Uri.parse('$baseUrl/api/trade-licenses/fcm-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({'fcm_token': fcmToken}),
    );
  }
  
  // Listen for token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    http.post(
      Uri.parse('$baseUrl/api/trade-licenses/fcm-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({'fcm_token': newToken}),
    );
  });
}
```

### Remove FCM Token on Logout

```dart
Future<void> removeFcmToken(String jwtToken) async {
  await http.delete(
    Uri.parse('$baseUrl/api/trade-licenses/fcm-token'),
    headers: {
      'Authorization': 'Bearer $jwtToken',
    },
  );
}
```

### Handle Incoming Notifications

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// Handle foreground messages
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Got a message whilst in the foreground!');
  print('Message data: ${message.data}');
  
  if (message.notification != null) {
    // Show a local notification or dialog
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: Text(message.notification!.title ?? 'Notification'),
        content: Text(message.notification!.body ?? ''),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to renewal status screen
              _navigateToRenewalStatus(message.data);
            },
            child: Text('View'),
          ),
        ],
      ),
    );
  }
});

// Handle background messages (when app is in background)
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  _navigateToRenewalStatus(message.data);
});

// Handle messages when app is terminated (requires top-level handler)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void _navigateToRenewalStatus(Map<String, dynamic> data) {
  final type = data['type'];
  final renewalId = data['renewal_id'];
  
  if (type == 'trade_license_renewal' && renewalId != null) {
    // Navigate to renewal status/details screen
    navigatorKey.currentState?.pushNamed(
      '/renewal-status',
      arguments: {'renewal_id': int.parse(renewalId)},
    );
  }
}
```

### Push Notification Payload Structure

When renewal status changes, the backend sends notifications with this structure:

```json
{
  "message": {
    "token": "{device_fcm_token}",
    "notification": {
      "title": "Trade License Renewal",
      "body": "Your trade license renewal has been approved. Please proceed with payment."
    },
    "data": {
      "type": "trade_license_renewal",
      "license_no": "No.TMB/TL/2022/03 (A)",
      "status": "APPROVED",
      "renewal_id": "1",
      "click_action": "FLUTTER_NOTIFICATION_CLICK"
    },
    "android": {
      "priority": "high",
      "notification": {
        "channel_id": "trade_license_renewals",
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      }
    },
    "apns": {
      "headers": { "apns-priority": "10" },
      "payload": {
        "aps": {
          "alert": { "title": "Trade License Renewal", "body": "..." },
          "sound": "default"
        }
      }
    }
  }
}
```

### Notification Messages by Status

| Status | Notification Title | Notification Body |
|---|---|---|
| `APPROVED` | Trade License Renewal | Your trade license renewal has been approved. Please proceed with payment. |
| `PAYMENT_PENDING` | Trade License Renewal | Payment is pending for your trade license renewal. Please complete the payment. |
| `PAID` | Trade License Renewal | Payment received for your trade license renewal. |
| `COMPLETED` | Trade License Renewal | Your trade license renewal is completed. License validity has been extended. |
| `REJECTED` | Trade License Renewal | Your trade license renewal has been rejected. Reason: {admin_remarks} |

---

## Status Flow

```
PENDING_APPROVAL → APPROVED → PAYMENT_PENDING → PAID → COMPLETED
                 ↘ REJECTED
```

| Status | Description |
|---|---|
| `PENDING_APPROVAL` | Newly submitted, awaiting admin review |
| `APPROVED` | Admin approved the renewal |
| `PAYMENT_PENDING` | Payment amount generated, awaiting payment |
| `PAID` | Payment completed |
| `COMPLETED` | Renewal fully processed |
| `REJECTED` | Admin rejected the renewal |

---

## Validation Rules

1. **Declaration required** - `declaration_accepted` must be `true`
2. **Documents required** - At least one document must be uploaded
3. **License must be active** - Cannot renew cancelled/blacklisted licenses
4. **No duplicate renewals** - Cannot submit if a pending renewal already exists

---

## Declaration Text

```
I hereby declare that all information provided is correct.
```

---

## Searchable Dropdown

The search API (GET) supports searching by:
- **License Number** (e.g., "TMB/TL")
- **Business Name** (e.g., "Doe Enterprises")
- **Owner Name** (e.g., "John Doe")

If no query parameter is provided, returns all licenses (up to 200).

Use the existing Trade License Payment module's searchable dropdown component for consistency.

---

## File Upload Notes

- Content-Type: `multipart/form-data`
- Max file size: 10MB per file
- Field name for documents: `documents[]`
- Supported document types: PDF, JPG, PNG, DOC, DOCX

---

## Android Notification Channel Setup

Add this to your `AndroidManifest.xml` inside the `<application>` tag:

```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="trade_license_renewals" />
```

Create the notification channel in your main activity:

```kotlin
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
    val channel = NotificationChannel(
        "trade_license_renewals",
        "Trade License Renewals",
        NotificationManager.IMPORTANCE_HIGH
    ).apply {
        description = "Notifications for trade license renewal status updates"
    }
    val notificationManager = getSystemService(NotificationManager::class.java)
    notificationManager.createNotificationChannel(channel)
}