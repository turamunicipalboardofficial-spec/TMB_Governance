import '../../../core/error/error_handler.dart';
import '../data/garbage_admin_data_source.dart';
import '../models/garbage_models.dart';

class GarbageAdminRepository {
  final GarbageAdminDataSource _dataSource;

  GarbageAdminRepository(this._dataSource);

  Future<TruckListResult> listTrucks({
    int? wardId,
    String? status,
    String? search,
    int perPage = 15,
    int page = 1,
  }) async {
    try {
      final response = await _dataSource.listTrucks(
        wardId: wardId,
        status: status,
        search: search,
        perPage: perPage,
        page: page,
      );
      return TruckListResult.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<List<DriverProfileModel>> listDrivers() async {
    try {
      final response = await _dataSource.listDrivers();
      final data = response['data'] as List? ?? [];
      return data.map((e) => DriverProfileModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<GarbageTruckModel> addTruck({
    required String truckNumber,
    required String plateNumber,
    required String truckType,
    required num capacityTons,
    required int wardId,
    String status = 'active',
  }) async {
    try {
      final response = await _dataSource.addTruck({
        'truck_number': truckNumber,
        'plate_number': plateNumber,
        'truck_type': truckType,
        'capacity_tons': capacityTons,
        'ward_id': wardId,
        'status': status,
      });
      return GarbageTruckModel.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<GarbageTruckModel> updateTruck({
    required int id,
    String? truckNumber,
    String? plateNumber,
    String? truckType,
    num? capacityTons,
    int? wardId,
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (truckNumber != null) data['truck_number'] = truckNumber;
      if (plateNumber != null) data['plate_number'] = plateNumber;
      if (truckType != null) data['truck_type'] = truckType;
      if (capacityTons != null) data['capacity_tons'] = capacityTons;
      if (wardId != null) data['ward_id'] = wardId;
      if (status != null) data['status'] = status;

      final response = await _dataSource.updateTruck(id, data);
      return GarbageTruckModel.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<AssignDriverResult> assignDriver({
    required int driverUserId,
    required int truckId,
  }) async {
    try {
      final response = await _dataSource.assignDriver(
        driverUserId: driverUserId,
        truckId: truckId,
      );
      return AssignDriverResult.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<ScheduleModel> createSchedule({
    required int wardId,
    required int truckId,
    int? routeId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    String collectionType = 'regular',
  }) async {
    try {
      final response = await _dataSource.createSchedule({
        'ward_id': wardId,
        'truck_id': truckId,
        if (routeId != null) 'route_id': routeId,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'collection_type': collectionType,
      });
      return ScheduleModel.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<FleetDashboardModel> getDashboard() async {
    try {
      final response = await _dataSource.getDashboard();
      return FleetDashboardModel.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
