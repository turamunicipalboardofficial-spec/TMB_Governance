# Trade License - Flutter Integration Guide

## Overview

This guide covers integrating the Trade License Search & Payment feature into the Flutter app. The flow is:

1. User types a license number → autocomplete dropdown appears
2. User selects a license → full details are displayed
3. User taps "Pay" → payment is processed and status updates to "paid"

---

## Base URL

```dart
const String baseUrl = 'https://laravelv2.turamunicipalboard.com/api';
// For local development:
// const String baseUrl = 'http://127.0.0.1:8000/api';
```

> **Note:** No JWT authentication token is required for these endpoints. They are publicly accessible.

---

## API Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/trade-licenses/search` | Autocomplete search by license number |
| `POST` | `/api/trade-licenses/details` | Get full license details |
| `POST` | `/api/trade-licenses/pay` | Mark license as paid |
| `GET` | `/api/trade-licenses/stats` | Get payment statistics |

---

## 1. Search License Numbers (Autocomplete Dropdown)

### Request

```
POST /api/trade-licenses/search
Content-Type: application/json

{
    "query": "TMB/TL/2022"
}
```

### Response (200 OK)

```json
{
    "status": true,
    "message": "License search results",
    "data": [
        {
            "license_no": "No.TMB/TL/2022/01 (A)",
            "name": "Shri Amit Rishi",
            "business_name": "Rice Hotel"
        },
        {
            "license_no": "No.TMB/TL/2022/02 (A)",
            "name": "Shri Santosh Kumar Thakur",
            "business_name": "M/s STYLE X SALOON"
        }
    ]
}
```

### Response (200 OK - Empty query)

```json
{
    "status": true,
    "message": "Please enter at least 1 character to search",
    "data": []
}
```

### Flutter Implementation

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class TradeLicenseSearchResult {
  final String licenseNo;
  final String name;
  final String businessName;

  TradeLicenseSearchResult({
    required this.licenseNo,
    required this.name,
    required this.businessName,
  });

  factory TradeLicenseSearchResult.fromJson(Map<String, dynamic> json) {
    return TradeLicenseSearchResult(
      licenseNo: json['license_no'] ?? '',
      name: json['name'] ?? '',
      businessName: json['business_name'] ?? '',
    );
  }
}

Future<List<TradeLicenseSearchResult>> searchTradeLicenses(String query) async {
  if (query.length < 1) return [];

  final response = await http.post(
    Uri.parse('$baseUrl/trade-licenses/search'),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: json.encode({'query': query}),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == true) {
      return (data['data'] as List)
          .map((item) => TradeLicenseSearchResult.fromJson(item))
          .toList();
    }
  }
  return [];
}
```

### Autocomplete Dropdown Widget

```dart
class TradeLicenseSearchField extends StatefulWidget {
  final Function(TradeLicenseSearchResult) onSelected;

  const TradeLicenseSearchField({Key? key, required this.onSelected})
      : super(key: key);

  @override
  State<TradeLicenseSearchField> createState() => _TradeLicenseSearchFieldState();
}

class _TradeLicenseSearchFieldState extends State<TradeLicenseSearchField> {
  final TextEditingController _controller = TextEditingController();
  List<TradeLicenseSearchResult> _suggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;

  void _onTextChanged(String value) async {
    if (value.length < 1) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    final results = await searchTradeLicenses(value);

    setState(() {
      _suggestions = results;
      _isLoading = false;
      _showSuggestions = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Enter License Number',
            hintText: 'e.g. TMB/TL/2022',
            prefixIcon: Icon(Icons.search),
            suffixIcon: _isLoading
                ? Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            border: OutlineInputBorder(),
          ),
          onChanged: _onTextChanged,
        ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final item = _suggestions[index];
                return ListTile(
                  title: Text(
                    item.licenseNo,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    '${item.name} - ${item.businessName}',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    _controller.text = item.licenseNo;
                    setState(() => _showSuggestions = false);
                    widget.onSelected(item);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
```

---

## 2. Get License Details

### Request

```
POST /api/trade-licenses/details
Content-Type: application/json

{
    "license_no": "No.TMB/TL/2022/01 (A)"
}
```

### Response (200 OK)

```json
{
    "status": true,
    "message": "License details retrieved successfully",
    "data": {
        "id": 1,
        "sl_no": 1,
        "name": "Shri Amit Rishi",
        "business_name": "Rice Hotel",
        "renewal_date": null,
        "business_address": "Anandamath, Tura",
        "license_no": "No.TMB/TL/2022/01 (A)",
        "trade_type": "Rice Hotel",
        "license_fee_per_annum": 500.00,
        "valid_upto": "2024-03-14",
        "remarks": "",
        "payment_status": "unpaid",
        "payment_date": null,
        "created_at": "2026-05-19T00:00:00.000000Z",
        "updated_at": "2026-05-19T00:00:00.000000Z"
    }
}
```

### Response (404 Not Found)

```json
{
    "status": false,
    "message": "License not found",
    "data": null
}
```

### Flutter Implementation

```dart
Future<TradeLicense?> getTradeLicenseDetails(String licenseNo) async {
  final response = await http.post(
    Uri.parse('$baseUrl/trade-licenses/details'),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: json.encode({'license_no': licenseNo}),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == true && data['data'] != null) {
      return TradeLicense.fromJson(data['data']);
    }
  }
  return null;
}
```

### License Details Screen

```dart
class TradeLicenseDetailScreen extends StatefulWidget {
  final String licenseNo;

  const TradeLicenseDetailScreen({Key? key, required this.licenseNo})
      : super(key: key);

  @override
  State<TradeLicenseDetailScreen> createState() => _TradeLicenseDetailScreenState();
}

class _TradeLicenseDetailScreenState extends State<TradeLicenseDetailScreen> {
  TradeLicense? _license;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final license = await getTradeLicenseDetails(widget.licenseNo);

    setState(() {
      _license = license;
      _isLoading = false;
      if (license == null) _error = 'License not found';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trade License Details')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
              : _buildDetails(),
    );
  }

  Widget _buildDetails() {
    final license = _license!;
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(license),
          SizedBox(height: 20),
          if (!license.isPaid) _buildPayButton(license),
          if (license.isPaid) _buildPaidBadge(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(TradeLicense license) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('License No.', license.licenseNo),
            _buildRow('Name', license.name ?? 'N/A'),
            _buildRow('Business Name', license.businessName ?? 'N/A'),
            _buildRow('Business Address', license.businessAddress ?? 'N/A'),
            _buildRow('Trade Type', license.tradeType ?? 'N/A'),
            _buildRow('License Fee/Year', '₹${license.licenseFeePerAnnum ?? 0}'),
            _buildRow('Valid Upto', license.validUpto ?? 'N/A'),
            _buildRow('Renewal Date', license.renewalDate ?? 'N/A'),
            if (license.remarks != null && license.remarks!.isNotEmpty)
              _buildRow('Remarks', license.remarks!),
            Divider(),
            _buildRow('Payment Status', license.paymentStatus.toUpperCase(),
                isBold: true,
                color: license.isPaid ? Colors.green : Colors.red),
            if (license.paymentDate != null)
              _buildRow('Payment Date', license.paymentDate!),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(TradeLicense license) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _processPayment(license),
        icon: Icon(Icons.payment),
        label: Text(
          'Pay ₹${license.licenseFeePerAnnum ?? 0}',
          style: TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPaidBadge() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 28),
          SizedBox(width: 8),
          Text(
            'PAYMENT COMPLETED',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(TradeLicense license) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Payment'),
        content: Text(
          'Pay ₹${license.licenseFeePerAnnum} for license ${license.licenseNo}?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Confirm Pay')),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await payTradeLicense(license.licenseNo);
      if (result != null && mounted) {
        setState(() => _license = result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
```

---

## 3. Pay for License

### Request

```
POST /api/trade-licenses/pay
Content-Type: application/json

{
    "license_no": "No.TMB/TL/2022/01 (A)",
    "amount": 500.00,
    "remarks": "Paid via mobile app"
}
```

> Note: `amount` and `remarks` are optional fields.

### Response (200 OK - Payment Success)

```json
{
    "status": true,
    "message": "Payment successful. License has been marked as paid.",
    "data": {
        "id": 1,
        "sl_no": 1,
        "name": "Shri Amit Rishi",
        "business_name": "Rice Hotel",
        "renewal_date": null,
        "business_address": "Anandamath, Tura",
        "license_no": "No.TMB/TL/2022/01 (A)",
        "trade_type": "Rice Hotel",
        "license_fee_per_annum": 500.00,
        "valid_upto": "2024-03-14",
        "remarks": "",
        "payment_status": "paid",
        "payment_date": "2026-05-19T00:00:00.000000Z",
        "created_at": "2026-05-19T00:00:00.000000Z",
        "updated_at": "2026-05-19T00:00:00.000000Z"
    }
}
```

### Response (200 OK - Already Paid)

```json
{
    "status": true,
    "message": "License payment has already been made",
    "data": {
        "id": 1,
        "sl_no": 1,
        "name": "Shri Amit Rishi",
        "business_name": "Rice Hotel",
        "renewal_date": null,
        "business_address": "Anandamath, Tura",
        "license_no": "No.TMB/TL/2022/01 (A)",
        "trade_type": "Rice Hotel",
        "license_fee_per_annum": 500.00,
        "valid_upto": "2024-03-14",
        "remarks": "",
        "payment_status": "paid",
        "payment_date": "2026-05-19T00:00:00.000000Z",
        "created_at": "2026-05-19T00:00:00.000000Z",
        "updated_at": "2026-05-19T00:00:00.000000Z"
    }
}
```

### Response (404 Not Found)

```json
{
    "status": false,
    "message": "License not found",
    "data": null
}
```

### Flutter Implementation

```dart
Future<TradeLicense?> payTradeLicense(String licenseNo, {double? amount, String? remarks}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/trade-licenses/pay'),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'license_no': licenseNo,
      if (amount != null) 'amount': amount,
      if (remarks != null) 'remarks': remarks,
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == true && data['data'] != null) {
      return TradeLicense.fromJson(data['data']);
    }
  }
  return null;
}
```

---

## 4. Get Payment Statistics (Optional Admin Endpoint)

### Request

```
GET /api/trade-licenses/stats
```

### Response (200 OK)

```json
{
    "status": true,
    "message": "Trade license statistics",
    "data": {
        "total": 1350,
        "paid": 0,
        "unpaid": 1350
    }
}
```

### Flutter Implementation

```dart
class TradeLicenseStats {
  final int total;
  final int paid;
  final int unpaid;

  TradeLicenseStats({
    required this.total,
    required this.paid,
    required this.unpaid,
  });

  factory TradeLicenseStats.fromJson(Map<String, dynamic> json) {
    return TradeLicenseStats(
      total: json['total'] ?? 0,
      paid: json['paid'] ?? 0,
      unpaid: json['unpaid'] ?? 0,
    );
  }
}

Future<TradeLicenseStats?> getTradeLicenseStats() async {
  final response = await http.get(
    Uri.parse('$baseUrl/trade-licenses/stats'),
    headers: {'Accept': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == true && data['data'] != null) {
      return TradeLicenseStats.fromJson(data['data']);
    }
  }
  return null;
}
```

---

## Complete Service Class

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class TradeLicenseService {
  static const String baseUrl = 'https://laravelv2.turamunicipalboard.com/api';

  /// Search license numbers for autocomplete dropdown
  static Future<List<TradeLicenseSearchResult>> search(String query) async {
    if (query.length < 1) return [];

    final response = await http.post(
      Uri.parse('$baseUrl/trade-licenses/search'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({'query': query}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        return (data['data'] as List)
            .map((item) => TradeLicenseSearchResult.fromJson(item))
            .toList();
      }
    }
    return [];
  }

  /// Get full license details by license number
  static Future<TradeLicense?> getDetails(String licenseNo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/trade-licenses/details'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({'license_no': licenseNo}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true && data['data'] != null) {
        return TradeLicense.fromJson(data['data']);
      }
    }
    return null;
  }

  /// Pay for a trade license
  static Future<TradeLicense?> pay(String licenseNo, {double? amount, String? remarks}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/trade-licenses/pay'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'license_no': licenseNo,
        if (amount != null) 'amount': amount,
        if (remarks != null) 'remarks': remarks,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true && data['data'] != null) {
        return TradeLicense.fromJson(data['data']);
      }
    }
    return null;
  }

  /// Get statistics (total/paid/unpaid counts)
  static Future<TradeLicenseStats?> getStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/trade-licenses/stats'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true && data['data'] != null) {
        return TradeLicenseStats.fromJson(data['data']);
      }
    }
    return null;
  }
}

// ───────────────────────────────────────────
// Data Models
// ───────────────────────────────────────────

class TradeLicenseSearchResult {
  final String licenseNo;
  final String name;
  final String businessName;

  TradeLicenseSearchResult({
    required this.licenseNo,
    required this.name,
    required this.businessName,
  });

  factory TradeLicenseSearchResult.fromJson(Map<String, dynamic> json) {
    return TradeLicenseSearchResult(
      licenseNo: json['license_no'] ?? '',
      name: json['name'] ?? '',
      businessName: json['business_name'] ?? '',
    );
  }
}

class TradeLicense {
  final int id;
  final int? slNo;
  final String? name;
  final String? businessName;
  final String? renewalDate;
  final String? businessAddress;
  final String licenseNo;
  final String? tradeType;
  final double? licenseFeePerAnnum;
  final String? validUpto;
  final String? remarks;
  final String paymentStatus;
  final String? paymentDate;

  TradeLicense({
    required this.id,
    this.slNo,
    this.name,
    this.businessName,
    this.renewalDate,
    this.businessAddress,
    required this.licenseNo,
    this.tradeType,
    this.licenseFeePerAnnum,
    this.validUpto,
    this.remarks,
    required this.paymentStatus,
    this.paymentDate,
  });

  factory TradeLicense.fromJson(Map<String, dynamic> json) {
    return TradeLicense(
      id: json['id'],
      slNo: json['sl_no'],
      name: json['name'],
      businessName: json['business_name'],
      renewalDate: json['renewal_date'],
      businessAddress: json['business_address'],
      licenseNo: json['license_no'],
      tradeType: json['trade_type'],
      licenseFeePerAnnum: json['license_fee_per_annum'] != null
          ? (json['license_fee_per_annum'] as num).toDouble()
          : null,
      validUpto: json['valid_upto'],
      remarks: json['remarks'],
      paymentStatus: json['payment_status'] ?? 'unpaid',
      paymentDate: json['payment_date'],
    );
  }

  bool get isPaid => paymentStatus == 'paid';
}

class TradeLicenseStats {
  final int total;
  final int paid;
  final int unpaid;

  TradeLicenseStats({
    required this.total,
    required this.paid,
    required this.unpaid,
  });

  factory TradeLicenseStats.fromJson(Map<String, dynamic> json) {
    return TradeLicenseStats(
      total: json['total'] ?? 0,
      paid: json['paid'] ?? 0,
      unpaid: json['unpaid'] ?? 0,
    );
  }
}
```

---

## Complete Usage Example (Main Screen)

```dart
import 'package:flutter/material.dart';

class TradeLicenseScreen extends StatefulWidget {
  const TradeLicenseScreen({Key? key}) : super(key: key);

  @override
  State<TradeLicenseScreen> createState() => _TradeLicenseScreenState();
}

class _TradeLicenseScreenState extends State<TradeLicenseScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<TradeLicenseSearchResult> _suggestions = [];
  TradeLicense? _selectedLicense;
  bool _isSearching = false;
  bool _isLoadingDetails = false;
  bool _isPaying = false;

  void _onSearchChanged(String value) async {
    if (value.length < 1) {
      setState(() {
        _suggestions = [];
        _selectedLicense = null;
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await TradeLicenseService.search(value);
    setState(() {
      _suggestions = results;
      _isSearching = false;
    });
  }

  void _onLicenseSelected(TradeLicenseSearchResult item) async {
    setState(() {
      _searchController.text = item.licenseNo;
      _suggestions = [];
      _isLoadingDetails = true;
      _selectedLicense = null;
    });

    final license = await TradeLicenseService.getDetails(item.licenseNo);
    setState(() {
      _selectedLicense = license;
      _isLoadingDetails = false;
    });
  }

  void _onPayPressed() async {
    if (_selectedLicense == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Payment'),
        content: Text(
          'Pay ₹${_selectedLicense!.licenseFeePerAnnum} '
          'for license ${_selectedLicense!.licenseNo}?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Pay Now')),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isPaying = true);
      final result = await TradeLicenseService.pay(_selectedLicense!.licenseNo);
      setState(() {
        if (result != null) _selectedLicense = result;
        _isPaying = false;
      });

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment successful!'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trade License Payment')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Search Field ──
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter License Number',
                hintText: 'e.g. TMB/TL/2022',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _isSearching
                    ? Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : null,
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),

            // ── Suggestions Dropdown ──
            if (_suggestions.isNotEmpty)
              Container(
                margin: EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: BoxConstraints(maxHeight: 250),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final item = _suggestions[index];
                    return ListTile(
                      dense: true,
                      title: Text(item.licenseNo,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text(
                          '${item.name} • ${item.businessName}',
                          style: TextStyle(fontSize: 12)),
                      onTap: () => _onLicenseSelected(item),
                    );
                  },
                ),
              ),

            SizedBox(height: 20),

            // ── Loading Details ──
            if (_isLoadingDetails) CircularProgressIndicator(),

            // ── License Details Card ──
            if (_selectedLicense != null) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow('License No.', _selectedLicense!.licenseNo),
                      _infoRow('Name', _selectedLicense!.name ?? 'N/A'),
                      _infoRow('Business', _selectedLicense!.businessName ?? 'N/A'),
                      _infoRow('Address', _selectedLicense!.businessAddress ?? 'N/A'),
                      _infoRow('Trade Type', _selectedLicense!.tradeType ?? 'N/A'),
                      _infoRow('Fee/Year', '₹${_selectedLicense!.licenseFeePerAnnum ?? 0}'),
                      _infoRow('Valid Upto', _selectedLicense!.validUpto ?? 'N/A'),
                      Divider(),
                      _infoRow('Status', _selectedLicense!.paymentStatus.toUpperCase(),
                          color: _selectedLicense!.isPaid ? Colors.green : Colors.red),
                      if (_selectedLicense!.paymentDate != null)
                        _infoRow('Paid On', _selectedLicense!.paymentDate!),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // ── Pay Button or Paid Badge ──
              if (!_selectedLicense!.isPaid)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isPaying ? null : _onPayPressed,
                    icon: _isPaying
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Icon(Icons.payment),
                    label: Text(_isPaying
                        ? 'Processing...'
                        : 'Pay ₹${_selectedLicense!.licenseFeePerAnnum ?? 0}'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              if (_selectedLicense!.isPaid)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('PAYMENT COMPLETED',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800)),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700))),
          Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontWeight:
                          color != null ? FontWeight.bold : FontWeight.normal,
                      color: color))),
        ],
      ),
    );
  }
}
```

---

## Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.2.1
```

---

## Flow Diagram

```
┌─────────────────────────────────────────────┐
│          User opens Trade License screen     │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  User types license number in search field   │
│  (e.g., "TMB/TL/2022")                      │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  POST /api/trade-licenses/search             │
│  → Returns matching licenses for dropdown    │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  User selects a license from dropdown        │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  POST /api/trade-licenses/details            │
│  → Returns full license details              │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  Display license details card                │
│  • Name, Business, Address, Trade Type       │
│  • License Fee, Valid Upto                   │
│  • Payment Status (Paid / Unpaid)            │
└─────────────────┬───────────────────────────┘
                  │
          ┌───────┴───────┐
          │               │
     Unpaid           Already Paid
          │               │
          ▼               ▼
┌──────────────────┐  ┌──────────────────┐
│ Show "Pay" button│  │ Show "Paid" badge│
└────────┬─────────┘  └──────────────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│  User taps "Pay" → Confirmation dialog       │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  POST /api/trade-licenses/pay                │
│  → payment_status = "paid"                   │
│  → payment_date = now()                      │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  Show success snackbar + "Paid" badge        │
└─────────────────────────────────────────────┘
```

---

## Error Handling

| Status Code | Meaning | Action |
|-------------|---------|--------|
| 200 | Success | Process data |
| 404 | License not found | Show "License not found" message |
| 500 | Server error | Show generic error, retry |

Always check the `status` field in the response JSON:
- `status: true` → Operation succeeded
- `status: false` → Operation failed, read `message` for details