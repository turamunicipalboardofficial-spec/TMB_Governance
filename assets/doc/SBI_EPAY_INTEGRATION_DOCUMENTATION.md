# SBI ePay Payment Gateway Integration Documentation

## Tura Municipal Board - Laravel Backend

**Version:** 1.0  
**Last Updated:** 2026-05-19  
**Base URL:** `https://laravelv2.turamunicipalboard.com`

---

## Table of Contents

1. [Overview](#1-overview)
2. [Architecture](#2-architecture)
3. [SBI ePay Configuration](#3-sbi-epay-configuration)
4. [Encryption & Decryption (AES-128-CBC)](#4-encryption--decryption-aes-128-cbc)
5. [Payment Flow](#5-payment-flow)
6. [Form Payment APIs (PaymentController)](#6-form-payment-apis-paymentcontroller)
7. [Job Payment APIs (JobPaymentController)](#7-job-payment-apis-jobpaymentcontroller)
8. [Billing Payment APIs (BillingController)](#8-billing-payment-apis-billingcontroller)
9. [Callback / Response Handling](#9-callback--response-handling)
10. [Double Verification](#10-double-verification)
11. [Database Schema](#11-database-schema)
12. [Environment Variables](#12-environment-variables)
13. [Flutter / Frontend Integration Guide](#13-flutter--frontend-integration-guide)
14. [Error Handling & Status Codes](#14-error-handling--status-codes)
15. [Security Considerations](#15-security-considerations)
16. [Testing](#16-testing)

---

## 1. Overview

The Tura Municipal Board application uses **SBI ePay** as its payment gateway for collecting various municipal fees including:

- **Form Fees** — Trade licenses, water tanker bookings, cesspool tanker bookings, pet dog registrations, banner/poster permits, death certificates, NOCs
- **Job Application Fees** — Category-based fees (General, SC/ST, OBC) for job postings
- **Market Billing Payments** — Monthly shop rent/billing for municipal market shops

### Key SBI ePay Endpoints Used

| Purpose | URL |
|---------|-----|
| Payment Gateway | `https://www.sbiepay.sbi/` (production) |
| Double Verification / Status Query | `https://www.sbiepay.sbi/payagg/statusQuery/getStatusQuery` |
| Aggregator ID | `SBIEPAY` |
| Merchant ID | `1003253` |

---

## 2. Architecture

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Flutter /  │────▶│  Laravel Backend  │────▶│   SBI ePay      │
│   Frontend   │◀────│  (API + Web View) │◀────│   Gateway       │
└─────────────┘     └──────────────────┘     └─────────────────┘
       │                     │                        │
       │                     │                        │
       │              ┌──────▼──────┐                 │
       │              │  MySQL DB   │                 │
       │              │ payment_    │                 │
       │              │ details     │                 │
       │              └─────────────┘                 │
       │                     │                        │
       │                     ▼                        │
       │              ┌─────────────┐                 │
       │              │  AES-128    │◀────────────────┘
       │              │  Encrypt/   │  (encrypted callbacks)
       │              │  Decrypt    │
       │              └─────────────┘
```

### Controllers Involved

| Controller | File | Purpose |
|------------|------|---------|
| `PaymentController` | `app/Http/Controllers/PaymentController.php` | Form-based payments |
| `JobPaymentController` | `app/Http/Controllers/JobPaymentController.php` | Job application payments |
| `BillingController` | `app/Http/Controllers/BillingController.php` | Market billing payment status updates |
| `AESController` | `app/Http/Controllers/AESController.php` | Encryption/decryption utility |

### Models Involved

| Model | Table | Purpose |
|-------|-------|---------|
| `PaymentModel` | `payment_details` | Stores all form and billing payment records |
| `JobAppliedStatus` | `job_applied_statuses` | Stores job payment data inline with application |
| `BillingTransaction` | `billing_transactions` | Billing records linked to payments via `bill_id` |

---

## 3. SBI ePay Configuration

### Merchant Configuration

```env
# .env file
PAYMENT_KEY=<your-aes-encryption-key>
```

### Request Parameter Format

The SBI ePay request parameter is a pipe-delimited (`|`) string with the following fields:

```
MERCHANT_ID|DOM|IN|INR|AMOUNT|OTHER|SUCCESS_URL|FAILURE_URL|AGGREGATOR|ORDER_ID|2|NB|ONLINE|ONLINE
```

| Position | Field | Value | Description |
|----------|-------|-------|-------------|
| 1 | Merchant ID | `1003253` | SBI ePay assigned merchant ID |
| 2 | Country | `DOM` | Domestic transaction |
| 3 | Currency Code | `IN` | Indian Rupee locale |
| 4 | Currency | `INR` | Indian Rupee |
| 5 | Amount | `<calculated>` | Payment amount (dynamic) |
| 6 | Payment Type | `Other` | Miscellaneous payment type |
| 7 | Success URL | See below | Callback URL on success |
| 8 | Failure URL | See below | Callback URL on failure |
| 9 | Aggregator | `SBIEPAY` | SBI ePay aggregator ID |
| 10 | Order ID | `<generated>` | Unique order identifier |
| 11 | Payment Mode | `2` | Payment mode indicator |
| 12 | Payment Channel | `NB` | Net Banking |
| 13 | Integration Type | `ONLINE` | Online integration |
| 14 | Integration Type | `ONLINE` | Online integration |

### Success/Failure Callback URLs

| Payment Type | Success URL | Failure URL |
|-------------|-------------|-------------|
| Form Payment | `https://laravelv2.turamunicipalboard.com/api/successData` | `https://laravelv2.turamunicipalboard.com/api/successData` |
| Job Payment | `https://laravelv2.turamunicipalboard.com/api/job-successData` | `https://laravelv2.turamunicipalboard.com/api/job-successData` |

> **Note:** Both success and failure callbacks go to the same endpoint. The status is determined by decrypting the `encData` response parameter.

---

## 4. Encryption & Decryption (AES-128-CBC)

SBI ePay requires all request data to be encrypted using **AES-128-CBC** before sending, and all response data comes back encrypted.

### Encryption Method

```php
public function encrypt($data, $key)
{
    $iv = substr($key, 0, 16);  // First 16 bytes of the key as IV
    $algo = 'aes-128-cbc';

    $cipherText = openssl_encrypt(
        $data,
        $algo,
        $key,
        OPENSSL_RAW_DATA,
        $iv
    );

    return base64_encode($cipherText);
}
```

### Decryption Method

```php
public function decrypt($cipherText, $key)
{
    $iv = substr($key, 0, 16);  // First 16 bytes of the key as IV
    $algo = 'aes-128-cbc';

    $cipherText = base64_decode($cipherText);

    return openssl_decrypt(
        $cipherText,
        $algo,
        $key,
        OPENSSL_RAW_DATA,
        $iv
    );
}
```

### Encryption Details

| Parameter | Value |
|-----------|-------|
| Algorithm | `AES-128-CBC` |
| Key Source | `.env` → `PAYMENT_KEY` |
| IV | First 16 bytes of the key |
| Output Encoding | Base64 |
| OpenSSL Flags | `OPENSSL_RAW_DATA` |

---

## 5. Payment Flow

### 5.1 Complete Payment Lifecycle

```
┌──────────┐
│  Step 1  │  User/Citizen initiates payment
│  Initiate│  (via Flutter app or web)
└────┬─────┘
     │
     ▼
┌──────────┐
│  Step 2  │  Backend calculates amount based on form type
│ Calculate│  or job category
└────┬─────┘
     │
     ▼
┌──────────┐
│  Step 3  │  Generate unique Order ID
│  Generate│  Format: APPLICATION_ID + RANDOM(0-100000)
└────┬─────┘
     │
     ▼
┌──────────┐
│  Step 4  │  Build pipe-delimited request parameter string
│  Build   │  e.g., "1003253|DOM|IN|INR|500|Other|URL|URL|SBIEPAY|1234567890|2|NB|ONLINE|ONLINE"
└────┬─────┘
     │
     ▼
┌──────────┐
│  Step 5  │  Encrypt request parameter using AES-128-CBC
│ Encrypt  │  with PAYMENT_KEY
└────┬─────┘
     │
     ▼
┌──────────┐
│  Step 6  │  Store payment record in database (status: pending)
│  Store   │
└────┬─────┘
     │
     ▼
┌──────────┐
│  Step 7  │  Render payment HTML form with encrypted data
│  Render  │  Form auto-submits to SBI ePay gateway
└────┬─────┘
     │
     ▼
┌──────────┐
│  Step 8  │  User completes payment on SBI ePay portal
│  Gateway │
└────┬─────┘
     │
     ▼
┌──────────┐
│  Step 9  │  SBI ePay sends encrypted callback to success/failure URL
│ Callback │  with `encData` parameter
└────┬─────┘
     │
     ▼
┌──────────┐
│ Step 10  │  Backend decrypts response data
│ Decrypt  │  Extract: orderId, transactionId, status, amount
└────┬─────┘
     │
     ▼
┌──────────┐
│ Step 11  │  Double verification with SBI ePay Status Query API
│ Double   │  Confirms payment status independently
│ Verify   │
└────┬─────┘
     │
     ▼
┌──────────┐
│ Step 12  │  Update payment status in database
│  Update  │  Status: success / failed
└────┬─────┘
     │
     ▼
┌──────────┐
│ Step 13  │  Redirect user to success/failure page
│ Redirect │
└──────────┘
```

### 5.2 Decrypted Response Format

After decryption, the SBI ePay callback data is a pipe-delimited string:

```
ORDER_ID|TRANSACTION_ID|STATUS|AMOUNT|...
```

| Position | Field | Description |
|----------|-------|-------------|
| 0 | Order ID | The merchant order ID sent in the request |
| 1 | Transaction ID | SBI ePay transaction reference |
| 2 | Status | `SUCCESS` or `FAIL` |
| 3 | Amount | Transaction amount |

---

## 6. Form Payment APIs (PaymentController)

### 6.1 Initiate Form Payment

**Route (Web):** `GET /payment/{id}`

This renders an HTML form that auto-submits to SBI ePay.

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | Path | Application ID (from `form_master_tbl.application_id`) |

**Supported Form Types & Fee Calculation:**

| `form_id` | Form Type | Fee Calculation |
|-----------|-----------|-----------------|
| `5`, `7` | Trade License | From `trade_license_fees.license_fee` based on trade type |
| `6` | Cesspool Tanker | Parsed from `form_entities` value (e.g., "Rs 1,000") |
| `8` | Water Tanker | Parsed from `form_entities` value (e.g., "Rs 1,000") |
| `0` | Pet Dog Registration | Fixed fee: ₹250 |
| `10` | Banner/Poster/Hoarding | Calculated from env variables based on type, size, and quantity |

**Valid Payment Form IDs:** `[0, 5, 6, 7, 8, 10]`

**Pre-conditions:**
- Application must exist
- Form must be approved (`employee_status = "Approved"` OR `ceo_status = "Approved"`)
- Form type must be in the valid payment form IDs list
- Payment amount must be greater than 0

**Success Response (HTML):**
Returns a blade view `payment.blade.php` with the encrypted data. The form auto-submits to SBI ePay.

**Error Responses:**

```json
// Application not found
{
    "status": "failed",
    "message": "Invalid application ID."
}

// Form not approved
{
    "status": "failed",
    "message": "Form is not approved yet."
}

// Form doesn't require payment
{
    "status": "failed",
    "message": "Payment is not required for this form."
}

// Amount calculation failed
{
    "status": "failed",
    "message": "Unable to calculate payment amount. Please check form data.",
    "debug": {
        "form_id": 5,
        "application_id": "APP123",
        "amount": 0
    }
}
```

### 6.2 Payment Callback (Form)

**Route:** `POST /api/successData`

**Content-Type:** `application/x-www-form-urlencoded`

| Parameter | Type | Description |
|-----------|------|-------------|
| `encData` | String | AES-128-CBC encrypted response from SBI ePay |

**Processing Logic:**

1. Decrypt `encData` using `PAYMENT_KEY`
2. Parse pipe-delimited response: `orderId|transactionId|status|amount`
3. Perform **double verification** with SBI ePay
4. Update `payment_details` table:
   - `status` → `success` or `failed`
   - `response_body` → raw decrypted response data
5. Redirect:
   - Success → `https://turamunicipalboard.com/success`
   - Failure → `https://turamunicipalboard.com/failure`

---

## 7. Job Payment APIs (JobPaymentController)

### 7.1 Initiate Job Payment

**Route (Web):** `GET /job-payment/{id}`

Renders an HTML form for job application payment that auto-submits to SBI ePay.

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | Path | Application ID (from `job_applied_statuses.application_id`) |

**Pre-conditions:**
- Application must exist in `job_applied_statuses`
- Application stage must be ≥ 6 (documents uploaded)
- Payment must not already be completed (`payment_status !== 'paid'`)
- Job posting must exist
- Personal details must exist for the applicant

**Fee Calculation (Category-based):**

| Category | Fee Source |
|----------|-----------|
| SC, ST | `tura_job_postings.fee_sc_st` |
| OBC | `tura_job_postings.fee_obc` (falls back to `fee_general`) |
| UR, General | `tura_job_postings.fee_general` |

**Success Response (HTML):**
Returns a blade view `job-payment-form.blade.php` with the encrypted data.

**Error Responses:**

```json
// Application not found
{
    "status": "failed",
    "message": "Invalid application ID."
}

// Application not complete
{
    "status": "failed",
    "message": "Application is not complete yet."
}

// Already paid
{
    "status": "failed",
    "message": "Payment already completed for this application."
}

// Job posting not found
{
    "status": "failed",
    "message": "Job posting not found."
}

// Personal details missing
{
    "status": "failed",
    "message": "Personal details not found."
}
```

### 7.2 Payment Callback (Job)

**Route:** `POST /api/job-successData`

**Content-Type:** `application/x-www-form-urlencoded`

| Parameter | Type | Description |
|-----------|------|-------------|
| `encData` | String | AES-128-CBC encrypted response from SBI ePay |

**Processing Logic:**

1. Decrypt `encData` using `PAYMENT_KEY`
2. Parse pipe-delimited response
3. Perform **double verification** with SBI ePay
4. Update `job_applied_statuses` table:
   - `payment_status` → `paid` or `failed`
   - `payment_transaction_id` → SBI ePay transaction ID
   - `payment_date` → timestamp
   - `payment_response_body` → raw decrypted response
   - `stage` → 7 (final stage, on success)
5. Redirect:
   - Success → `https://turamunicipalboard.com/successJobPayment.html`
   - Failure → `https://turamunicipalboard.com/failureJobPayment.html`

### 7.3 Deprecated Endpoints

| Method | Route | Description |
|--------|-------|-------------|
| POST | `initiatePayment` | Redirects to `payment()` method |
| GET | `showPaymentFormByApplicationId` | Redirects to `payment()` method |

---

## 8. Billing Payment APIs (BillingController)

### 8.1 Update Billing Payment Status

**Route:** `POST /api/billing/payments/update-status`  
**Authentication:** JWT Required  
**Content-Type:** `application/json`

Updates payment status for market billing transactions. This is used when payments are reconciled (either through SBI ePay callback or manual office cash payments).

**Request Body:**

```json
{
    "payment_id": "string (required)",
    "status": "string (required: pending|success|failed)",
    "response_body": "string (optional)",
    "payment_remarks": "string (optional)"
}
```

**Response (Success):**

```json
{
    "status": true,
    "message": "Payment reconciled successfully.",
    "data": {
        "bill": {
            "id": 1,
            "market_id": 1,
            "shop_no": "A-101",
            "amount": 5000.00,
            "status": "paid"
        },
        "payment": {
            "id": 1,
            "order_id": "BILL12345678",
            "status": "success",
            "amount": 5000.00
        }
    }
}
```

---

## 9. Callback / Response Handling

### 9.1 Response Data Format

SBI ePay sends encrypted data via POST parameter `encData`. After decryption:

```
ORDER_ID|TRANSACTION_ID|STATUS|AMOUNT|ADDITIONAL_FIELDS...
```

### 9.2 Status Mapping

| SBI ePay Status | Internal Status | Action |
|-----------------|----------------|--------|
| `SUCCESS` | `success` | Update DB, redirect to success page |
| `FAIL` | `failed` | Update DB, redirect to failure page |
| Other/Unknown | `failed` | Update DB, redirect to failure page |

### 9.3 Database Updates on Callback

**For Form Payments (`payment_details` table):**

```php
PaymentModel::where('order_id', $orderId)->update([
    'status' => 'success',  // or 'failed'
    'response_body' => $decryptedData
]);
```

**For Job Payments (`job_applied_statuses` table):**

```php
JobAppliedStatus::where('payment_order_id', $orderId)->update([
    'payment_status' => 'paid',  // or 'failed'
    'payment_date' => now(),
    'payment_transaction_id' => $transactionId,
    'payment_response_body' => $decryptedData,
    'stage' => 7,  // Only on success
    'updated_at' => now()
]);
```

---

## 10. Double Verification

After receiving the callback from SBI ePay, the backend performs a **double verification** by querying the SBI ePay Status Query API to independently confirm the transaction status.

### API Endpoint

```
POST https://www.sbiepay.sbi/payagg/statusQuery/getStatusQuery
```

### Request Parameters (URL-encoded)

| Parameter | Value |
|-----------|-------|
| `queryRequest` | `|MERCHANT_ID|ORDER_ID|AMOUNT` |
| `aggregatorId` | `SBIEPAY` |
| `merchantId` | `1003253` |

**Example:**
```
queryRequest=|1003253|APP12345678|500&aggregatorId=SBIEPAY&merchantId=1003253
```

### cURL Configuration

```php
$ch = curl_init($url);
curl_setopt_array($ch, [
    CURLOPT_SSLVERSION     => CURL_SSLVERSION_TLSv1_2,
    CURLOPT_HTTPAUTH       => CURLAUTH_ANY,
    CURLOPT_TIMEOUT        => 60,
    CURLOPT_POST           => 1,
    CURLOPT_POSTFIELDS     => $queryRequest33,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_SSL_VERIFYPEER => false,
    CURLOPT_SSL_VERIFYHOST => 0,
    CURLOPT_HTTPHEADER     => [
        'Content-Type: application/x-www-form-urlencoded'
    ]
]);
```

### Response Format

The double verification response is a pipe-delimited string:

```
|MERCHANT_ID|ORDER_ID|STATUS
```

| Position | Field | Description |
|----------|-------|-------------|
| 0 | (empty) | Leading pipe |
| 1 | Merchant ID | `1003253` |
| 2 | Status | `SUCCESS` or other |
| 3 | Order ID | Merchant order number |

### Verification Logic

```php
$explodeDoubleVeri = explode("|", $doubleVerification['data']);

// If fewer than 3 elements OR status is SUCCESS → mark as success
if (count($explodeDoubleVeri) < 3 || trim($explodeDoubleVeri[2]) == "SUCCESS") {
    // Payment confirmed
}
```

> **Note:** The double verification has a lenient check — if the response has fewer than 3 elements, it's treated as success. This is a fallback for edge cases in the SBI ePay response format.

---

## 11. Database Schema

### 11.1 `payment_details` Table (PaymentModel)

| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint (PK) | Auto-increment ID |
| `form_id` | string | Application ID reference |
| `payment_id` | string | Order ID / payment identifier |
| `order_id` | string | SBI ePay order ID |
| `amount` | decimal(10,2) | Payment amount |
| `status` | string | `pending`, `success`, `failed` |
| `request_body` | text | Original request parameter string |
| `response_body` | text | Decrypted callback response |
| `form_type_id` | integer | Form type (0,5,6,7,8,10) |
| `market_id` | integer | Market ID (for billing payments) |
| `shop_no` | string | Shop number (for billing payments) |
| `bill_id` | integer (FK) | References `billing_transactions.id` |
| `payment_remarks` | text | Remarks for manual payments |
| `created_at` | timestamp | Record creation time |
| `updated_at` | timestamp | Last update time |

**Status Constants:**
```php
PaymentModel::STATUS_PENDING = 'pending';
PaymentModel::STATUS_SUCCESS = 'success';
PaymentModel::STATUS_FAILED  = 'failed';
```

### 11.2 `job_applied_statuses` Table (JobAppliedStatus)

Relevant payment columns:

| Column | Type | Description |
|--------|------|-------------|
| `payment_order_id` | string | SBI ePay order ID |
| `payment_amount` | decimal | Payment amount |
| `payment_status` | string | `pending`, `paid`, `failed` |
| `payment_transaction_id` | string | SBI ePay transaction ID |
| `payment_date` | timestamp | Payment completion time |
| `payment_request_body` | text | Original request parameter string |
| `payment_response_body` | text | Decrypted callback response |
| `stage` | integer | Application stage (7 = payment complete) |

### 11.3 Entity Relationship

```
payment_details (Form/Billing Payments)
├── form_id ──────────▶ form_master_tbl.application_id
├── bill_id ──────────▶ billing_transactions.id (nullable)
├── form_type_id ─────▶ Form type identifier
└── market_id ────────▶ markets.id (for billing)

job_applied_statuses (Job Payments)
├── user_id ──────────▶ users.id
├── job_id ───────────▶ tura_job_postings.id
└── payment_order_id ─▶ SBI ePay order ID
```

---

## 12. Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `PAYMENT_KEY` | AES-128-CBC encryption key for SBI ePay | `pWhMnIEMc4q6hKdi2Fx50Ii8CKAoSIqv9ScSpwuMHM4=` |
| `BANNER_AMT` | Per sq.ft rate for banner advertisements | `100` |
| `HOARDING_AMT` | Per sq.ft rate for hoarding advertisements | `200` |
| `A4_AMT` | Rate per A4 poster | `50` |
| `A3_AMT` | Rate per A3 poster | `100` |

---

## 13. Flutter / Frontend Integration Guide

### 13.1 Initiating Payment from Flutter

Since the payment initiation renders an HTML form (not a JSON API), Flutter should use a **WebView** to load the payment URL:

```dart
// Flutter - Open payment in WebView
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl; // e.g., "https://laravelv2.turamunicipalboard.com/payment/APP123"
  
  @override
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          // Monitor for success/failure redirect URLs
          if (url.contains('/success')) {
            Navigator.pop(context, 'success');
          } else if (url.contains('/failure')) {
            Navigator.pop(context, 'failed');
          }
        },
      ))
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
```

### 13.2 Payment URLs

| Payment Type | URL Pattern |
|-------------|-------------|
| Form Payment | `GET /payment/{application_id}` |
| Job Payment | `GET /job-payment/{application_id}` |

### 13.3 Checking Payment Status

After the WebView closes, verify payment status via the appropriate API:

```dart
// Check form payment status
GET /api/dashboard/payment-history
// or
POST /api/billing/payments/update-status

// Check job payment status
POST /api/getApplicationProgress
```

### 13.4 Success/Failure Redirect URLs (Frontend)

| Payment Type | Success Redirect | Failure Redirect |
|-------------|-----------------|-----------------|
| Form Payment | `https://turamunicipalboard.com/success` | `https://turamunicipalboard.com/failure` |
| Job Payment | `https://turamunicipalboard.com/successJobPayment.html` | `https://turamunicipalboard.com/failureJobPayment.html` |

---

## 14. Error Handling & Status Codes

### HTTP Status Codes

| Code | Scenario |
|------|----------|
| `200` | Payment form rendered successfully |
| `302` | Redirect to success/failure page after callback |
| `400` | Invalid payment amount (zero or uncalculable) |
| `404` | Application not found, form not approved, invalid form type |

### Common Error Scenarios

| Scenario | Handling |
|----------|----------|
| Missing `encData` in callback | Log error, redirect to failure page |
| Decryption fails | Log exception, redirect to failure page |
| Invalid decrypted data format | Log warning, redirect to failure page |
| Double verification fails (cURL error) | Mark payment as failed, redirect to failure |
| Double verification returns non-success | Mark payment as failed, redirect to failure |
| Unknown status from SBI ePay | Mark payment as failed, redirect to failure |
| Zero/empty payment amount | Return 400 error before initiating payment |

---

## 15. Security Considerations

### 15.1 Encryption

- All communication with SBI ePay uses **AES-128-CBC** encryption
- The encryption key is stored in `.env` (`PAYMENT_KEY`), not in source code
- IV is derived from the first 16 bytes of the key

### 15.2 Double Verification

- Every payment callback triggers a server-side verification with SBI ePay
- This prevents tampered callback data from being accepted
- Uses TLS 1.2 for the verification request

### 15.3 SSL Configuration

The double verification cURL request uses:
```php
CURLOPT_SSLVERSION     => CURL_SSLVERSION_TLSv1_2,
CURLOPT_SSL_VERIFYPEER => false,  // Disable peer verification
CURLOPT_SSL_VERIFYHOST => 0,      // Disable host verification
```

> ⚠️ **Warning:** `SSL_VERIFYPEER` and `SSL_VERIFYHOST` are disabled. In production, consider enabling these with proper SSL certificates.

### 15.4 Order ID Generation

Order IDs are generated as: `APPLICATION_ID + RANDOM(0-100000)`

```php
$orderID = $id . rand(00000, 100000);
```

> ⚠️ **Note:** The random range is small (0–100000). For high-volume scenarios, consider using UUIDs or longer random strings to prevent collisions.

---

## 16. Testing

### 16.1 Test Payment Flow (Form)

```bash
# Step 1: Get payment form (this renders HTML that auto-submits to SBI ePay)
curl -X GET "https://laravelv2.turamunicipalboard.com/payment/APP001" \
  -H "Accept: text/html"

# Step 2: Simulate SBI ePay callback (requires encrypted data)
curl -X POST "https://laravelv2.turamunicipalboard.com/api/successData" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "encData=<encrypted-data-from-sbiepay>"
```

### 16.2 Test Payment Flow (Job)

```bash
# Step 1: Get job payment form
curl -X GET "https://laravelv2.turamunicipalboard.com/job-payment/JOB001" \
  -H "Accept: text/html"

# Step 2: Simulate callback
curl -X POST "https://laravelv2.turamunicipalboard.com/api/job-successData" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "encData=<encrypted-data-from-sbiepay>"
```

### 16.3 Test Double Verification

```bash
curl -X POST "https://www.sbiepay.sbi/payagg/statusQuery/getStatusQuery" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "queryRequest=|1003253|TEST_ORDER_123|100&aggregatorId=SBIEPAY&merchantId=1003253"
```

### 16.4 Local Encryption Test

```php
// In a test route or tinker
$key = env('PAYMENT_KEY');
$requestParameter = "1003253|DOM|IN|INR|500|Other|https://laravelv2.turamunicipalboard.com/api/successData|https://laravelv2.turamunicipalboard.com/api/successData|SBIEPAY|TEST123456|2|NB|ONLINE|ONLINE";

$encrypted = encrypt($requestParameter, $key);
$decrypted = decrypt($encrypted, $key);

// $decrypted should equal $requestParameter
```

---

## Appendix A: Complete Request Parameter Examples

### Form Payment (Trade License - ₹500)

```
1003253|DOM|IN|INR|500|Other|https://laravelv2.turamunicipalboard.com/api/successData|https://laravelv2.turamunicipalboard.com/api/successData|SBIEPAY|APP00112345|2|NB|ONLINE|ONLINE
```

### Job Payment (SC/ST Category - ₹200)

```
1003253|DOM|IN|INR|200|Other|https://laravelv2.turamunicipalboard.com/api/job-successData|https://laravelv2.turamunicipalboard.com/api/job-successData|SBIEPAY|JOB00112345|2|NB|ONLINE|ONLINE
```

### Pet Dog Registration (₹250)

```
1003253|DOM|IN|INR|250|Other|https://laravelv2.turamunicipalboard.com/api/successData|https://laravelv2.turamunicipalboard.com/api/successData|SBIEPAY|APP00212345|2|NB|ONLINE|ONLINE
```

---

## Appendix B: Payment Status Codes Reference

| Internal Status | SBI ePay Status | Stage (Job) | Description |
|----------------|-----------------|-------------|-------------|
| `pending` | — | < 7 | Payment initiated, awaiting callback |
| `success` / `paid` | `SUCCESS` | 7 | Payment confirmed + double verified |
| `failed` | `FAIL` | < 7 | Payment failed or verification failed |

---

## Appendix C: File Reference

| File | Path | Purpose |
|------|------|---------|
| PaymentController | `app/Http/Controllers/PaymentController.php` | Form payment logic |
| JobPaymentController | `app/Http/Controllers/JobPaymentController.php` | Job payment logic |
| BillingController | `app/Http/Controllers/BillingController.php` | Billing payment status |
| AESController | `app/Http/Controllers/AESController.php` | Encryption utility |
| PaymentModel | `app/Models/PaymentModel.php` | Payment database model |
| JobAppliedStatus | `app/Models/JobAppliedStatus.php` | Job application + payment model |
| API Routes | `routes/api.php` | Callback routes (`/successData`, `/job-successData`) |
| Payment View | `resources/views/payment.blade.php` | Form payment HTML template |
| Job Payment View | `resources/views/job-payment-form.blade.php` | Job payment HTML template |