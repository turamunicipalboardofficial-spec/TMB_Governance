# Payment History & Grievance API Documentation

## Table of Contents
1. [Payment History APIs](#1-payment-history-apis)
   - [1.1 Citizen Payment History](#11-citizen-payment-history)
   - [1.2 Citizen Payment Dues](#12-citizen-payment-dues)
   - [1.3 Admin Payment History](#13-admin-payment-history)
2. [Grievance APIs](#2-grievance-apis)
   - [2.1 Submit Grievance](#21-submit-grievance)
   - [2.2 My Grievances](#22-my-grievances)
   - [2.3 Grievance Details](#23-grievance-details)
   - [2.4 Grievance Categories](#24-grievance-categories)
   - [2.5 Admin: All Grievances](#25-admin-all-grievances)
   - [2.6 Admin: Update Grievance Status](#26-admin-update-grievance-status)
3. [Database Schema](#3-database-schema)
4. [Flutter Integration Guide](#4-flutter-integration-guide)

**Base URL:** `https://laravelv2.turamunicipalboard.com`

---

## 1. Payment History APIs

**Controller:** `App\Http\Controllers\DashboardController`
**Service:** `App\Http\Controllers\DashboardService`

All payment history endpoints require **JWT authentication**.

### Authentication Header

```
Authorization: Bearer {jwt_token}
```

---

### 1.1 Citizen Payment History

Returns complete payment history for the authenticated citizen.

| Property | Value |
|----------|-------|
| **Route** | `GET /api/dashboard/payment-history` |
| **Method** | `DashboardController@paymentHistory` |
| **Authentication** | JWT Required |
| **Description** | Get complete payment history for the authenticated user |

#### Request

```http
GET /api/dashboard/payment-history
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

#### Response - Success (200)

```json
{
    "status": "success",
    "data": {
        "payments": [
            {
                "id": 1,
                "form_id": 12345,
                "order_id": "1234567890",
                "amount": 5000.00,
                "form_type_id": 5,
                "form_type_name": "Trade License (New)",
                "status": "success",
                "created_at": "2026-05-15T10:30:00.000000Z"
            },
            {
                "id": 2,
                "form_id": 67890,
                "order_id": "6789012345",
                "amount": 250.00,
                "form_type_id": 0,
                "form_type_name": "Pet Dog Registration",
                "status": "success",
                "created_at": "2026-05-10T14:20:00.000000Z"
            }
        ],
        "total_payments": 2,
        "total_amount": 5250.00
    }
}
```

#### Response - Unauthorized (401)

```json
{
    "status": "error",
    "message": "Unauthorized. Please login first."
}
```

#### Response - Server Error (500)

```json
{
    "status": "error",
    "message": "Failed to load payment history"
}
```

---

### 1.2 Citizen Payment Dues

Returns all unpaid/pending payment dues for the authenticated citizen.

| Property | Value |
|----------|-------|
| **Route** | `GET /api/dashboard/payment-dues` |
| **Method** | `DashboardController@paymentDues` |
| **Authentication** | JWT Required |
| **Description** | Get outstanding payment dues for the authenticated user |

#### Request

```http
GET /api/dashboard/payment-dues
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

#### Response - Success (200)

```json
{
    "status": "success",
    "data": {
        "dues": [
            {
                "id": 10,
                "form_id": 11111,
                "amount": 250.00,
                "form_type_id": 0,
                "form_type_name": "Pet Dog Registration",
                "status": "pending",
                "created_at": "2026-05-18T09:00:00.000000Z"
            }
        ],
        "total_dues": 1,
        "total_pending_amount": 250.00
    }
}
```

#### Response - Unauthorized (401)

```json
{
    "status": "error",
    "message": "Unauthorized. Please login first."
}
```

#### Response - Not Found (404)

```json
{
    "status": "error",
    "message": "No pending dues found"
}
```

#### Response - Server Error (500)

```json
{
    "status": "error",
    "message": "Failed to load payment dues"
}
```

---

### 1.3 Admin Payment History

Returns all payment history across the system with optional filters. Requires admin/ceo/editor role.

| Property | Value |
|----------|-------|
| **Route** | `GET /api/dashboard/admin/payment-history` |
| **Method** | `DashboardController@adminPaymentHistory` |
| **Authentication** | JWT Required (Admin/CEO/Editor role) |
| **Description** | Get comprehensive payment history with filters |

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string | No | Filter by payment status: `paid`, `failed`, `pending` |
| `form_type` | string | No | Filter by form type ID or name |
| `search` | string | No | Search by application ID, order ID, or name |
| `per_page` | integer | No | Results per page (default: 15) |

#### Request

```http
GET /api/dashboard/admin/payment-history?status=paid&form_type=5&per_page=20
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

#### Response - Success (200)

```json
{
    "status": "success",
    "data": {
        "payments": [
            {
                "id": 1,
                "form_id": 12345,
                "order_id": "1234567890",
                "amount": 5000.00,
                "form_type_id": 5,
                "form_type_name": "Trade License (New)",
                "status": "success",
                "transaction_id": "TXN123456",
                "user_name": "John Doe",
                "created_at": "2026-05-15T10:30:00.000000Z"
            }
        ],
        "total_payments": 1,
        "total_amount": 5000.00,
        "current_page": 1,
        "last_page": 1,
        "per_page": 20
    }
}
```

#### Response - Unauthorized (401)

```json
{
    "status": "error",
    "message": "Unauthorized. Please login first."
}
```

#### Response - Forbidden (403)

```json
{
    "status": "error",
    "message": "Access denied. Admin privileges required."
}
```

#### Response - Server Error (500)

```json
{
    "status": "error",
    "message": "Failed to load payment history"
}
```

---

### Payment History Form Types Reference

| form_type_id | Form Type Name |
|--------------|----------------|
| 0 | Pet Dog Registration |
| 5 | Trade License (New) |
| 6 | Cesspool Tanker |
| 7 | Trade License (Renewal) |
| 8 | Water Tanker |
| 10 | Banner / Hoarding / Poster |

---

## 2. Grievance APIs

**Controller:** `App\Http\Controllers\GrievanceController`
**Service:** `App\Services\GrievanceService`

### 2.1 Submit Grievance

Submit a new grievance complaint. Optionally authenticated — if JWT is provided, the grievance is linked to the user.

| Property | Value |
|----------|-------|
| **Route** | `POST /api/grievances/submit` |
| **Method** | `GrievanceController@submit` |
| **Authentication** | Optional (JWT recommended) |
| **Content-Type** | `multipart/form-data` |
| **Description** | Submit a new grievance complaint |

#### Request Body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | **Yes** | Complainant name (max 255 chars) |
| `email` | string | No | Complainant email (max 255 chars) |
| `phone` | string | **Yes** | Complainant phone number (max 20 chars) |
| `ward_id` | string | No | Ward ID (max 50 chars) |
| `locality` | string | No | Locality name (max 255 chars) |
| `category` | string | **Yes** | Grievance category (see categories below) |
| `subject` | string | **Yes** | Grievance subject/title (max 500 chars) |
| `description` | string | **Yes** | Detailed description of the grievance |
| `attachment` | file | No | File attachment (max 5MB: jpg, jpeg, png, gif, pdf, doc, docx) |

#### Request Example (multipart/form-data)

```
POST /api/grievances/submit
Content-Type: multipart/form-data

name: John Doe
email: john@example.com
phone: +91-9876543210
ward_id: 5
locality: Ward 5, Main Road
category: Water Supply
subject: No water supply for 3 days
description: Our area has not received water supply for the past 3 days. Multiple complaints to local office have gone unanswered.
attachment: [file]
```

#### Response - Success (201)

```json
{
    "status": true,
    "message": "Grievance submitted successfully",
    "data": {
        "grievance_id": "GRV-20260519-0001",
        "name": "John Doe",
        "phone": "+91-9876543210",
        "category": "Water Supply",
        "subject": "No water supply for 3 days",
        "status": "pending",
        "created_at": "2026-05-19T10:00:00.000000Z"
    }
}
```

#### Response - Validation Error (422)

```json
{
    "status": false,
    "message": "Validation errors",
    "data": null,
    "errors": {
        "name": ["The name field is required."],
        "phone": ["The phone field is required."],
        "category": ["The category field is required."],
        "subject": ["The subject field is required."],
        "description": ["The description field is required."]
    }
}
```

#### Response - Server Error (500)

```json
{
    "status": false,
    "message": "Failed to submit grievance",
    "data": null
}
```

---

### 2.2 My Grievances

Get all grievances submitted by the authenticated citizen, with optional status filter and pagination.

| Property | Value |
|----------|-------|
| **Route** | `POST /api/grievances/my` |
| **Method** | `GrievanceController@myGrievances` |
| **Authentication** | JWT Required |
| **Description** | List all grievances for the authenticated citizen |

#### Request Body (JSON)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string | No | Filter by status: `pending`, `in_progress`, `resolved`, `rejected` |
| `per_page` | integer | No | Results per page (default: 10) |

#### Request Example

```http
POST /api/grievances/my
Content-Type: application/json
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...

{
    "status": "pending",
    "per_page": 10
}
```

#### Response - Success (200)

```json
{
    "status": true,
    "message": "Grievances fetched successfully",
    "data": {
        "current_page": 1,
        "data": [
            {
                "id": 1,
                "grievance_id": "GRV-20260519-0001",
                "name": "John Doe",
                "category": "Water Supply",
                "subject": "No water supply for 3 days",
                "status": "pending",
                "created_at": "2026-05-19T10:00:00.000000Z"
            },
            {
                "id": 2,
                "grievance_id": "GRV-20260518-0003",
                "name": "John Doe",
                "category": "Roads",
                "subject": "Pothole on main road",
                "status": "in_progress",
                "created_at": "2026-05-18T08:30:00.000000Z"
            }
        ],
        "total": 2,
        "per_page": 10,
        "last_page": 1
    }
}
```

#### Response - Unauthorized (401)

```json
{
    "status": false,
    "message": "Authentication required",
    "data": null
}
```

#### Response - Server Error (500)

```json
{
    "status": false,
    "message": "Failed to fetch grievances",
    "data": null
}
```

---

### 2.3 Grievance Details

Get detailed information about a specific grievance by its grievance ID.

| Property | Value |
|----------|-------|
| **Route** | `POST /api/grievances/details` |
| **Method** | `GrievanceController@details` |
| **Authentication** | Optional (JWT recommended) |
| **Description** | Get detailed information about a specific grievance |

#### Request Body (JSON)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `grievance_id` | string | **Yes** | Grievance ID (e.g., `GRV-20260519-0001`) |

#### Request Example

```http
POST /api/grievances/details
Content-Type: application/json
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...

{
    "grievance_id": "GRV-20260519-0001"
}
```

#### Response - Success (200)

```json
{
    "status": true,
    "message": "Grievance details fetched successfully",
    "data": {
        "id": 1,
        "grievance_id": "GRV-20260519-0001",
        "user_id": 42,
        "name": "John Doe",
        "email": "john@example.com",
        "phone": "+91-9876543210",
        "ward_id": "5",
        "locality": "Ward 5, Main Road",
        "category": "Water Supply",
        "subject": "No water supply for 3 days",
        "description": "Our area has not received water supply for the past 3 days. Multiple complaints to local office have gone unanswered.",
        "attachment_path": "grievances/abc123.pdf",
        "status": "in_progress",
        "admin_remarks": "Complaint forwarded to Water Supply Department.",
        "resolved_by": null,
        "resolved_at": null,
        "created_at": "2026-05-19T10:00:00.000000Z",
        "updated_at": "2026-05-19T15:30:00.000000Z"
    }
}
```

#### Response - Validation Error (422)

```json
{
    "status": false,
    "message": "Validation errors",
    "data": null,
    "errors": {
        "grievance_id": ["The grievance_id field is required."]
    }
}
```

#### Response - Not Found (404)

```json
{
    "status": false,
    "message": "Grievance not found",
    "data": null
}
```

---

### 2.4 Grievance Categories

Get the list of available grievance categories.

| Property | Value |
|----------|-------|
| **Route** | `GET /api/grievances/categories` |
| **Method** | `GrievanceController@categories` |
| **Authentication** | Not required |
| **Description** | Get list of available grievance categories |

#### Request

```http
GET /api/grievances/categories
```

#### Response - Success (200)

```json
{
    "status": true,
    "message": "Categories fetched successfully",
    "data": [
        "Water Supply",
        "Roads",
        "Sanitation",
        "Electricity",
        "Drainage",
        "Other"
    ]
}
```

---

### 2.5 Admin: All Grievances

Admin endpoint to get all grievances with filters. Requires admin/ceo/editor role.

| Property | Value |
|----------|-------|
| **Route** | `POST /api/grievances/admin/all` |
| **Method** | `GrievanceController@adminAll` |
| **Authentication** | JWT Required (Admin/CEO/Editor role) |
| **Description** | Get all grievances with optional filters |

#### Request Body (JSON)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string | No | Filter by status: `pending`, `in_progress`, `resolved`, `rejected` |
| `category` | string | No | Filter by category name |
| `search` | string | No | Search by grievance ID, name, phone, or subject |
| `per_page` | integer | No | Results per page (default: 15) |

#### Request Example

```http
POST /api/grievances/admin/all
Content-Type: application/json
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...

{
    "status": "pending",
    "category": "Water Supply",
    "search": "GRV-20260519",
    "per_page": 15
}
```

#### Response - Success (200)

```json
{
    "status": true,
    "message": "All grievances fetched successfully",
    "data": {
        "current_page": 1,
        "data": [
            {
                "id": 1,
                "grievance_id": "GRV-20260519-0001",
                "name": "John Doe",
                "phone": "+91-9876543210",
                "email": "john@example.com",
                "ward_id": "5",
                "locality": "Ward 5, Main Road",
                "category": "Water Supply",
                "subject": "No water supply for 3 days",
                "description": "Our area has not received water supply for the past 3 days.",
                "status": "pending",
                "admin_remarks": null,
                "resolved_by": null,
                "resolved_at": null,
                "created_at": "2026-05-19T10:00:00.000000Z",
                "updated_at": "2026-05-19T10:00:00.000000Z"
            }
        ],
        "total": 1,
        "per_page": 15,
        "last_page": 1
    }
}
```

#### Response - Unauthorized (401)

```json
{
    "status": "error",
    "message": "Unauthorized. Please login first."
}
```

#### Response - Server Error (500)

```json
{
    "status": false,
    "message": "Failed to fetch grievances",
    "data": null
}
```

---

### 2.6 Admin: Update Grievance Status

Admin endpoint to update the status of a grievance with optional remarks.

| Property | Value |
|----------|-------|
| **Route** | `POST /api/grievances/admin/update-status` |
| **Method** | `GrievanceController@adminUpdateStatus` |
| **Authentication** | JWT Required (Admin/CEO/Editor role) |
| **Description** | Update grievance status with optional admin remarks |

#### Request Body (JSON)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `grievance_id` | string | **Yes** | Grievance ID (must exist in `grievances.grievance_id`) |
| `status` | string | **Yes** | New status: `pending`, `in_progress`, `resolved`, `rejected` |
| `admin_remarks` | string | No | Admin remarks/comments |

#### Request Example

```http
POST /api/grievances/admin/update-status
Content-Type: application/json
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...

{
    "grievance_id": "GRV-20260519-0001",
    "status": "resolved",
    "admin_remarks": "Water supply issue has been resolved. Pipeline repair completed on 2026-05-20."
}
```

#### Response - Success (200)

```json
{
    "status": true,
    "message": "Grievance status updated successfully",
    "data": {
        "id": 1,
        "grievance_id": "GRV-20260519-0001",
        "status": "resolved",
        "admin_remarks": "Water supply issue has been resolved. Pipeline repair completed on 2026-05-20.",
        "resolved_by": "Admin",
        "resolved_at": "2026-05-20T12:00:00.000000Z",
        "updated_at": "2026-05-20T12:00:00.000000Z"
    }
}
```

#### Response - Validation Error (422)

```json
{
    "status": false,
    "message": "Validation errors",
    "data": null,
    "errors": {
        "grievance_id": ["The selected grievance_id is invalid."],
        "status": ["The selected status is invalid."]
    }
}
```

#### Response - Server Error (500)

```json
{
    "status": false,
    "message": "Failed to update grievance status",
    "data": null
}
```

---

### Grievance Status Lifecycle

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   PENDING    │────▶│ IN_PROGRESS  │────▶│  RESOLVED   │
└─────────────┘     └──────────────┘     └─────────────┘
       │
       │
       ▼
┌─────────────┐
│  REJECTED   │
└─────────────┘
```

| Status | Description |
|--------|-------------|
| `pending` | Newly submitted grievance, awaiting review |
| `in_progress` | Grievance is being worked on by the administration |
| `resolved` | Grievance has been resolved |
| `rejected` | Grievance has been rejected by administration |

---

## 3. Database Schema

### 3.1 Payment Details Table (`payment_details`)

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint (PK) | Auto-increment primary key |
| `form_id` | bigint | Application/form ID |
| `payment_id` | string | Order ID used for payment |
| `order_id` | string | Unique order ID |
| `amount` | decimal(10,2) | Payment amount |
| `form_type_id` | integer | Form type (0, 5, 6, 7, 8, 10) |
| `status` | string | `success` / `failed` / `pending` |
| `request_body` | text | Payment gateway request data |
| `response_body` | text | Payment gateway response data |
| `created_at` | timestamp | Record creation time |
| `updated_at` | timestamp | Last update time |

### 3.2 Grievances Table (`grievances`)

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint (PK) | Auto-increment primary key |
| `grievance_id` | string (unique) | Auto-generated grievance ID (`GRV-YYYYMMDD-XXXX`) |
| `user_id` | bigint (nullable) | Citizen user ID (foreign key to `users.id`) |
| `name` | string | Complainant name |
| `email` | string (nullable) | Complainant email |
| `phone` | string | Complainant phone number |
| `ward_id` | string (nullable) | Ward ID |
| `locality` | string (nullable) | Locality name |
| `category` | string | Grievance category |
| `subject` | string | Grievance subject/title |
| `description` | text | Detailed grievance description |
| `attachment_path` | string (nullable) | File attachment storage path |
| `status` | string (default: `pending`) | Current status: `pending`, `in_progress`, `resolved`, `rejected` |
| `admin_remarks` | text (nullable) | Admin response/remarks |
| `resolved_by` | string (nullable) | Name of admin who resolved |
| `resolved_at` | timestamp (nullable) | Resolution timestamp |
| `created_at` | timestamp | Submission time |
| `updated_at` | timestamp | Last update time |

**Indexes:** `user_id`, `grievance_id`, `status`, `category`

---

## 4. Flutter Integration Guide

### 4.1 Get Payment History

```dart
Future<Map<String, dynamic>> getPaymentHistory() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/dashboard/payment-history'),
    headers: {
      'Authorization': 'Bearer $jwtToken',
      'Accept': 'application/json',
    },
  );
  return jsonDecode(response.body);
}
```

### 4.2 Get Payment Dues

```dart
Future<Map<String, dynamic>> getPaymentDues() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/dashboard/payment-dues'),
    headers: {
      'Authorization': 'Bearer $jwtToken',
      'Accept': 'application/json',
    },
  );
  return jsonDecode(response.body);
}
```

### 4.3 Get Admin Payment History

```dart
Future<Map<String, dynamic>> getAdminPaymentHistory({
  String? status,
  String? formType,
  String? search,
  int perPage = 15,
}) async {
  var uri = Uri.parse('$baseUrl/api/dashboard/admin/payment-history').replace(
    queryParameters: {
      if (status != null) 'status': status,
      if (formType != null) 'form_type': formType,
      if (search != null) 'search': search,
      'per_page': perPage.toString(),
    },
  );

  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $jwtToken',
      'Accept': 'application/json',
    },
  );
  return jsonDecode(response.body);
}
```

### 4.4 Submit Grievance

```dart
Future<Map<String, dynamic>> submitGrievance({
  required String name,
  required String phone,
  required String category,
  required String subject,
  required String description,
  String? email,
  String? wardId,
  String? locality,
  File? attachment,
}) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/api/grievances/submit'),
  );

  request.fields['name'] = name;
  request.fields['phone'] = phone;
  request.fields['category'] = category;
  request.fields['subject'] = subject;
  request.fields['description'] = description;
  if (email != null) request.fields['email'] = email;
  if (wardId != null) request.fields['ward_id'] = wardId;
  if (locality != null) request.fields['locality'] = locality;

  if (attachment != null) {
    request.files.add(
      await http.MultipartFile.fromPath('attachment', attachment.path),
    );
  }

  if (jwtToken != null) {
    request.headers['Authorization'] = 'Bearer $jwtToken';
  }

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);
  return jsonDecode(response.body);
}
```

### 4.5 Get My Grievances

```dart
Future<Map<String, dynamic>> getMyGrievances({
  String? status,
  int perPage = 10,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/grievances/my'),
    headers: {
      'Authorization': 'Bearer $jwtToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      if (status != null) 'status': status,
      'per_page': perPage,
    }),
  );
  return jsonDecode(response.body);
}
```

### 4.6 Get Grievance Details

```dart
Future<Map<String, dynamic>> getGrievanceDetails({
  required String grievanceId,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/grievances/details'),
    headers: {
      'Authorization': 'Bearer $jwtToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      'grievance_id': grievanceId,
    }),
  );
  return jsonDecode(response.body);
}
```

### 4.7 Get Grievance Categories

```dart
Future<Map<String, dynamic>> getGrievanceCategories() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/grievances/categories'),
    headers: {
      'Accept': 'application/json',
    },
  );
  return jsonDecode(response.body);
}
```

### 4.8 Admin: Get All Grievances

```dart
Future<Map<String, dynamic>> adminGetAllGrievances({
  String? status,
  String? category,
  String? search,
  int perPage = 15,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/grievances/admin/all'),
    headers: {
      'Authorization': 'Bearer $jwtToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      if (status != null) 'status': status,
      if (category != null) 'category': category,
      if (search != null) 'search': search,
      'per_page': perPage,
    }),
  );
  return jsonDecode(response.body);
}
```

### 4.9 Admin: Update Grievance Status

```dart
Future<Map<String, dynamic>> adminUpdateGrievanceStatus({
  required String grievanceId,
  required String status,
  String? adminRemarks,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/grievances/admin/update-status'),
    headers: {
      'Authorization': 'Bearer $jwtToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      'grievance_id': grievanceId,
      'status': status,
      if (adminRemarks != null) 'admin_remarks': adminRemarks,
    }),
  );
  return jsonDecode(response.body);
}
```

---

## Complete API Endpoints Summary

### Payment History Routes

| Method | Endpoint | Controller | Auth | Description |
|--------|----------|------------|------|-------------|
| GET | `/api/dashboard/payment-history` | `DashboardController@paymentHistory` | JWT (Citizen) | Get user's payment history |
| GET | `/api/dashboard/payment-dues` | `DashboardController@paymentDues` | JWT (Citizen) | Get user's pending payment dues |
| GET | `/api/dashboard/admin/payment-history` | `DashboardController@adminPaymentHistory` | JWT (Admin/CEO/Editor) | Get all payment history with filters |

### Grievance Routes

| Method | Endpoint | Controller | Auth | Description |
|--------|----------|------------|------|-------------|
| POST | `/api/grievances/submit` | `GrievanceController@submit` | Optional JWT | Submit a new grievance |
| POST | `/api/grievances/my` | `GrievanceController@myGrievances` | JWT (Citizen) | List user's grievances |
| POST | `/api/grievances/details` | `GrievanceController@details` | Optional JWT | Get grievance details by ID |
| GET | `/api/grievances/categories` | `GrievanceController@categories` | None | Get available categories |
| POST | `/api/grievances/admin/all` | `GrievanceController@adminAll` | JWT (Admin/CEO/Editor) | Get all grievances with filters |
| POST | `/api/grievances/admin/update-status` | `GrievanceController@adminUpdateStatus` | JWT (Admin/CEO/Editor) | Update grievance status |

---

*Documentation generated on 2026-05-19*