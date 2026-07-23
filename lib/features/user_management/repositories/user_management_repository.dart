import 'package:tmb_governance/core/error/error_handler.dart';
import 'package:tmb_governance/features/user_management/data/user_management_data_source.dart';
import 'package:tmb_governance/features/user_management/models/create_consumer_request.dart';
import 'package:tmb_governance/features/user_management/models/create_driver_request.dart';
import 'package:tmb_governance/features/user_management/models/create_employee_request.dart';
import 'package:tmb_governance/features/user_management/models/update_user_request.dart';
import 'package:tmb_governance/features/user_management/models/user_model.dart';

class UserManagementRepository {
  final UserManagementDataSource _dataSource;

  UserManagementRepository(this._dataSource);

  Future<UserModel> createDriver(CreateDriverRequest request) async {
    try {
      final data = await _dataSource.createDriver(request);
      // The driver-creation endpoint returns the user flat under `data`
      // (e.g. { data: { id, firstname, ..., driver_profile: {...} } }),
      // not nested under a `user` key.
      final userData = data['data'];
      return UserModel.fromJson(userData as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<UserModel> createEmployee(CreateEmployeeRequest request) async {
    try {
      final data = await _dataSource.createEmployee(request);
      return UserModel.fromJson(data['data']);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<UserModel> createConsumer(CreateConsumerRequest request) async {
    try {
      final data = await _dataSource.createConsumer(request);
      return UserModel.fromJson(data['data']);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<Map<String, dynamic>> listUsers({
    String? role,
    int? wardId,
    String? search,
    int perPage = 15,
    int page = 1,
  }) async {
    try {
      final data = await _dataSource.listUsers(
        role: role,
        wardId: wardId,
        search: search,
        perPage: perPage,
        page: page,
      );
      final innerData = data['data'];
      final users = (innerData['data'] as List)
          .map((e) => UserModel.fromJson(e))
          .toList();
      return {
        'users': users,
        'currentPage': innerData['current_page'] ?? 1,
        'total': innerData['total'] ?? 0,
        'perPage': innerData['per_page'] ?? 15,
      };
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<UserModel> updateUser(int userId, UpdateUserRequest request) async {
    try {
      final data = await _dataSource.updateUser(userId, request);
      return UserModel.fromJson(data['data']);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<UserModel> toggleUserActive(int userId, bool isActive) async {
    try {
      final data = await _dataSource.toggleUserActive(userId, isActive);
      return UserModel.fromJson(data['data']);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// Trucks available in a ward, for the driver-creation truck picker.
  Future<List<TruckOption>> getWardTrucks(int wardId) async {
    try {
      final data = await _dataSource.getWardTrucks(wardId);
      final trucks = (data['data']?['trucks'] as List? ?? [])
          .map((e) => TruckOption.fromJson(e as Map<String, dynamic>))
          .toList();
      return trucks;
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}

class TruckOption {
  final int id;
  final String truckNumber;
  final String? plateNumber;
  final bool isOnRoute;

  TruckOption({
    required this.id,
    required this.truckNumber,
    this.plateNumber,
    this.isOnRoute = false,
  });

  factory TruckOption.fromJson(Map<String, dynamic> json) {
    return TruckOption(
      id: json['id'] ?? 0,
      truckNumber: json['truck_number']?.toString() ?? 'Truck',
      plateNumber: json['plate_number']?.toString(),
      isOnRoute: json['is_on_route'] == true,
    );
  }

  String get displayLabel =>
      plateNumber != null && plateNumber!.isNotEmpty
          ? '$truckNumber ($plateNumber)'
          : truckNumber;
}