class DriverRouteData {
  final DriverInfo? driver;
  final TruckInfo? truck;
  final DriverRouteInfo? route;
  final ScheduleInfo? schedule;

  DriverRouteData({this.driver, this.truck, this.route, this.schedule});

  factory DriverRouteData.fromJson(Map<String, dynamic> json) {
    return DriverRouteData(
      driver:
          json['driver'] != null ? DriverInfo.fromJson(json['driver']) : null,
      truck:
          json['truck'] != null ? TruckInfo.fromJson(json['truck']) : null,
      route:
          json['route'] != null
              ? DriverRouteInfo.fromJson(json['route'])
              : null,
      schedule:
          json['schedule'] != null
              ? ScheduleInfo.fromJson(json['schedule'])
              : null,
    );
  }
}

class DriverInfo {
  final int id;
  final String name;
  final String phone;
  final String? email;

  DriverInfo({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
    );
  }
}

class TruckInfo {
  final int id;
  final String truckNumber;
  final String plateNumber;
  final num? capacityTons;
  final String status;

  TruckInfo({
    required this.id,
    required this.truckNumber,
    required this.plateNumber,
    this.capacityTons,
    required this.status,
  });

  factory TruckInfo.fromJson(Map<String, dynamic> json) {
    return TruckInfo(
      id: json['id'] ?? 0,
      truckNumber: json['truck_number'] ?? '',
      plateNumber: json['plate_number'] ?? '',
      capacityTons: json['capacity_tons'],
      status: json['status'] ?? '',
    );
  }
}

class DriverRouteInfo {
  final int routeId;
  final String routeName;
  final num? distanceKm;
  final num? estimatedDurationMinutes;
  final List<RouteStop> stops;

  DriverRouteInfo({
    required this.routeId,
    required this.routeName,
    this.distanceKm,
    this.estimatedDurationMinutes,
    required this.stops,
  });

  factory DriverRouteInfo.fromJson(Map<String, dynamic> json) {
    return DriverRouteInfo(
      routeId: json['route_id'] ?? 0,
      routeName: json['route_name'] ?? '',
      distanceKm: json['distance_km'],
      estimatedDurationMinutes: json['estimated_duration_minutes'],
      stops:
          (json['stops'] as List<dynamic>?)
              ?.map((e) => RouteStop.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class RouteStop {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int sequence;
  final String status;

  RouteStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.sequence,
    required this.status,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      sequence: json['sequence'] ?? 0,
      status: json['status'] ?? 'pending',
    );
  }
}

class ScheduleInfo {
  final int id;
  final String day;
  final String startTime;
  final String endTime;
  final String collectionType;

  ScheduleInfo({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.collectionType,
  });

  factory ScheduleInfo.fromJson(Map<String, dynamic> json) {
    return ScheduleInfo(
      id: json['id'] ?? 0,
      day: json['day'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      collectionType: json['collection_type'] ?? '',
    );
  }
}

class DriverShiftData {
  final int? shiftId;
  final String? shiftStartedAt;
  final String? shiftEndedAt;
  final int? totalLocationsReported;
  final num? totalDistanceKm;

  DriverShiftData({
    this.shiftId,
    this.shiftStartedAt,
    this.shiftEndedAt,
    this.totalLocationsReported,
    this.totalDistanceKm,
  });

  factory DriverShiftData.fromJson(Map<String, dynamic> json) {
    return DriverShiftData(
      shiftId: json['shift_id'],
      shiftStartedAt: json['started_at'],
      shiftEndedAt: json['ended_at'],
      totalLocationsReported: json['total_locations_reported'],
      totalDistanceKm: json['total_distance_km'],
    );
  }
}

class DriverLoginResponse {
  final bool status;
  final String message;
  final String? token;
  final String? driverName;

  DriverLoginResponse({
    required this.status,
    required this.message,
    this.token,
    this.driverName,
  });

  factory DriverLoginResponse.fromJson(Map<String, dynamic> json) {
    return DriverLoginResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      driverName: json['driver_name'],
    );
  }
}