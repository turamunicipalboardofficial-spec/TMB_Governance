# Holding Tax - Flutter Integration Guide

## Overview

This document describes the backend APIs and integration logic for the **Holding Tax** module in the Flutter app. The flow is:

1. User types a Holding Number in a search field → autocomplete dropdown appears with matching results
2. User selects a Holding Number from the dropdown → full details are fetched and displayed
3. User taps "Pay" → payment is processed, status updates to "paid"
4. If already paid, show a "Payment Completed" badge instead of the pay button

---

## Base URL

```
https://laravelv2.turamunicipalboard.com/api
```

> **Note:** No JWT authentication token is required for these endpoints. They are publicly accessible.

---

## API Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/holding-taxes/search` | Autocomplete search by holding number or name |
| `POST` | `/api/holding-taxes/details` | Get full holding tax details by holding number |
| `POST` | `/api/holding-taxes/pay` | Mark holding tax as paid |
| `GET`  | `/api/holding-taxes/stats` | Get payment statistics (total/paid/unpaid counts) |

---

## 1. Search Holding Numbers (Autocomplete)

**Purpose:** Provide a dropdown/autocomplete where the user types partial holding number or name and gets matching results.

### Request

```
POST /api/holding-taxes/search
Content-Type: application/json
Accept: application/json

{
    "q": "TMB/HT/Mat"
}
```

- **`q`** (string, optional): The search query. Can be a partial holding number or name. Minimum 1 character.
- If `q` is empty or omitted, returns all 1,322 records (limit 200).

### Response (200 OK)

```json
{
    "status": true,
    "message": "All holding tax records",
    "data": [
        {
            "holding_no": "No.TMB/HT/Mat/1",
            "name": "Smt Sengmetira A Sangma",
            "address": "Matchakolgre"
        },
        {
            "holding_no": "No.TMB/HT/Mat/2",
            "name": "Shri Becking D Marak",
            "address": "Matchakolgre"
        }
    ]
}
```

### Response Fields in Each Item

| Field | Type | Description |
|-------|------|-------------|
| `holding_no` | string | The unique holding number (primary key) |
| `name` | string | Owner name |
| `address` | string | Holding address/locality |

### Logic to Implement in Flutter

1. Create a text field for "Enter Holding Number".
2. On every text change (debounce ~300ms recommended):
   - If text length < 1, clear the dropdown.
   - Call `POST /api/holding-taxes/search` with `{"q": "<typed_text>"}`.
   - Parse the `data` array from the response.
   - Display each item in a dropdown list showing: `holding_no` (bold) + `name` (subtitle) + `address`.
3. When user taps a dropdown item:
   - Fill the text field with the selected `holding_no`.
   - Hide the dropdown.
   - Trigger the details API call (see next section).

### Model to Parse

Create a `HoldingTaxSearchResult` model with:
- `holding_no` → String
- `name` → String
- `address` → String

Parse from `json['holding_no']`, `json['name']`, `json['address']`.

---

## 2. Get Holding Tax Details

**Purpose:** After user selects a holding number from the autocomplete, fetch and display full details.

### Request

```
POST /api/holding-taxes/details
Content-Type: application/json
Accept: application/json

{
    "holding_no": "No.TMB/HT/Mat/1"
}
```

- **`holding_no`** (string, required): The exact holding number selected from search.

### Response (200 OK - Found)

```json
{
    "status": true,
    "message": "Holding tax details retrieved successfully",
    "data": {
        "holding_no": "No.TMB/HT/Mat/1",
        "sl_no": "1",
        "name": "Smt Sengmetira A Sangma",
        "address": "Matchakolgre",
        "holding_tax": 720.0,
        "water_tax": 0.0,
        "latrine_tax": 0.0,
        "latrine_fee": 0.0,
        "light_and_fan": 0.0,
        "conservancy_scavenging": 0.0,
        "swachh_bharat_mission": 0.0,
        "total_tax": 720.0,
        "remarks": "",
        "ward": "VIII",
        "payment_status": "unpaid",
        "payment_date": null,
        "paid_amount": null,
        "payment_remarks": null,
        "created_at": "2026-05-19T00:00:00.000000Z",
        "updated_at": "2026-05-19T00:00:00.000000Z"
    }
}
```

### Response (404 Not Found)

```json
{
    "status": false,
    "message": "Holding tax record not found",
    "data": null
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `holding_no` | string | Unique holding number (primary key) |
| `sl_no` | string | Serial number from Excel |
| `name` | string | Owner name |
| `address` | string | Address/locality |
| `holding_tax` | float | Holding tax amount |
| `water_tax` | float | Water tax amount |
| `latrine_tax` | float | Latrine tax amount |
| `latrine_fee` | float | Latrine fee |
| `light_and_fan` | float | Light and fan charges |
| `conservancy_scavenging` | float | Conservancy/scavenging charges |
| `swachh_bharat_mission` | float | Swachh Bharat Mission cess |
| `total_tax` | float | **Total tax due** (sum of all above) |
| `remarks` | string | Remarks (if any) |
| `ward` | string | Ward name (e.g. "VIII") |
| `payment_status` | string | `"paid"` or `"unpaid"` |
| `payment_date` | string/null | ISO date when payment was made |
| `paid_amount` | float/null | Amount that was paid |
| `payment_remarks` | string/null | Payment remarks |
| `created_at` | string | Record creation timestamp |
| `updated_at` | string | Last update timestamp |

### Logic to Implement in Flutter

1. On selecting a holding number from the autocomplete, call `POST /api/holding-taxes/details`.
2. Show a loading indicator while the API call is in progress.
3. On success (`status == true`), parse the `data` object into a `HoldingTax` model and display:
   - Owner name, address, ward
   - All individual tax components (holding_tax, water_tax, etc.)
   - **Total Tax** prominently displayed
   - Payment status (green badge if paid, red if unpaid)
   - If paid, also show payment_date, paid_amount, payment_remarks
4. On failure (`status == false`), show error message "Holding tax record not found".
5. Based on `payment_status`:
   - If `"unpaid"` → show "Pay ₹{total_tax}" button
   - If `"paid"` → show "PAYMENT COMPLETED" badge with payment details

### Model to Parse

Create a `HoldingTax` model with all fields listed above. All numeric fields (`holding_tax`, `water_tax`, etc.) should be parsed as `double`. Parse `null` values gracefully for optional fields like `payment_date`, `paid_amount`, `payment_remarks`.

---

## 3. Pay Holding Tax

**Purpose:** Process the payment for a holding tax record. This marks the record as "paid" in the database.

### Request

```
POST /api/holding-taxes/pay
Content-Type: application/json
Accept: application/json

{
    "holding_no": "No.TMB/HT/Mat/1",
    "paid_amount": 720.00,
    "payment_remarks": "Paid via mobile app"
}
```

- **`holding_no`** (string, required): The exact holding number to pay for.
- **`paid_amount`** (float, optional): The amount being paid. If not provided, defaults to `total_tax`.
- **`payment_remarks`** (string, optional): Any remarks about the payment (e.g. "Paid via mobile app", "Cash payment").

### Response (200 OK - Payment Success)

```json
{
    "status": true,
    "message": "Payment successful. Holding tax has been marked as paid.",
    "data": {
        "holding_no": "No.TMB/HT/Mat/1",
        "sl_no": "1",
        "name": "Smt Sengmetira A Sangma",
        "address": "Matchakolgre",
        "holding_tax": 720.0,
        "water_tax": 0.0,
        "latrine_tax": 0.0,
        "latrine_fee": 0.0,
        "light_and_fan": 0.0,
        "conservancy_scavenging": 0.0,
        "swachh_bharat_mission": 0.0,
        "total_tax": 720.0,
        "remarks": "",
        "ward": "VIII",
        "payment_status": "paid",
        "payment_date": "2026-05-19",
        "paid_amount": 720.0,
        "payment_remarks": "Paid via mobile app",
        "created_at": "2026-05-19T00:00:00.000000Z",
        "updated_at": "2026-05-19T12:30:00.000000Z"
    }
}
```

### Response (200 OK - Already Paid)

```json
{
    "status": true,
    "message": "Holding tax payment has already been made",
    "data": {
        "holding_no": "No.TMB/HT/Mat/1",
        "payment_status": "paid",
        "payment_date": "2026-05-19",
        "paid_amount": 720.0,
        "payment_remarks": "Paid via mobile app",
        "...": "..."
    }
}
```

> When `message` contains "already been made", the record was already paid. Show the existing payment info to the user.

### Response (404 Not Found)

```json
{
    "status": false,
    "message": "Holding tax record not found",
    "data": null
}
```

### Logic to Implement in Flutter

1. When user taps the "Pay" button:
   - Show a confirmation dialog: "Pay ₹{total_tax} for Holding No. {holding_no}?"
   - If confirmed, call `POST /api/holding-taxes/pay` with the holding_no, paid_amount (use total_tax), and payment_remarks.
2. While the API call is in progress, show a loading state on the button (disable it, show spinner).
3. On success response:
   - If `message` contains "Payment successful" → show green success snackbar "Payment successful!"
   - If `message` contains "already been made" → show info snackbar "This holding tax has already been paid."
   - Update the details screen with the new data (refresh the holding tax object from the response).
   - Switch from "Pay" button to "PAYMENT COMPLETED" badge.
4. On failure → show red error snackbar "Payment failed. Please try again."

---

## 4. Get Statistics (Optional)

**Purpose:** Get overall counts of paid/unpaid holding tax records. Useful for admin dashboards or summary screens.

### Request

```
GET /api/holding-taxes/stats
Accept: application/json
```

No request body needed.

### Response (200 OK)

```json
{
    "status": true,
    "message": "Holding tax statistics",
    "data": {
        "total": 1322,
        "paid": 0,
        "unpaid": 1322
    }
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `total` | int | Total number of holding tax records |
| `paid` | int | Number of records marked as paid |
| `unpaid` | int | Number of records still unpaid |

### Logic to Implement in Flutter

1. Call `GET /api/holding-taxes/stats` (no body needed).
2. Parse the `data` object into a `HoldingTaxStats` model.
3. Display in a summary card: "Total: {total} | Paid: {paid} | Unpaid: {unpaid}".

---

## Complete Screen Flow

### Screen 1: Search & Select

1. Display a search text field with hint "Enter Holding Number (e.g. TMB/HT/Mat/1)".
2. As user types, call the search API and show results in a dropdown below the field.
3. Each dropdown item displays:
   - **Line 1 (bold):** `holding_no`
   - **Line 2 (subtitle):** `name` — `address`
4. When user taps an item, fill the text field and navigate to details.

### Screen 2: Holding Tax Details

1. Show a loading indicator while fetching details.
2. Display all tax information in a card:
   - **Header:** Holding No, Owner Name, Address, Ward
   - **Tax Breakdown:** Holding Tax, Water Tax, Latrine Tax, Latrine Fee, Light & Fan, Conservancy/Scavenging, Swachh Bharat Mission
   - **Total Tax:** Display prominently (large, bold)
   - **Payment Status:**
     - If `unpaid`: Show red "UNPAID" badge + "Pay ₹{total_tax}" button
     - If `paid`: Show green "PAYMENT COMPLETED" badge + payment date, paid amount, remarks

### Screen 3: Payment Confirmation

1. Show a confirmation dialog with: "Pay ₹{total_tax} for Holding No. {holding_no}?"
2. Two buttons: "Cancel" and "Confirm Pay"
3. On confirm, call the pay API.
4. On success, update the UI to show paid status.

---

## Error Handling

| Scenario | HTTP Status | Action |
|----------|-------------|--------|
| Network error | N/A | Show "Network error. Please check your connection." |
| Search returns empty | 200 (empty `data`) | Show "No results found" below the search field |
| Details not found | 404 | Show "Holding tax record not found" |
| Payment fails | 4xx/5xx | Show "Payment failed. Please try again." |
| Already paid | 200 (message: "already been made") | Show info snackbar, update UI to paid state |

---

## Data Model Summary

### HoldingTaxSearchResult
- `holding_no` → String
- `name` → String
- `address` → String

### HoldingTax (Full Details)
- `holding_no` → String (primary key)
- `sl_no` → String
- `name` → String
- `address` → String
- `holding_tax` → double
- `water_tax` → double
- `latrine_tax` → double
- `latrine_fee` → double
- `light_and_fan` → double
- `conservancy_scavenging` → double
- `swachh_bharat_mission` → double
- `total_tax` → double
- `remarks` → String
- `ward` → String
- `payment_status` → String ("paid" / "unpaid")
- `payment_date` → String? (nullable)
- `paid_amount` → double? (nullable)
- `payment_remarks` → String? (nullable)
- `created_at` → String
- `updated_at` → String

### HoldingTaxStats
- `total` → int
- `paid` → int
- `unpaid` → int

---

## Quick Reference - API Calls

| Action | Method | Endpoint | Body |
|--------|--------|----------|------|
| Search | POST | `/api/holding-taxes/search` | `{"q": "search_term"}` |
| Details | POST | `/api/holding-taxes/details` | `{"holding_no": "No.TMB/HT/Mat/1"}` |
| Pay | POST | `/api/holding-taxes/pay` | `{"holding_no": "No.TMB/HT/Mat/1", "paid_amount": 720, "payment_remarks": "..."}` |
| Stats | GET | `/api/holding-taxes/stats` | None |