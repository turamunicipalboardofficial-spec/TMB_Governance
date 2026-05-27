# 📱 Tura Municipal Board - Dashboard, Advertisements & Notices Flutter Integration Guide

## 📋 Table of Contents

1. [Overview](#overview)
2. [Authentication & Roles](#authentication--roles)
3. [Dashboard APIs](#dashboard-apis)
4. [Advertisement APIs](#advertisement-apis)
5. [Notice & Announcement APIs](#notice--announcement-apis)
6. [Flutter Implementation](#flutter-implementation)
7. [Complete Widget Examples](#complete-widget-examples)

---

## Overview

This guide covers the integration of **Dashboard**, **Advertisement**, and **Notice & Announcement** APIs in the Flutter app. The app has two user roles:

| Role | Description | Login Type |
|------|-------------|------------|
| **Citizen** | Regular citizens who can view data | `user` role |
| **Admin** | Employees and CEO who can manage data | `admin`, `ceo`, `employee`, `editor` roles |

### Base URL
```
https://laravelv2.turamunicipalboard.com/api
```

### Common Headers
```dart
{
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer <JWT_TOKEN>',
}
```

---

## Authentication & Roles

### Login Response (includes role)
```json
{
  "status": true,
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "citizen"  // or "admin", "ceo", "employee", "editor"
  }
}
```

### Role-Based Access Control in Flutter
```dart
class AuthService {
  String? _userRole;
  
  bool get isCitizen => _userRole == 'citizen';
  bool get isAdmin => ['admin', 'ceo', 'employee', 'editor'].contains(_userRole);
  bool get canManageContent => ['admin', 'ceo', 'editor'].contains(_userRole);
  bool get canManageNotices => ['admin', 'ceo', 'employee', 'editor'].contains(_userRole);
  
  void setRole(String role) {
    _userRole = role;
  }
}
```

---

## Dashboard APIs

### 1. Citizen Dashboard

**Endpoint:** `GET /api/dashboard/citizen`

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "status": "success",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "9876543210"
    },
    "summary": {
      "total_applications": 5,
      "pending_applications": 2,
      "approved_applications": 3,
      "total_payments": 15000.00,
      "pending_dues": 5000.00
    },
    "recent_applications": [...],
    "recent_payments": [...],
    "notices": [...],
    "advertisements": [...]
  }
}
```

### 2. Admin Dashboard

**Endpoint:** `GET /api/dashboard/admin`

**Headers:** `Authorization: Bearer <token>` (requires admin/ceo/editor role)

**Response:**
```json
{
  "status": "success",
  "data": {
    "total_users": 1500,
    "total_applications": 3200,
    "pending_approvals": 45,
    "total_revenue": 2500000.00,
    "today_collections": 25000.00,
    "active_advertisements": 12,
    "active_notices": 8,
    "recent_activities": [...],
    "monthly_stats": [...]
  }
}
```

### 3. Payment Dues

**Endpoint:** `GET /api/dashboard/payment-dues`

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "status": "success",
  "data": {
    "total_dues": 15000.00,
    "dues": [
      {
        "id": 1,
        "type": "billing",
        "description": "Shop Rent - March 2026",
        "amount": 5000.00,
        "due_date": "2026-04-15",
        "status": "unpaid"
      }
    ]
  }
}
```

### 4. Payment History

**Endpoint:** `GET /api/dashboard/payment-history`

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "status": "success",
  "data": {
    "payments": [
      {
        "id": 1,
        "type": "billing",
        "description": "Shop Rent - February 2026",
        "amount": 5000.00,
        "payment_date": "2026-02-10",
        "status": "paid",
        "transaction_id": "TXN123456"
      }
    ]
  }
}
```

---

## Advertisement APIs

### Role-Based Access Summary

| Operation | Citizen | Admin (CEO/Employee) |
|-----------|---------|---------------------|
| View active ads | ✅ | ✅ |
| Record click | ✅ | ✅ |
| Create ad | ❌ | ✅ |
| List all ads | ❌ | ✅ |
| Get ad by ID | ❌ | ✅ |
| Update ad | ❌ | ✅ |
| Delete ad | ❌ | ✅ |
| Publish/Pause/Reject | ❌ | ✅ |
| Statistics | ❌ | ✅ |

---

### CITIZEN ENDPOINTS

### 1. Get Active Advertisements (Citizen)

**Endpoint:** `GET /api/ads`

**Query Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `position` | string | No | Filter by position (e.g., "home_banner", "sidebar") |
| `limit` | int | No | Max 20, default 5 |

**Response:**
```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "advertiser_name": "ABC Corp",
      "advertiser_type": "business",
      "title": "Summer Sale",
      "description": "50% off on all items",
      "image_url": "https://example.com/ad.jpg",
      "redirect_url": "https://example.com",
      "position": "home_banner",
      "priority": 10,
      "start_date": "2026-05-01",
      "end_date": "2026-05-31"
    }
  ]
}
```

### 2. Record Ad Click (Citizen)

**Endpoint:** `POST /api/ads/{id}/click`

**Response:**
```json
{
  "status": "success",
  "data": {
    "message": "Click recorded successfully",
    "ad_id": 1,
    "redirect_url": "https://example.com"
  }
}
```

---

### ADMIN ENDPOINTS

### 3. Create Advertisement (Admin)

**Endpoint:** `POST /api/advertisements`

**Required Role:** `admin`, `ceo`, `editor`

**Request Body:**
```json
{
  "advertiser_name": "ABC Corp",
  "advertiser_type": "business",
  "title": "Summer Sale",
  "description": "50% off on all items",
  "contact_person": "John Doe",
  "contact_phone": "9876543210",
  "contact_email": "john@abc.com",
  "website_url": "https://abc.com",
  "image_url": "https://example.com/ad.jpg",
  "redirect_url": "https://example.com/sale",
  "position": "home_banner",
  "status": "draft",
  "start_date": "2026-05-01",
  "end_date": "2026-05-31",
  "amount_paid": 5000.00,
  "priority": 10,
  "admin_remarks": "Premium advertiser"
}
```

**Field Validation:**
| Field | Required | Type | Max Length |
|-------|----------|------|------------|
| `advertiser_name` | ✅ | string | 255 |
| `advertiser_type` | ✅ | string | 50 |
| `title` | ❌ | string | 255 |
| `description` | ❌ | string | - |
| `contact_person` | ❌ | string | 255 |
| `contact_phone` | ❌ | string | 20 |
| `contact_email` | ❌ | email | 255 |
| `website_url` | ❌ | string | 500 |
| `image_url` | ❌ | string | 500 |
| `redirect_url` | ❌ | string | 500 |
| `position` | ❌ | string | 50 |
| `status` | ❌ | string | 20 |
| `start_date` | ❌ | date | - |
| `end_date` | ❌ | date | must be >= start_date |
| `amount_paid` | ❌ | numeric | min: 0 |
| `priority` | ❌ | integer | min: 0 |
| `admin_remarks` | ❌ | string | - |

**Response (201):**
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "advertiser_name": "ABC Corp",
    "advertiser_type": "business",
    "title": "Summer Sale",
    "description": "50% off on all items",
    "contact_person": "John Doe",
    "contact_phone": "9876543210",
    "contact_email": "john@abc.com",
    "website_url": "https://abc.com",
    "image_url": "https://example.com/ad.jpg",
    "redirect_url": "https://example.com/sale",
    "position": "home_banner",
    "status": "draft",
    "start_date": "2026-05-01",
    "end_date": "2026-05-31",
    "amount_paid": 5000.00,
    "priority": 10,
    "admin_remarks": "Premium advertiser",
    "click_count": 0,
    "created_at": "2026-05-19T00:00:00.000000Z",
    "updated_at": "2026-05-19T00:00:00.000000Z"
  }
}
```

### 4. List All Advertisements (Admin)

**Endpoint:** `GET /api/advertisements`

**Query Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `status` | string | - | Filter by status (draft, active, paused, rejected, archived) |
| `advertiser_type` | string | - | Filter by type |
| `position` | string | - | Filter by position |
| `search` | string | - | Search in title, description, advertiser_name |
| `sort_by` | string | `created_at` | Sort field |
| `sort_order` | string | `desc` | Sort direction (asc/desc) |
| `per_page` | int | `15` | Results per page |

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "data": [...],
    "current_page": 1,
    "last_page": 5,
    "per_page": 15,
    "total": 75
  }
}
```

### 5. Get Advertisement by ID (Admin)

**Endpoint:** `GET /api/advertisements/{id}`

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "advertiser_name": "ABC Corp",
    "advertiser_type": "business",
    "title": "Summer Sale",
    "description": "50% off on all items",
    "contact_person": "John Doe",
    "contact_phone": "9876543210",
    "contact_email": "john@abc.com",
    "website_url": "https://abc.com",
    "image_url": "https://example.com/ad.jpg",
    "redirect_url": "https://example.com/sale",
    "position": "home_banner",
    "status": "active",
    "start_date": "2026-05-01",
    "end_date": "2026-05-31",
    "amount_paid": 5000.00,
    "priority": 10,
    "click_count": 150,
    "admin_remarks": "Premium advertiser",
    "created_by": 1,
    "approved_by": 2,
    "created_at": "2026-05-01T10:00:00.000000Z",
    "updated_at": "2026-05-15T14:30:00.000000Z"
  }
}
```

### 6. Update Advertisement (Admin)

**Endpoint:** `PUT /api/advertisements/{id}`

**Request Body:** (all fields optional - use `sometimes` validation)
```json
{
  "title": "Updated Summer Sale",
  "description": "Now 60% off!",
  "status": "active",
  "priority": 20
}
```

**Response (200):** Same as create response with updated values.

### 7. Delete Advertisement (Admin)

**Endpoint:** `DELETE /api/advertisements/{id}`

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "message": "Advertisement deleted successfully"
  }
}
```

### 8. Publish Advertisement (Admin)

**Endpoint:** `POST /api/advertisements/{id}/publish`

**Request Body (optional):**
```json
{
  "admin_remarks": "Approved for publication"
}
```

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "status": "active",
    "approved_by": 2,
    "approved_at": "2026-05-19T10:00:00.000000Z",
    "admin_remarks": "Approved for publication"
  }
}
```

### 9. Pause Advertisement (Admin)

**Endpoint:** `POST /api/advertisements/{id}/pause`

**Request Body (optional):**
```json
{
  "admin_remarks": "Temporarily paused"
}
```

### 10. Reject Advertisement (Admin)

**Endpoint:** `POST /api/advertisements/{id}/reject`

**Request Body (optional):**
```json
{
  "admin_remarks": "Content violates guidelines"
}
```

### 11. Advertisement Statistics (Admin)

**Endpoint:** `GET /api/advertisements/stats/overview`

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "total_ads": 75,
    "active_ads": 12,
    "draft_ads": 5,
    "paused_ads": 3,
    "total_clicks": 5000,
    "total_revenue": 150000.00
  }
}
```

---

## Notice & Announcement APIs

### Role-Based Access Summary

| Operation | Citizen | Admin (CEO/Employee) |
|-----------|---------|---------------------|
| View active notices | ✅ | ✅ |
| Create notice | ❌ | ✅ |
| List all notices | ❌ | ✅ |
| Get notice by ID | ❌ | ✅ |
| Update notice | ❌ | ✅ |
| Delete notice | ❌ | ✅ |
| Publish/Archive | ❌ | ✅ |
| Toggle Pin | ❌ | ✅ |
| Statistics | ❌ | ✅ |

---

### CITIZEN ENDPOINTS

### 1. Get Active Notices (Citizen)

**Endpoint:** `GET /api/feed/notices`

**Query Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | No | Filter: "notice" or "announcement" |
| `target_audience` | string | No | Filter by target audience |
| `limit` | int | No | Max results, default 10 |

**Response:**
```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "title": "Water Supply Disruption",
      "content": "Water supply will be disrupted on...",
      "type": "notice",
      "priority": "high",
      "status": "published",
      "target_audience": "all",
      "attachment_url": "https://example.com/notice.pdf",
      "publish_date": "2026-05-15",
      "expiry_date": "2026-05-20",
      "is_pinned": true,
      "created_at": "2026-05-15T10:00:00.000000Z"
    }
  ]
}
```

---

### ADMIN ENDPOINTS

### 2. Create Notice/Announcement (Admin)

**Endpoint:** `POST /api/notices`

**Required Role:** `admin`, `ceo`, `employee`, `editor`

**Request Body:**
```json
{
  "title": "Water Supply Disruption",
  "content": "Due to maintenance work, water supply will be disrupted in Ward 1-5 on 20th May 2026 from 9 AM to 5 PM.",
  "type": "notice",
  "priority": "high",
  "status": "draft",
  "target_audience": "all",
  "attachment_url": "https://example.com/notice.pdf",
  "publish_date": "2026-05-15",
  "expiry_date": "2026-05-20",
  "is_pinned": true,
  "admin_remarks": "Urgent notice for all wards"
}
```

**Field Validation:**
| Field | Required | Type | Values/Max |
|-------|----------|------|------------|
| `title` | ✅ | string | 255 |
| `content` | ✅ | string | - |
| `type` | ❌ | string | `notice`, `announcement` |
| `priority` | ❌ | string | `low`, `medium`, `high`, `urgent` |
| `status` | ❌ | string | `draft`, `published`, `archived` |
| `target_audience` | ❌ | string | 100 |
| `attachment_url` | ❌ | string | 500 |
| `publish_date` | ❌ | date | - |
| `expiry_date` | ❌ | date | must be >= publish_date |
| `is_pinned` | ❌ | boolean | - |
| `admin_remarks` | ❌ | string | - |

**Response (201):**
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "title": "Water Supply Disruption",
    "content": "Due to maintenance work...",
    "type": "notice",
    "priority": "high",
    "status": "draft",
    "target_audience": "all",
    "attachment_url": "https://example.com/notice.pdf",
    "publish_date": "2026-05-15",
    "expiry_date": "2026-05-20",
    "is_pinned": true,
    "admin_remarks": "Urgent notice for all wards",
    "created_by": 1,
    "created_at": "2026-05-19T00:00:00.000000Z",
    "updated_at": "2026-05-19T00:00:00.000000Z"
  }
}
```

### 3. List All Notices (Admin)

**Endpoint:** `GET /api/notices`

**Query Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `status` | string | - | Filter: draft, published, archived |
| `type` | string | - | Filter: notice, announcement |
| `priority` | string | - | Filter: low, medium, high, urgent |
| `target_audience` | string | - | Filter by audience |
| `search` | string | - | Search in title, content |
| `sort_by` | string | `created_at` | Sort field |
| `sort_order` | string | `desc` | Sort direction |
| `per_page` | int | `15` | Results per page |

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "data": [...],
    "current_page": 1,
    "last_page": 3,
    "per_page": 15,
    "total": 42
  }
}
```

### 4. Get Notice by ID (Admin)

**Endpoint:** `GET /api/notices/{id}`

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "title": "Water Supply Disruption",
    "content": "Due to maintenance work...",
    "type": "notice",
    "priority": "high",
    "status": "published",
    "target_audience": "all",
    "attachment_url": "https://example.com/notice.pdf",
    "publish_date": "2026-05-15",
    "expiry_date": "2026-05-20",
    "is_pinned": true,
    "admin_remarks": "Urgent notice for all wards",
    "created_by": 1,
    "approved_by": 2,
    "created_at": "2026-05-15T10:00:00.000000Z",
    "updated_at": "2026-05-15T14:30:00.000000Z"
  }
}
```

### 5. Update Notice (Admin)

**Endpoint:** `PUT /api/notices/{id}`

**Request Body:** (all fields optional)
```json
{
  "title": "Updated: Water Supply Disruption",
  "content": "Updated content...",
  "priority": "urgent",
  "is_pinned": true
}
```

### 6. Delete Notice (Admin)

**Endpoint:** `DELETE /api/notices/{id}`

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "message": "Notice/Announcement deleted successfully"
  }
}
```

### 7. Publish Notice (Admin)

**Endpoint:** `POST /api/notices/{id}/publish`

**Request Body (optional):**
```json
{
  "admin_remarks": "Approved for publication"
}
```

### 8. Archive Notice (Admin)

**Endpoint:** `POST /api/notices/{id}/archive`

**Request Body (optional):**
```json
{
  "admin_remarks": "No longer relevant"
}
```

### 9. Toggle Pin Notice (Admin)

**Endpoint:** `POST /api/notices/{id}/toggle-pin`

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "is_pinned": true,
    "message": "Notice pinned successfully"
  }
}
```

### 10. Notice Statistics (Admin)

**Endpoint:** `GET /api/notices/stats/overview`

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "total": 42,
    "published": 25,
    "draft": 10,
    "archived": 7,
    "notices": 30,
    "announcements": 12,
    "pinned": 3
  }
}
```

---

## Flutter Implementation

### 1. API Service Class

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://laravelv2.turamunicipalboard.com/api';
  String? _token;
  String? _userRole;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  void setToken(String token) {
    _token = token;
  }

  void setRole(String role) {
    _userRole = role;
  }

  bool get isAdmin => ['admin', 'ceo', 'employee', 'editor'].contains(_userRole);
  bool get isCitizen => _userRole == 'citizen';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> _get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$baseUrl/$endpoint').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _post(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final response = await http.post(uri, headers: _headers, body: jsonEncode(body ?? {}));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _put(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final response = await http.put(uri, headers: _headers, body: jsonEncode(body ?? {}));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final response = await http.delete(uri, headers: _headers);
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: body['message'] ?? 'Unknown error',
        errors: body['errors'],
      );
    }
  }

  // ==================== DASHBOARD ====================

  Future<Map<String, dynamic>> getCitizenDashboard() async {
    return _get('dashboard/citizen');
  }

  Future<Map<String, dynamic>> getAdminDashboard() async {
    return _get('dashboard/admin');
  }

  Future<Map<String, dynamic>> getPaymentDues() async {
    return _get('dashboard/payment-dues');
  }

  Future<Map<String, dynamic>> getPaymentHistory() async {
    return _get('dashboard/payment-history');
  }

  // ==================== ADVERTISEMENTS (CITIZEN) ====================

  Future<Map<String, dynamic>> getActiveAds({String? position, int? limit}) async {
    final params = <String, String>{};
    if (position != null) params['position'] = position;
    if (limit != null) params['limit'] = limit.toString();
    return _get('ads', queryParams: params);
  }

  Future<Map<String, dynamic>> recordAdClick(int adId) async {
    return _post('ads/$adId/click');
  }

  // ==================== ADVERTISEMENTS (ADMIN) ====================

  Future<Map<String, dynamic>> createAdvertisement(Map<String, dynamic> data) async {
    return _post('advertisements', body: data);
  }

  Future<Map<String, dynamic>> getAdvertisements({
    String? status,
    String? advertiserType,
    String? position,
    String? search,
    String? sortBy,
    String? sortOrder,
    int? perPage,
    int? page,
  }) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    if (advertiserType != null) params['advertiser_type'] = advertiserType;
    if (position != null) params['position'] = position;
    if (search != null) params['search'] = search;
    if (sortBy != null) params['sort_by'] = sortBy;
    if (sortOrder != null) params['sort_order'] = sortOrder;
    if (perPage != null) params['per_page'] = perPage.toString();
    if (page != null) params['page'] = page.toString();
    return _get('advertisements', queryParams: params);
  }

  Future<Map<String, dynamic>> getAdvertisementById(int id) async {
    return _get('advertisements/$id');
  }

  Future<Map<String, dynamic>> updateAdvertisement(int id, Map<String, dynamic> data) async {
    return _put('advertisements/$id', body: data);
  }

  Future<Map<String, dynamic>> deleteAdvertisement(int id) async {
    return _delete('advertisements/$id');
  }

  Future<Map<String, dynamic>> publishAdvertisement(int id, {String? remarks}) async {
    return _post('advertisements/$id/publish', body: {
      if (remarks != null) 'admin_remarks': remarks,
    });
  }

  Future<Map<String, dynamic>> pauseAdvertisement(int id, {String? remarks}) async {
    return _post('advertisements/$id/pause', body: {
      if (remarks != null) 'admin_remarks': remarks,
    });
  }

  Future<Map<String, dynamic>> rejectAdvertisement(int id, {String? remarks}) async {
    return _post('advertisements/$id/reject', body: {
      if (remarks != null) 'admin_remarks': remarks,
    });
  }

  Future<Map<String, dynamic>> getAdvertisementStats() async {
    return _get('advertisements/stats/overview');
  }

  // ==================== NOTICES (CITIZEN) ====================

  Future<Map<String, dynamic>> getActiveNotices({String? type, String? targetAudience, int? limit}) async {
    final params = <String, String>{};
    if (type != null) params['type'] = type;
    if (targetAudience != null) params['target_audience'] = targetAudience;
    if (limit != null) params['limit'] = limit.toString();
    return _get('feed/notices', queryParams: params);
  }

  // ==================== NOTICES (ADMIN) ====================

  Future<Map<String, dynamic>> createNotice(Map<String, dynamic> data) async {
    return _post('notices', body: data);
  }

  Future<Map<String, dynamic>> getNotices({
    String? status,
    String? type,
    String? priority,
    String? targetAudience,
    String? search,
    String? sortBy,
    String? sortOrder,
    int? perPage,
    int? page,
  }) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    if (type != null) params['type'] = type;
    if (priority != null) params['priority'] = priority;
    if (targetAudience != null) params['target_audience'] = targetAudience;
    if (search != null) params['search'] = search;
    if (sortBy != null) params['sort_by'] = sortBy;
    if (sortOrder != null) params['sort_order'] = sortOrder;
    if (perPage != null) params['per_page'] = perPage.toString();
    if (page != null) params['page'] = page.toString();
    return _get('notices', queryParams: params);
  }

  Future<Map<String, dynamic>> getNoticeById(int id) async {
    return _get('notices/$id');
  }

  Future<Map<String, dynamic>> updateNotice(int id, Map<String, dynamic> data) async {
    return _put('notices/$id', body: data);
  }

  Future<Map<String, dynamic>> deleteNotice(int id) async {
    return _delete('notices/$id');
  }

  Future<Map<String, dynamic>> publishNotice(int id, {String? remarks}) async {
    return _post('notices/$id/publish', body: {
      if (remarks != null) 'admin_remarks': remarks,
    });
  }

  Future<Map<String, dynamic>> archiveNotice(int id, {String? remarks}) async {
    return _post('notices/$id/archive', body: {
      if (remarks != null) 'admin_remarks': remarks,
    });
  }

  Future<Map<String, dynamic>> togglePinNotice(int id) async {
    return _post('notices/$id/toggle-pin');
  }

  Future<Map<String, dynamic>> getNoticeStats() async {
    return _get('notices/stats/overview');
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? errors;

  ApiException({required this.statusCode, required this.message, this.errors});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
```

---

## Complete Widget Examples

### 2. Dashboard Screen (Role-Based)

```dart
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      setState(() => _isLoading = true);
      
      final response = _api.isAdmin
          ? await _api.getAdminDashboard()
          : await _api.getCitizenDashboard();
      
      setState(() {
        _dashboardData = response['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Text(
              'Welcome, ${_dashboardData?['user']?['name'] ?? 'User'}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Admin Stats Cards
            if (_api.isAdmin) ..._buildAdminStats(),
            
            // Citizen Summary Cards
            if (_api.isCitizen) ..._buildCitizenSummary(),

            SizedBox(height: 20),

            // Recent Notices Section
            _buildNoticesSection(),
            
            SizedBox(height: 20),

            // Advertisements Carousel
            _buildAdvertisementsSection(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAdminStats() {
    return [
      Row(
        children: [
          _buildStatCard('Total Users', '${_dashboardData?['total_users'] ?? 0}', Icons.people, Colors.blue),
          SizedBox(width: 12),
          _buildStatCard('Applications', '${_dashboardData?['total_applications'] ?? 0}', Icons.description, Colors.green),
        ],
      ),
      SizedBox(height: 12),
      Row(
        children: [
          _buildStatCard('Pending', '${_dashboardData?['pending_approvals'] ?? 0}', Icons.pending, Colors.orange),
          SizedBox(width: 12),
          _buildStatCard('Revenue', '₹${_dashboardData?['total_revenue'] ?? 0}', Icons.money, Colors.purple),
        ],
      ),
    ];
  }

  List<Widget> _buildCitizenSummary() {
    final summary = _dashboardData?['summary'] ?? {};
    return [
      Row(
        children: [
          _buildStatCard('Applications', '${summary['total_applications'] ?? 0}', Icons.description, Colors.blue),
          SizedBox(width: 12),
          _buildStatCard('Pending', '${summary['pending_applications'] ?? 0}', Icons.pending, Colors.orange),
        ],
      ),
      SizedBox(height: 12),
      Row(
        children: [
          _buildStatCard('Approved', '${summary['approved_applications'] ?? 0}', Icons.check_circle, Colors.green),
          SizedBox(width: 12),
          _buildStatCard('Dues', '₹${summary['pending_dues'] ?? 0}', Icons.money_off, Colors.red),
        ],
      ),
    ];
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(title, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoticesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Latest Notices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NoticesListScreen())),
              child: Text('View All'),
            ),
          ],
        ),
        // Notices will be loaded from API
        _buildNoticeCard('Water Supply Disruption', 'high', 'May 20, 2026'),
        _buildNoticeCard('Property Tax Deadline', 'medium', 'May 25, 2026'),
      ],
    );
  }

  Widget _buildNoticeCard(String title, String priority, String date) {
    Color priorityColor = priority == 'urgent' ? Colors.red
        : priority == 'high' ? Colors.orange
        : priority == 'medium' ? Colors.blue
        : Colors.grey;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: priorityColor,
          child: Icon(Icons.notification_important, color: Colors.white),
        ),
        title: Text(title),
        subtitle: Text(date),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _buildAdvertisementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Advertisements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Container(
          height: 150,
          child: FutureBuilder<Map<String, dynamic>>(
            future: _api.getActiveAds(limit: 5),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
              
              final ads = snapshot.data!['data'] as List? ?? [];
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ads.length,
                itemBuilder: (context, index) {
                  final ad = ads[index];
                  return _buildAdCard(ad);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdCard(Map<String, dynamic> ad) {
    return GestureDetector(
      onTap: () => _api.recordAdClick(ad['id']),
      child: Container(
        width: 250,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: ad['image_url'] != null
              ? DecorationImage(
                  image: NetworkImage(ad['image_url']),
                  fit: BoxFit.cover,
                )
              : null,
          color: Colors.grey[300],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
          padding: EdgeInsets.all(12),
          alignment: Alignment.bottomLeft,
          child: Text(
            ad['title'] ?? ad['advertiser_name'] ?? 'Advertisement',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
```

### 3. Admin Advertisement Management Screen

```dart
class AdminAdvertisementsScreen extends StatefulWidget {
  @override
  _AdminAdvertisementsScreenState createState() => _AdminAdvertisementsScreenState();
}

class _AdminAdvertisementsScreenState extends State<AdminAdvertisementsScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _advertisements = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _lastPage = 1;

  @override
  void initState() {
    super.initState();
    _loadAdvertisements();
  }

  Future<void> _loadAdvertisements({int page = 1}) async {
    try {
      setState(() => _isLoading = true);
      final response = await _api.getAdvertisements(page: page, perPage: 15);
      final data = response['data'];
      
      setState(() {
        _advertisements = data['data'] ?? [];
        _currentPage = data['current_page'] ?? 1;
        _lastPage = data['last_page'] ?? 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e);
    }
  }

  Future<void> _deleteAd(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Advertisement'),
        content: Text('Are you sure you want to delete this advertisement?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _api.deleteAdvertisement(id);
        _loadAdvertisements(page: _currentPage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Advertisement deleted'), backgroundColor: Colors.green),
        );
      } catch (e) {
        _showError(e);
      }
    }
  }

  Future<void> _publishAd(int id) async {
    try {
      await _api.publishAdvertisement(id);
      _loadAdvertisements(page: _currentPage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Advertisement published'), backgroundColor: Colors.green),
      );
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _pauseAd(int id) async {
    try {
      await _api.pauseAdvertisement(id);
      _loadAdvertisements(page: _currentPage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Advertisement paused'), backgroundColor: Colors.orange),
      );
    } catch (e) {
      _showError(e);
    }
  }

  void _showError(dynamic e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Advertisements'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateAdvertisementScreen()),
              );
              _loadAdvertisements();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadAdvertisements(page: _currentPage),
              child: ListView.builder(
                itemCount: _advertisements.length,
                itemBuilder: (context, index) {
                  final ad = _advertisements[index];
                  return _buildAdListItem(ad);
                },
              ),
            ),
      bottomNavigationBar: _lastPage > 1
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: _currentPage > 1
                        ? () => _loadAdvertisements(page: _currentPage - 1)
                        : null,
                  ),
                  Text('Page $_currentPage of $_lastPage'),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: _currentPage < _lastPage
                        ? () => _loadAdvertisements(page: _currentPage + 1)
                        : null,
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildAdListItem(Map<String, dynamic> ad) {
    Color statusColor;
    switch (ad['status']) {
      case 'active': statusColor = Colors.green; break;
      case 'draft': statusColor = Colors.grey; break;
      case 'paused': statusColor = Colors.orange; break;
      case 'rejected': statusColor = Colors.red; break;
      default: statusColor = Colors.blue;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad['title'] ?? ad['advertiser_name'] ?? 'Untitled',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'By: ${ad['advertiser_name'] ?? 'Unknown'}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    (ad['status'] ?? 'unknown').toString().toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.visibility, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('${ad['click_count'] ?? 0} clicks'),
                SizedBox(width: 16),
                Icon(Icons.money, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('₹${ad['amount_paid'] ?? 0}'),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (ad['status'] == 'draft' || ad['status'] == 'paused')
                  TextButton.icon(
                    icon: Icon(Icons.publish, color: Colors.green),
                    label: Text('Publish'),
                    onPressed: () => _publishAd(ad['id']),
                  ),
                if (ad['status'] == 'active')
                  TextButton.icon(
                    icon: Icon(Icons.pause, color: Colors.orange),
                    label: Text('Pause'),
                    onPressed: () => _pauseAd(ad['id']),
                  ),
                TextButton.icon(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  label: Text('Edit'),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditAdvertisementScreen(adId: ad['id']),
                      ),
                    );
                    _loadAdvertisements(page: _currentPage);
                  },
                ),
                TextButton.icon(
                  icon: Icon(Icons.delete, color: Colors.red),
                  label: Text('Delete'),
                  onPressed: () => _deleteAd(ad['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4. Create Advertisement Screen (Admin)

```dart
class CreateAdvertisementScreen extends StatefulWidget {
  @override
  _CreateAdvertisementScreenState createState() => _CreateAdvertisementScreenState();
}

class _CreateAdvertisementScreenState extends State<CreateAdvertisementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  bool _isSubmitting = false;

  final _advertiserNameController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _websiteUrlController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _redirectUrlController = TextEditingController();
  final _amountPaidController = TextEditingController();
  final _remarksController = TextEditingController();

  String _advertiserType = 'business';
  String _position = 'home_banner';
  String _status = 'draft';
  DateTime? _startDate;
  DateTime? _endDate;
  int _priority = 0;

  final List<String> _advertiserTypes = ['business', 'government', 'ngo', 'individual', 'other'];
  final List<String> _positions = ['home_banner', 'sidebar', 'footer', 'popup', 'inline'];
  final List<String> _statuses = ['draft', 'active'];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final data = {
        'advertiser_name': _advertiserNameController.text,
        'advertiser_type': _advertiserType,
        'title': _titleController.text.isNotEmpty ? _titleController.text : null,
        'description': _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        'contact_person': _contactPersonController.text.isNotEmpty ? _contactPersonController.text : null,
        'contact_phone': _contactPhoneController.text.isNotEmpty ? _contactPhoneController.text : null,
        'contact_email': _contactEmailController.text.isNotEmpty ? _contactEmailController.text : null,
        'website_url': _websiteUrlController.text.isNotEmpty ? _websiteUrlController.text : null,
        'image_url': _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
        'redirect_url': _redirectUrlController.text.isNotEmpty ? _redirectUrlController.text : null,
        'position': _position,
        'status': _status,
        'start_date': _startDate?.toIso8601String().split('T')[0],
        'end_date': _endDate?.toIso8601String().split('T')[0],
        'amount_paid': _amountPaidController.text.isNotEmpty ? double.tryParse(_amountPaidController.text) : null,
        'priority': _priority,
        'admin_remarks': _remarksController.text.isNotEmpty ? _remarksController.text : null,
      };

      // Remove null values
      data.removeWhere((key, value) => value == null);

      await _api.createAdvertisement(data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Advertisement created successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Advertisement')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _advertiserNameController,
                decoration: InputDecoration(labelText: 'Advertiser Name *', border: OutlineInputBorder()),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _advertiserType,
                decoration: InputDecoration(labelText: 'Advertiser Type *', border: OutlineInputBorder()),
                items: _advertiserTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _advertiserType = v!),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _contactPersonController,
                decoration: InputDecoration(labelText: 'Contact Person', border: OutlineInputBorder()),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _contactPhoneController,
                decoration: InputDecoration(labelText: 'Contact Phone', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _contactEmailController,
                decoration: InputDecoration(labelText: 'Contact Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL', border: OutlineInputBorder()),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _redirectUrlController,
                decoration: InputDecoration(labelText: 'Redirect URL', border: OutlineInputBorder()),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _position,
                      decoration: InputDecoration(labelText: 'Position', border: OutlineInputBorder()),
                      items: _positions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (v) => setState(() => _position = v!),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      decoration: InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                      items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _status = v!),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(_startDate != null ? 'Start: ${_startDate!.toString().split(' ')[0]}' : 'Start Date'),
                      leading: Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) setState(() => _startDate = date);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text(_endDate != null ? 'End: ${_endDate!.toString().split(' ')[0]}' : 'End Date'),
                      leading: Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: _startDate ?? DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) setState(() => _endDate = date);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _amountPaidController,
                decoration: InputDecoration(labelText: 'Amount Paid', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _remarksController,
                decoration: InputDecoration(labelText: 'Admin Remarks', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Create Advertisement', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 5. Admin Notice Management Screen

```dart
class AdminNoticesScreen extends StatefulWidget {
  @override
  _AdminNoticesScreenState createState() => _AdminNoticesScreenState();
}

class _AdminNoticesScreenState extends State<AdminNoticesScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _notices = [];
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      final noticesResponse = await _api.getNotices(perPage: 50);
      final statsResponse = await _api.getNoticeStats();
      
      setState(() {
        _notices = noticesResponse['data']['data'] ?? [];
        _stats = statsResponse['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e);
    }
  }

  Future<void> _deleteNotice(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Notice'),
        content: Text('Are you sure you want to delete this notice?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _api.deleteNotice(id);
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notice deleted'), backgroundColor: Colors.green),
        );
      } catch (e) {
        _showError(e);
      }
    }
  }

  Future<void> _publishNotice(int id) async {
    try {
      await _api.publishNotice(id);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notice published'), backgroundColor: Colors.green),
      );
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _archiveNotice(int id) async {
    try {
      await _api.archiveNotice(id);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notice archived'), backgroundColor: Colors.orange),
      );
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _togglePin(int id) async {
    try {
      await _api.togglePinNotice(id);
      _loadData();
    } catch (e) {
      _showError(e);
    }
  }

  void _showError(dynamic e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Notices'),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () => _showStatsDialog(),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateNoticeScreen()),
              );
              _loadData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                itemCount: _notices.length,
                itemBuilder: (context, index) {
                  final notice = _notices[index];
                  return _buildNoticeListItem(notice);
                },
              ),
            ),
    );
  }

  Widget _buildNoticeListItem(Map<String, dynamic> notice) {
    Color priorityColor;
    switch (notice['priority']) {
      case 'urgent': priorityColor = Colors.red; break;
      case 'high': priorityColor = Colors.orange; break;
      case 'medium': priorityColor = Colors.blue; break;
      default: priorityColor = Colors.grey;
    }

    Color statusColor;
    switch (notice['status']) {
      case 'published': statusColor = Colors.green; break;
      case 'draft': statusColor = Colors.grey; break;
      case 'archived': statusColor = Colors.brown; break;
      default: statusColor = Colors.blue;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (notice['is_pinned'] == true)
                  Icon(Icons.push_pin, color: Colors.red, size: 18),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    notice['title'] ?? 'Untitled',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: priorityColor),
                  ),
                  child: Text(
                    (notice['priority'] ?? 'low').toString().toUpperCase(),
                    style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    (notice['status'] ?? 'draft').toString().toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              notice['content'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.category, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text('${notice['type'] ?? 'notice'}', style: TextStyle(fontSize: 12)),
                SizedBox(width: 12),
                Icon(Icons.people, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text('${notice['target_audience'] ?? 'all'}', style: TextStyle(fontSize: 12)),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                if (notice['status'] == 'draft')
                  ActionChip(
                    avatar: Icon(Icons.publish, size: 16, color: Colors.green),
                    label: Text('Publish'),
                    onPressed: () => _publishNotice(notice['id']),
                  ),
                if (notice['status'] == 'published')
                  ActionChip(
                    avatar: Icon(Icons.archive, size: 16, color: Colors.orange),
                    label: Text('Archive'),
                    onPressed: () => _archiveNotice(notice['id']),
                  ),
                ActionChip(
                  avatar: Icon(
                    notice['is_pinned'] == true ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 16,
                    color: notice['is_pinned'] == true ? Colors.red : Colors.grey,
                  ),
                  label: Text(notice['is_pinned'] == true ? 'Unpin' : 'Pin'),
                  onPressed: () => _togglePin(notice['id']),
                ),
                ActionChip(
                  avatar: Icon(Icons.edit, size: 16, color: Colors.blue),
                  label: Text('Edit'),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditNoticeScreen(noticeId: notice['id']),
                      ),
                    );
                    _loadData();
                  },
                ),
                ActionChip(
                  avatar: Icon(Icons.delete, size: 16, color: Colors.red),
                  label: Text('Delete'),
                  onPressed: () => _deleteNotice(notice['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Notice Statistics'),
        content: _stats == null
            ? Text('No data')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatRow('Total', '${_stats!['total'] ?? 0}'),
                  _buildStatRow('Published', '${_stats!['published'] ?? 0}'),
                  _buildStatRow('Draft', '${_stats!['draft'] ?? 0}'),
                  _buildStatRow('Archived', '${_stats!['archived'] ?? 0}'),
                  Divider(),
                  _buildStatRow('Notices', '${_stats!['notices'] ?? 0}'),
                  _buildStatRow('Announcements', '${_stats!['announcements'] ?? 0}'),
                  _buildStatRow('Pinned', '${_stats!['pinned'] ?? 0}'),
                ],
              ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close')),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
```

### 6. Citizen Notices List Screen

```dart
class NoticesListScreen extends StatefulWidget {
  @override
  _NoticesListScreenState createState() => _NoticesListScreenState();
}

class _NoticesListScreenState extends State<NoticesListScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _notices = [];
  bool _isLoading = true;
  String? _filterType;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices({String? type}) async {
    try {
      setState(() => _isLoading = true);
      final response = await _api.getActiveNotices(type: type, limit: 50);
      setState(() {
        _notices = response['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading notices: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notices & Announcements'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _filterType = value == 'all' ? null : value);
              _loadNotices(type: _filterType);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'all', child: Text('All')),
              PopupMenuItem(value: 'notice', child: Text('Notices')),
              PopupMenuItem(value: 'announcement', child: Text('Announcements')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _notices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No notices available', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadNotices(type: _filterType),
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _notices.length,
                    itemBuilder: (context, index) {
                      final notice = _notices[index];
                      return _buildNoticeCard(notice);
                    },
                  ),
                ),
    );
  }

  Widget _buildNoticeCard(Map<String, dynamic> notice) {
    Color priorityColor;
    switch (notice['priority']) {
      case 'urgent': priorityColor = Colors.red; break;
      case 'high': priorityColor = Colors.orange; break;
      case 'medium': priorityColor = Colors.blue; break;
      default: priorityColor = Colors.grey;
    }

    IconData typeIcon = notice['type'] == 'announcement'
        ? Icons.campaign
        : Icons.notification_important;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: notice['is_pinned'] == true ? 4 : 1,
      child: InkWell(
        onTap: () => _showNoticeDetail(notice),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (notice['is_pinned'] == true)
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.push_pin, color: Colors.red, size: 16),
                    ),
                  CircleAvatar(
                    backgroundColor: priorityColor.withOpacity(0.1),
                    child: Icon(typeIcon, color: priorityColor, size: 20),
                    radius: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notice['title'] ?? 'Untitled',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                (notice['priority'] ?? 'low').toString().toUpperCase(),
                                style: TextStyle(fontSize: 10, color: priorityColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              notice['type'] ?? 'notice',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                notice['content'] ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              if (notice['publish_date'] != null) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Published: ${notice['publish_date']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (notice['expiry_date'] != null) ...[
                      SizedBox(width: 16),
                      Icon(Icons.event_busy, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        'Expires: ${notice['expiry_date']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showNoticeDetail(Map<String, dynamic> notice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                notice['title'] ?? 'Untitled',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text(notice['type'] ?? 'notice'),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  ),
                  SizedBox(width: 8),
                  Chip(
                    label: Text((notice['priority'] ?? 'low').toString().toUpperCase()),
                    backgroundColor: _getPriorityColor(notice['priority']).withOpacity(0.1),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                notice['content'] ?? '',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              if (notice['attachment_url'] != null) ...[
                SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.attachment),
                  label: Text('View Attachment'),
                  onPressed: () {
                    // Open attachment URL
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'urgent': return Colors.red;
      case 'high': return Colors.orange;
      case 'medium': return Colors.blue;
      default: return Colors.grey;
    }
  }
}
```

### 7. App Navigation (Role-Based)

```dart
class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    
    return MaterialApp(
      title: 'Tura Municipal Board',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: api.isAdmin ? AdminHomeScreen() : CitizenHomeScreen(),
    );
  }
}

class CitizenHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DashboardScreen(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notices'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (_) => NoticesListScreen()));
              break;
          }
        },
      ),
    );
  }
}

class AdminHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, size: 32),
                    radius: 30,
                  ),
                  SizedBox(height: 10),
                  Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DashboardScreen())),
            ),
            ListTile(
              leading: Icon(Icons.campaign),
              title: Text('Advertisements'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminAdvertisementsScreen())),
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notices'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminNoticesScreen())),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Clear token and navigate to login
              },
            ),
          ],
        ),
      ),
      body: DashboardScreen(),
    );
  }
}
```

### 8. Error Handling Model

```dart
class ApiResponse<T> {
  final String status;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.status,
    this.data,
    this.message,
    this.errors,
  });

  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromData) {
    return ApiResponse(
      status: json['status'] ?? 'error',
      data: json['data'] != null && fromData != null ? fromData(json['data']) : json['data'],
      message: json['message'],
      errors: json['errors'],
    );
  }
}
```

---

## Summary: Complete API Endpoint Reference

### Dashboard
| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| GET | `/api/dashboard/citizen` | Citizen | Citizen dashboard data |
| GET | `/api/dashboard/admin` | Admin/CEO/Editor | Admin dashboard with metrics |
| GET | `/api/dashboard/payment-dues` | Any | Payment dues list |
| GET | `/api/dashboard/payment-history` | Any | Payment history |

### Advertisements - Citizen
| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| GET | `/api/ads` | Any | Get active ads |
| POST | `/api/ads/{id}/click` | Any | Record ad click |

### Advertisements - Admin
| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| POST | `/api/advertisements` | Admin/CEO/Editor | Create ad |
| GET | `/api/advertisements` | Admin/CEO/Editor | List all ads (paginated) |
| GET | `/api/advertisements/{id}` | Admin/CEO/Editor | Get ad details |
| PUT | `/api/advertisements/{id}` | Admin/CEO/Editor | Update ad |
| DELETE | `/api/advertisements/{id}` | Admin/CEO/Editor | Delete ad |
| POST | `/api/advertisements/{id}/publish` | Admin/CEO/Editor | Publish ad |
| POST | `/api/advertisements/{id}/pause` | Admin/CEO/Editor | Pause ad |
| POST | `/api/advertisements/{id}/reject` | Admin/CEO/Editor | Reject ad |
| GET | `/api/advertisements/stats/overview` | Admin/CEO/Editor | Ad statistics |

### Notices - Citizen
| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| GET | `/api/feed/notices` | Any | Get active notices |

### Notices - Admin
| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| POST | `/api/notices` | Admin/CEO/Employee/Editor | Create notice |
| GET | `/api/notices` | Admin/CEO/Employee/Editor | List all notices |
| GET | `/api/notices/{id}` | Admin/CEO/Employee/Editor | Get notice details |
| PUT | `/api/notices/{id}` | Admin/CEO/Employee/Editor | Update notice |
| DELETE | `/api/notices/{id}` | Admin/CEO/Employee/Editor | Delete notice |
| POST | `/api/notices/{id}/publish` | Admin/CEO/Employee/Editor | Publish notice |
| POST | `/api/notices/{id}/archive` | Admin/CEO/Employee/Editor | Archive notice |
| POST | `/api/notices/{id}/toggle-pin` | Admin/CEO/Employee/Editor | Toggle pin |
| GET | `/api/notices/stats/overview` | Admin/CEO/Employee/Editor | Notice statistics |

### Admin Payment History
| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| GET | `/api/dashboard/admin/payment-history` | Admin/CEO | Get all payment history with filters |

**Query Parameters for Admin Payment History:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string | No | Filter by status: `paid` or `failed` |
| `form_type` | string | No | Filter by form type: `Advertisement`, `Notice`, `Job Application`, `Grievance` |
| `per_page` | integer | No | Results per page (default: 15) |

---

*Generated for Tura Municipal Board Flutter App Integration*
*API Base URL: https://laravelv2.turamunicipalboard.com/api*