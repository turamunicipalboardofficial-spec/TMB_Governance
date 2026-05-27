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
    final data = await _dataSource.createDriver(request);
    final userData = data['data']['user'];
    return UserModel.fromJson(userData);
  }

  Future<UserModel> createEmployee(CreateEmployeeRequest request) async {
    final data = await _dataSource.createEmployee(request);
    return UserModel.fromJson(data['data']);
  }

  Future<UserModel> createConsumer(CreateConsumerRequest request) async {
    final data = await _dataSource.createConsumer(request);
    return UserModel.fromJson(data['data']);
  }

  Future<Map<String, dynamic>> listUsers({
    String? role,
    int? wardId,
    String? search,
    int perPage = 15,
    int page = 1,
  }) async {
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
  }

  Future<UserModel> updateUser(int userId, UpdateUserRequest request) async {
    final data = await _dataSource.updateUser(userId, request);
    return UserModel.fromJson(data['data']);
  }

  Future<UserModel> toggleUserActive(int userId, bool isActive) async {
    final data = await _dataSource.toggleUserActive(userId, isActive);
    return UserModel.fromJson(data['data']);
  }
}