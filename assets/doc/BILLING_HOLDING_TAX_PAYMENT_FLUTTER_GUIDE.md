# Billing & Holding Tax Payment Integration — Flutter Guide

## Tura Municipal Board — SBI ePay Gateway

**Version:** 1.0  
**Last Updated:** 2026-05-25  
**Base URL:** `https://laravelv2.turamunicipalboard.com`

---

## Table of Contents

1. [Overview](#1-overview)
2. [Payment Flow Diagram](#2-payment-flow-diagram)
3. [Prerequisites](#3-prerequisites)
4. [Billing Payment APIs](#4-billing-payment-apis)
   - [4.1 Get Billing List](#41-get-billing-list)
   - [4.2 Initiate Billing Payment](#42-initiate-billing-payment)
   - [4.3 Check Billing Payment Status](#43-check-billing-payment-status)
5. [Holding Tax Payment APIs](#5-holding-tax-payment-apis)
   - [5.1 Search Holding Taxes](#51-search-holding-taxes)
   - [5.2 Get Holding Tax Details](#52-get-holding-tax-details)
   - [5.3 Initiate Holding Tax Payment](#53-initiate-holding-tax-payment)
   - [5.4 Check Holding Tax Payment Status](#54-check-holding-tax-payment-status)
6. [SBI ePay WebView Integration](#6-sbi-epay-webview-integration)
7. [Flutter Code Examples](#7-flutter-code-examples)
   - [7.1 Billing Payment Flow](#71-billing-payment-flow)
   - [7.2 Holding Tax Payment Flow](#72-holding-tax-payment-flow)
   - [7.3 WebView Form Post Helper](#73-webview-form-post-helper)
   - [7.4 Payment Status Polling](#74-payment-status-polling)
8. [Backend Callback Handling](#8-backend-callback-handling)
9. [Database Schema](#9-database-schema)
10. [Error Handling](#10-error-handling)
11. [Deployment Checklist](#11-deployment-checklist)

---

## 1. Overview

The billing and holding tax payment integration uses the **same SBI ePay gateway** as form payments and job payments. The backend handles all encryption and decryption — Flutter only needs to:

1. **Call the initiate API** → get encrypted data + gateway URL
2. **Open a WebView** → POST the encrypted data to SBI ePay
3. **Handle the callback** → the backend receives the callback and updates the database
4. **Poll for status** → Flutter checks the payment status API after the WebView closes

### Payment Types

| Payment Type | Source Table | Amount Field | Status Field |
|---|---|---|---|
| **Billing** | `billing_transactions` | `total_amount` | `status` (`pending` → `paid`) |
| **Holding Tax** | `holding_taxes` | `amount_payable` | `payment_status` (`unpaid` → `paid`) |

### Transaction Tracking

All billing and holding tax payments are tracked in the `sbi_epay_transactions` table:

| Column | Description |
|---|---|
| `order_id` | Unique SBI ePay order ID (e.g., `SBI17166501234567`) |
| `payment_type` | `billing` or `holding_tax` |
| `source_id` | ID of the billing_transactions or holding_taxes record |
| `amount` | Payment amount |
| `status` | `pending` → `processing` → `success` / `failed` |
| `payment_id` | SBI ePay transaction reference (set after callback) |
| `request_body` | Encrypted request details (JSON) |
| `response_body` | Decrypted callback response |

---

## 2. Payment Flow Diagram

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐     ┌──────────┐
│  Flutter App │     │ Laravel API  │     │  SBI ePay   │     │ Database │
└──────┬──────┘     └──────┬───────┘     └──────┬──────┘     └────┬─────┘
       │                    │                     │                  │
       │  1. POST initiate  │                     │                  │
       │  (billing_id or    │                     │                  │
       │   holding_tax_id)  │                     │                  │
       │───────────────────>│                     │                  │
       │                    │ 2. Read amount      │                  │
       │                    │    from source table │                  │
       │                    │─────────────────────────────────────────>│
       │                    │<─────────────────────────────────────────│
       │                    │ 3. Encrypt data      │                  │
       │                    │ 4. Store in          │                  │
       │                    │    sbi_epay_txn      │                  │
       │                    │─────────────────────────────────────────>│
       │                    │<─────────────────────────────────────────│
       │  5. Return:        │                     │                  │
       │  - encrypted_data  │                     │                  │
       │  - gateway_url     │                     │                  │
       │  - order_id        │                     │                  │
       │<───────────────────│                     │                  │
       │                    │                     │                  │
       │  6. Open WebView   │                     │                  │
       │  POST to gateway   │                     │                  │
       │──────────────────────────────────────────>│                  │
       │                    │                     │ 7. User pays     │
       │                    │                     │    on SBI page    │
       │                    │                     │                  │
       │                    │  8. Callback POST   │                  │
       │                    │  (encrypted resp)   │                  │
       │                    │<────────────────────│                  │
       │                    │ 9. Decrypt          │                  │
       │                    │ 10. Double verify   │                  │
       │                    │ 11. Update status   │                  │
       │                    │─────────────────────────────────────────>│
       │                    │                     │                  │
       │  12. WebView closes│                     │                  │
       │  13. Poll status   │                     │                  │
       │───────────────────>│                     │                  │
       │                    │ 14. Read status     │                  │
       │                    │─────────────────────────────────────────>│
       │  15. Return status │<─────────────────────────────────────────│
       │<───────────────────│                     │                  │
       │                    │                     │                  │
       │  16. Show success  │                     │                  │
       │  or failure UI     │                     │                  │
       │                    │                     │                  │
```

---

## 3. Prerequisites

### Flutter Packages Required

```yaml
dependencies:
  webview_flutter: ^4.0.0   # For SBI ePay payment page
  http: ^1.0.0               # For API calls
```

### Authentication

**No JWT token is required** for the billing and holding tax payment endpoints. These are public APIs.

### Important Notes

- The `encrypted_data` is generated server-side — Flutter does **NOT** handle any encryption
- The callback URL is also server-side (`/api/sbi-epay/callback`) — SBI ePay calls the backend directly
- Flutter only needs to: call initiate → open WebView → poll status after WebView closes

---

## 4. Billing Payment APIs

### 4.1 Get Billing List

Get all billing transactions for a market/shop. (Existing billing API)

**Endpoint:** `GET /api/billing/transactions`

**Query Parameters:**

| Param | Type | Required | Description |
|---|---|---|---|
| `market_id` | int | No | Filter by market |
| `shop_no` | string | No | Filter by shop number |
| `status` | string | No | Filter by status: `pending`, `paid`, `overdue` |

**Response (200):**

```json
{
  "status": true,
  "data": {
    "transactions": [
      {
        "id": 1,
        "market_id": 1,
        "shop_no": "A-101",
        "bill_month": "January",
        "bill_year": "2026",
        "rent_amount": "5000.00",
        "electricity_amount": "1200.00",
        "late_fee": "0.00",
        "total_amount": "6200.00",
        "paid_amount": "0.00",
        "status": "pending",
        "due_date": "2026-01-15",
        "generated_at": "2026-01-01"
      }
    ]
  }
}
```

### 4.2 Initiate Billing Payment

Initiates SBI ePay payment for a specific billing transaction.

**Endpoint:** `POST /api/sbi-epay/initiate-billing/{billing_id}`

**Path Parameters:**

| Param | Type | Required | Description |
|---|---|---|---|
| `billing_id` | int | Yes | The billing transaction ID |

**Headers:**

```
Content-Type: application/json
Accept: application/json
```

**Response (200) — Success:**

```json
{
  "status": true,
  "message": "Billing payment initiated",
  "data": {
    "order_id": "SBI17166501234567",
    "merchant_id": "1003253",
    "amount": 6200.00,
    "currency": "INR",
    "payment_gateway_url": "https://www.sbiepay.in/secure/AggregatorHostedPayment",
    "encrypted_data": "Base64EncodedEncryptedData==",
    "pay_mode": "9",
    "collect_pay_mode": "9",
    "description": "Bill payment for shop A-101 - January/2026",
    "return_url": "https://laravelv2.turamunicipalboard.com/api/sbi-epay/callback",
    "billing_id": 1
  }
}
```

**Response (200) — Already Paid:**

```json
{
  "status": false,
  "message": "Billing already paid",
  "paid": true
}
```

**Response (200) — Pending Payment Exists:**

```json
{
  "status": false,
  "message": "A pending payment already exists for this billing",
  "existing_order_id": "SBI17166501234000"
}
```

**Response (404):**

```json
{
  "status": false,
  "message": "Billing transaction not found"
}
```

### 4.3 Check Billing Payment Status

Check the current payment status for a billing transaction.

**Endpoint:** `GET /api/sbi-epay/billing-status/{billing_id}`

**Response (200):**

```json
{
  "status": true,
  "data": {
    "billing_id": 1,
    "billing_status": "paid",
    "total_amount": 6200.00,
    "paid_amount": 6200.00,
    "payment": {
      "order_id": "SBI17166501234567",
      "amount": 6200.00,
      "status": "success",
      "payment_id": "SBI_TXN_12345",
      "created_at": "2026-01-10T10:30:00.000000Z",
      "updated_at": "2026-01-10T10:31:00.000000Z"
    }
  }
}
```

**Status Values:**

| billing_status | Payment Status | Description |
|---|---|---|
| `pending` | `pending` | Payment initiated, user hasn't completed |
| `pending` | `failed` | Payment failed |
| `paid` | `success` | Payment completed successfully |

---

## 5. Holding Tax Payment APIs

### 5.1 Search Holding Taxes

Search for holding taxes by holding number or owner name. (Existing API)

**Endpoint:** `POST /api/holding-taxes/search`

**Request Body:**

```json
{
  "query": "HT-001"
}
```

**Response (200):**

```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "holding_no": "HT-001",
      "owner_name": "John Doe",
      "address": "Ward No. 5, Tura",
      "current_year": "2025-2026",
      "amount_payable": "12000.00",
      "payment_status": "unpaid"
    }
  ]
}
```

### 5.2 Get Holding Tax Details

Get full details of a holding tax record.

**Endpoint:** `POST /api/holding-taxes/details`

**Request Body:**

```json
{
  "holding_no": "HT-001"
}
```

**Response (200):**

```json
{
  "status": true,
  "data": {
    "id": 1,
    "holding_no": "HT-001",
    "owner_name": "John Doe",
    "address": "Ward No. 5, Tura",
    "current_year": "2025-2026",
    "annual_value": "100000.00",
    "tax_rate": "12.00",
    "amount_payable": "12000.00",
    "paid_amount": "0.00",
    "payment_status": "unpaid",
    "payment_date": null,
    "payment_remarks": null
  }
}
```

### 5.3 Initiate Holding Tax Payment

Initiates SBI ePay payment for a specific holding tax.

**Endpoint:** `POST /api/sbi-epay/initiate-holding-tax/{holding_tax_id}`

**Path Parameters:**

| Param | Type | Required | Description |
|---|---|---|---|
| `holding_tax_id` | int | Yes | The holding tax record ID |

**Response (200) — Success:**

```json
{
  "status": true,
  "message": "Holding tax payment initiated",
  "data": {
    "order_id": "SBI17166501239999",
    "merchant_id": "1003253",
    "amount": 12000.00,
    "currency": "INR",
    "payment_gateway_url": "https://www.sbiepay.in/secure/AggregatorHostedPayment",
    "encrypted_data": "Base64EncodedEncryptedData==",
    "pay_mode": "9",
    "collect_pay_mode": "9",
    "description": "Holding tax payment for holding HT-001 - FY 2025-2026",
    "return_url": "https://laravelv2.turamunicipalboard.com/api/sbi-epay/callback",
    "holding_tax_id": 1
  }
}
```

**Response (200) — Already Paid:**

```json
{
  "status": false,
  "message": "Holding tax already paid",
  "paid": true
}
```

**Response (200) — Pending Payment Exists:**

```json
{
  "status": false,
  "message": "A pending payment already exists for this holding tax",
  "existing_order_id": "SBI17166501230000"
}
```

### 5.4 Check Holding Tax Payment Status

**Endpoint:** `GET /api/sbi-epay/holding-tax-status/{holding_tax_id}`

**Response (200):**

```json
{
  "status": true,
  "data": {
    "holding_tax_id": 1,
    "payment_status": "paid",
    "amount_payable": 12000.00,
    "paid_amount": 12000.00,
    "payment": {
      "order_id": "SBI17166501239999",
      "amount": 12000.00,
      "status": "success",
      "payment_id": "SBI_TXN_67890",
      "created_at": "2026-01-10T10:30:00.000000Z",
      "updated_at": "2026-01-10T10:31:00.000000Z"
    }
  }
}
```

---

## 6. SBI ePay WebView Integration

### How to Open the Payment Page

After calling the initiate API, you get `encrypted_data`, `merchant_id`, and `payment_gateway_url`. You need to **POST a form** to the gateway URL with these fields:

```html
<form method="POST" action="https://www.sbiepay.in/secure/AggregatorHostedPayment">
  <input type="hidden" name="merchantId" value="1003253" />
  <input type="hidden" name="encryptedData" value="<encrypted_data>" />
</form>
```

### Flutter WebView Approach

In Flutter, use `webview_flutter` to create an HTML form and auto-submit it:

```dart
// Build the HTML form that auto-submits to SBI ePay
String buildSbiEpayForm({
  required String merchantId,
  required String encryptedData,
  required String gatewayUrl,
}) {
  return '''
  <!DOCTYPE html>
  <html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Processing Payment...</title>
    <style>
      body { 
        display: flex; 
        justify-content: center; 
        align-items: center; 
        height: 100vh; 
        font-family: Arial, sans-serif;
        background: #f5f5f5;
      }
      .loader { text-align: center; }
      .spinner {
        border: 4px solid #f3f3f3;
        border-top: 4px solid #1976d2;
        border-radius: 50%;
        width: 40px;
        height: 40px;
        animation: spin 1s linear infinite;
        margin: 0 auto 16px;
      }
      @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
    </style>
  </head>
  <body>
    <div class="loader">
      <div class="spinner"></div>
      <p>Redirecting to SBI ePay...</p>
    </div>
    <form id="sbiForm" method="POST" action="$gatewayUrl">
      <input type="hidden" name="merchantId" value="$merchantId" />
      <input type="hidden" name="encryptedData" value="$encryptedData" />
    </form>
    <script>
      document.getElementById('sbiForm').submit();
    </script>
  </body>
  </html>
  ''';
}
```

### Detecting Payment Completion

The SBI ePay callback is a **server-to-server POST** — it does NOT redirect to the Flutter app. After the user completes or cancels payment on SBI ePay, the WebView may redirect to the callback URL. You should:

1. **Listen for URL changes** in the WebView for the callback URL
2. **Close the WebView** when the callback URL is detected
3. **Poll the status API** from Flutter to confirm payment result

```dart
WebView(
  initialUrl: 'about:blank',
  onWebViewCreated: (controller) {
    final html = buildSbiEpayForm(
      merchantId: response['data']['merchant_id'],
      encryptedData: response['data']['encrypted_data'],
      gatewayUrl: response['data']['payment_gateway_url'],
    );
    controller.loadHtmlString(html);
  },
  navigationDelegate: (request) {
    // When SBI redirects to callback URL, close WebView and check status
    if (request.url.contains('/api/sbi-epay/callback')) {
      Navigator.pop(context); // Close WebView
      _checkPaymentStatus();  // Poll status API
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  },
)
```

---

## 7. Flutter Code Examples

### 7.1 Billing Payment Flow

```dart
class BillingPaymentService {
  final String baseUrl = 'https://laravelv2.turamunicipalboard.com/api';

  /// Step 1: Initiate billing payment
  Future<Map<String, dynamic>> initiateBillingPayment(int billingId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sbi-epay/initiate-billing/$billingId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    final data = json.decode(response.body);
    
    if (data['status'] == true) {
      return data['data']; // Contains encrypted_data, merchant_id, etc.
    } else {
      throw Exception(data['message'] ?? 'Failed to initiate payment');
    }
  }

  /// Step 2: Open WebView with SBI ePay form (use buildSbiEpayForm from section 6)

  /// Step 3: Check payment status after WebView closes
  Future<Map<String, dynamic>> checkBillingPaymentStatus(int billingId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/sbi-epay/billing-status/$billingId'),
      headers: {
        'Accept': 'application/json',
      },
    );

    final data = json.decode(response.body);
    
    if (data['status'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to check status');
    }
  }

  /// Full flow: Initiate → WebView → Poll Status
  Future<void> payBilling(BuildContext context, int billingId) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // 1. Initiate
      final paymentData = await initiateBillingPayment(billingId);
      
      // Close loading
      Navigator.pop(context);

      // 2. Open WebView
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SbiEpayWebView(
            merchantId: paymentData['merchant_id'],
            encryptedData: paymentData['encrypted_data'],
            gatewayUrl: paymentData['payment_gateway_url'],
          ),
        ),
      );

      // 3. Check status (with polling for delayed callbacks)
      bool isPaid = false;
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(seconds: 3));
        final status = await checkBillingPaymentStatus(billingId);
        if (status['billing_status'] == 'paid') {
          isPaid = true;
          break;
        }
      }

      if (isPaid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh billing list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment status pending. Please check again later.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading if open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

### 7.2 Holding Tax Payment Flow

```dart
class HoldingTaxPaymentService {
  final String baseUrl = 'https://laravelv2.turamunicipalboard.com/api';

  /// Step 1: Initiate holding tax payment
  Future<Map<String, dynamic>> initiateHoldingTaxPayment(int holdingTaxId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sbi-epay/initiate-holding-tax/$holdingTaxId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    final data = json.decode(response.body);
    
    if (data['status'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to initiate payment');
    }
  }

  /// Step 3: Check payment status
  Future<Map<String, dynamic>> checkHoldingTaxPaymentStatus(int holdingTaxId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/sbi-epay/holding-tax-status/$holdingTaxId'),
      headers: {
        'Accept': 'application/json',
      },
    );

    final data = json.decode(response.body);
    
    if (data['status'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to check status');
    }
  }

  /// Full flow
  Future<void> payHoldingTax(BuildContext context, int holdingTaxId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final paymentData = await initiateHoldingTaxPayment(holdingTaxId);
      Navigator.pop(context);

      // Open WebView
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SbiEpayWebView(
            merchantId: paymentData['merchant_id'],
            encryptedData: paymentData['encrypted_data'],
            gatewayUrl: paymentData['payment_gateway_url'],
          ),
        ),
      );

      // Poll for status
      bool isPaid = false;
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(seconds: 3));
        final status = await checkHoldingTaxPaymentStatus(holdingTaxId);
        if (status['payment_status'] == 'paid') {
          isPaid = true;
          break;
        }
      }

      if (isPaid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Holding tax payment successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment status pending. Please check again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

### 7.3 WebView Form Post Helper

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SbiEpayWebView extends StatefulWidget {
  final String merchantId;
  final String encryptedData;
  final String gatewayUrl;

  const SbiEpayWebView({
    Key? key,
    required this.merchantId,
    required this.encryptedData,
    required this.gatewayUrl,
  }) : super(key: key);

  @override
  State<SbiEpayWebView> createState() => _SbiEpayWebViewState();
}

class _SbiEpayWebViewState extends State<SbiEpayWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            // Detect SBI ePay callback redirect
            if (request.url.contains('/api/sbi-epay/callback')) {
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    _loadPaymentForm();
  }

  void _loadPaymentForm() {
    final html = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Processing Payment...</title>
      <style>
        body { 
          display: flex; 
          justify-content: center; 
          align-items: center; 
          height: 100vh; 
          font-family: Arial, sans-serif;
          background: #f5f5f5;
          margin: 0;
        }
        .loader { text-align: center; }
        .spinner {
          border: 4px solid #f3f3f3;
          border-top: 4px solid #1976d2;
          border-radius: 50%;
          width: 40px;
          height: 40px;
          animation: spin 1s linear infinite;
          margin: 0 auto 16px;
        }
        @keyframes spin { 
          0% { transform: rotate(0deg); } 
          100% { transform: rotate(360deg); } 
        }
        p { color: #333; font-size: 16px; }
      </style>
    </head>
    <body>
      <div class="loader">
        <div class="spinner"></div>
        <p>Redirecting to SBI ePay...</p>
      </div>
      <form id="sbiForm" method="POST" action="${widget.gatewayUrl}">
        <input type="hidden" name="merchantId" value="${widget.merchantId}" />
        <input type="hidden" name="encryptedData" value="${widget.encryptedData}" />
      </form>
      <script>
        document.getElementById('sbiForm').submit();
      </script>
    </body>
    </html>
    ''';

    _controller.loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SBI ePay Payment'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
```

### 7.4 Payment Status Polling

Since the SBI ePay callback is server-to-server, the Flutter app must **poll** the status API after the WebView closes:

```dart
/// Poll payment status until it resolves or times out.
/// 
/// [type] - 'billing' or 'holding_tax'
/// [id] - billing_id or holding_tax_id
/// 
/// Returns true if payment succeeded, false otherwise.
Future<bool> pollPaymentStatus({
  required String type, // 'billing' or 'holding_tax'
  required int id,
  int maxRetries = 6,
  Duration interval = const Duration(seconds: 5),
}) async {
  final baseUrl = 'https://laravelv2.turamunicipalboard.com/api';
  
  for (int i = 0; i < maxRetries; i++) {
    await Future.delayed(interval);
    
    try {
      final endpoint = type == 'billing'
          ? '$baseUrl/sbi-epay/billing-status/$id'
          : '$baseUrl/sbi-epay/holding-tax-status/$id';
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Accept': 'application/json'},
      );
      
      final data = json.decode(response.body);
      
      if (data['status'] == true) {
        final statusField = type == 'billing'
            ? data['data']['billing_status']
            : data['data']['payment_status'];
        
        if (statusField == 'paid') {
          return true; // Payment successful
        }
        
        // Check SBI transaction status
        final payment = data['data']['payment'];
        if (payment != null && payment['status'] == 'failed') {
          return false; // Payment failed
        }
      }
    } catch (e) {
      debugPrint('Status poll attempt $i failed: $e');
    }
  }
  
  return false; // Timed out or failed
}
```

---

## 8. Backend Callback Handling

The SBI ePay callback is handled entirely by the backend. Here's what happens:

### Callback URL

```
POST https://laravelv2.turamunicipalboard.com/api/sbi-epay/callback
```

### Callback Flow

1. **Receive encrypted response** from SBI ePay
2. **Decrypt** using AES-128-CBC
3. **Parse response fields** (AggregatorID, MerchantID, OrderID, TxnAmount, AuthStatus, etc.)
4. **Determine payment type** by looking up order_id in:
   - `payment_details` table (for application payments)
   - `sbi_epay_transactions` table (for billing/holding tax payments)
5. **Double verification** via SBI ePay status query API
6. **Update status** in `sbi_epay_transactions`
7. **Update source table**:
   - Billing: `billing_transactions.status = 'paid'`, `billing_transactions.paid_amount = <amount>`
   - Holding Tax: `holding_taxes.payment_status = 'paid'`, `holding_taxes.paid_amount = <amount>`, `holding_taxes.payment_date = NOW()`, `holding_taxes.payment_remarks = 'SBI ePay - TxnRef: <ref>'`

### AuthStatus Codes

| Code | Meaning | Description |
|---|---|---|
| `0300` | Success | Payment completed successfully |
| `0399` | Failed | Payment failed |
| Other | Error | Various error states |

---

## 9. Database Schema

### sbi_epay_transactions Table

```sql
CREATE TABLE sbi_epay_transactions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(255) UNIQUE NOT NULL,
    payment_type ENUM('billing', 'holding_tax') NOT NULL,
    source_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',  -- pending, processing, success, failed
    payment_id VARCHAR(255) NULL,           -- SBI ePay txn reference
    request_body TEXT NULL,                  -- Encrypted request details (JSON)
    response_body TEXT NULL,                 -- Decrypted callback response
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    
    INDEX idx_payment_type_source (payment_type, source_id),
    INDEX idx_order_id (order_id),
    INDEX idx_status (status)
);
```

---

## 10. Error Handling

### Common Error Responses

| Status Code | Scenario | Response |
|---|---|---|
| `200` with `status: false` | Already paid | `{ "status": false, "message": "Billing already paid", "paid": true }` |
| `200` with `status: false` | Pending payment exists | `{ "status": false, "message": "A pending payment already exists..." }` |
| `404` | Billing/Holding tax not found | `{ "status": false, "message": "Billing transaction not found" }` |
| `500` | Server error | `{ "status": false, "message": "Failed to initiate...", "error": "..." }` |

### Flutter Error Handling Pattern

```dart
try {
  final paymentData = await initiateBillingPayment(billingId);
  // ... proceed with WebView
} on http.ClientException catch (e) {
  // Network error
  showError('Network error. Please check your connection.');
} catch (e) {
  final message = e.toString();
  if (message.contains('already paid')) {
    showInfo('This bill has already been paid.');
  } else if (message.contains('pending payment')) {
    showInfo('A payment is already in progress. Please wait.');
  } else {
    showError('Payment initiation failed. Please try again.');
  }
}
```

---

## 11. Deployment Checklist

### Backend (Already Done ✅)

- [x] `sbi_epay_transactions` migration created
- [x] `SbiEpayTransaction` model created
- [x] `SbiEpayController` extended with billing/holding tax endpoints
- [x] Callback handler extended for billing/holding tax type
- [x] Routes registered:
  - `POST /api/sbi-epay/initiate-billing/{billing_id}`
  - `POST /api/sbi-epay/initiate-holding-tax/{holding_tax_id}`
  - `GET /api/sbi-epay/billing-status/{billing_id}`
  - `GET /api/sbi-epay/holding-tax-status/{holding_tax_id}`
- [x] Source table updates on successful payment

### Database (Run on Server)

```bash
php artisan migrate
```

### Flutter App (Pending)

- [ ] Add `webview_flutter` package to `pubspec.yaml`
- [ ] Create `SbiEpayWebView` widget (see section 7.3)
- [ ] Implement billing payment flow in billing screen
- [ ] Implement holding tax payment flow in holding tax screen
- [ ] Add payment status polling after WebView closes
- [ ] Handle "already paid" and "pending payment" states in UI
- [ ] Show success/failure dialogs after payment
- [ ] Refresh list screens after successful payment

### Testing

1. **Billing Payment:**
   - Get a pending billing transaction ID
   - Call `POST /api/sbi-epay/initiate-billing/{id}`
   - Open WebView with returned data
   - Complete/test payment on SBI ePay sandbox
   - Verify `billing_transactions.status` changed to `paid`

2. **Holding Tax Payment:**
   - Get an unpaid holding tax ID
   - Call `POST /api/sbi-epay/initiate-holding-tax/{id}`
   - Open WebView with returned data
   - Complete/test payment on SBI ePay sandbox
   - Verify `holding_taxes.payment_status` changed to `paid`

3. **Status Check:**
   - Call status endpoints after payment to confirm updates
   - Verify `sbi_epay_transactions` has `status: success` and `payment_id` populated

---

## API Quick Reference

| # | Method | Endpoint | Description |
|---|---|---|---|
| 1 | `POST` | `/api/sbi-epay/initiate-billing/{billing_id}` | Initiate billing payment |
| 2 | `GET` | `/api/sbi-epay/billing-status/{billing_id}` | Check billing payment status |
| 3 | `POST` | `/api/sbi-epay/initiate-holding-tax/{holding_tax_id}` | Initiate holding tax payment |
| 4 | `GET` | `/api/sbi-epay/holding-tax-status/{holding_tax_id}` | Check holding tax payment status |
| 5 | `GET` | `/api/holding-taxes/search` | Search holding taxes (existing) |
| 6 | `POST` | `/api/holding-taxes/details` | Get holding tax details (existing) |
| 7 | `GET` | `/api/billing/transactions` | Get billing list (existing) |