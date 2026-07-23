// Models for the Garbage Management (admin) module.
//
// Mirrors real backend responses from `GarbageTruckController` /
// `GarbageTruckService` (see routes/api.php `admin/trucks` group).

num? _asNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  if (v is String) return num.tryParse(v);
  return null;
}

bool _asBool(dynamic v) {
  if (v is bool) return v;
  if (v is int) return v == 1;
  if (v is String) return v == '1' || v.toLowerCase() == 'true';
  return false;
}

class TruckDriverInfo {
  final int? driverId;
  final int? userId;
  final String name;
  final String? phone;
  final bool isOnDuty;

  TruckDriverInfo({
    this.driverId,
    this.userId,
    required this.name,
    this.phone,
    this.isOnDuty = false,
  });

  factory TruckDriverInfo.fromJson(Map<String, dynamic> json) {
    return TruckDriverInfo(
      driverId: json['driver_id'] is int ? json['driver_id'] : int.tryParse('${json['driver_id']}'),
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse('${json['user_id']}'),
      name: json['name']?.toString() ?? 'Unknown',
      phone: json['phone']?.toString(),
      isOnDuty: _asBool(json['is_on_duty']),
    );
  }
}

class GarbageTruckModel {
  final int id;
  final String truckNumber;
  final String plateNumber;
  final String truckType;
  final num? capacityTons;
  final int wardId;
  final String? wardName;
  final String status;
  final bool isOnRoute;
  final TruckDriverInfo? driver;
  final String? lastLocationUpdate;

  GarbageTruckModel({
    required this.id,
    required this.truckNumber,
    required this.plateNumber,
    required this.truckType,
    this.capacityTons,
    required this.wardId,
    this.wardName,
    required this.status,
    this.isOnRoute = false,
    this.driver,
    this.lastLocationUpdate,
  });

  factory GarbageTruckModel.fromJson(Map<String, dynamic> json) {
    return GarbageTruckModel(
      id: json['id'] ?? 0,
      truckNumber: json['truck_number']?.toString() ?? '',
      plateNumber: json['plate_number']?.toString() ?? '',
      truckType: json['truck_type']?.toString() ?? '',
      capacityTons: _asNum(json['capacity_tons']),
      wardId: json['ward_id'] is int ? json['ward_id'] : int.tryParse('${json['ward_id']}') ?? 0,
      wardName: json['ward_name']?.toString(),
      status: json['status']?.toString() ?? 'active',
      isOnRoute: _asBool(json['is_on_route']),
      driver: json['driver'] != null
          ? TruckDriverInfo.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      lastLocationUpdate: json['last_location_update']?.toString(),
    );
  }

  bool get hasDriver => driver != null;
}

class TruckListResult {
  final List<GarbageTruckModel> trucks;
  final int currentPage;
  final int lastPage;
  final int total;

  TruckListResult({
    required this.trucks,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory TruckListResult.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List? ?? [])
        .map((e) => GarbageTruckModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return TruckListResult(
      trucks: list,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? list.length,
    );
  }
}

class DriverProfileModel {
  final int driverId;
  final int userId;
  final String name;
  final String? phone;
  final int? wardId;
  final String? driverLicenseNumber;
  final String? licenseExpiry;
  final bool isOnDuty;
  final int? truckId;
  final String? truckNumber;

  DriverProfileModel({
    required this.driverId,
    required this.userId,
    required this.name,
    this.phone,
    this.wardId,
    this.driverLicenseNumber,
    this.licenseExpiry,
    this.isOnDuty = false,
    this.truckId,
    this.truckNumber,
  });

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    return DriverProfileModel(
      driverId: json['driver_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name']?.toString() ?? 'Unknown',
      phone: json['phone']?.toString(),
      wardId: json['ward_id'] is int ? json['ward_id'] : int.tryParse('${json['ward_id']}'),
      driverLicenseNumber: json['driver_license_number']?.toString(),
      licenseExpiry: json['license_expiry']?.toString(),
      isOnDuty: _asBool(json['is_on_duty']),
      truckId: json['truck_id'] is int ? json['truck_id'] : int.tryParse('${json['truck_id']}'),
      truckNumber: json['truck_number']?.toString(),
    );
  }

  bool get isAssigned => truckId != null;
  String get displayLabel => isAssigned ? '$name ($truckNumber)' : name;
}

class AssignDriverResult {
  final String driverName;
  final String? driverLicense;
  final String truckNumber;

  AssignDriverResult({
    required this.driverName,
    this.driverLicense,
    required this.truckNumber,
  });

  factory AssignDriverResult.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'] as Map<String, dynamic>? ?? {};
    final truck = json['truck'] as Map<String, dynamic>? ?? {};
    return AssignDriverResult(
      driverName: driver['name']?.toString() ?? '',
      driverLicense: driver['license']?.toString(),
      truckNumber: truck['truck_number']?.toString() ?? '',
    );
  }
}

class ScheduleModel {
  final int id;
  final int wardId;
  final int truckId;
  final int? routeId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String collectionType;
  final bool isActive;

  ScheduleModel({
    required this.id,
    required this.wardId,
    required this.truckId,
    this.routeId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.collectionType,
    this.isActive = true,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] ?? 0,
      wardId: json['ward_id'] ?? 0,
      truckId: json['truck_id'] ?? 0,
      routeId: json['route_id'],
      dayOfWeek: json['day_of_week']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      collectionType: json['collection_type']?.toString() ?? 'regular',
      isActive: _asBool(json['is_active']),
    );
  }
}

class FleetSummary {
  final int totalTrucks;
  final int activeTrucks;
  final int onRouteNow;
  final int inMaintenance;

  FleetSummary({
    required this.totalTrucks,
    required this.activeTrucks,
    required this.onRouteNow,
    required this.inMaintenance,
  });

  factory FleetSummary.fromJson(Map<String, dynamic> json) {
    return FleetSummary(
      totalTrucks: json['total_trucks'] ?? 0,
      activeTrucks: json['active_trucks'] ?? 0,
      onRouteNow: json['on_route_now'] ?? 0,
      inMaintenance: json['in_maintenance'] ?? 0,
    );
  }
}

class DriverSummary {
  final int totalDrivers;
  final int onDutyNow;
  final int offDuty;

  DriverSummary({
    required this.totalDrivers,
    required this.onDutyNow,
    required this.offDuty,
  });

  factory DriverSummary.fromJson(Map<String, dynamic> json) {
    return DriverSummary(
      totalDrivers: json['total_drivers'] ?? 0,
      onDutyNow: json['on_duty_now'] ?? 0,
      offDuty: json['off_duty'] ?? 0,
    );
  }
}

class ActiveTruckSummary {
  final String truckNumber;
  final String? driver;
  final String? ward;
  final String? lastUpdate;

  ActiveTruckSummary({
    required this.truckNumber,
    this.driver,
    this.ward,
    this.lastUpdate,
  });

  factory ActiveTruckSummary.fromJson(Map<String, dynamic> json) {
    return ActiveTruckSummary(
      truckNumber: json['truck_number']?.toString() ?? '',
      driver: json['driver']?.toString(),
      ward: json['ward']?.toString(),
      lastUpdate: json['last_update']?.toString(),
    );
  }
}

class FleetDashboardModel {
  final FleetSummary fleetSummary;
  final DriverSummary driverSummary;
  final int todayScheduledCollections;
  final List<ActiveTruckSummary> activeTrucks;

  FleetDashboardModel({
    required this.fleetSummary,
    required this.driverSummary,
    required this.todayScheduledCollections,
    required this.activeTrucks,
  });

  factory FleetDashboardModel.fromJson(Map<String, dynamic> json) {
    return FleetDashboardModel(
      fleetSummary: FleetSummary.fromJson(json['fleet_summary'] as Map<String, dynamic>? ?? {}),
      driverSummary: DriverSummary.fromJson(json['driver_summary'] as Map<String, dynamic>? ?? {}),
      todayScheduledCollections: (json['today_collections'] as Map?)?['total_scheduled'] ?? 0,
      activeTrucks: (json['active_trucks'] as List? ?? [])
          .map((e) => ActiveTruckSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
