import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';

class DriverDataSource {
  /// POST /api/driver/login
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.driverLogin,
      data: {'phone': phone, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/driver/shift/start
  Future<Map<String, dynamic>> startShift({
    required double latitude,
    required double longitude,
  }) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.driverStartShift,
      data: {'latitude': latitude, 'longitude': longitude},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/driver/shift/end
  Future<Map<String, dynamic>> endShift({
    required double latitude,
    required double longitude,
  }) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.driverEndShift,
      data: {'latitude': latitude, 'longitude': longitude},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/driver/location/update
  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
    required double speed,
    required double heading,
    required double altitude,
    required double accuracy,
    required String timestamp,
  }) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.driverUpdateLocation,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'speed': speed,
        'heading': heading,
        'altitude': altitude,
        'accuracy': accuracy,
        'timestamp': timestamp,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/driver/route
  Future<Map<String, dynamic>> getAssignedRoute() async {
    final response = await NetworkService.to.get(
      ApiEndpoints.driverAssignedRoute,
    );
    return response.data as Map<String, dynamic>;
  }
}