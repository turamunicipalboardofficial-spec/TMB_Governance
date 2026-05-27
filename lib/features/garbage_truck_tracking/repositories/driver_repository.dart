import '../../../core/error/error_handler.dart';
import '../data/driver_data_source.dart';
import '../models/driver_route_model.dart';

class DriverRepository {
  final DriverDataSource _dataSource;

  DriverRepository(this._dataSource);

  Future<DriverLoginResponse> login(String phone, String password) async {
    try {
      final json = await _dataSource.login(phone: phone, password: password);
      return DriverLoginResponse.fromJson(json);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<Map<String, dynamic>> startShift(
    double latitude,
    double longitude,
  ) async {
    try {
      return await _dataSource.startShift(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<Map<String, dynamic>> endShift(
    double latitude,
    double longitude,
  ) async {
    try {
      return await _dataSource.endShift(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
    required double speed,
    required double heading,
    required double altitude,
    required double accuracy,
    required String timestamp,
  }) async {
    try {
      return await _dataSource.updateLocation(
        latitude: latitude,
        longitude: longitude,
        speed: speed,
        heading: heading,
        altitude: altitude,
        accuracy: accuracy,
        timestamp: timestamp,
      );
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<DriverRouteData> getAssignedRoute() async {
    try {
      final json = await _dataSource.getAssignedRoute();
      return DriverRouteData.fromJson(json['data'] ?? {});
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}