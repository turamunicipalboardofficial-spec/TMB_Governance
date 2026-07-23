import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';

class GarbageAdminDataSource {
  /// GET /api/admin/trucks
  Future<dynamic> listTrucks({
    int? wardId,
    String? status,
    String? search,
    int perPage = 15,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'per_page': perPage,
      'page': page,
    };
    if (wardId != null) queryParams['ward_id'] = wardId;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await NetworkService.to.get(
      ApiEndpoints.adminTrucks,
      queryParameters: queryParams,
    );
    return response.data;
  }

  /// GET /api/admin/trucks/drivers
  Future<dynamic> listDrivers() async {
    final response = await NetworkService.to.get(ApiEndpoints.adminListDrivers);
    return response.data;
  }

  /// POST /api/admin/trucks
  Future<dynamic> addTruck(Map<String, dynamic> data) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.adminTrucks,
      data: data,
    );
    return response.data;
  }

  /// PUT /api/admin/trucks/{id}
  Future<dynamic> updateTruck(int id, Map<String, dynamic> data) async {
    final response = await NetworkService.to.put(
      ApiEndpoints.adminUpdateTruck.replaceAll('{id}', id.toString()),
      data: data,
    );
    return response.data;
  }

  /// POST /api/admin/trucks/assign-driver
  Future<dynamic> assignDriver({
    required int driverUserId,
    required int truckId,
  }) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.adminAssignDriver,
      data: {
        'driver_user_id': driverUserId,
        'truck_id': truckId,
      },
    );
    return response.data;
  }

  /// POST /api/admin/trucks/schedule
  Future<dynamic> createSchedule(Map<String, dynamic> data) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.adminCreateSchedule,
      data: data,
    );
    return response.data;
  }

  /// GET /api/admin/trucks/dashboard
  Future<dynamic> getDashboard() async {
    final response = await NetworkService.to.get(ApiEndpoints.adminGarbageDashboard);
    return response.data;
  }
}
