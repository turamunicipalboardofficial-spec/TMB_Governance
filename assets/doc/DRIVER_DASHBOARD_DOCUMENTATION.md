# 🚛 Driver Dashboard Feature — Comprehensive Documentation

> **Feature:** Garbage Truck Driver Dashboard  
> **Module:** `lib/features/garbage_truck_tracking/`  
> **State Management:** GetX  
> **Last Updated:** 2026-05-25

---

## Table of Contents

1. [Overview](#1-overview)
2. [File Structure](#2-file-structure)
3. [Authentication Flow](#3-authentication-flow)
4. [Data Models](#4-data-models)
5. [API Endpoints](#5-api-endpoints)
6. [Controller Logic](#6-controller-logic)
7. [Views & UI](#7-views--ui)
8. [GPS & Location Tracking](#8-gps--location-tracking)
9. [Dependency Injection (Binding)](#9-dependency-injection-binding)
10. [Routing](#10-routing)
11. [State Diagram](#11-state-diagram)
12. [Dependencies](#12-dependencies)

---

## 1. Overview

The **Driver Dashboard** is a role-specific interface within the Garbage Truck Tracking module. It allows authenticated garbage truck drivers to:

- **Log in** using their registered phone number and password.
- **Start / End shifts** to control when GPS tracking is active.
- **View their assigned route** for the day with sequenced stops.
- **Send GPS location updates** to the server (automatic every 15 seconds + manual trigger).
- **Monitor real-time stats**: speed, heading, altitude, accuracy, coordinates.
- **View shift summaries** after ending a shift (duration, distance, locations reported).

### Key Capabilities

| Capability | Description |
|---|---|
| Phone + Password Auth | Secure login via API token storage in SharedPreferences |
| Shift Lifecycle | Start → Active tracking → End shift |
| Auto GPS Updates | Location sent to server every **15 seconds** during active shift |
| Manual Location Send | On-demand GPS push via "Send Location" button |
| Route Visualization | Mock map + sequenced stop list with status indicators |
| Reactive UI | All state managed via GetX `Rx` observables + `Obx` widgets |

---

## 2. File Structure

```
lib/features/garbage_truck_tracking/
├── controllers/
│   ├── driver_dashboard_controller.dart    # Main controller (auth, shift, GPS, route)
│   └── garbage_truck_controller.dart       # Citizen-facing truck list controller
├── data/
│   └── garbage_truck_data_source.dart      # API data source (driver + admin + citizen)
├── driver_dashboard_binding.dart           # GetX binding for DI
├── models/
│   └── driver_route_model.dart             # Data models (DriverRouteData, RouteStop, etc.)
├── repositories/
│   └── garbage_truck_repository.dart       # Repository layer (error handling, logging)
└── views/
    ├── garbage_truck_view.dart             # Citizen-facing truck list view
    ├── garbage_truck_detail_view.dart      # Citizen-facing truck detail view
    └── widgets/
        ├── live_map_tab.dart               # Citizen live map with location-aware UI
        └── driver/
            ├── driver_view.dart            # Main dashboard (3-tab scaffold)
            ├── driver_map_tab.dart         # Driver map tab (visualization + GPS status)
            ├── driver_route_tab.dart       # Driver route tab (sequenced stops)
            └── driver_shift_tab.dart       # Driver shift tab (start/end + GPS info)
```

---

## 3. Authentication Flow

### 3.1 Login Screen

The driver login screen is embedded within `driver_view.dart` and includes:

- **Phone Number** input field (type: phone, 10-digit validation)
- **Password** input field (obscured, minimum 4 characters)
- **Sign In** button that calls the login API

### 3.2 Login Process

```
User enters phone + password
        │
        ▼
POST /api/driver/login  { phone, password }
        │
        ▼
  ┌─── Response ───┐
  │                 │
Success           Failure
  │                 │
  ▼                 ▼
Save token to     Show error
SharedPreferences   Snackbar
  │
  ▼
Fetch driver name from response
  │
  ▼
Navigate to Dashboard (tab index 0)
```

### 3.3 Token Storage

- **Key:** `auth_token`
- **Storage:** `SharedPreferences` (persistent local storage)
- **Usage:** Automatically attached to all subsequent API requests via `ApiProvider`

### 3.4 Logout

- Clears `auth_token` from SharedPreferences
- Resets all controller state (shift, route, location data)
- Navigates back to login screen

---

## 4. Data Models

### File: `lib/features/garbage_truck_tracking/models/driver_route_model.dart`

#### `DriverRouteData`

| Field | Type | Description |
|---|---|---|
| `driver` | `DriverInfo?` | Driver details |
| `truck` | `TruckInfo?` | Assigned truck details |
| `route` | `DriverRouteInfo?` | Route with sequenced stops |
| `schedule` | `ScheduleInfo?` | Schedule (day, time, collection type) |

#### `DriverInfo`

| Field | Type |
|---|---|
| `id` | `int` |
| `name` | `String` |
| `phone` | `String` |
| `email` | `String?` |

#### `TruckInfo`

| Field | Type |
|---|---|
| `id` | `int` |
| `truckNumber` | `String` |
| `plateNumber` | `String` |
| `capacityTons` | `num?` |
| `status` | `String` |

#### `DriverRouteInfo`

| Field | Type |
|---|---|
| `routeId` | `int` |
| `routeName` | `String` |
| `distanceKm` | `num?` |
| `estimatedDurationMinutes` | `num?` |
| `stops` | `List<RouteStop>` |

#### `RouteStop`

| Field | Type | Description |
|---|---|---|
| `id` | `int` | Stop ID |
| `name` | `String` | Stop name |
| `latitude` | `double` | GPS latitude |
| `longitude` | `double` | GPS longitude |
| `sequence` | `int` | Order in route |
| `status` | `String` | `pending` / `in_progress` / `completed` / `skipped` |

#### `ScheduleInfo`

| Field | Type |
|---|---|
| `id` | `int` |
| `day` | `String` |
| `startTime` | `String` |
| `endTime` | `String` |
| `collectionType` | `String` |

#### `DriverShiftData`

| Field | Type |
|---|---|
| `shiftId` | `int?` |
| `shiftStartedAt` | `String?` |
| `shiftEndedAt` | `String?` |
| `totalLocationsReported` | `int?` |
| `totalDistanceKm` | `num?` |

---

## 5. API Endpoints

All endpoints are relative to the configured `ApiConstants.baseUrl`.

### 5.1 Driver Login

```
POST /api/driver/login
Content-Type: application/json

Request Body:
{
  "phone": "9876543210",
  "password": "securePass123"
}

Response (Success):
{
  "status": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "driver_name": "John Doe"
}
```

### 5.2 Start Shift

```
POST /api/driver/shift/start
Authorization: Bearer <token>
Content-Type: application/json

Request Body:
{
  "latitude": 25.5138,
  "longitude": 90.2195
}

Response:
{
  "status": true,
  "message": "Shift started",
  "data": {
    "shift_id": 42,
    "started_at": "2026-05-25T08:00:00Z"
  }
}
```

### 5.3 End Shift

```
POST /api/driver/shift/end
Authorization: Bearer <token>
Content-Type: application/json

Request Body:
{
  "latitude": 25.5200,
  "longitude": 90.2250
}

Response:
{
  "status": true,
  "message": "Shift ended",
  "data": {
    "shift_id": 42,
    "started_at": "2026-05-25T08:00:00Z",
    "ended_at": "2026-05-25T16:30:00Z",
    "total_locations_reported": 342,
    "total_distance_km": 45.2
  }
}
```

### 5.4 Update Location

```
POST /api/driver/location/update
Authorization: Bearer <token>
Content-Type: application/json

Request Body:
{
  "latitude": 25.5150,
  "longitude": 90.2200,
  "speed": 25.5,
  "heading": 180.0,
  "altitude": 50.0,
  "accuracy": 5.0,
  "timestamp": "2026-05-25T08:15:30Z"
}

Response:
{
  "status": true,
  "message": "Location updated"
}
```

### 5.5 Get Driver Route

```
GET /api/driver/route
Authorization: Bearer <token>

Response:
{
  "status": true,
  "data": {
    "driver": {
      "id": 1,
      "name": "John Doe",
      "phone": "9876543210"
    },
    "truck": {
      "id": 5,
      "truck_number": "TMB-005",
      "plate_number": "ML-05-AF-1234",
      "capacity_tons": 5
    },
    "route": {
      "route_id": 10,
      "route_name": "Main Market Route",
      "distance_km": 12.5,
      "estimated_duration_minutes": 120,
      "stops": [
        {
          "id": 1,
          "name": "Main Market",
          "latitude": 25.5138,
          "longitude": 90.2195,
          "sequence": 1,
          "status": "pending"
        }
      ]
    },
    "schedule": {
      "id": 1,
      "day": "monday",
      "start_time": "06:00",
      "end_time": "10:00",
      "collection_type": "residential"
    }
  }
}
```

---

## 6. Controller Logic

### File: `lib/features/garbage_truck_tracking/controllers/driver_dashboard_controller.dart`

The `DriverDashboardController` extends `GetxController` and manages all driver dashboard state.

### 6.1 State Enums

```dart
enum DriverAuthState { initial, loading, authenticated, error }
enum DriverShiftState { idle, loading, active, ended, error }
enum DriverRouteState { initial, loading, loaded, error }
```

### 6.2 Observable State Variables

#### Authentication State
| Variable | Type | Description |
|---|---|---|
| `authState` | `Rx<DriverAuthState>` | Current auth state |
| `isLoggedIn` | `RxBool` | Whether driver is authenticated |
| `driverName` | `RxnString` | Driver's display name |
| `loginError` | `RxnString` | Login error message |

#### Shift State
| Variable | Type | Description |
|---|---|---|
| `shiftState` | `Rx<DriverShiftState>` | Current shift state |
| `isOnShift` | `bool` (getter) | `true` when `shiftState == active` |
| `shiftStartTime` | `Rxn<DateTime>` | When shift was started |
| `shiftDuration` | `String` (getter) | Formatted HH:MM:SS duration |
| `shiftData` | `Rxn<DriverShiftData>` | Shift summary data after ending |
| `truckNumber` | `RxnString` | Assigned truck number |
| `errorMessage` | `RxnString` | Error message for UI display |

#### GPS Location State
| Variable | Type | Description |
|---|---|---|
| `currentLatitude` | `Rxn<double>` | Current GPS latitude |
| `currentLongitude` | `Rxn<double>` | Current GPS longitude |
| `currentSpeed` | `RxDouble` | Current speed in km/h |
| `currentHeading` | `Rxn<double>` | Heading in degrees |
| `currentAltitude` | `Rxn<double>` | Altitude in meters |
| `currentAccuracy` | `Rxn<double>` | GPS accuracy in meters |
| `isSendingLocation` | `RxBool` | Whether a location update is in progress |
| `totalLocationsSent` | `RxInt` | Count of locations sent this shift |
| `lastLocationSentAt` | `Rxn<DateTime>` | Timestamp of last successful send |
| `onLocationUpdate` | `Function(double, double)?` | Callback for external location updates |

#### Route State
| Variable | Type | Description |
|---|---|---|
| `routeState` | `Rx<DriverRouteState>` | Current route loading state |
| `routeData` | `Rxn<DriverRouteData>` | Fetched route + truck + schedule data |

### 6.3 Key Methods

#### `checkAuth()`
- Called in `onInit()`
- Reads `auth_token` from SharedPreferences
- If token exists → sets state to `authenticated`, fetches route
- If no token → stays at login screen

#### `login(String phone, String password)`
- Calls `_repo.login(phone, password)`
- On success: saves token, sets `driverName`, fetches route, shows success snackbar
- On failure: sets `loginError`, shows error snackbar

#### `logout()`
- Clears SharedPreferences token
- Stops GPS timer
- Resets all state to initial values

#### `startShift()`
- Gets current GPS coordinates via `Geolocator.getCurrentPosition()`
- Calls `_repo.startShift(latitude, longitude)`
- On success: starts 15-second GPS timer, sets `shiftState = active`
- On failure: shows error snackbar

#### `endShift()`
- Gets current GPS coordinates
- Stops GPS timer
- Calls `_repo.endShift(latitude, longitude)`
- On success: parses shift summary data, sets `shiftState = ended`

#### `sendManualLocationUpdate()`
- Gets current GPS position
- Calls `_repo.updateLocation()` with all GPS data
- Updates `totalLocationsSent` counter

#### `_startLocationUpdates()` (private)
- Creates a **15-second periodic timer**
- Each tick: gets GPS position → sends to server → updates UI state
- Calls `onLocationUpdate` callback if set

#### `loadDriverRoute()`
- Calls `_repo.getDriverRoute()`
- Parses response into `DriverRouteData`
- Updates `truckNumber` from route data

#### `fetchCurrentLocation()` (private)
- Uses `Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)`
- Updates all GPS observables (lat, lng, speed, heading, altitude, accuracy)
- Returns `Position?` for use by callers

#### `updateShiftDuration()` (private)
- Called every second via timer when shift is active
- Calculates elapsed time from `shiftStartTime`
- Updates `shiftDuration` formatted string

---

## 7. Views & UI

### 7.1 Main Dashboard (`driver_view.dart`)

A **3-tab Scaffold** with bottom navigation:

| Tab | Icon | Widget | Purpose |
|---|---|---|---|
| Shift | Icons.local_shipping_rounded | `DriverShiftTab` | Start/end shift, GPS status |
| Route | Icons.route_rounded | `DriverRouteTab` | View assigned route & stops |
| Map | Icons.map_rounded | `DriverMapTab` | Map visualization & GPS status |

#### App Bar Features
- Gradient background (`AppColors.headerGradient`)
- Driver name display
- Last location send timestamp (when on shift)
- Truck number display (when assigned)
- Logout button (red, with confirmation dialog)

#### Conditional Rendering
- **Not logged in:** Shows login form
- **Logged in:** Shows 3-tab dashboard with `IndexedStack` for tab persistence

### 7.2 Shift Tab (`driver_shift_tab.dart`)

Displays 4 cards:

1. **Truck Info Card** — Truck number, plate number, schedule (day, time, collection type)
2. **Shift Status Card** — Active/Inactive indicator, shift duration timer, Start/End Shift button
3. **Location Status Card** — GPS coordinates (lat/lng), speed, last update time
4. **Shift Summary Card** — Shown after ending shift (start/end time, locations reported, distance)

#### End Shift Dialog
- Confirmation dialog with warning icon
- "GPS tracking will stop" message
- Cancel / End Shift buttons

### 7.3 Route Tab (`driver_route_tab.dart`)

Displays:

1. **Route Header Card** — Route name, stop count, estimated duration, distance
2. **Route Stops List** — Timeline-style list with:
   - Sequence number circle (color-coded by status)
   - Stop name
   - Status badge (pending/in_progress/completed/skipped)
   - GPS coordinates
3. **Tips Card** — Helpful instructions for drivers

#### Stop Status Colors
| Status | Color | Icon |
|---|---|---|
| `completed` | Green (#2D9A66) | check_rounded |
| `in_progress` | Blue (#60A5FA) | directions_run_rounded |
| `skipped` | Red (#D3444D) | skip_next_rounded |
| `pending` | Gray (textSecondary) | radio_button_unchecked |

### 7.4 Map Tab (`driver_map_tab.dart`)

Displays:

1. **Map Card** — Mock visualization with:
   - Green gradient background with grid lines
   - Stop markers (positioned algorithmically, color-coded)
   - Current location marker ("You" badge)
   - Legend showing completed/total stops
   - "Send Location" and "Refresh Route" action buttons
2. **Current Location Card** — Lat, lng, speed, heading
3. **Route Stops Overview** — Progress bar + completed/in_progress/pending counts
4. **GPS Status Card** — Active/Inactive indicator, update count, last send time

---

## 8. GPS & Location Tracking

### 8.1 Location Service Integration

The driver dashboard uses the `geolocator` package directly (not through the centralized `LocationService`) for driver-specific GPS tracking.

### 8.2 GPS Update Flow

```
Shift Started
    │
    ▼
Start 15-second Timer
    │
    ▼ (every 15 seconds)
Geolocator.getCurrentPosition(desiredAccuracy: high)
    │
    ▼
Update UI observables (lat, lng, speed, heading, altitude, accuracy)
    │
    ▼
POST /api/driver/location/update
    │
    ▼
Increment totalLocationsSent
Update lastLocationSentAt
    │
    ▼
Call onLocationUpdate callback (if set)
    │
    ▼
Wait 15 seconds → repeat
```

### 8.3 GPS Data Captured

| Field | Source | Unit |
|---|---|---|
| Latitude | `position.latitude` | Degrees |
| Longitude | `position.longitude` | Degrees |
| Speed | `position.speed * 3.6` | km/h (converted from m/s) |
| Heading | `position.heading` | Degrees (0-360) |
| Altitude | `position.altitude` | Meters |
| Accuracy | `position.accuracy` | Meters |
| Timestamp | `DateTime.now().toUtc().toIso8601String()` | ISO 8601 UTC |

### 8.4 Location Permission Handling

**⚠️ IMPORTANT:** The driver dashboard currently does **NOT** explicitly request location permissions before accessing GPS. The `Geolocator.getCurrentPosition()` call will throw a `LocationPermissionException` if permissions are not granted.

**Current flow:**
1. Driver starts shift
2. Controller calls `Geolocator.getCurrentPosition()`
3. If permission denied → exception caught → error snackbar shown

**Recommended improvement:**
- Add explicit permission check and request in `onInit()` or before shift start
- Use `Geolocator.checkPermission()` → `Geolocator.requestPermission()` flow
- Show explanatory dialog if permission is permanently denied
- Direct user to app settings if `LocationPermission.deniedForever`

### 8.5 Manual Location Send

The "Send Location" button on the Map tab triggers `sendManualLocationUpdate()`:
- Gets fresh GPS position
- Sends to server immediately (outside the 15-second timer cycle)
- Useful for on-demand updates or when driver suspects auto-update failed

---

## 9. Dependency Injection (Binding)

### File: `lib/features/garbage_truck_tracking/driver_dashboard_binding.dart`

```dart
class DriverDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure ApiProvider is available
    if (!Get.isRegistered<ApiProvider>()) {
      Get.put<ApiProvider>(ApiProvider(), permanent: true);
    }
    
    // Data source (handles HTTP calls)
    Get.lazyPut<GarbageTruckDataSource>(
      () => GarbageTruckDataSource(Get.find<ApiProvider>()),
    );
    
    // Repository (error handling, logging)
    Get.lazyPut<GarbageTruckRepository>(
      () => GarbageTruckRepository(Get.find<GarbageTruckDataSource>()),
    );
    
    // Controller (business logic, state management)
    Get.lazyPut<DriverDashboardController>(
      () => DriverDashboardController(Get.find<GarbageTruckRepository>()),
    );
  }
}
```

### Dependency Chain
```
ApiProvider (HTTP client with auth token)
    │
    ▼
GarbageTruckDataSource (raw API calls)
    │
    ▼
GarbageTruckRepository (error handling, response parsing)
    │
    ▼
DriverDashboardController (state, timers, GPS, business logic)
```

---

## 10. Routing

### Route: `AppRoutes.driverDashboard`

```dart
// In app_routes.dart
static const String driverDashboard = '/driver-dashboard';

// In app_pages.dart
GetPage(
  name: AppRoutes.driverDashboard,
  page: () => const DriverView(),
  binding: DriverDashboardBinding(),
  transition: Transition.fadeIn,
  transitionDuration: const Duration(milliseconds: 300),
)
```

**Note:** This route is **not linked** from the main app navigation (home, auth, splash). It is accessible only via direct navigation or deep link, as the driver role is separate from the citizen-facing app flow.

---

## 11. State Diagram

```
                    ┌─────────────────────────────────────┐
                    │          App Launch                  │
                    │   checkAuth() reads SharedPreferences│
                    └──────────────┬──────────────────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    │                             │
              Token Found                   No Token
                    │                             │
                    ▼                             ▼
           ┌────────────────┐           ┌────────────────┐
           │  Authenticated │           │  Login Screen  │
           │  (Dashboard)   │           │  Phone + Pass  │
           └───────┬────────┘           └───────┬────────┘
                   │                            │
                   │                     POST /driver/login
                   │                            │
                   │                  ┌─────────┴─────────┐
                   │                  │                   │
                   │               Success             Failure
                   │                  │                   │
                   │                  ▼                   ▼
                   │         Save Token            Show Error
                   │         Fetch Route           Stay on Login
                   │                  │
                   └──────────────────┘
                            │
                   ┌────────┴────────┐
                   │  Dashboard      │
                   │  (3 Tabs)       │
                   └────────┬────────┘
                            │
              ┌─────────────┼─────────────┐
              │             │             │
         Shift Tab     Route Tab     Map Tab
              │             │             │
    ┌─────────┴──────┐      │             │
    │                │      │             │
Inactive          Active    │             │
    │                │      │             │
    ▼                ▼      │             │
Start Shift    End Shift    │             │
    │                │      │             │
    ▼                ▼      │             │
GPS Timer ON   GPS Timer OFF│             │
    │                │      │             │
    ▼                ▼      │             │
Every 15s:     Show Summary  │             │
Send Location              │             │
```

---

## 12. Dependencies

### Flutter Packages

| Package | Version | Purpose |
|---|---|---|
| `get` | ^4.7.2 | State management, DI, routing |
| `geolocator` | ^14.0.2 | GPS position retrieval |
| `geocoding` | ^4.0.2 | Reverse geocoding (address from coordinates) |
| `shared_preferences` | ^2.5.3 | Token persistence |
| `http` | (via ApiProvider) | HTTP client |

### Android Permissions Required

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS Permissions Required

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to track garbage truck routes and provide real-time collection updates.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to track garbage truck routes and provide real-time collection updates.</string>
```

---

## Appendix: Error Handling

| Scenario | Handling |
|---|---|
| Login fails | Error snackbar + `loginError` set |
| GPS permission denied | Caught in try/catch → error snackbar |
| GPS service disabled | Caught in try/catch → error snackbar |
| Location update API fails | Logged + `isSendingLocation` reset to false |
| Route fetch fails | `routeState = error` + retry button shown |
| Shift start fails | Error snackbar + `shiftState = idle` |
| Network timeout | Caught in repository layer → error message propagated |