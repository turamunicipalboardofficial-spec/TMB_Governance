# 🚛 Garbage Truck Real-Time Tracking System — Complete Documentation

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Database Schema](#database-schema)
4. [API Endpoints](#api-endpoints)
   - [Driver APIs](#driver-apis)
   - [Consumer APIs](#consumer-apis)
   - [Admin APIs](#admin-apis)
5. [ETA Calculation Logic](#eta-calculation-logic)
6. [Real-Time Updates Strategy](#real-time-updates-strategy)
7. [Driver Authentication](#driver-authentication)
8. [Flutter Integration Guide](#flutter-integration-guide)
9. [Implementation Steps](#implementation-steps)
10. [Deployment Notes](#deployment-notes)

---

## Overview

The Garbage Truck Real-Time Tracking System is an **Ola/Uber-style GPS tracking module** integrated into the Tura Municipal Corporation app. It allows:

- **Consumers (Citizens):** View garbage trucks on a map in real-time, check estimated arrival time (ETA), and view collection schedules for their ward.
- **Drivers:** Login separately, update GPS location (auto or manual), start/end shifts, and view assigned routes.
- **Admins (CEO/Editor):** Manage trucks, assign drivers, create collection schedules, and monitor fleet activity.

### Key Features

| Feature | Description |
|---------|-------------|
| Real-time GPS tracking | Trucks report location every 10-15 seconds |
| Map view for consumers | See all active trucks on a map (like Uber/Ola) |
| ETA calculation | "Your truck will arrive in ~12 minutes" |
| Ward-based filtering | Consumers see only trucks in their ward |
| Driver shift management | Start/end shift toggles tracking on/off |
| Collection schedule | Weekly schedule per ward |
| Fleet dashboard (Admin) | Overview of all trucks, active drivers, completed routes |
| Push notifications | Notify consumers when truck is nearby (future) |

---

## Architecture

```
┌─────────────────────────┐         GPS Location Update          ┌────────────────────────────┐
│                         │ ──── POST /driver/location/update ──► │                            │
│   Driver App (Flutter)  │         (lat, lng, speed, heading)   │     Laravel API Backend    │
│   - Background GPS      │                                      │     (This Project)         │
│   - Start/End Shift     │ ◄─── GET /driver/route ──────────── │                            │
│   - Route Display       │                                      │     ┌──────────────────┐   │
└─────────────────────────┘                                      │     │   MySQL Database │   │
                                                                 │     │   - trucks       │   │
┌─────────────────────────┐         GET /trucks/nearby?lat=X&lng=Y│     │   - locations    │   │
│                         │ ◄──── GET /trucks/eta?lat=X&lng=Y ── │     │   - drivers      │   │
│  Consumer App (Flutter) │         (trucks + ETA response)       │     │   - routes       │   │
│   - Map with truck      │                                      │     │   - schedules    │   │
│     markers             │ ──── GET /trucks/ward/{id} ─────────► │     └──────────────────┘   │
│   - ETA countdown       │                                      │                            │
│   - Schedule view       │                                      └────────────────────────────┘
│   - Notifications       │                                                  ▲
└─────────────────────────┘                                                  │
                                                                 ┌───────────┴──────────────┐
                                                                 │                          │
                                                                 │  Admin App / Dashboard   │
                                                                 │  - Fleet overview        │
                                                                 │  - Truck CRUD            │
                                                                 │  - Driver assignment     │
                                                                 │  - Schedule management   │
                                                                 │                          │
                                                                 └──────────────────────────┘
```

### Technology Stack

| Component | Technology |
|-----------|-----------|
| Backend API | Laravel 10+ (PHP 8.1+) |
| Authentication | JWT (tymon/jwt-auth) — existing in project |
| Database | MySQL |
| Location Storage | MySQL with indexed lat/lng (upgrade to PostGIS/Spatial later) |
| Consumer App | Flutter (Google Maps / Mapbox) |
| Driver App | Flutter (with background location service) |
| Real-time | Polling (MVP) → WebSocket/Pusher (Future) |

---

## Database Schema

### Table 1: `garbage_trucks`

Master table for all garbage trucks in the fleet.

```sql
CREATE TABLE garbage_trucks (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    truck_number VARCHAR(50) NOT NULL UNIQUE,          -- e.g., "TM-GT-001"
    plate_number VARCHAR(20) NOT NULL UNIQUE,           -- e.g., "ML-07-A-1234"
    truck_type ENUM('compactor', 'dumper', 'side_loader', 'roll_off') DEFAULT 'compactor',
    capacity_tons DECIMAL(5,2) DEFAULT 5.00,            -- capacity in tons
    ward_id BIGINT UNSIGNED NOT NULL,                   -- FK to ward_list.id (assigned area)
    status ENUM('active', 'maintenance', 'retired', 'breakdown') DEFAULT 'active',
    is_on_route BOOLEAN DEFAULT FALSE,                  -- currently on collection route
    latitude DECIMAL(10,8) DEFAULT NULL,                -- last known latitude
    longitude DECIMAL(11,8) DEFAULT NULL,               -- last known longitude
    last_location_update TIMESTAMP DEFAULT NULL,        -- when GPS was last received
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_ward_id (ward_id),
    INDEX idx_status (status),
    INDEX idx_is_on_route (is_on_route),
    INDEX idx_location (latitude, longitude)
);
```

**Sample Data:**
```sql
INSERT INTO garbage_trucks (truck_number, plate_number, truck_type, capacity_tons, ward_id, status) VALUES
('TM-GT-001', 'ML-07-A-1234', 'compactor', 5.00, 1, 'active'),
('TM-GT-002', 'ML-07-B-5678', 'dumper', 3.50, 1, 'active'),
('TM-GT-003', 'ML-07-C-9012', 'compactor', 5.00, 2, 'active'),
('TM-GT-004', 'ML-07-D-3456', 'side_loader', 2.00, 3, 'active'),
('TM-GT-005', 'ML-07-E-7890', 'roll_off', 7.00, 2, 'active');
```

---

### Table 2: `garbage_truck_drivers`

Driver profiles linked to the existing `users` table.

```sql
CREATE TABLE garbage_truck_drivers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL UNIQUE,            -- FK to users.id
    driver_license_number VARCHAR(50) NOT NULL,         -- driving license
    license_expiry DATE NOT NULL,
    truck_id BIGINT UNSIGNED DEFAULT NULL,              -- currently assigned truck (FK to garbage_trucks.id)
    is_on_duty BOOLEAN DEFAULT FALSE,                   -- currently on shift
    shift_started_at TIMESTAMP DEFAULT NULL,
    shift_ended_at TIMESTAMP DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_truck_id (truck_id),
    INDEX idx_is_on_duty (is_on_duty),
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (truck_id) REFERENCES garbage_trucks(id) ON DELETE SET NULL
);
```

**Sample Data:**
```sql
INSERT INTO garbage_truck_drivers (user_id, driver_license_number, license_expiry, truck_id) VALUES
(101, 'ML-DL-2023-001', '2027-12-31', 1),
(102, 'ML-DL-2023-002', '2027-06-30', 2),
(103, 'ML-DL-2023-003', '2028-03-15', 3),
(104, 'ML-DL-2023-004', '2026-11-20', 4),
(105, 'ML-DL-2023-005', '2027-09-01', 5);
```

---

### Table 3: `garbage_truck_locations`

GPS location history log for all trucks. This is the core table for real-time tracking.

```sql
CREATE TABLE garbage_truck_locations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    truck_id BIGINT UNSIGNED NOT NULL,                  -- FK to garbage_trucks.id
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    speed_kmh DECIMAL(5,2) DEFAULT 0.00,               -- current speed in km/h
    heading DECIMAL(5,2) DEFAULT NULL,                  -- direction 0-360 degrees
    accuracy_meters DECIMAL(8,2) DEFAULT NULL,          -- GPS accuracy in meters
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_truck_id (truck_id),
    INDEX idx_recorded_at (recorded_at),
    INDEX idx_truck_recorded (truck_id, recorded_at),
    INDEX idx_location (latitude, longitude),
    
    FOREIGN KEY (truck_id) REFERENCES garbage_trucks(id) ON DELETE CASCADE
);
```

**Note:** This table will grow rapidly. Consider:
- Partitioning by `recorded_at` (monthly partitions)
- Auto-deleting records older than 30 days via scheduled command
- Only keeping the latest location per truck in `garbage_trucks` table for fast queries

---

### Table 4: `garbage_truck_routes`

Route definitions for each ward — the planned path trucks follow.

```sql
CREATE TABLE garbage_truck_routes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    route_name VARCHAR(100) NOT NULL,                   -- e.g., "Ward 1 - Main Street Route"
    ward_id BIGINT UNSIGNED NOT NULL,                   -- FK to ward_list.id
    truck_id BIGINT UNSIGNED DEFAULT NULL,              -- assigned truck
    stops JSON NOT NULL,                                 -- ordered list of stops with lat/lng
    -- Example: [{"name": "Main Market", "lat": 25.5138, "lng": 90.2195, "sequence": 1}, ...]
    estimated_duration_minutes INT DEFAULT 60,          -- total route time estimate
    distance_km DECIMAL(6,2) DEFAULT NULL,              -- total route distance
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_ward_id (ward_id),
    INDEX idx_truck_id (truck_id),
    INDEX idx_is_active (is_active),
    
    FOREIGN KEY (ward_id) REFERENCES ward_list(id) ON DELETE CASCADE,
    FOREIGN KEY (truck_id) REFERENCES garbage_trucks(id) ON DELETE SET NULL
);
```

**Sample Data:**
```sql
INSERT INTO garbage_truck_routes (route_name, ward_id, truck_id, stops, estimated_duration_minutes, distance_km) VALUES
('Ward 1 - Main Street Route', 1, 1, 
 '[{"name": "Main Market Area", "lat": 25.5138, "lng": 90.2195, "sequence": 1}, 
   {"name": "Hospital Road", "lat": 25.5150, "lng": 90.2210, "sequence": 2}, 
   {"name": "Civil Lines", "lat": 25.5165, "lng": 90.2225, "sequence": 3}, 
   {"name": "Ward Office", "lat": 25.5180, "lng": 90.2240, "sequence": 4}]', 
 45, 8.50),
('Ward 2 - Residential Area Route', 2, 3,
 '[{"name": "Rongkhon Colony", "lat": 25.5200, "lng": 90.2300, "sequence": 1},
   {"name": "Dobasipara", "lat": 25.5215, "lng": 90.2315, "sequence": 2},
   {"name": "Chandmari", "lat": 25.5230, "lng": 90.2330, "sequence": 3}]',
 35, 6.20);
```

---

### Table 5: `garbage_collection_schedules`

Weekly collection schedule per ward.

```sql
CREATE TABLE garbage_collection_schedules (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ward_id BIGINT UNSIGNED NOT NULL,                   -- FK to ward_list.id
    truck_id BIGINT UNSIGNED NOT NULL,                  -- assigned truck
    route_id BIGINT UNSIGNED DEFAULT NULL,              -- assigned route
    day_of_week ENUM('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday') NOT NULL,
    start_time TIME NOT NULL,                           -- e.g., '06:00:00'
    end_time TIME NOT NULL,                             -- e.g., '10:00:00'
    collection_type ENUM('regular', 'bulk', 'recycling', 'special') DEFAULT 'regular',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_ward_id (ward_id),
    INDEX idx_truck_id (truck_id),
    INDEX idx_day_of_week (day_of_week),
    INDEX idx_is_active (is_active),
    
    FOREIGN KEY (ward_id) REFERENCES ward_list(id) ON DELETE CASCADE,
    FOREIGN KEY (truck_id) REFERENCES garbage_trucks(id) ON DELETE CASCADE,
    FOREIGN KEY (route_id) REFERENCES garbage_truck_routes(id) ON DELETE SET NULL
);
```

**Sample Data:**
```sql
INSERT INTO garbage_collection_schedules (ward_id, truck_id, route_id, day_of_week, start_time, end_time, collection_type) VALUES
(1, 1, 1, 'monday',    '06:00:00', '10:00:00', 'regular'),
(1, 1, 1, 'wednesday', '06:00:00', '10:00:00', 'regular'),
(1, 1, 1, 'friday',    '06:00:00', '10:00:00', 'regular'),
(1, 2, 1, 'tuesday',   '07:00:00', '11:00:00', 'recycling'),
(1, 2, 1, 'thursday',  '07:00:00', '11:00:00', 'recycling'),
(2, 3, 2, 'monday',    '06:30:00', '10:30:00', 'regular'),
(2, 3, 2, 'thursday',  '06:30:00', '10:30:00', 'regular'),
(3, 4, NULL, 'wednesday', '07:00:00', '09:00:00', 'regular'),
(3, 4, NULL, 'saturday',  '07:00:00', '09:00:00', 'bulk');
```

---

### Entity Relationship Diagram

```
users (existing)
  │
  ├── 1:1 ──► garbage_truck_drivers
  │                │
  │                └── N:1 ──► garbage_trucks
  │                                │
  │                                ├── 1:N ──► garbage_truck_locations (GPS history)
  │                                ├── 1:N ──► garbage_truck_routes
  │                                └── 1:N ──► garbage_collection_schedules
  │
ward_list (existing)
  │
  ├── 1:N ──► garbage_trucks
  ├── 1:N ──► garbage_truck_routes
  └── 1:N ──► garbage_collection_schedules
```

---

## API Endpoints

### Base URL

```
{{base_url}}/api
```

All endpoints are inside the `api` middleware group. Authenticated routes use JWT middleware (`auth`).

---

### Driver APIs

> **Authentication:** JWT token required. User must have `role = 'driver'` and a record in `garbage_truck_drivers`.

#### 1. Driver Login

```http
POST /api/login
Content-Type: application/json

{
    "email": "driver1@tura.gov.in",
    "password": "password123"
}
```

**Response:**
```json
{
    "status": true,
    "message": "Login successful",
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "user": {
        "id": 101,
        "firstname": "Ramesh",
        "lastname": "Sangma",
        "email": "driver1@tura.gov.in",
        "role": "driver"
    }
}
```

> **Note:** Drivers use the same `/api/login` endpoint as regular users. The `role` field determines access to driver-specific APIs.

---

#### 2. Start Shift

Marks the driver as on-duty and begins GPS tracking.

```http
POST /api/driver/shift/start
Authorization: Bearer {token}
Content-Type: application/json

{
    "latitude": 25.5100,
    "longitude": 90.2150
}
```

**Request Body:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `latitude` | float | No | Starting latitude |
| `longitude` | float | No | Starting longitude |

**Response:**
```json
{
    "status": true,
    "message": "Shift started. GPS tracking is now active.",
    "data": {
        "driver_id": 1,
        "truck_id": 1,
        "truck_number": "TM-GT-001",
        "shift_started_at": "2026-05-11T06:00:00.000000Z",
        "route": {
            "id": 1,
            "route_name": "Ward 1 - Main Street Route",
            "stops": [
                {"name": "Main Market Area", "lat": 25.5138, "lng": 90.2195, "sequence": 1},
                {"name": "Hospital Road", "lat": 25.5150, "lng": 90.2210, "sequence": 2}
            ],
            "estimated_duration_minutes": 45
        }
    }
}
```

**Error Response:**
```json
// Driver profile not found
{
    "status": false,
    "message": "Driver profile not found"
}
```

---

#### 3. End Shift

Stops GPS tracking and marks driver as off-duty.

```http
POST /api/driver/shift/end
Authorization: Bearer {token}
Content-Type: application/json

{
    "latitude": 25.5180,
    "longitude": 90.2240
}
```

**Request Body:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `latitude` | float | No | Final latitude |
| `longitude` | float | No | Final longitude |

**Response:**
```json
{
    "status": true,
    "message": "Shift ended. GPS tracking stopped.",
    "data": {
        "driver_id": 1,
        "truck_id": 1,
        "shift_started_at": "2026-05-11T06:00:00.000000Z",
        "shift_ended_at": "2026-05-11T10:30:00.000000Z",
        "total_locations_reported": 180,
        "total_distance_km": 12.5
    }
}
```

---

#### 4. Update GPS Location

> **Primary endpoint for real-time tracking.** Driver app calls this every 10-15 seconds from background service.

```http
POST /api/driver/location/update
Authorization: Bearer {token}
Content-Type: application/json

{
    "latitude": 25.5138,
    "longitude": 90.2195,
    "speed_kmh": 22.5,
    "heading": 135.5,
    "accuracy_meters": 10.0
}
```

**Request Body:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `latitude` | float | Yes | - | Current latitude |
| `longitude` | float | Yes | - | Current longitude |
| `speed_kmh` | float | No | 0 | Current speed in km/h |
| `heading` | float | No | null | Direction 0-360 degrees |
| `accuracy_meters` | float | No | null | GPS accuracy in meters |

**Response:**
```json
{
    "status": true,
    "message": "Location updated successfully",
    "data": {
        "truck_id": 1,
        "truck_number": "TM-GT-001",
        "latitude": 25.5138,
        "longitude": 90.2195,
        "speed_kmh": 22.5,
        "heading": 135.5,
        "updated_at": "2026-05-11T16:30:45.000000Z"
    }
}
```

**Error Responses:**
```json
// Driver not assigned to any truck
{
    "status": false,
    "message": "No truck assigned to this driver"
}

// Driver not on duty
{
    "status": false,
    "message": "Driver is not on active shift. Start your shift first."
}
```

---

#### 5. Get Assigned Route

Returns today's assigned route with all stops.

```http
GET /api/driver/route
Authorization: Bearer {token}
```

**Response:**
```json
{
    "status": true,
    "data": {
        "truck": {
            "id": 1,
            "truck_number": "TM-GT-001",
            "plate_number": "ML-07-A-1234"
        },
        "schedule": {
            "day": "monday",
            "start_time": "06:00",
            "end_time": "10:00",
            "collection_type": "regular"
        },
        "route": {
            "id": 1,
            "route_name": "Ward 1 - Main Street Route",
            "estimated_duration_minutes": 45,
            "distance_km": 8.50,
            "stops": [
                {
                    "id": 1,
                    "name": "Main Market Area",
                    "latitude": 25.5138,
                    "longitude": 90.2195,
                    "sequence": 1,
                    "status": "pending"
                },
                {
                    "id": 2,
                    "name": "Hospital Road",
                    "latitude": 25.5150,
                    "longitude": 90.2210,
                    "sequence": 2,
                    "status": "pending"
                }
            ]
        }
    }
}
```

---

### Consumer APIs

> **Authentication:** JWT token required. Any authenticated user (citizen).

#### 6. Get Trucks in Ward

Returns all active trucks assigned to a specific ward with their latest GPS positions.

```http
GET /api/trucks/ward/{wardId}
Authorization: Bearer {token}
```

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `wardId` | int | Yes | Ward ID |

**Example:**
```http
GET /api/trucks/ward/1
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

**Response:**
```json
{
    "status": true,
    "data": {
        "ward_id": 1,
        "ward_name": "Ward 1 - Tura",
        "total_trucks": 2,
        "active_on_route": 2,
        "trucks": [
            {
                "id": 1,
                "truck_number": "TM-GT-001",
                "plate_number": "ML-07-A-1234",
                "truck_type": "compactor",
                "is_on_route": true,
                "driver": {
                    "name": "Ramesh Sangma",
                    "phone": "9876543210"
                },
                "current_location": {
                    "latitude": 25.5138,
                    "longitude": 90.2195,
                    "speed_kmh": 22.5,
                    "heading": 135.5,
                    "updated_at": "2026-05-11T16:30:45.000000Z",
                    "seconds_ago": 8
                },
                "route": {
                    "route_name": "Ward 1 - Main Street Route",
                    "current_stop_index": 2,
                    "total_stops": 4
                }
            }
        ]
    }
}
```

---

#### 7. Get Nearby Trucks

Find trucks within a specified radius of the consumer's GPS location. Uses the Haversine formula.

```http
GET /api/trucks/nearby?latitude=25.5140&longitude=90.2200&radius=3
Authorization: Bearer {token}
```

**Query Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `latitude` | float | Yes | - | Consumer's current latitude |
| `longitude` | float | Yes | - | Consumer's current longitude |
| `radius` | float | No | 5 | Search radius in kilometers |

**Response:**
```json
{
    "status": true,
    "data": {
        "consumer_location": {
            "latitude": 25.5140,
            "longitude": 90.2200
        },
        "radius_km": 3,
        "trucks_found": 2,
        "trucks": [
            {
                "id": 1,
                "truck_number": "TM-GT-001",
                "plate_number": "ML-07-A-1234",
                "truck_type": "compactor",
                "is_on_route": true,
                "distance_km": 0.35,
                "distance_text": "350 meters away",
                "estimated_arrival_minutes": 5,
                "eta_text": "Arriving in ~5 minutes",
                "current_location": {
                    "latitude": 25.5138,
                    "longitude": 90.2195,
                    "speed_kmh": 22.5,
                    "heading": 135.5,
                    "updated_at": "2026-05-11T16:30:45.000000Z"
                },
                "driver": {
                    "name": "Ramesh Sangma"
                }
            }
        ]
    }
}
```

---

#### 8. Get ETA for Nearest Truck

Get the estimated time of arrival of the nearest truck to the consumer's location.

```http
GET /api/trucks/eta?latitude=25.5140&longitude=90.2200&ward_id=1
Authorization: Bearer {token}
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `latitude` | float | Yes | Consumer's latitude |
| `longitude` | float | Yes | Consumer's longitude |
| `ward_id` | int | Yes | Consumer's ward ID (must exist in `ward_list`) |

**Response:**
```json
{
    "status": true,
    "data": {
        "nearest_truck": {
            "id": 1,
            "truck_number": "TM-GT-001",
            "plate_number": "ML-07-A-1234",
            "driver_name": "Ramesh Sangma"
        },
        "distance_km": 0.35,
        "distance_text": "350 meters",
        "estimated_arrival_minutes": 5,
        "eta_text": "Arriving in ~5 minutes",
        "truck_speed_kmh": 22.5,
        "truck_heading": 135.5,
        "truck_location": {
            "latitude": 25.5138,
            "longitude": 90.2195,
            "updated_at": "2026-05-11T16:30:45.000000Z"
        },
        "next_collection_schedule": {
            "day": "monday",
            "start_time": "06:00",
            "end_time": "10:00",
            "collection_type": "regular"
        }
    }
}
```

---

#### 9. Track Specific Truck

Get real-time location of a specific truck (for detailed tracking view).

```http
GET /api/trucks/track/{truckId}
Authorization: Bearer {token}
```

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `truckId` | int | Yes | Truck ID |

**Response:**
```json
{
    "status": true,
    "data": {
        "truck": {
            "id": 1,
            "truck_number": "TM-GT-001",
            "plate_number": "ML-07-A-1234",
            "truck_type": "compactor"
        },
        "is_on_route": true,
        "driver": {
            "name": "Ramesh Sangma",
            "phone": "9876543210"
        },
        "current_location": {
            "latitude": 25.5138,
            "longitude": 90.2195,
            "speed_kmh": 22.5,
            "heading": 135.5,
            "updated_at": "2026-05-11T16:30:45.000000Z"
        },
        "route_progress": {
            "route_name": "Ward 1 - Main Street Route",
            "completed_stops": 2,
            "total_stops": 4,
            "next_stop": {
                "name": "Civil Lines",
                "latitude": 25.5165,
                "longitude": 90.2225
            },
            "progress_percentage": 50
        },
        "recent_path": [
            {"lat": 25.5120, "lng": 90.2180, "time": "2026-05-11T16:28:45Z"},
            {"lat": 25.5128, "lng": 90.2186, "time": "2026-05-11T16:29:45Z"},
            {"lat": 25.5138, "lng": 90.2195, "time": "2026-05-11T16:30:45Z"}
        ]
    }
}
```

---

#### 10. Get Collection Schedule for Ward

Returns the weekly garbage collection schedule for a ward.

```http
GET /api/trucks/schedule/{wardId}
Authorization: Bearer {token}
```

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `wardId` | int | Yes | Ward ID |

**Response:**
```json
{
    "status": true,
    "data": {
        "ward_id": 1,
        "ward_name": "Ward 1 - Tura",
        "schedule": {
            "monday": [
                {
                    "truck_number": "TM-GT-001",
                    "start_time": "06:00",
                    "end_time": "10:00",
                    "collection_type": "regular",
                    "route_name": "Ward 1 - Main Street Route"
                }
            ],
            "tuesday": [
                {
                    "truck_number": "TM-GT-002",
                    "start_time": "07:00",
                    "end_time": "11:00",
                    "collection_type": "recycling",
                    "route_name": "Ward 1 - Residential Route"
                }
            ],
            "wednesday": [],
            "thursday": [],
            "friday": [],
            "saturday": [],
            "sunday": []
        },
        "today": "monday",
        "next_collection": {
            "day": "monday",
            "start_time": "06:00",
            "truck_number": "TM-GT-001",
            "collection_type": "regular",
            "status": "in_progress"
        }
    }
}
```

---

#### 11. Get All Active Trucks (Map View)

Returns all currently active trucks across all wards for the map overview.

```http
GET /api/trucks/map
Authorization: Bearer {token}
```

**Response:**
```json
{
    "status": true,
    "data": {
        "total_active_trucks": 5,
        "trucks": [
            {
                "id": 1,
                "truck_number": "TM-GT-001",
                "plate_number": "ML-07-A-1234",
                "ward_id": 1,
                "ward_name": "Ward 1",
                "is_on_route": true,
                "latitude": 25.5138,
                "longitude": 90.2195,
                "speed_kmh": 22.5,
                "heading": 135.5,
                "updated_at": "2026-05-11T16:30:45.000000Z"
            },
            {
                "id": 3,
                "truck_number": "TM-GT-003",
                "plate_number": "ML-07-C-9012",
                "ward_id": 2,
                "ward_name": "Ward 2",
                "is_on_route": true,
                "latitude": 25.5200,
                "longitude": 90.2300,
                "speed_kmh": 15.0,
                "heading": 270.0,
                "updated_at": "2026-05-11T16:30:50.000000Z"
            }
        ]
    }
}
```

---

### Admin APIs

> **Authentication:** JWT token required. User must have `role = 'admin'`, `role = 'ceo'`, or `role = 'editor'`.

#### 12. Add New Truck

```http
POST /api/admin/trucks
Authorization: Bearer {token}
Content-Type: application/json

{
    "truck_number": "TM-GT-006",
    "plate_number": "ML-07-F-1111",
    "truck_type": "compactor",
    "capacity_tons": 5.00,
    "ward_id": 3
}
```

**Request Body:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `truck_number` | string | Yes | Unique truck identifier (max 20 chars) |
| `plate_number` | string | Yes | Vehicle plate number (max 20 chars) |
| `truck_type` | string | Yes | One of: `compactor`, `dumper`, `side_loader`, `roll_off` |
| `capacity_tons` | float | Yes | Capacity in tons (min 0.5) |
| `ward_id` | int | Yes | Ward ID (must exist in `ward_list`) |
| `status` | string | No | One of: `active`, `maintenance`, `retired`, `breakdown`. Default: `active` |
| `latitude` | float | No | Initial latitude |
| `longitude` | float | No | Initial longitude |

**Response (201):**
```json
{
    "status": true,
    "message": "Truck added successfully",
    "data": {
        "id": 6,
        "truck_number": "TM-GT-006",
        "plate_number": "ML-07-F-1111",
        "truck_type": "compactor",
        "capacity_tons": 5.00,
        "ward_id": 3,
        "status": "active"
    }
}
```

---

#### 13. Update Truck Details

```http
PUT /api/admin/trucks/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
    "truck_type": "roll_off",
    "capacity_tons": 7.00,
    "ward_id": 2,
    "status": "maintenance"
}
```

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | int | Yes | Truck ID |

**Request Body (all fields optional):**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `truck_number` | string | No | Unique truck identifier |
| `plate_number` | string | No | Vehicle plate number |
| `truck_type` | string | No | One of: `compactor`, `dumper`, `side_loader`, `roll_off` |
| `capacity_tons` | float | No | Capacity in tons (min 0.5) |
| `ward_id` | int | No | Ward ID |
| `status` | string | No | One of: `active`, `maintenance`, `retired`, `breakdown` |

---

#### 14. Assign Driver to Truck

```http
POST /api/admin/trucks/assign-driver
Authorization: Bearer {token}
Content-Type: application/json

{
    "driver_user_id": 101,
    "truck_id": 1
}
```

**Request Body:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `driver_user_id` | int | Yes | User ID of the driver (must exist in `users`) |
| `truck_id` | int | Yes | Truck ID (must exist in `garbage_trucks`) |

**Response:**
```json
{
    "status": true,
    "message": "Driver assigned to truck successfully",
    "data": {
        "driver": {
            "id": 1,
            "user_id": 101,
            "name": "Ramesh Sangma",
            "license": "ML-DL-2023-001"
        },
        "truck": {
            "id": 1,
            "truck_number": "TM-GT-001"
        }
    }
}
```

---

#### 15. Create Collection Schedule

```http
POST /api/admin/trucks/schedule
Authorization: Bearer {token}
Content-Type: application/json

{
    "ward_id": 1,
    "truck_id": 1,
    "route_id": 1,
    "day_of_week": "monday",
    "start_time": "06:00",
    "end_time": "10:00",
    "collection_type": "regular"
}
```

**Request Body:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `ward_id` | int | Yes | Ward ID (must exist in `ward_list`) |
| `truck_id` | int | Yes | Truck ID (must exist in `garbage_trucks`) |
| `route_id` | int | No | Route ID (must exist in `garbage_truck_routes`) |
| `day_of_week` | string | Yes | One of: `monday`, `tuesday`, `wednesday`, `thursday`, `friday`, `saturday`, `sunday` |
| `start_time` | string | Yes | Start time in `H:i` format (e.g., `06:00`) |
| `end_time` | string | Yes | End time in `H:i` format, must be after `start_time` |
| `collection_type` | string | No | One of: `regular`, `bulk`, `recycling`, `special`. Default: `regular` |

**Response (201):**
```json
{
    "status": true,
    "message": "Schedule created successfully",
    "data": {
        "id": 10,
        "ward_id": 1,
        "truck_id": 1,
        "route_id": 1,
        "day_of_week": "monday",
        "start_time": "06:00",
        "end_time": "10:00",
        "collection_type": "regular"
    }
}
```

---

#### 16. Fleet Dashboard

Admin overview of all fleet activity.

```http
GET /api/admin/trucks/dashboard
Authorization: Bearer {token}
```

**Response:**
```json
{
    "status": true,
    "data": {
        "fleet_summary": {
            "total_trucks": 10,
            "active_trucks": 7,
            "on_route_now": 5,
            "in_maintenance": 2,
            "inactive": 1
        },
        "driver_summary": {
            "total_drivers": 12,
            "on_duty_now": 5,
            "off_duty": 7
        },
        "today_collections": {
            "total_scheduled": 8,
            "completed": 3,
            "in_progress": 4,
            "pending": 1
        },
        "active_trucks": [
            {
                "truck_number": "TM-GT-001",
                "driver": "Ramesh Sangma",
                "ward": "Ward 1",
                "route": "Main Street Route",
                "progress": "2/4 stops",
                "last_update": "2026-05-11T16:30:45Z"
            }
        ]
    }
}
```

---

## ETA Calculation Logic

### Simple Haversine + Speed Formula

```php
/**
 * Calculate estimated arrival time using Haversine distance and truck speed.
 *
 * @param float $lat1 Consumer latitude
 * @param float $lng1 Consumer longitude
 * @param float $lat2 Truck latitude
 * @param float $lng2 Truck longitude
 * @param float $truckSpeedKmh Current truck speed (if 0, use default)
 * @return array ['distance_km' => float, 'eta_minutes' => int]
 */
public function calculateETA(
    float $lat1, float $lng1,
    float $lat2, float $lng2,
    float $truckSpeedKmh = 0
): array {
    // Haversine formula
    $earthRadius = 6371; // km
    $dLat = deg2rad($lat2 - $lat1);
    $dLng = deg2rad($lng2 - $lng1);
    
    $a = sin($dLat / 2) * sin($dLat / 2) +
         cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
         sin($dLng / 2) * sin($dLng / 2);
    
    $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
    $distanceKm = $earthRadius * $c;
    
    // Use truck's current speed, or default to 20 km/h (city average)
    $speed = $truckSpeedKmh > 0 ? $truckSpeedKmh : 20.0;
    
    // ETA in minutes
    $etaMinutes = ($distanceKm / $speed) * 60;
    
    // Add buffer for stops (2 min per estimated stop en route)
    $stopBuffer = max(0, floor($distanceKm / 2) * 2); // rough: 1 stop per 2km
    $etaMinutes += $stopBuffer;
    
    return [
        'distance_km' => round($distanceKm, 2),
        'eta_minutes' => (int) ceil($etaMinutes),
    ];
}
```

### Advanced ETA with Route Sequence (Future Enhancement)

For more accurate ETA, consider:
1. Calculate which route stop the truck is heading to next
2. Sum remaining stops until consumer's nearest stop
3. Add travel time between remaining stops
4. Add stop dwell time (2-3 min per stop)

```php
/**
 * Advanced: ETA based on route sequence
 */
public function calculateRouteBasedETA(int $truckId, float $consumerLat, float $consumerLng): array
{
    $truck = GarbageTruck::with('routes.stops')->find($truckId);
    $currentLat = $truck->latitude;
    $currentLng = $truck->longitude;
    
    // Find which stop the truck is closest to (current position)
    $currentStopIndex = $this->findClosestStopIndex($truck, $currentLat, $currentLng);
    
    // Find which stop is closest to consumer
    $consumerStopIndex = $this->findClosestStopIndex($truck, $consumerLat, $consumerLng);
    
    // If consumer stop is behind truck, truck already passed → no ETA
    if ($consumerStopIndex <= $currentStopIndex) {
        return ['eta_minutes' => null, 'status' => 'truck_already_passed'];
    }
    
    // Calculate distance through remaining stops
    $totalDistance = 0;
    $stopsRemaining = 0;
    $prevLat = $currentLat;
    $prevLng = $currentLng;
    
    for ($i = $currentStopIndex; $i <= $consumerStopIndex; $i++) {
        $stop = $truck->routes->stops[$i];
        $totalDistance += $this->haversine($prevLat, $prevLng, $stop->lat, $stop->lng);
        $stopsRemaining++;
        $prevLat = $stop->lat;
        $prevLng = $stop->lng;
    }
    
    // Add distance from last stop to consumer
    $totalDistance += $this->haversine($prevLat, $prevLng, $consumerLat, $consumerLng);
    
    // ETA = travel time + stop dwell time
    $speed = max($truck->last_speed, 15); // min 15 km/h
    $travelTime = ($totalDistance / $speed) * 60; // minutes
    $stopTime = $stopsRemaining * 2.5; // 2.5 min per stop
    
    return [
        'distance_km' => round($totalDistance, 2),
        'eta_minutes' => (int) ceil($travelTime + $stopTime),
        'stops_remaining' => $stopsRemaining,
    ];
}
```

### Haversine Distance Helper

```php
/**
 * Calculate distance between two GPS coordinates using Haversine formula.
 */
public function haversine(float $lat1, float $lng1, float $lat2, float $lng2): float
{
    $earthRadius = 6371; // km
    $dLat = deg2rad($lat2 - $lat1);
    $dLng = deg2rad($lng2 - $lng1);
    
    $a = sin($dLat / 2) ** 2 +
         cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
         sin($dLng / 2) ** 2;
    
    return $earthRadius * 2 * atan2(sqrt($a), sqrt(1 - $a));
}
```

---

## Real-Time Updates Strategy

### Phase 1: Polling (MVP — Recommended to Start)

**How it works:**
1. Consumer app fetches truck positions via `GET /api/trucks/nearby` every **10-15 seconds**
2. Map markers update with new positions
3. ETA recalculates on each poll

**Pros:**
- Simple to implement
- No additional infrastructure
- Works with existing Laravel setup

**Cons:**
- Higher server load with many consumers
- Slight delay (10-15 seconds)
- Battery drain on mobile

**Flutter Polling Example:**
```dart
Timer.periodic(Duration(seconds: 15), (timer) async {
  final trucks = await apiService.getNearbyTrucks(
    latitude: currentLat,
    longitude: currentLng,
    radius: 3,
  );
  setState(() {
    truckMarkers = trucks;
  });
});
```

### Phase 2: WebSocket / Pusher (Future Enhancement)

**How it works:**
1. Driver app sends GPS to Laravel API
2. Laravel broadcasts location to a Pusher channel (e.g., `ward.1.trucks`)
3. Consumer app subscribes to ward channel and receives instant updates

**Implementation:**
```php
// In GarbageTruckService after updating location:
broadcast(new TruckLocationUpdated($truck, $location))->toOthers();
```

```dart
// In Flutter:
pusher.subscribe('ward.${wardId}.trucks')
  .bind('truck.location.updated', (event) {
    updateTruckMarker(jsonDecode(event.data));
  });
```

### Phase 3: Server-Sent Events (SSE) — Alternative

Lighter than WebSocket, one-directional (server → client). Good for map updates.

---

## Driver Authentication

### Approach: Role-Based Authentication

Add a `role` column to the existing `users` table:

```sql
ALTER TABLE users ADD COLUMN role ENUM('user', 'driver', 'admin', 'ceo', 'editor') DEFAULT 'user' AFTER phone_no;
```

**User table role values:**

| Role | Description | Access |
|------|-------------|--------|
| `user` | Regular citizen | Consumer APIs only |
| `driver` | Garbage truck driver | Driver APIs + basic user features |
| `admin` | Municipality admin | Admin APIs + Consumer APIs |
| `ceo` | CEO level | All APIs |
| `editor` | Content editor | Limited admin APIs |

### Driver Registration Flow

1. Admin creates a user account with `role = 'driver'`
2. Admin creates driver profile in `garbage_truck_drivers` table
3. Admin assigns driver to a truck
4. Driver logs in via `/api/login` → receives JWT token with role info
5. Flutter app checks role and shows Driver UI or Consumer UI accordingly

### Middleware Protection

```php
// Driver-only routes
Route::middleware(['auth', 'role:driver'])->group(function () {
    Route::post('driver/location/update', ...);
    Route::post('driver/shift/start', ...);
    Route::post('driver/shift/end', ...);
    Route::get('driver/route', ...);
});

// Admin-only routes
Route::middleware(['auth', 'role:admin,ceo,editor'])->group(function () {
    Route::post('admin/trucks', ...);
    Route::post('admin/trucks/assign-driver', ...);
});
```

### Role Middleware

```php
// app/Http/Middleware/CheckRole.php
public function handle($request, Closure $next, ...$roles)
{
    if (!in_array($request->user()->role, $roles)) {
        return response()->json([
            'status' => false,
            'message' => 'Unauthorized. Required role: ' . implode(' or ', $roles)
        ], 403);
    }
    return $next($request);
}
```

---

## Flutter Integration Guide

### For Consumer App

#### Key Flutter Packages

```yaml
dependencies:
  google_maps_flutter: ^2.5.0    # Map display
  geolocator: ^10.1.0            # Get user GPS
  http: ^1.1.0                   # API calls
  flutter_polyline_points: ^2.0.0 # Draw truck path on map
  location: ^5.0.0               # Background location
```

#### Map Screen Architecture

```dart
class GarbageTruckMapScreen extends StatefulWidget {
  @override
  _GarbageTruckMapScreenState createState() => _GarbageTruckMapScreenState();
}

class _GarbageTruckMapScreenState extends State<GarbageTruckMapScreen> {
  GoogleMapController? mapController;
  Set<Marker> truckMarkers = {};
  Timer? pollingTimer;
  
  @override
  void initState() {
    super.initState();
    _loadNearbyTrucks();
    // Poll every 15 seconds
    pollingTimer = Timer.periodic(Duration(seconds: 15), (_) => _loadNearbyTrucks());
  }
  
  Future<void> _loadNearbyTrucks() async {
    Position pos = await Geolocator.getCurrentPosition();
    final response = await http.get(Uri.parse(
      '$baseUrl/trucks/nearby?latitude=${pos.latitude}&longitude=${pos.longitude}&radius=3'
    ));
    final data = jsonDecode(response.body);
    
    setState(() {
      truckMarkers = (data['data']['trucks'] as List).map((truck) {
        return Marker(
          markerId: MarkerId('truck_${truck['id']}'),
          position: LatLng(
            truck['current_location']['latitude'],
            truck['current_location']['longitude'],
          ),
          rotation: truck['current_location']['heading'] ?? 0,
          icon: truckIcon, // Custom garbage truck icon
          infoWindow: InfoWindow(
            title: truck['truck_number'],
            snippet: truck['eta_text'],
          ),
        );
      }).toSet();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) => mapController = controller,
      initialCameraPosition: CameraPosition(
        target: LatLng(25.5138, 90.2195), // Tura coordinates
        zoom: 14,
      ),
      markers: truckMarkers,
      myLocationEnabled: true,
    );
  }
}
```

#### ETA Card Widget

```dart
class ETACard extends StatelessWidget {
  final Map<String, dynamic> truckData;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.green),
                SizedBox(width: 8),
                Text(truckData['truck_number'], style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text(truckData['distance_text'], style: TextStyle(color: Colors.grey)),
              ],
            ),
            SizedBox(height: 8),
            Text(
              truckData['eta_text'], // "Arriving in ~5 minutes"
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
```

### For Driver App

#### Background GPS Service

```yaml
dependencies:
  geolocator: ^10.1.0
  background_locator_2: ^1.0.0   # Or location: ^5.0.0
  http: ^1.1.0
  shared_preferences: ^2.2.0     # Store JWT token
```

#### Location Update Service

```dart
class LocationUpdateService {
  static const String baseUrl = 'https://your-api-url.com/api';
  Timer? _timer;
  
  void startTracking(String jwtToken, int truckId) {
    // Send location every 15 seconds
    _timer = Timer.periodic(Duration(seconds: 15), (_) async {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      await http.post(
        Uri.parse('$baseUrl/driver/location/update'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'speed_kmh': pos.speed * 3.6, // m/s to km/h
          'heading': pos.heading,
          'accuracy_meters': pos.accuracy,
        }),
      );
    });
  }
  
  void stopTracking() {
    _timer?.cancel();
  }
}
```

---

## Implementation Steps

### Backend (Laravel) — Step by Step

| Step | Task | Files |
|------|------|-------|
| 1 | Add `role` column to `users` table | Migration |
| 2 | Create `garbage_trucks` migration | `database/migrations/xxxx_create_garbage_trucks_table.php` |
| 3 | Create `garbage_truck_drivers` migration | `database/migrations/xxxx_create_garbage_truck_drivers_table.php` |
| 4 | Create `garbage_truck_locations` migration | `database/migrations/xxxx_create_garbage_truck_locations_table.php` |
| 5 | Create `garbage_truck_routes` migration | `database/migrations/xxxx_create_garbage_truck_routes_table.php` |
| 6 | Create `garbage_collection_schedules` migration | `database/migrations/xxxx_create_garbage_collection_schedules_table.php` |
| 7 | Create `GarbageTruck` model | `app/Models/GarbageTruck.php` |
| 8 | Create `GarbageTruckDriver` model | `app/Models/GarbageTruckDriver.php` |
| 9 | Create `GarbageTruckLocation` model | `app/Models/GarbageTruckLocation.php` |
| 10 | Create `GarbageTruckRoute` model | `app/Models/GarbageTruckRoute.php` |
| 11 | Create `GarbageCollectionSchedule` model | `app/Models/GarbageCollectionSchedule.php` |
| 12 | Create `CheckRole` middleware | `app/Http/Middleware/CheckRole.php` |
| 13 | Create `GarbageTruckService` | `app/Services/GarbageTruckService.php` |
| 14 | Create `GarbageTruckController` | `app/Http/Controllers/GarbageTruckController.php` |
| 15 | Register all routes in `api.php` | `routes/api.php` |
| 16 | Register middleware in `Kernel.php` | `app/Http/Kernel.php` |
| 17 | Create database seeder | `database/seeders/GarbageTruckSeeder.php` |
| 18 | Generate Swagger documentation | `GARBAGE_TRUCK_TRACKING_API_SWAGGER.yaml` |

### Frontend (Flutter) — Step by Step

| Step | Task | Description |
|------|------|-------------|
| 1 | Add packages | google_maps_flutter, geolocator, http |
| 2 | Create API service | `GarbageTruckApiService` for all API calls |
| 3 | Build Map Screen | Google Maps with truck markers |
| 4 | Build ETA Card | Bottom sheet with nearest truck info |
| 5 | Build Schedule View | Weekly collection schedule per ward |
| 6 | Build Driver Login | Separate login flow or role detection |
| 7 | Build Driver Map | Route display + shift controls |
| 8 | Background GPS | Location updates every 15 seconds |
| 9 | Push Notifications | FCM notification when truck nearby |
| 10 | Testing | End-to-end testing with real devices |

---

## Deployment Notes

### Server Requirements

- PHP 8.1+ with existing Laravel setup
- MySQL 8.0+ (JSON column support)
- HTTPS required for GPS permissions on mobile
- Server with low latency (GPS updates are time-sensitive)

### Performance Considerations

1. **Location table cleanup:** Create a scheduled command to delete GPS records older than 30 days:
   ```php
   // app/Console/Commands/CleanupOldLocations.php
   GarbageTruckLocation::where('recorded_at', '<', now()->subDays(30))->delete();
   ```

2. **Indexing:** Ensure all indexes are created (included in migrations above).

3. **Caching:** Cache ward schedules (they change infrequently):
   ```php
   Cache::remember("ward_{$wardId}_schedule", 3600, function () use ($wardId) {
       return GarbageCollectionSchedule::where('ward_id', $wardId)->get();
   });
   ```

4. **Rate limiting:** Apply rate limiting to location update endpoint:
   ```php
   Route::post('driver/location/update', ...)->middleware('throttle:120,1'); // 120 per minute
   ```

### GPS Accuracy Tips for Driver App

- Use `LocationAccuracy.high` in Flutter
- Minimum distance filter: ignore updates if truck moved less than 5 meters
- Battery optimization: reduce update frequency when truck is stationary
- Fallback: if GPS unavailable, use network-based location

---

## API Summary Table

| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 1 | POST | `/api/login` | No | - | Driver/User login (returns JWT) |
| 2 | POST | `/api/driver/shift/start` | JWT | Driver | Start shift, begin tracking |
| 3 | POST | `/api/driver/shift/end` | JWT | Driver | End shift, stop tracking |
| 4 | POST | `/api/driver/location/update` | JWT | Driver | Update GPS location |
| 5 | GET | `/api/driver/route` | JWT | Driver | Get today's route + stops |
| 6 | GET | `/api/trucks/map` | JWT | User | All active trucks on map |
| 7 | GET | `/api/trucks/nearby` | JWT | User | Find trucks near me |
| 8 | GET | `/api/trucks/eta` | JWT | User | ETA of nearest truck |
| 9 | GET | `/api/trucks/ward/{wardId}` | JWT | User | Trucks in my ward |
| 10 | GET | `/api/trucks/track/{truckId}` | JWT | User | Track specific truck |
| 11 | GET | `/api/trucks/schedule/{wardId}` | JWT | User | Collection schedule |
| 12 | POST | `/api/admin/trucks` | JWT | Admin | Add new truck |
| 13 | PUT | `/api/admin/trucks/{id}` | JWT | Admin | Update truck |
| 14 | POST | `/api/admin/trucks/assign-driver` | JWT | Admin | Assign driver to truck |
| 15 | POST | `/api/admin/trucks/schedule` | JWT | Admin | Create schedule |
| 16 | GET | `/api/admin/trucks/dashboard` | JWT | Admin | Fleet dashboard |

---

## File Structure (Laravel Backend)

```
app/
├── Console/
│   └── Commands/
│       └── CleanupOldLocations.php         # Scheduled cleanup
├── Http/
│   ├── Controllers/
│   │   └── GarbageTruckController.php      # All API endpoints
│   ├── Middleware/
│   │   └── CheckRole.php                   # Role-based access
├── Models/
│   ├── GarbageTruck.php
│   ├── GarbageTruckDriver.php
│   ├── GarbageTruckLocation.php
│   ├── GarbageTruckRoute.php
│   └── GarbageCollectionSchedule.php
├── Services/
│   └── GarbageTruckService.php             # Business logic + ETA

database/
├── migrations/
│   ├── xxxx_add_role_to_users_table.php
│   ├── xxxx_create_garbage_trucks_table.php
│   ├── xxxx_create_garbage_truck_drivers_table.php
│   ├── xxxx_create_garbage_truck_locations_table.php
│   ├── xxxx_create_garbage_truck_routes_table.php
│   └── xxxx_create_garbage_collection_schedules_table.php
├── seeders/
│   └── GarbageTruckSeeder.php

routes/
└── api.php                                  # New routes added

GARBAGE_TRUCK_TRACKING_DOCUMENTATION.md      # This file
GARBAGE_TRUCK_TRACKING_API_SWAGGER.yaml      # Swagger spec
```

---

*Document created: May 11, 2026*
*Last updated: May 12, 2026*
*Project: Tura Municipal Corporation — Laravel Backend*
*Feature: Garbage Truck Real-Time Tracking System*